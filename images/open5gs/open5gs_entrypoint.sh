#! /bin/bash

# Create dummy interfaces on localhost ip range for open5gs entities to bind to
###############################################################################
for IP in {2..20}; do
    ip link add name lo$IP type dummy
    ip ad ad 127.0.0.$IP/24 dev lo$IP
    ip link set lo$IP up >/dev/null 2>&1
done

# Setup TUN interface
#####################
mkdir -p /dev/net && mknod /dev/net/tun c 10 200

# Create the ogstun iface and assign an IP to it
ip tuntap add name ogstun mode tun 2>/dev/null
ip addr del 10.45.0.1/16 dev ogstun 2>/dev/null
ip addr add 10.45.0.1/16 dev ogstun
ip link set ogstun up >/dev/null 2>&1

# Redirect traffict to ogstun interface & route via subnet ip (to reach IPs from outside of the container)
iptables -t nat -A POSTROUTING -s 10.45.0.0/16 ! -o ogstun -j MASQUERADE
iptables -A INPUT -i ogstun -j ACCEPT

# Run mongodb
#############
mkdir -p /data/db /tmp/logs && /usr/bin/mongod > /tmp/logs/mongo.log 2>&1 &

# Wait for mongodb to be available, otherwise open5gs will not start correctly
while ! (nc -zv 127.0.0.1 27017 >/dev/null 2>&1); do
    sleep 1
done

# Clean up
##########
iptables -t nat -D POSTROUTING -s 10.45.0.0/16 ! -o ogstun -j MASQUERADE
iptables -D INPUT -i ogstun -j ACCEPT
ip link delete ogstun
for IP in {2..20}; do
    ip link delete lo$IP
done

# Set local IP for NGAP port
sed -i "s/127.0.0.5/${BIND_ADDR}/g" /root/5gc-config.yaml
sed -i "s/- addr: ::1/# - addr: ::1/g" /root/5gc-config.yaml
sed -i "s/- addr: 2001:db8:cafe::1/# - addr: 2001:db8:cafe::1/g" /root/5gc-config.yaml
sed -i "s/mcc: 999/mcc: 001/g" /root/5gc-config.yaml
sed -i "s/mnc: 70/mnc: 01/g" /root/5gc-config.yaml
sed -i "s/tac: 1/tac: 7/g" /root/5gc-config.yaml

# Run Open5GS
5gc -c /root/5gc-config.yaml
