#
# Copyright 2021-2025 Software Radio Systems Limited
#
# By using this file, you agree to the terms and conditions set
# forth in the LICENSE file which can be found at the top level of
# the distribution.
#

FROM ubuntu:24.04 AS builder

RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y --no-install-recommends \
    git ca-certificates \
    build-essential libnuma-dev python3 && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

ARG RT_TESTS_VERSION=v2.8
RUN git clone git://git.kernel.org/pub/scm/utils/rt-tests/rt-tests.git && \
    cd rt-tests && \
    git checkout ${RT_TESTS_VERSION} && \
    make && \
    DESTDIR=/install make install

FROM ubuntu:24.04
COPY --from=builder /install /
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y --no-install-recommends \
    libnuma-dev && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*
