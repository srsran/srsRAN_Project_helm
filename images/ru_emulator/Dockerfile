#
# Copyright 2021-2023 Software Radio Systems Limited
#
# By using this file, you agree to the terms and conditions set
# forth in the LICENSE file which can be found at the top level of
# the distribution.
#

FROM ubuntu:22.04 as builder

ARG DPDK_VERSION=dpdk-23.11
ARG EXTRA_CMAKE_ARGS=""

### Install dependencies
RUN apt-get update && apt-get install -y \
    cmake make gcc g++ pkg-config libfftw3-dev libmbedtls-dev libsctp-dev \
    libyaml-cpp-dev libgtest-dev libnuma-dev python3-pip curl pciutils iproute2 \
    net-tools nano git && \
    pip3 install meson ninja pyelftools

### Install DPDK
WORKDIR /builder/dpdk
RUN curl -L "https://fast.dpdk.org/rel/${DPDK_VERSION}.tar.xz" | tar xJf - && \
    cd "${DPDK_VERSION}" && \
    meson setup build && \
    cd build && \
    ninja && \
    meson install && \
    ldconfig

### Build srsRAN Project
WORKDIR /builder/srs
RUN git clone https://github.com/srsran/srsRAN_Project srsran && \
    cd srsran && \
    mkdir -p ./build && \
    cd build && \
    cmake -DENABLE_DPDK=ON ${EXTRA_CMAKE_ARGS} ../ && \
    make -j `nproc` ru_emulator

FROM ubuntu:22.04

COPY --from=builder /builder/srs/srsran/build/tests/integrationtests/ofh/ru_emulator /usr/local/bin/ru_emulator
COPY --from=builder /usr/local /usr/local

### Install dependencies
RUN apt-get update && apt-get install -y \
    libfftw3-dev libmbedtls-dev libsctp-dev iproute2 \
    libyaml-cpp-dev libnuma-dev python3-pip pciutils && \
    apt clean && \
    pip3 install pyelftools && \
    ldconfig
