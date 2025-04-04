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
if [ -n "${NTP_SERVER}" ]; then
  ntpdate ${NTP_SERVER}
  phc_ctl ${INTERFACE} set
fi
phc2sys -s ${INTERFACE} -w -m -f /etc/config/linuxptp.cfg  &
phc2sys_pid=$!
cat "/proc/${phc2sys_pid}/fd/1" > /tmp/phc2sys.stdout &
liveness-phc2sys.sh /tmp/phc2sys.stdout
