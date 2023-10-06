ARG OS_VERSION=22.04
FROM ubuntu:${OS_VERSION}

ENV PYTHONBUFFERED=1
ENV DEBIAN_FRONTEND=noninteractive
ENV REPO_URL=https://github.com/open5gs/open5gs

RUN apt-get update \
    && apt install -y software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Open5gs dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    ninja-build \
    build-essential \
    flex \
    bison \
    git \
    cmake \
    libsctp-dev \
    libgnutls28-dev \
    libgcrypt-dev \
    libssl-dev \
    libidn11-dev \
    libmongoc-dev \
    libbson-dev \
    libyaml-dev \
    libnghttp2-dev \
    libmicrohttpd-dev \
    libcurl4-gnutls-dev \
    libnghttp2-dev \
    libtins-dev \
    meson \
    gettext \
    gdb \
    iproute2 \
    iptables \
    iputils-ping \
    netcat \
    iperf3 \
    libtalloc-dev

ARG OPEN5GS_VERSION=v2.5.6

# Build and install Open5gs
RUN git clone --depth 1 --branch $OPEN5GS_VERSION $REPO_URL /open5gs && \
    cd open5gs && \
    meson build --prefix=`pwd`/install && \
    ninja -C build && \
    cp /open5gs/build/configs/sample.yaml /root/5gc-config.yaml && \
    ln -s /open5gs/build/tests/app/5gc /usr/local/bin/5gc && \
    ln -s /open5gs/build/tests/app/epc /usr/local/bin/epc && \
    ln -s /open5gs/build/tests/app/app /usr/local/bin/app

# Install MongoDB
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y --no-install-recommends wget gnupg \ 
    && wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | apt-key add \
    && . /etc/os-release \
    && echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu $UBUNTU_CODENAME/mongodb-org/6.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-6.0.list \
    && DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y --no-install-recommends mongodb-org \
    && apt-get autoremove && apt-get clean

ADD open5gs_entrypoint.sh /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/open5gs_entrypoint.sh"]
