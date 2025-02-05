#!/bin/bash
#
# Copyright 2021-2023 Software Radio Systems Limited
#
# By using this file, you agree to the terms and conditions set
# forth in the LICENSE file which can be found at the top level of
# the distribution.
#

# This Bash script monitors the phc2sys logfile and checks if
# the rms value is below a specified threshold (upper_limit). It also checks if
# the timestamp in the phc2sys logfile increases. It writes a health check
# file (/tmp/healthcheck) in case the application is running correct. It has a timeout
# of 10 seconds of not receiving a valid NMEA messages. If the timeout is reached,
# the health check file is removed and the applications terminates.

phc2sys_output_file=$1
upper_limit=120   # max rms
lower_limit=-120  # min rms
timeout=10        # timeout in seconds
last_timestamp=0
counter=0

while true; do
    last_line=$(tail -n 1 "$phc2sys_output_file")

    if [[ -z $last_line ]]; then
        echo "Warning: No new data found in $phc2sys_output_file. Check if the system is working properly."
        ((counter++))
    elif [[ $last_line == *"CLOCK_REALTIME phc"* ]]; then
        timestamp=$(echo "$last_line" | awk -F'[][]' '{print $2}' | sed 's/://' | cut -d'.' -f1)
        last_value=$(echo "$last_line" | awk '/CLOCK_REALTIME phc offset/ {print $5}')

        # Validate the timestamp and last_value
        if [[ -n $timestamp && $timestamp =~ ^[0-9]+$ ]] && [[ -n $last_value && $last_value =~ ^-?[0-9]+$ ]]; then
            if [ "$last_value" -lt "$upper_limit" ] && [ "$last_value" -gt "$lower_limit" ] && [ "$timestamp" -gt "$last_timestamp" ]; then
                touch /tmp/phc2sys-healthy
                last_timestamp=$timestamp
                counter=0
            else
                echo "Warning: Invalid timestamp or offset value detected in log entry."
                echo "Warning: Last line: $last_line"
                ((counter++))
            fi
        else
            echo "Warning: Invalid timestamp or offset value detected in log entry."
            echo "Warning: Last line: $last_line"
            ((counter++))
        fi
    else
        echo "Warning: No valid entry found in the phc2sys log."
        ((counter++))
    fi

    if [ "$counter" -gt "$timeout" ]; then
        echo "Timeout reached: No valid data received for $timeout seconds. Marking system as unhealthy."
        rm -f /tmp/phc2sys-healthy
    fi
    sleep 1
done
