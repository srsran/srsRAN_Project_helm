#!/bin/bash
#
# Copyright 2021-2023 Software Radio Systems Limited
#
# By using this file, you agree to the terms and conditions set
# forth in the LICENSE file which can be found at the top level of
# the distribution.
#

# This Bash script monitors the ts2phc logfile and checks if
# the rms value is below a specified threshold (upper_limit). It also checks if
# the timestamp in the ts2phc logfile increases. It writes a health check
# file (/tmp/healthcheck) in case the application is running correct. It has a timeout
# of 10 seconds of not receiving a valid NMEA messages. If the timeout is reached,
# the health check file is removed and the applications terminates.

ts2phc_output_file=$1
upper_rms_limit="${2:-25}"           # max rms threshold, default 25ns
lower_rms_limit=-$upper_rms_limit    # min rms threshold
timeout=10                           # timeout in seconds
last_timestamp=0
counter=0

while true; do
    last_line=$(grep 'offset' "$ts2phc_output_file" | tail -n 1)

    if [[ -z $last_line ]]; then
        echo "Warning: No valid offset data found. Check if the GPS antenna is connected properly."
        ((counter++))
    elif [[ $last_line == *"s2"* ]]; then
        timestamp=$(echo "$last_line" | awk -F'[][]' '{print $2}')
        last_rms_value=$(echo "$last_line" | sed -n 's/.*offset\s*\([-0-9]*\)\s*s2.*/\1/p' | awk '{print int($1)}')

        # Check if both timestamp and last_rms_value are valid integers
        if [[ -n $timestamp && $timestamp =~ ^[0-9]+$ ]] && [[ -n $last_rms_value && $last_rms_value =~ ^-?[0-9]+$ ]]; then
            if [ "$last_rms_value" -lt "$upper_rms_limit" ] && [ "$last_rms_value" -gt "$lower_rms_limit" ] && (( $(echo "$timestamp > $last_timestamp" | bc -l) )); then
                touch /tmp/ts2phc-healthy
                last_timestamp=$timestamp
                counter=0
            else
                echo "Warning: Invalid timestamp or offset value detected."
                echo "Warning: Last line: $last_line"
                ((counter++))
            fi
        else
            echo "Warning: Invalid timestamp or offset value detected."
            echo "Warning: Last line: $last_line"
            ((counter++))
        fi
    else
        echo "Warning: Last entry found in ts2phc output is invalid."
        echo "Warning: Last line: $last_line"
        ((counter++))
    fi

    if [ "$counter" -gt "$timeout" ]; then
        rm -f /tmp/ts2phc-healthy
    fi
    sleep 2
done
