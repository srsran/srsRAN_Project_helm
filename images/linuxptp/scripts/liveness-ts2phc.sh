#!/bin/bash
#
# Copyright 2021-2023 Software Radio Systems Limited
#
# By using this file, you agree to the terms and conditions set
# forth in the LICENSE file which can be found at the top level of
# the distribution.
#

# This Bash script monitors the ptp4l logfile and checks if
# the rms value is below a specified threshold (upper_limit). It also checks if
# the timestamp in the ptp4l logfile increases. It writes a health check
# file (/tmp/healthcheck) in case the application is running correct. It has a timeout
# of 10 seconds of not receiving a valid ptp4l messages. If the timeout is reached,
# the health check file is removed and the applications terminates.

ts2phc_output_file=$1
upper_rms_limit="${2:-25}"           # max rms threshold, default 25ns
lower_rms_limit=-$upper_rms_limit    # min rms threshold
timeout=10                           # timeout in seconds
last_timestamp=0
counter=0

while true; do
    last_line=$(grep 'offset' "$ts2phc_output_file" | tail -n 1)
    if [[ $last_line == *"s2"* ]]; then
        timestamp=$(echo "$last_line" | awk -F'[][]' '{print $2}')
        last_rms_value=$(echo "$last_line" | sed -n 's/.*offset\s*\([-0-9]*\)\s*s2.*/\1/p' | awk '{print int($1)}')
        if [ "$last_rms_value" -lt "$upper_rms_limit" ] && [ "$last_rms_value" -gt "$lower_rms_limit" ] && (( $(echo "$timestamp > $last_timestamp" | bc -l) )); then
            touch /tmp/ts2phc-healthy
            last_timestamp=$timestamp
            counter=0
        else
            ((counter++))
        fi
    else
        ((counter++))
    fi

    if [ "$counter" -gt "$timeout" ]; then
        rm -f /tmp/ts2phc-healthy
    fi
    sleep 1
done
