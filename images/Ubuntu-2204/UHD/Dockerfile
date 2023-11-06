FROM ubuntu:22.04

ARG UHD_VERSION=UHD-4.1
ARG EXTRA_CMAKE_ARGS=""

### Install dependencies
RUN apt-get update && apt-get install -y \
    cmake make gcc g++ git pkg-config libfftw3-dev libmbedtls-dev libsctp-dev \
    libyaml-cpp-dev libgtest-dev libnuma-dev python3-pip curl git autoconf automake build-essential \
    cpufrequtils ethtool inetutils-tools libboost-all-dev libncurses5 libncurses5-dev libusb-1.0-0 libusb-1.0-0-dev \
    libusb-dev python3-dev python3-mako python3-numpy python3-requests python3-scipy python3-setuptools \
    python3-ruamel.yaml  && \
    pip3 install meson ninja pyelftools

### Build and install UHD
RUN git clone https://github.com/EttusResearch/uhd &&\
    cd uhd && \
    git checkout ${UHD_VERSION} && \
    mkdir -p host/build && \
    cd host/build && \
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local -DENABLE_PYTHON_API=OFF -DENABLE_EXAMPLES=OFF -DENABLE_TESTS=OFF .. && \
    make -j`nproc` && make -j`nproc` install && \
    /usr/local/lib/uhd/utils/uhd_images_downloader.py && \
    ldconfig

### Build srsGNB
RUN mkdir -p /builder && \
    git clone https://github.com/srsran/srsRAN_Project /builder/srsran && \
    mkdir -p /builder/srsgnb/build /opt/srsgnb && \
    cd build && \
    cmake -DBUILD_TESTS=False -DCMAKE_INSTALL_PREFIX=/opt/srsgnb -DUHD_ENABLE=ON ${EXTRA_CMAKE_ARGS} ../ && \
    make -j`nproc` && make -j`nproc` install && \
    ln -s /builder/srsgnb/build/apps/gnb/gnb /usr/bin/gnb
