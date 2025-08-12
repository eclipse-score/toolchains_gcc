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

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@score_toolchains_gcc//rules:gcc.bzl", "gcc_toolchain")

def _gcc_impl(mctx):
    """Implementation of the module extension."""

    for mod in mctx.modules:
        if not mod.is_root:
            fail("Only the root module can use the 'gcc' extension")

    toolchains = []
    features_by_name = {}
    warning_flags_by_name = {}

    for mod in mctx.modules:
        for tag in mod.tags.toolchain:
            toolchains.append({
                "name": tag.name,
                "url": tag.url,
                "strip_prefix": tag.strip_prefix,
                "sha256": tag.sha256,
                "target_arch": tag.target_arch,
                "exec_arch": tag.exec_arch,
            })

        for tag in mod.tags.extra_features:
            name = tag.name
            if name not in features_by_name:
                features_by_name[name] = []
            for feature in tag.features:
                features_by_name[name].append(feature)

        for tag in mod.tags.warning_flags:
            name = tag.name
            warning_flags_by_name[name] = {
                "minimal_warnings": tag.minimal_warnings,
                "strict_warnings": tag.strict_warnings,
                "treat_warnings_as_errors": tag.treat_warnings_as_errors
            }

    # If no toolchains specified, use defaults
    if not toolchains:
        # Default toolchains from skarlsson/toolchains_gcc_packages
        toolchains = [
            {
                "name": "gcc_toolchain_x86_64",
                "url": "https://github.com/skarlsson/toolchains_gcc_packages/releases/download/v0.0.2-pr3/x86_64-unknown-linux-gnu_gcc12.tar.gz",
                "sha256": "ede0289c89a633f6f0b7fa5079a1fbc912e9a8607d01a792e3d78f4939d4e96a",
                "strip_prefix": "x86_64-unknown-linux-gnu",
                "target_arch": "x86_64",
                "exec_arch": "x86_64",
            },
            {
                "name": "gcc_toolchain_aarch64",
                "url": "https://github.com/skarlsson/toolchains_gcc_packages/releases/download/v0.0.2-pr3/aarch64-unknown-linux-gnu_gcc12.tar.gz",
                "sha256": "cd9fcac29bea3dd7e52724166491a10e152f58188c9f25568e6f50b6c38f6dc3",
                "strip_prefix": "aarch64-unknown-linux-gnu",
                "target_arch": "aarch64",
                "exec_arch": "x86_64",
            },
        ]

    for toolchain_info in toolchains:
        name = toolchain_info["name"]
        target_arch = toolchain_info["target_arch"]
        
        # Determine target triple based on architecture
        target_triple = "%s-unknown-linux-gnu" % target_arch
        
        http_archive(
            name = "%s_gcc" % name,
            urls = [toolchain_info["url"]],
            build_file_content = """
# Generated BUILD file for gcc toolchain
package(default_visibility = ["//visibility:public"])

filegroup(
    name = "all_files",
    srcs = glob(["*/**/*"]),
)

filegroup(
    name = "bin",
    srcs = ["bin"],
)

filegroup(
    name = "ar",
    srcs = ["bin/{triple}-ar"],
)

filegroup(
    name = "gcc",
    srcs = ["bin/{triple}-gcc"],
)

filegroup(
    name = "gcov",
    srcs = ["bin/{triple}-gcov"],
)

filegroup(
    name = "gpp",
    srcs = ["bin/{triple}-g++"],
)

filegroup(
    name = "strip",
    srcs = ["bin/{triple}-strip"],
)

filegroup(
    name = "sysroot_dir",
    srcs = ["{triple}/sysroot"],
)
""".format(triple = target_triple),
            sha256 = toolchain_info["sha256"],
            strip_prefix = toolchain_info["strip_prefix"],
        )

        gcc_toolchain(
            name = name,
            gcc_repo = "%s_gcc" % name,
            extra_features = features_by_name.get(name, []),
            warning_flags = warning_flags_by_name.get(name, None),
            target_arch = toolchain_info["target_arch"],
            exec_arch = toolchain_info["exec_arch"],
        )

gcc = module_extension(
    implementation = _gcc_impl,
    tag_classes = {
        "toolchain": tag_class(
            attrs = {
                "name": attr.string(doc = "Same name as the toolchain tag.", default="gcc_toolchain"),
                "url": attr.string(doc = "Url to the toolchain package."),
                "strip_prefix": attr.string(doc = "Strip prefix from toolchain package.", default=""),
                "sha256": attr.string(doc = "Checksum of the package"),
                "target_arch": attr.string(doc = "Target architecture (x86_64 or aarch64)", default="x86_64"),
                "exec_arch": attr.string(doc = "Execution architecture (x86_64 or aarch64)", default="x86_64"),
            },
        ),
        "warning_flags": tag_class(
            attrs = {
                "name": attr.string(doc = "Same name as the toolchain tag.", default="gcc_toolchain"),
                "minimal_warnings": attr.string_list(
                    doc = "List of extra flags for 'minimal_warnings' features.",
                    default= [],
                ),
                "strict_warnings": attr.string_list(
                    doc = "List of extra flags for 'strict_warnings' features.",
                    default= [],
                ),
                "treat_warnings_as_errors": attr.string_list(
                    doc = "List of extra flags for 'treat_warnings_as_errors' features.",
                    default= [],
                ),
            },
        ),
        "extra_features": tag_class(
            attrs = {
                "name": attr.string(doc = "Same name as the toolchain tag.", default="gcc_toolchain"),
                "features": attr.string_list(
                    doc = "List of extra compiler and linker features.",
                    default= [],
                ),
            },
        ),
    }
)
