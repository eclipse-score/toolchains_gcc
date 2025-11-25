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
load("@score_toolchains_gcc//extensions:gcc_defs.bzl", 
    "DEFAULT_MINIMAL_WARNINGS",
    "DEFAULT_STRICT_WARNINGS",
    "DEFAULT_WARNINGS_AS_ERRORS",
    "DEFAULT_FEATURES",
    "ALL_WALL_WARNINGS",
)

def _validate_warning_flag(flag):
    if not flag.startswith("-W"):
        fail("Invalid warning flag: '%s'. Must start with '-W'" % flag)

    if flag.startswith("-Wno-"):
        warning_name = flag[5:]

        for minimal_flag in DEFAULT_MINIMAL_WARNINGS:
            minimal_name = minimal_flag[2:]
            if minimal_name == warning_name or minimal_flag == flag:
                fail("Cannot disable minimal warning '%s' using '%s'" % (minimal_flag, flag))

        for wall_flag in ALL_WALL_WARNINGS:
            wall_name = wall_flag[2:]
            if wall_name == warning_name or wall_flag == flag:
                fail("Cannot disable -Wall warning '%s' using '%s'" % (wall_flag, flag))

    if flag.startswith("-Wno-error"):
        if "=" in flag:
            warning_name = flag.split("=", 1)[1]
            for minimal_flag in DEFAULT_MINIMAL_WARNINGS:
                if minimal_flag[2:] == warning_name:
                    fail("Cannot convert minimal warning '%s' back to non-error using '%s'" % (minimal_flag, flag))
            for wall_flag in ALL_WALL_WARNINGS:
                if wall_flag[2:] == warning_name:
                    fail("Cannot convert -Wall warning '%s' back to non-error using '%s'" % (wall_flag, flag))
        else:
            fail("Cannot disable all errors using '%s' because minimal and -Wall warnings must remain errors" % flag)

    return True


def _gcc_impl(mctx):
    """Implementation of the module extension."""

    for mod in mctx.modules:
        if not mod.is_root:
            fail("Only the root module can use the 'gcc' extension")

    toolchain_info = None
    features = list(DEFAULT_FEATURES)
    warning_flags = {
        "minimal_warnings": list(DEFAULT_MINIMAL_WARNINGS),
        "strict_warnings": list(DEFAULT_STRICT_WARNINGS),
        "treat_warnings_as_errors": list(DEFAULT_WARNINGS_AS_ERRORS),
        "additional_warnings": [],
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
                    if remove_feature == "minimal_warnings":
                        fail("'minimal_warnings' feature is protected and cannot be disabled")
                        
                    if remove_feature == "treat_warnings_as_errors":
                        fail("'treat_warnings_as_errors' feature is protected and cannot be disabled")

                    if remove_feature in features:
                        features.remove(remove_feature)
                else:
                    if f not in features:
                        features.append(f)

        for tag in mod.tags.warning_flags:
            for flag in tag.additional_warnings:
                _validate_warning_flag(flag)
                if flag not in warning_flags["additional_warnings"]:
                    warning_flags["additional_warnings"].append(flag)

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
                "additional_warnings": attr.string_list(
                    doc = "List of additional warning flags. Patterns: '-W<warning-name>', '-Wno-error=<warning-name>'. Cannot use '-Wno-' to disable warnings from DEFAULT_MINIMAL_WARNINGS.",
                    default = [],
                ),
            },
        ),
        "extra_features": tag_class(
            attrs = {
                "features": attr.string_list(
                    doc = "List of extra compiler and linker features. Use '-strict_warnings' to disable strict warnings (minimal_warnings and treat_warnings_as_errors cannot be disabled).",
                    default = [],
                ),
            },
        ),
    }
)
