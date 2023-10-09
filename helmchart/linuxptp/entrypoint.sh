#!/bin/bash
INTERFACE=enp1s0f0
ptp4l -2 -i ${INTERFACE} -f /etc/config/linuxptp.cfg -m > /tmp/ptp4l.log 2>&1 & \
phc2sys -s ${INTERFACE} -w -m -R 8 -f /etc/config/linuxptp.cfg > /tmp/phc2sys.log 2>&1