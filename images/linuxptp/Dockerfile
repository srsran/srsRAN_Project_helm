#
# Copyright 2021-2023 Software Radio Systems Limited
#
# By using this file, you agree to the terms and conditions set
# forth in the LICENSE file which can be found at the top level of
# the distribution.
#

ARG LINUXPTP_VERSION=v4.0
FROM ubuntu:24.04 AS builder

RUN apt update && apt install -y git make gcc musl-dev && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /linuxptp-agent
RUN git clone https://github.com/richardcochran/linuxptp.git && \
    cd linuxptp && \
    git checkout ${LINUXPTP_VERSION} && \
    make clean && make

FROM ubuntu:24.04

COPY --from=builder /linuxptp-agent/linuxptp/ptp4l /usr/local/bin/
COPY --from=builder /linuxptp-agent/linuxptp/phc2sys /usr/local/bin/
COPY --from=builder /linuxptp-agent/linuxptp/pmc /usr/local/bin/
COPY scripts/ /usr/local/bin/

RUN apt update && apt install -y musl-dev bc && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* && \
    ldconfig
