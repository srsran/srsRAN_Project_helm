FROM ubuntu:22.04 as builder

ARG UHD_VERSION=UHD-4.1
ARG EXTRA_CMAKE_ARGS=""

### Install dependencies
RUN apt-get update && apt-get install -y \
    cmake make gcc g++ git pkg-config libfftw3-dev libmbedtls-dev libsctp-dev \
    libyaml-cpp-dev python3-pip git autoconf automake build-essential python3-ruamel.yaml \
    cpufrequtils inetutils-tools libboost-all-dev libncurses5 libncurses5-dev libusb-1.0-0 libusb-1.0-0-dev \
    libusb-dev python3-dev python3-mako python3-numpy python3-requests python3-scipy python3-setuptools

### Build and install UHD
WORKDIR /builder/uhd
RUN git clone https://github.com/EttusResearch/uhd &&\
    cd uhd && \
    git checkout ${UHD_VERSION} && \
    mkdir -p host/build && \
    cd host/build && \
    cmake \
    -DCMAKE_INSTALL_PREFIX=/builder/uhd/uhd-build \
    -DENABLE_PYTHON_API=OFF \
    -DENABLE_EXAMPLES=OFF \
    -DENABLE_TESTS=OFF .. && \
    make -j `nproc` && make -j `nproc` install

### Build srsRAN Project
WORKDIR /builder/srs
RUN git clone https://github.com/srsran/srsRAN_Project srsran && \
    cd srsran && \
    mkdir -p ./build && cd build && \
    cmake \
    -DBUILD_TESTS=False \
    -DCMAKE_INSTALL_PREFIX=/builder/srs/srsran-build \
    -DUHD_DIR=/builder/uhd/uhd-build \
    -DENABLE_UHD=ON ${EXTRA_CMAKE_ARGS} ../ && \
    make -j `nproc` && make -j `nproc` install

FROM ubuntu:22.04

COPY --from=builder /builder/srs/srsran-build /usr/local
COPY --from=builder /builder/uhd/uhd-build /usr/local

### Install dependencies
RUN apt-get update && apt-get install -y \
    libfftw3-dev libmbedtls-dev libsctp-dev libyaml-cpp-dev libnuma-dev python3-pip python3-ruamel.yaml \
    cpufrequtils inetutils-tools libboost-all-dev libncurses5 libncurses5-dev libusb-1.0-0 libusb-1.0-0-dev \
    libusb-dev python3-dev python3-mako python3-numpy python3-requests python3-scipy python3-setuptools && \
    apt clean && \
    ldconfig && \
    /usr/local/lib/uhd/utils/uhd_images_downloader.py
