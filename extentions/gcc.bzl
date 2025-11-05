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

    DEFAULT_FEATURES = [
        "minimal_warnings",
        "strict_warnings",
        "treat_warnings_as_errors",
    ]


    DEFAULT_WARNING_FLAGS = {
        "minimal_warnings": [
            "-Wall",
            "-Wextra",
            "-Wundef",
            "-Wwrite-strings",
            "-Wpointer-arith",
            "-Wcast-align",
            "-Wshadow",
            "-Wswitch-bool",
            "-Wredundant-decls",
            "-Wswitch-enum",
            "-Wtype-limits",
            "-Wformat",
            "-Wformat-security",
            "-Wconversion",
            "-Wlogical-op",
            "-Wreturn-local-addr",
            "-Wunused-but-set-variable",
            "-Wunused-parameter",
            "-Wunused-but-set-parameter",
            "-Wunused-variable",
            "-Wunused",
            "-Wparentheses",
            "-Wuninitialized",
            "-Wsequence-point",
            "-Wsign-compare",
            "-Wignored-qualifiers",
            "-Wcast-qual",
            "-Wreturn-type",
            "-Wcomment"
        ],
        "strict_warnings": [
            "-Wpedantic",
            "-Wbad-function-cast",
            "-Wstrict-prototypes",
            "-Wodr",
            "-Wlogical-not-parentheses",
            "-Wsizeof-array-argument",
            "-Wbool-compare",
            "-Winvalid-pch",
            "-Wformat=2",
            "-Wmissing-format-attribute",
            "-Wformat-nonliteral",
            "-Wformat-signedness",
            "-Wvla",
            "-Wuseless-cast",
            "-Wdouble-promotion",
            "-Wmissing-prototypes",
            "-Wreorder",
            "-Wnarrowing"
        ],
        "treat_warnings_as_errors": []
    }


    toolchain_info = None
    features = list(DEFAULT_FEATURES)
    warning_flags = {
        "minimal_warnings": list(DEFAULT_WARNING_FLAGS["minimal_warnings"]),
        "strict_warnings": list(DEFAULT_WARNING_FLAGS["strict_warnings"]),
        "treat_warnings_as_errors": list(DEFAULT_WARNING_FLAGS["treat_warnings_as_errors"]),
    }

    for mod in mctx.modules:
        for tag in mod.tags.toolchain:
            toolchain_info = {
                "name": tag.name,
                "url": tag.url,
                "strip_prefix": tag.strip_prefix,
                "sha256": tag.sha256,
            }

        for tag in mod.tags.extra_features:
            for feature in tag.features:
                f = feature.strip()
                if not f:
                    continue
                if f.startswith("-"):
                    remove_feature = f[1:].strip()
                    if remove_feature in features:
                        features.remove(remove_feature)
                else:
                    if f not in features:
                        features.append(f)

        for tag in mod.tags.warning_flags:
            for flag in tag.minimal_warnings:
                if flag not in warning_flags["minimal_warnings"]:
                    warning_flags["minimal_warnings"].append(flag)

            for flag in tag.strict_warnings:
                if flag not in warning_flags["strict_warnings"]:
                    warning_flags["strict_warnings"].append(flag)

            for flag in tag.treat_warnings_as_errors:
                if flag not in warning_flags["treat_warnings_as_errors"]:
                    warning_flags["treat_warnings_as_errors"].append(flag)

    if toolchain_info:
        http_archive(
            name = "%s_gcc" % toolchain_info["name"],
            urls = [toolchain_info["url"]],
            build_file = "@score_toolchains_gcc//toolchain/third_party:gcc.BUILD",
            sha256 = toolchain_info["sha256"],
            strip_prefix = toolchain_info["strip_prefix"],
        )

        gcc_toolchain(
            name = toolchain_info["name"],
            gcc_repo = "%s_gcc" % toolchain_info["name"],
            extra_features = features,
            warning_flags = warning_flags,
        )

    else:
        fail("Cannot create gcc toolchain repository, some info is missing!")

gcc = module_extension(
    implementation = _gcc_impl,
    tag_classes = {
        "toolchain": tag_class(
            attrs = {
                "name": attr.string(doc = "Same name as the toolchain tag.", default="gcc_toolchain"),
                "url": attr.string(doc = "Url to the toolchain package."),
                "strip_prefix": attr.string(doc = "Strip prefix from toolchain package.", default=""),
                "sha256": attr.string(doc = "Checksum of the package"),
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
