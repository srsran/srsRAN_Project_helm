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
  [[ -n "${tee_pid:-}" ]] && kill -TERM "$tee_pid" 2>/dev/null || true
  [[ -n "${phc2sys_pid:-}" ]] && kill -TERM "$phc2sys_pid" 2>/dev/null || true
  wait "${tee_pid:-}"  2>/dev/null || true
  wait "${phc2sys_pid:-}" 2>/dev/null || true
  rm -f /tmp/phc2sys.pipe
  exit 0
}

trap cleanup SIGTERM SIGINT

if [ -n "${NTP_SERVER}" ]; then
  ntpdate ${NTP_SERVER}
  phc_ctl ${INTERFACE} set
fi

# make sure we always get lines promptly
LOGFILE=/tmp/phc2sys.stdout
PIPE=/tmp/phc2sys.pipe
rm -f "$PIPE" && mkfifo "$PIPE"

# start phc2sys, write to the fifo (add -u 1 for periodic lines)
stdbuf -oL -eL phc2sys -s "${INTERFACE}" -c CLOCK_REALTIME -w -m -u 1 -f /etc/config/linuxptp.cfg \
  >"$PIPE" 2>&1 &
phc2sys_pid=$!

# tee from the fifo to a file (and to container stdout)
tee -a "$LOGFILE" <"$PIPE" &
tee_pid=$!

liveness-phc2sys.sh /tmp/phc2sys.stdout &
liveness_pid=$!
wait "$liveness_pid"
