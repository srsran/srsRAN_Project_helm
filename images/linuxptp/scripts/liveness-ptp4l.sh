#!/bin/bash
#
# Copyright 2021-2023 Software Radio Systems Limited
#
# By using this file, you agree to the terms and conditions set
# forth in the LICENSE file which can be found at the top level of
# the distribution.
#

upper_limit=$1
lower_limit=-$upper_limit

# check port state
state=$(pmc -u -b 0 'GET PORT_DATA_SET' -f /etc/config/linuxptp.cfg | grep -oP 'portState\s+\K\w+' | awk '{print $1}')
if [ "$state" != "SLAVE" ]; then
    echo "ptp not established"
    exit 1
fi

# check offset
offset=$(pmc -u -b 0 'GET CURRENT_DATA_SET' -f /etc/config/linuxptp.cfg | grep -oP 'offsetFromMaster\s+\K[-0-9.]+' | awk '{print $1}')
if (( $(echo "$offset > $upper_limit" |bc -l) )) || (( $(echo "$offset < $lower_limit" |bc -l) )); then
    echo "offsetFromMaster (${offset}) is not in accepted range"
    exit 1
fi
exit 0
