#!/bin/bash
#
# Copyright 2021-2025 Software Radio Systems Limited
#
# By using this file, you agree to the terms and conditions set
# forth in the LICENSE file which can be found at the top level of
# the distribution.
#

# This script updates the gNB configuration file dynamically.
# - Injects cu_up/cu_cp IP overrides when HOSTNETWORK=false or USE_EXT_CORE=true,
#   using POD_IP for bind_addr and LB_IP for ext_addr (if external core is used).
# - If a hal section exists with eal_args, replaces the CPU core list inside @(...)
#   with the CPUs available to the container as read from cgroups (v1/v2),
#   working for both privileged and non-privileged containers.
# - Processes each cell in the ru_ofh section in case the SR-IOV proivder is used: 
#   replaces the network_interface field with the corresponding BDF from 
#   PCIDEVICE_<RESOURCE> and updates du_mac_addr using the MAC obtained from dmesg
#   for that BDF.
#
# You can pass the full extended resource name (e.g., "intel.com/intel_sriov_netdevice")
# as an environment variable RESOURCE_EXTENDED. The script converts it to the environment
# variable name (e.g., PCIDEVICE_INTEL_COM_INTEL_SRIOV_NETDEVICE) and uses its value for
# processing.
#
# Usage: ./entrypoint.sh /etc/config/gnb-config.yml
# This script has only been tested in containers with Ubuntu 22.04 or higher!

# Function to convert full extended resource name to environment variable name.
# Example: "intel.com/intel_sriov_netdevice" -> "PCIDEVICE_INTEL_COM_INTEL_SRIOV_NETDEVICE"
convert_resource_name() {
  local resource_full="$1"
  # Uppercase the string and replace dots and slashes with underscores.
  local varname
  varname=$(echo "$resource_full" | tr '[:lower:]' '[:upper:]' | sed -E 's/[./]/_/g')
  echo "PCIDEVICE_${varname}"
}

update_config_paths() {
    if [ -z "$1" ]; then
        echo "Error: Config file not provided."
        return 1
    fi

    local config_file="$1"
    local timestamp=$(date +'%Y%m%d-%H%M%S')

    local first_line
    first_line=$(grep -E '^[[:space:]]*[A-Za-z0-9_]*filename:' "$config_file" | head -1)
    if [ -z "$first_line" ]; then
        echo "Warning: No logfile or pcap filenames entries found in config file."
        return 0
    fi

    local original_path
    original_path=$(echo "$first_line" | sed -E 's/^[[:space:]]*[A-Za-z0-9_]*filename:[[:space:]]*(.*)$/\1/')
    
    local current_dir
    current_dir=$(dirname "$original_path")
    
    local ts_candidate base_dir
    ts_candidate=$(basename "$current_dir")
    if [[ "$ts_candidate" =~ ^[0-9]{8}-[0-9]{6}$ ]]; then
        # If a timestamp is present, remove it to get the true base directory.
        base_dir=$(dirname "$current_dir")
    else
        base_dir="$current_dir"
    fi

    local new_folder="${base_dir}/${timestamp}"
    mkdir -p "$new_folder"
  
    sed -i -E "s#([[:space:]]*(filename|[A-Za-z0-9_]+_filename):[[:space:]])${base_dir}(/[0-9]{8}-[0-9]{6})?/#\1${base_dir}/${timestamp}/#g" "$config_file"

    # create current symlink
    local symlink_path="${base_dir}/current"
    if [ -L "$symlink_path" ]; then
        rm -f "$symlink_path"
    fi
    ln -sf "./${timestamp}" "${symlink_path}"
    echo "$new_folder"
    return 0
}

# Detect container-available CPUs from cgroups (v1/v2, privileged/non-privileged)
get_container_cpus() {
  local cpuset=""
  local cgroup_path=""

  if [ -f /proc/self/cgroup ]; then
    cgroup_path=$(grep -E "cpuset|0::" /proc/self/cgroup | head -1 | cut -d: -f3)
  fi

  if [ -n "$cgroup_path" ] && [ "$cgroup_path" != "/" ]; then
    if [ -f "/sys/fs/cgroup/cpuset${cgroup_path}/cpuset.cpus" ]; then
      cpuset=$(cat "/sys/fs/cgroup/cpuset${cgroup_path}/cpuset.cpus")
    elif [ -f "/sys/fs/cgroup${cgroup_path}/cpuset.cpus" ]; then
      cpuset=$(cat "/sys/fs/cgroup${cgroup_path}/cpuset.cpus")
    fi
  fi

  if [ -z "$cpuset" ]; then
    if [ -f /sys/fs/cgroup/cpuset/cpuset.cpus ]; then
      cpuset=$(cat /sys/fs/cgroup/cpuset/cpuset.cpus)
    elif [ -f /sys/fs/cgroup/cpuset.cpus ]; then
      cpuset=$(cat /sys/fs/cgroup/cpuset.cpus)
    fi
  fi

  if [ -z "$cpuset" ]; then
    if command -v nproc >/dev/null 2>&1; then
      local n
      n=$(nproc)
      if [ "$n" -gt 0 ]; then
        cpuset="0-$((n-1))"
      else
        cpuset="0-1"
      fi
    else
      cpuset="0-1"
    fi
    echo "Warning: Could not determine CPU set from cgroup, using fallback: $cpuset" >&2
  fi

  echo "$cpuset" | xargs
}

# Update hal.eal_args cores (inside @(...)) only if hal section exists
update_hal_eal_args() {
  local config_file="$1"

  if ! grep -q "^[[:space:]]*hal:" "$config_file"; then
    return 0
  fi

  if ! grep -q "^[[:space:]]*eal_args:" "$config_file"; then
    return 0
  fi

  local cpus
  cpus=$(get_container_cpus)
  if [ -z "$cpus" ]; then
    echo "Warning: No CPUs detected; skipping hal.eal_args update" >&2
    return 0
  fi

  sed -i -E "s/(@\()[^)]*(\))/\\1${cpus}\\2/" "$config_file"
  echo "Updated hal.eal_args CPU list to: ${cpus}"
}

# Update each cell's network_interface and du_mac_addr using provided BDFs
update_network_interfaces_and_macs() {
  local config_file="$1"
  local device_list="$2"

  if [ -z "$device_list" ]; then
    return 0
  fi

  IFS=',' read -r -a bdf_array <<< "$device_list"
  local tmpfile
  tmpfile=$(mktemp)
  local counter=0
  local current_bdf=""

  while IFS= read -r line || [ -n "$line" ]; do
    if echo "$line" | grep -qE "^[[:space:]]*-[[:space:]]*network_interface:" && [ $counter -lt ${#bdf_array[@]} ]; then
      current_bdf=$(echo "${bdf_array[$counter]}" | xargs)
      indent=$(echo "$line" | sed -n 's/^\([[:space:]]*\).*/\1/p')
      echo "${indent}- network_interface: $current_bdf" >> "$tmpfile"
    elif echo "$line" | grep -q "^[[:space:]]*du_mac_addr:" && [ -n "$current_bdf" ]; then
      mac=$(dmesg | grep "$current_bdf" | grep "MAC address:" | tail -n 1 | sed -n 's/.*MAC address: \([0-9a-fA-F:]\+\).*/\1/p')
      indent=$(echo "$line" | sed -n 's/^\([[:space:]]*\).*/\1/p')
      if [ -n "$mac" ]; then
        echo "${indent}du_mac_addr: $mac" >> "$tmpfile"
        echo "For BDF $current_bdf, MAC: $mac"
      else
        echo "Warning: Could not determine MAC for BDF $current_bdf" >&2
        echo "$line" >> "$tmpfile"
      fi
      counter=$((counter + 1))
      current_bdf=""
    else
      echo "$line" >> "$tmpfile"
    fi
  done < "$config_file"

  mv "$tmpfile" "$config_file"
}

inject_ip_overrides() {
  local config_file="$1"

  # In case HOSTNETWORK is set to true, we need to use the Pods IP as bind_addr. In case of
  # external core, we need to use the LoadBalancer IP as ext_addr.
  if [ "${HOSTNETWORK}" = "false" ] || [ "${USE_EXT_CORE}" = "true" ]; then
    local tmpfile
    tmpfile=$(mktemp)
    {
      echo "cu_up:"
      echo "  ngu:"
      echo "    socket:"
      echo "      - bind_addr: ${POD_IP}"
      if [ "${USE_EXT_CORE}" = "true" ]; then
        echo "        ext_addr: ${LB_IP}"
      fi
      echo "cu_cp:"
      echo "  amf:"
      echo "    bind_addr: ${POD_IP}"
    } > "$tmpfile"
    cat "$config_file" >> "$tmpfile"
    mv "$tmpfile" "$config_file"
  fi
}

terminate() {
  echo "Received SIGTERM, forwarding to gnb process..."
  gnb_pid=$(pgrep gnb)
  if [ -n "$gnb_pid" ] && kill -0 "$gnb_pid" 2>/dev/null; then
    kill -TERM "$gnb_pid" # send SIGTERM to gNB process
    wait "$pipe_pid" # wait for entire pipe to finish
    exit_code=$?
    echo "gNB terminated with exit code $exit_code"
    exit "$exit_code"
  fi
  exit 0
}

trap terminate SIGTERM SIGINT

PRESERVE_OLD_LOGS="${PRESERVE_OLD_LOGS:-false}"

# Use RESOURCE_EXTENDED if provided; otherwise, default to intel.com/intel_sriov_netdevice.
RESOURCE_EXTENDED="${RESOURCE_EXTENDED:-intel.com/intel_sriov_netdevice}"
RESOURCE_VAR=$(convert_resource_name "$RESOURCE_EXTENDED")
echo "Using resource environment variable: $RESOURCE_VAR"

# The value from the environment variable is accessed indirectly.
DEVICE_LIST="${!RESOURCE_VAR}"

# Check if config file is provided as an argument.
CONFIG_FILE="$1"
if [ -z "$CONFIG_FILE" ]; then
  echo "Usage: $0 <config_file>"
  exit 1
fi

# Move config file to a temporary location.
UPDATED_CONFIG="/tmp/gnb-config.yml"
cp "$CONFIG_FILE" "$UPDATED_CONFIG"

inject_ip_overrides "$UPDATED_CONFIG"

# Update hal eal_args if present
update_hal_eal_args "$UPDATED_CONFIG"

# If the device list is set, update each cell's network_interface and du_mac_addr using function
if [ -n "${DEVICE_LIST}" ]; then
  update_network_interfaces_and_macs "$UPDATED_CONFIG" "${DEVICE_LIST}"
fi

echo "Configuration file updated and placed in $UPDATED_CONFIG"

while true; do
  if [ "$PRESERVE_OLD_LOGS" = "true" ]; then
    CURR_LOG_PATH=$(update_config_paths "$UPDATED_CONFIG")
    {
      gnb -c "$UPDATED_CONFIG" 2>&1 | tee -a "${CURR_LOG_PATH}/gnb.stdout"
      exit ${PIPESTATUS[0]}
    } &
  else
    gnb -c "$UPDATED_CONFIG" &
  fi
  pipe_pid=$!
  wait "$pipe_pid"
  exit_code=$?
  echo "gNB exited with code $exit_code"
  if [ $exit_code -ne 0 ]; then
    exit $exit_code
  fi
done
