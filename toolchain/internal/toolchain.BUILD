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
load(":cc_toolchain_config.bzl", "cc_toolchain_config")

filegroup(
    name = "empty",
)

cc_toolchain_config(
    name = "cc_toolchain_config",
    ar_binary = "@%{gcc_repo}//:ar",
    cc_binary = "@%{gcc_repo}//:gcc",
    cxx_binary = "@%{gcc_repo}//:gpp",
    flavour = "gcc",
    gcov_binary = "@%{gcc_repo}//:gcov",
    strip_binary = "@%{gcc_repo}//:strip",
    sysroot = "@%{gcc_repo}//:sysroot_dir",
    version = "12",
)

cc_toolchain(
    name = "cc_toolchain",
    all_files = "@%{gcc_repo}//:all_files",
    ar_files = "@%{gcc_repo}//:all_files",
    as_files = "@%{gcc_repo}//:all_files",
    compiler_files = "@%{gcc_repo}//:all_files",
    coverage_files = "@%{gcc_repo}//:all_files",
    dwp_files = ":empty",
    linker_files = "@%{gcc_repo}//:all_files",
    objcopy_files = ":empty",
    strip_files = "@%{gcc_repo}//:all_files",
    toolchain_config = ":cc_toolchain_config",
)

toolchain(
    name = "%{tc_name}",
    exec_compatible_with = [
        "@platforms//cpu:%{exec_cpu}",
        "@platforms//os:linux",
    ],
    target_compatible_with = [
        "@platforms//cpu:%{target_cpu}",
        "@platforms//os:linux",
    ],
    toolchain = ":cc_toolchain",
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
    visibility = [
        "//:__pkg__",
    ],
)
