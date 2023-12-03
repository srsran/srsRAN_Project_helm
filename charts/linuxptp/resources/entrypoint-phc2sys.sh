#!/bin/bash
INTERFACE=$1
phc2sys -s ${INTERFACE} -w -m -R 8 -f /etc/config/linuxptp.cfg  &
phc2sys_pid=$!
cat "/proc/${phc2sys_pid}/fd/1" > /tmp/phc2sys.stdout &
liveness-phc2sys.sh /tmp/phc2sys.stdout
