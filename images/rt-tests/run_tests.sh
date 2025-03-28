#!/bin/bash

#
# Copyright 2021-2025 Software Radio Systems Limited
#
# By using this file, you agree to the terms and conditions set
# forth in the LICENSE file which can be found at the top level of
# the distribution.
#

main() {

    if (($# != 2)); then
        echo >&2 "Illegal number of parameters"
        echo >&2 "Run like this: \"./run_tests.sh <input_file> <output_folder>\""
        exit 1
    fi

    local input_file=$1
    local output_folder=$2

    # Check if the input file exists
    if [ ! -f "$input_file" ]; then
        echo >&2 "Input file does not exist"
        exit 1
    fi

    # Create the output folder if it does not exist
    mkdir -p "$output_folder"

    # Read input file
    pids=()
    while IFS=":" read -r binary args; do
        binary=$(echo "$binary" | xargs)
        args=$(echo "$args" | xargs)
        args="${args#\"}"
        args="${args%\"}"
        # Skip empty binary lines
        if [ -z "$binary" ]; then
            continue
        fi
        "$binary" $args > "$output_folder/$binary" 2>&1 &
        pid=$!
        echo "> Running: $binary $args [PID $pid]"
        pids+=("$pid")
    done < "$input_file"

    # Wait for all processes to end
    error=0
    for pid in "${pids[@]}"; do
        if ! wait "$pid"; then
            echo "!! Process with PID $pid FAILED"
            error=1
        fi
    done

    # Create latency plot for each cyclictest output file
    if [ -f "$output_folder/cyclictest" ]; then
        create_cyclictest_plot "$output_folder/cyclictest"
    fi

    # Exit 1 if any process failed
    if [ $error -ne 0 ]; then
        exit 1
    fi

}

create_cyclictest_plot() {

    local histogram_file=$1

    # Get maximum latency
    max=$(grep "Max Latencies" "$histogram_file" | tr " " "\n" | sort -n | tail -1 | sed s/^0*//)

    # Grep data lines, remove empty lines and create a common field separator
    grep -v -e "^#" -e "^$" "$histogram_file" | tr " " "\t" >histogram 

    # Create two-column data sets with latency classes and frequency values for each core, for example
    for i in $(seq 1 $(nproc --all));
    do
        column=$(expr $i + 1)
        cut -f1,"$column" histogram >histogram$i
    done

    # Create plot command header
    echo -n -e "set title \"Latency plot\"\n\
    set terminal png\n\
    set xlabel \"Latency (us), max $max us\"\n\
    set ylabel \"Number of latency samples\"\n\
    set output \"${histogram_file}_plot.png\"\n\
    plot " >plotcmd

    # Append plot command data references
    for i in $(seq 1 $(nproc --all))
    do
    if test $i != 1
    then
        echo -n ", " >>plotcmd
    fi
    cpuno=$(expr $i - 1)
    if test $cpuno -lt 10
    then
        title=" CPU$cpuno"
    else
        title="CPU$cpuno"
    fi
    echo -n "\"histogram$i\" using 1:2 title \"$title\" with histeps" >>plotcmd
    done

    # Execute plot command
    gnuplot -persist <plotcmd

    echo ">> cyclictest histogram created in ${histogram_file}_plot.png"

}

main "$@"
