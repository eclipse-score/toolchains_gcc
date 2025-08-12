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

""" Repository rule for setting up GCC Bazel build configuration
"""

def _get_string_warnings(flags):
    """Converts a list of warning flags into a Bazel flag group representation.

    Args:
        flags (list[str]): A list of compiler warning flags.

    Returns:
        str: A formatted string representing the flag group in Bazel syntax.
    """
    if len(flags):
        return "[flag_group(flags = [" + ", ".join(['"%s"' % f for f in flags]) + "])]"
    return "[]"

def _impl(rctx):
    """Implementation function for the GCC toolchain repository rule.

    This function generates the necessary Bazel build files and toolchain configurations
    based on the provided repository context.

    Args:
        rctx (repository_ctx): The Bazel repository context, providing access to attributes
            and methods for creating repository rules.
    """
    # Map architecture names to platform CPU values
    arch_map = {
        "x86_64": "x86_64",
        "aarch64": "aarch64",
    }
    
    # Determine target system name based on architecture
    target_system = "%s-linux" % rctx.attr.target_arch
    
    rctx.template(
        "BUILD",
        rctx.attr._cc_tolchain_build,
        {
            "%{gcc_repo}": rctx.attr.gcc_repo,
            "%{tc_name}": "host_gcc_12",
            "%{exec_cpu}": arch_map.get(rctx.attr.exec_arch, "x86_64"),
            "%{target_cpu}": arch_map.get(rctx.attr.target_arch, "x86_64"),
        },
    )
    minimal_warnings = "[]"
    strict_warnings = "[]"
    treat_warnings_as_errors = "[]"
    third_party_warnings = "[]"

    for key in rctx.attr.warning_flags:
        if key == "minimal_warnings":
            minimal_warnings = _get_string_warnings(rctx.attr.warning_flags[key])
        elif key == "strict_warnings":
            strict_warnings = _get_string_warnings(rctx.attr.warning_flags[key])
        elif key == "treat_warnings_as_errors":
            treat_warnings_as_errors = _get_string_warnings(rctx.attr.warning_flags[key])
        elif key == "third_party_warnings":
            third_party_warnings = _get_string_warnings(rctx.attr.warning_flags[key])
        else:
            fail("Warning feature '%s' not supported" % key)

    rctx.template(
        "cc_toolchain_config.bzl",
        rctx.attr._cc_toolchain_config_bzl,
        {
            "%{minimal_warnings_flags}": minimal_warnings,
            "%{minimal_warnings_switch}": "True" if "minimal_warnings" in rctx.attr.extra_features else "False",
            "%{strict_warnings_flags}": strict_warnings,
            "%{treat_warnings_as_errors_flags}": treat_warnings_as_errors,
            "%{treat_warnings_as_errors_switch}": "True" if "treat_warnings_as_errors" in rctx.attr.extra_features else "False",
            "%{third_party_warnings_flags}": third_party_warnings,
            "%{third_party_warnings_switch}": "True" if "third_party_warnings" in rctx.attr.extra_features else "False",
            "%{target_cpu}": rctx.attr.target_arch,
            "%{target_system}": target_system,
        },
    )

gcc_toolchain = repository_rule(
    implementation = _impl,
    attrs = {
        "gcc_repo": attr.string(doc="The URL of the GCC binary package."),
        "extra_features": attr.string_list(doc="A list of extra features to enable in the toolchain."),
        "warning_flags": attr.string_list_dict(doc="A dictionary mapping warning categories to lists of warning flags."),
        "target_arch": attr.string(default="x86_64", doc="Target architecture (x86_64 or aarch64)."),
        "exec_arch": attr.string(default="x86_64", doc="Execution architecture (x86_64 or aarch64)."),
        "_cc_toolchain_config_bzl": attr.label(
            default = "@score_toolchains_gcc//toolchain/internal:cc_toolchain_config.bzl",
            doc = "Path to the cc_toolchain_config.bzl template file.",
        ),
        "_cc_tolchain_build": attr.label(
            default = "@score_toolchains_gcc//toolchain/internal:toolchain.BUILD",
            doc = "Path to the Bazel BUILD file template for the toolchain.",
        ),
    },
)
