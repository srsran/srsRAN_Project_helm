#!/bin/bash
ptp4l -2 -i enp4s0f1 -f /etc/config/linuxptp.cfg -m > /tmp/ptp4l.log 2>&1 & \
phc2sys -s enp4s0f1 -w -m -R 8 -f /etc/config/linuxptp.cfg > /tmp/phc2sys.log 2>&1