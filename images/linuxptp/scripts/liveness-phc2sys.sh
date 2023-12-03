#!/bin/bash

# This Bash script monitors the ptp4l logfile and checks if
# the rms value is below a specified threshold (upper_limit). It also checks if
# the timestamp in the ptp4l logfile increases. It writes a health check
# file (/tmp/healthcheck) in case the application is running correct. It has a timeout
# of 10 seconds of not receiving a valid ptp4l messages. If the timeout is reached,
# the health check file is removed and the applications terminates.

phc2sys_output_file=$1
upper_limit=120   # max rms
lower_limit=-120  # max rms
timeout=10        # timeout in seconds
last_timestamp=0
counter=0

while true; do
    last_line=$(tail -n 1 "$phc2sys_output_file")
    if [[ $last_line == *"CLOCK_REALTIME phc"* ]]; then
        timestamp=$(echo "$last_line" | awk -F'[][]' '{print $2}' | sed 's/://' | cut -d'.' -f1)
        last_value=$(echo "$last_line" | awk '/CLOCK_REALTIME phc offset/ {print $5}')
        if [ "$last_value" -lt "$upper_limit" ] && [ "$last_value" -gt "$lower_limit" ] && [ "$timestamp" -gt "$last_timestamp" ]; then
            touch /tmp/phc2sys-healthy
            last_timestamp=$timestamp
            counter=0
        else
            ((counter++))
        fi
    else
        ((counter++))
    fi

    if [ "$counter" -gt "$timeout" ]; then
        rm -f /tmp/phc2sys-healthy
    fi
    sleep 1
done
