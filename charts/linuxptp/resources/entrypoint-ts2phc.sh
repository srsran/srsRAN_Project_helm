#!/bin/bash
#
# Copyright 2021-2025 Software Radio Systems Limited
#
# By using this file, you agree to the terms and conditions set
# forth in the LICENSE file which can be found at the top level of
# the distribution.
#

INTERFACE=$1
ts2phc -c ${INTERFACE} -s nmea -m -f /etc/config/ts2phc.cfg  &
ts2phc_pid=$!
cat "/proc/${ts2phc_pid}/fd/1" > /tmp/ts2phc.stdout &
liveness-ts2phc.sh /tmp/ts2phc.stdout
