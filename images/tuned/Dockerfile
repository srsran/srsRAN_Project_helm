FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        tuned dbus python3 ethtool procps bash util-linux ca-certificates && \
    rm -rf /var/lib/apt/lists/*
