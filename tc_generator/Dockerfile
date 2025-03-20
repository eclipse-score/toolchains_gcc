# *******************************************************************************
# Copyright (c) 2025 Contributors to the Eclipse Foundation
#
# See the NOTICE file(s) distributed with this work for additional
# information regarding copyright ownership.
#
# This program and the accompanying materials are made available under the
# terms of the Apache License Version 2.0 which is available at
# https://www.apache.org/licenses/LICENSE-2.0
#
# SPDX-License-Identifier: Apache-2.0
# *******************************************************************************

# Use a base image
FROM ubuntu:24.04

# Set default version of crosstool-ng
ARG VERSION=1.27.0

# Set non-interactive environment variables to avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true

# Set timezone
RUN { echo 'tzdata tzdata/Areas select Etc'; echo 'tzdata tzdata/Zones/Etc select UTC'; } | debconf-set-selections

# Install required dependencies (without prompts)
RUN apt-get update && apt-get install -y \
    autoconf \
    automake \
    bison \
    bzip2 \
    flex \
    g++ \
    gawk \
    gcc \
    git \
    gperf \
    help2man \
    libncurses5-dev \
    libstdc++6 \
    libtool \
    libtool-bin \
    make \
    meson \
    ninja-build \
    patch \
    python3-dev \
    rsync \
    texinfo \
    unzip \
    wget \
    xz-utils

# Download the version of Crosstool-NG and unpackage the archive
RUN wget "http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-${VERSION}.tar.bz2"
RUN mkdir ctng && tar -xf crosstool-ng-${VERSION}.tar.bz2 --strip-components=1 -C ctng

RUN mv /ctng/packages/gcc/12.4.0 /ctng/packages/gcc/12.2.0
RUN rm -rf /ctng/packages/gcc/12.2.0/chksum

ADD 12.2.0/chksum /ctng/packages/gcc/12.2.0/chksum

# Install the crosstool-ng tool
RUN cd ctng && \
    ./bootstrap && \
    ./configure --prefix=/usr/local && \
    make && \
    make install

# Remove archive and install directory
RUN rm -rf crosstool-ng-${VERSION}.tar.bz2
RUN rm -rf ctng
