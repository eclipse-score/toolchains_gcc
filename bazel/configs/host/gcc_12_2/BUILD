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

load("@rules_cc//cc:defs.bzl", "cc_toolchain")
load("//configs/host/gcc_12_2:cc_config.bzl", "cc_toolchain_config")

filegroup(
    name = "all_files",
    srcs = [
        "@host_gcc_12//:all_files",
    ],
)

filegroup(
    name = "empty",
)

cc_toolchain_config(
    name = "cc_toolchain_config",
    ar_binary = "@host_gcc_12//:ar",
    cc_binary = "@host_gcc_12//:gcc",
    cxx_binary = "@host_gcc_12//:gpp",
    flavour = "gcc",
    strip_binary = "@host_gcc_12//:strip",
    sysroot = "@host_gcc_12//:sysroot_dir",
    version = "12",
)

cc_toolchain(
    name = "cc_toolchain",
    all_files = ":all_files",
    ar_files = ":all_files",
    as_files = ":all_files",
    compiler_files = ":all_files",
    coverage_files = ":all_files",
    dwp_files = ":empty",
    linker_files = ":all_files",
    objcopy_files = ":empty",
    strip_files = ":all_files",
    toolchain_config = ":cc_toolchain_config",
)

toolchain(
    name = "host_gcc_12",
    exec_compatible_with = [
        "@platforms//cpu:x86_64",
        "@platforms//os:linux",
    ],
    target_compatible_with = [
        "@platforms//cpu:x86_64",
        "@platforms//os:linux",
    ],
    toolchain = ":cc_toolchain",
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
    visibility = [
        "//:__pkg__",
    ],
)
