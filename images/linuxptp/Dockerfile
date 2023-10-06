ARG LINUXPTP_VERSION=v4.1
FROM ubuntu:22.04

RUN apt update && apt install -y git make gcc musl-dev

RUN git clone https://github.com/richardcochran/linuxptp.git && \
    cd linuxptp && \
    git checkout ${LINUXPTP_VERSION} && \
    make && make install
