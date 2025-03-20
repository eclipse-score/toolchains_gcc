#!/bin/bash

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

export GCC=${GCC:?Please set GCC variable to desired gcc major version}

mkdir -p ${PWD}/output/downloads
mkdir -p ${PWD}/output/gcc${GCC}

###############################################################################
#
# Build
#
###############################################################################
export CT_PREFIX="${PWD}/output/gcc${GCC}"
DEFCONFIG=configs/x86_64-unknown-linux-gnu_gcc${GCC} ct-ng defconfig
ct-ng -j$(nproc) build

###############################################################################
#
# Package
#
###############################################################################
function get_commit_time() {
  TZ=UTC0 git log -1 \
    --format=tformat:%cd \
    --date=format:%Y-%m-%dT%H:%M:%SZ
}

SOURCE_EPOCH=$get_commit_time

tar -c \
    --sort=name \
    --mtime="${SOURCE_EPOCH}" \
    --owner=0 \
    --group=0 \
    --numeric-owner \
    -C "output/gcc${GCC}" . \
    | gzip -n > "output/x86_64-unknown-linux-gnu_gcc${GCC}.tar.gz"
