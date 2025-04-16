#!/bin/bash
#
# Copyright 2021-2025 Software Radio Systems Limited
#
# By using this file, you agree to the terms and conditions set
# forth in the LICENSE file which can be found at the top level of
# the distribution.
#

INTERFACE=$1

# Function to clean up on SIGTERM
cleanup() {
  echo "Received SIGTERM, stopping ts2phc..."
  if [ -n "$ts2phc_pid" ] && kill -0 "$ts2phc_pid" 2>/dev/null; then
    kill -TERM "$ts2phc_pid"
    kill -TERM "$liveness_pid"
    wait "$ts2phc_pid"
    wait "$liveness_pid"
  fi
  exit 0
}

trap cleanup SIGTERM SIGINT

ts2phc -c "${INTERFACE}" -s nmea -m -f /etc/config/ts2phc.cfg &
ts2phc_pid=$!

cat "/proc/${ts2phc_pid}/fd/1" > /tmp/ts2phc.stdout &

liveness-ts2phc.sh /tmp/ts2phc.stdout &
liveness_pid=$!
wait "$liveness_pid"
