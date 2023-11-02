FROM ubuntu:22.04

ARG DPDK_VERSION=dpdk-23.07
ARG EXTRA_CMAKE_ARGS=""

### Install dependencies
RUN apt-get update && apt-get install -y \
    cmake make gcc g++ pkg-config libfftw3-dev libmbedtls-dev libsctp-dev \
    libyaml-cpp-dev libgtest-dev libnuma-dev python3-pip curl pciutils iproute2 \
    net-tools nano git && \
    pip3 install meson ninja pyelftools

### Install DPDK 23.07 LTS
RUN mkdir -p /opt/dpdk && cd /opt/dpdk && \
    curl -L "https://fast.dpdk.org/rel/${DPDK_VERSION}.tar.xz" | tar xJf - && \
    cd dpdk-23.07 && \
    meson setup build && \
    cd build && \
    ninja && \
    meson install && \
    ldconfig

### Build srsRAN Project
RUN mkdir -p /builder && \
    git clone https://github.com/srsran/srsRAN_Project /builder/srsran && \
    cd /builder/srsran && \
    mkdir -p /builder/srsran/build /opt/srsran && \
    cd build && \
    cmake -DBUILD_TESTS=False -DCMAKE_INSTALL_PREFIX=/opt/srsran -DENABLE_DPDK=ON ${EXTRA_CMAKE_ARGS} ../ && \
    make -j`nproc` && make -j`nproc` install && \
    ln -s /builder/srsran/build/apps/gnb/gnb /usr/bin/gnb
