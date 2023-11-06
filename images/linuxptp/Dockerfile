ARG LINUXPTP_VERSION=v4.1
FROM ubuntu:22.04 AS builder

RUN apt update && apt install -y git make gcc musl-dev && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /linuxptp-agent
RUN git clone https://github.com/richardcochran/linuxptp.git && \
    cd linuxptp && \
    git checkout ${LINUXPTP_VERSION} && \
    make clean && make

FROM ubuntu:22.04

COPY --from=builder /linuxptp-agent/linuxptp/ptp4l /usr/local/bin/
COPY --from=builder /linuxptp-agent/linuxptp/phc2sys /usr/local/bin/

RUN apt update && apt install -y musl-dev && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* && \
    ldconfig
