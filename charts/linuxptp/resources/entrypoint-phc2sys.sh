#!/bin/bash
#
# Copyright 2021-2025 Software Radio Systems Limited
#
# By using this file, you agree to the terms and conditions set
# forth in the LICENSE file which can be found at the top level of
# the distribution.
#

set -e

INTERFACE=$1
NTP_SERVER=${2}

# Function to clean up on SIGTERM
cleanup() {
  echo "Received SIGTERM, stopping phc2sys..."
  if [ -n "$phc2sys_pid" ] && kill -0 "$phc2sys_pid" 2>/dev/null; then
    kill -TERM "$phc2sys_pid"
    kill -TERM "$liveness_pid"
    wait "$phc2sys_pid"
    wait "$liveness_pid"
  fi
  exit 0
}

trap cleanup SIGTERM SIGINT

if [ -n "${NTP_SERVER}" ]; then
  ntpdate ${NTP_SERVER}
  phc_ctl ${INTERFACE} set
fi

phc2sys -s "${INTERFACE}" -w -m -f /etc/config/linuxptp.cfg &
phc2sys_pid=$!

cat "/proc/${phc2sys_pid}/fd/1" > /tmp/phc2sys.stdout &

liveness-phc2sys.sh /tmp/phc2sys.stdout &
liveness_pid=$!
wait "$liveness_pid"
