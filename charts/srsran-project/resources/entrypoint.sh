#!/bin/bash
#
# Copyright 2021-2025 Software Radio Systems Limited
#
# By using this file, you agree to the terms and conditions set
# forth in the LICENSE file which can be found at the top level of
# the distribution.
#

# This script updates the gNB configuration file dynamically.
# It replaces the cu_cp/amf section's IP fields (bind_addr and addr) with values from the POD_IP and LB_IP environment variables.
# It then processes each cell in the ru_ofh section: for each cell, it replaces the network_interface field with the corresponding
# BDF from the comma-separated PCIDEVICE_<RESOURCE> environment variable and updates the du_mac_addr field with the MAC
# address obtained from dmesg for that BDF.
#
# You can pass the full extended resource name (e.g., "intel.com/intel_sriov_netdevice") as an environment variable
# RESOURCE_EXTENDED. The script converts it to the environment variable name (e.g., PCIDEVICE_INTEL_COM_INTEL_SRIOV_NETDEVICE)
# and uses its value for processing.
#
# Usage: ./entrypoint.sh /etc/config/gnb-config.yml
# Only tested in Ubuntu 22.04 container

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
        echo "Error: No filename entry found in config file."
        return 1
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
        rm -rf "$symlink_path"
    fi
    ln -s "$new_folder" "$symlink_path"
    echo "$new_folder"
    return 0
}

terminate() {
  echo "Received SIGTERM, forwarding to gnb process..."
  if [ -n "$gnb_pid" ] && kill -0 "$gnb_pid" 2>/dev/null; then
    kill -TERM "$gnb_pid"
    wait "$gnb_pid"
  fi
  exit 0
}

trap terminate SIGTERM SIGINT

PRESERVE_OLD_LOGS="${PRESERVE_OLD_LOGS:false}"

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

# In case HOSTNETWORK is set to true, we need to use the Pods IP as bind_addr. In case of
# external core, we need to use the LoadBalancer IP as ext_addr.
if [ "${HOSTNETWORK}" = "false" ] || [ "${USE_EXT_CORE}" = "true" ]; then
  block="cu_up:\\
  ngu:\\
    socket:\\
      - bind_addr: ${POD_IP}\\"

  if [ "${USE_EXT_CORE}" = "true" ]; then
    block="${block}
        ext_addr: ${LB_IP}\\"
  fi

  block="${block}
cu_cp:\\
  amf:\\
    bind_addr: ${POD_IP}"

  sed -i "1i\\
${block}" "${UPDATED_CONFIG}"
fi

# If the device list is set, update each cell's network_interface and du_mac_addr.
if [ -n "${DEVICE_LIST}" ]; then
  IFS=',' read -r -a bdf_array <<< "$DEVICE_LIST"
  tmpfile=$(mktemp)
  counter=0
  current_bdf=""

  while IFS= read -r line || [ -n "$line" ]; do
    # When a cell block contains a network_interface field, update it with the current BDF.
    if echo "$line" | grep -qE "^[[:space:]]*-[[:space:]]*network_interface:" && [ $counter -lt ${#bdf_array[@]} ]; then
      current_bdf=$(echo "${bdf_array[$counter]}" | xargs)
      indent=$(echo "$line" | sed -n 's/^\([[:space:]]*\).*/\1/p')
      echo "${indent}- network_interface: $current_bdf" >> "$tmpfile"
    # When a du_mac_addr field is encountered in the same cell block, update it using the MAC for current_bdf.
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
  done < "$UPDATED_CONFIG"
  
  mv "$tmpfile" "$UPDATED_CONFIG"
fi

echo "Configuration file updated and placed in $UPDATED_CONFIG"

while true; do
  if [ "$PRESERVE_OLD_LOGS" = "true" ]; then
    CURR_LOG_PATH=$(update_config_paths "$UPDATED_CONFIG")
    gnb -c "$UPDATED_CONFIG" | tee -a "${CURR_LOG_PATH}/gnb.stdout" &
  else
    gnb -c "$UPDATED_CONFIG" &
  fi
  gnb_pid=$!
  wait "$gnb_pid"
  exit_code=$?

  if [ $exit_code -ne 0 ]; then
    exit $exit_code
  fi
done
