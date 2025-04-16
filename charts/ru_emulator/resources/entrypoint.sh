#!/bin/bash
#
# Copyright 2021-2025 Software Radio Systems Limited
#
# By using this file, you agree to the terms and conditions set
# forth in the LICENSE file which can be found at the top level of
# the distribution.
#

# Function to convert full extended resource name to environment variable name.
# Example: "intel.com/intel_sriov_netdevice" -> "PCIDEVICE_INTEL_COM_INTEL_SRIOV_NETDEVICE"
convert_resource_name() {
  local resource_full="$1"
  # Uppercase the string and replace dots and slashes with underscores.
  local varname
  varname=$(echo "$resource_full" | tr '[:lower:]' '[:upper:]' | sed -E 's/[./]/_/g')
  echo "PCIDEVICE_${varname}"
}

# Trap and forward SIGTERM to ru_emulator
ru_pid=""

cleanup() {
  echo "Received SIGTERM, stopping ru_emulator..."
  if [ -n "$ru_pid" ] && kill -0 "$ru_pid" 2>/dev/null; then
    kill -TERM "$ru_pid"
    wait "$ru_pid"
  fi
  exit 0
}

trap cleanup SIGTERM SIGINT

CONFIG_FILE="$1"
if [ -z "$CONFIG_FILE" ]; then
    echo "Usage: $0 <config_file>"
    exit 1
fi

UPDATED_CONFIG="/tmp/gnb-config.yml"
cp "$CONFIG_FILE" "$UPDATED_CONFIG"

if [ -n "$RESOURCE_EXTENDED" ]; then
    RESOURCE_VAR=$(convert_resource_name "$RESOURCE_EXTENDED")
    echo "Using resource environment variable: $RESOURCE_VAR"
    DEVICE_LIST="${!RESOURCE_VAR}"

    # Get only first device from the list
    VF_PCI_ID="${DEVICE_LIST%%,*}"
    DU_MAC=$(dmesg | grep "${VF_PCI_ID}" | grep "MAC address:" | tail -n 1 | sed -n 's/.*MAC address: \([0-9a-fA-F:]\+\).*/\1/p')

    sed -i -e "s/^\(\s*du_mac_addr:\s*\).*$/\1$DU_MAC/" "$UPDATED_CONFIG" > /dev/null
    sed -i -e "s/^\(\s*network_interface:\s*\).*$/\1$VF_PCI_ID/" "$UPDATED_CONFIG" > /dev/null
fi

/usr/local/bin/ru_emulator -c "$UPDATED_CONFIG" &
ru_pid=$!
wait "$ru_pid"
