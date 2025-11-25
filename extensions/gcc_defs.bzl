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
DEFAULT_MINIMAL_WARNINGS = [
    "-Wall",
    "-Wundef",
    "-Wwrite-strings",
    "-Wpointer-arith",
    "-Wcast-align",
    "-Wredundant-decls",
    "-Wreturn-local-addr",
    "-Wcast-qual",
    "-Wbad-function-cast",
    "-Wodr",
    "-Wsizeof-array-argument",
    "-Wformat=2",
    "-Wmissing-format-attribute",
    "-Wformat-nonliteral",
    "-Wformat-signedness",
    "-Wmissing-prototypes",
    "-Wreorder"
]


# According to https://gcc.gnu.org/onlinedocs/gcc/Warning-Options.html,
# the `-Wall` option in GCC enables a set of warnings by default.
# The following list represents all warnings enabled by `-Wall`,
# This list is used ONLY for validation (to prevent disabling important warnings), not for direct compilation.
# For compilation, we use a smaller curated MINIMAL_WARNINGS list.

ALL_WALL_WARNINGS = [
    "-Waddress",
    "-Waligned-new",
    "-Warray-bounds=1",
    "-Warray-compare",
    "-Warray-parameter=2",
    "-Wbool-compare",
    "-Wbool-operation",
    "-Wc++11-compat",
    "-Wc++14-compat",
    "-Wc++17-compat",
    "-Wc++20-compat",
    "-Wcatch-value",
    "-Wchar-subscripts",
    "-Wclass-memaccess",
    "-Wcomment",
    "-Wdangling-else",
    "-Wdangling-pointer=2",
    "-Wdelete-non-virtual-dtor",
    "-Wduplicate-decl-specifier",
    "-Wenum-compare",
    "-Wenum-int-mismatch",
    "-Wformat=1",
    "-Wformat-contains-nul",
    "-Wformat-diag",
    "-Wformat-extra-args",
    "-Wformat-overflow=1",
    "-Wformat-truncation=1",
    "-Wformat-zero-length",
    "-Wframe-address",
    "-Wimplicit",
    "-Wimplicit-function-declaration",
    "-Wimplicit-int",
    "-Winfinite-recursion",
    "-Winit-self",
    "-Wint-in-bool-context",
    "-Wlogical-not-parentheses",
    "-Wmain",
    "-Wmaybe-uninitialized",
    "-Wmemset-elt-size",
    "-Wmemset-transposed-args",
    "-Wmisleading-indentation",
    "-Wmismatched-dealloc",
    "-Wmismatched-new-delete",
    "-Wmissing-attributes",
    "-Wmissing-braces",
    "-Wmultistatement-macros",
    "-Wnarrowing",
    "-Wnonnull",
    "-Wnonnull-compare",
    "-Wopenmp-simd",
    "-Woverloaded-virtual=1",
    "-Wpacked-not-aligned",
    "-Wparentheses",
    "-Wpessimizing-move",
    "-Wpointer-sign",
    "-Wrange-loop-construct",
    "-Wreorder",
    "-Wrestrict",
    "-Wreturn-type",
    "-Wself-move",
    "-Wsequence-point",
    "-Wsign-compare",
    "-Wsizeof-array-div",
    "-Wsizeof-pointer-div",
    "-Wsizeof-pointer-memaccess",
    "-Wstrict-aliasing",
    "-Wstrict-overflow=1",
    "-Wswitch",
    "-Wtautological-compare",
    "-Wtrigraphs",
    "-Wuninitialized",
    "-Wunknown-pragmas",
    "-Wunused",
    "-Wunused-but-set-variable",
    "-Wunused-const-variable=1",
    "-Wunused-function",
    "-Wunused-label",
    "-Wunused-local-typedefs",
    "-Wunused-value",
    "-Wunused-variable",
    "-Wuse-after-free=2",
    "-Wvla-parameter",
    "-Wvolatile-register-var",
    "-Wzero-length-bounds",
]

DEFAULT_STRICT_WARNINGS = [
    "-Wextra",
    "-Wpedantic",
    "-Wswitch-bool",
    "-Wconversion",
    "-Wlogical-op",
    "-Wunused-but-set-parameter",
    "-Wlogical-not-parentheses",
    "-Wbool-compare",
    "-Winvalid-pch",
    "-Wvla",
    "-Wuseless-cast",
    "-Wdouble-promotion",
    "-Wnarrowing"
]

DEFAULT_WARNINGS_AS_ERRORS = [
    "-Werror",
    "-Wno-error=deprecated-declarations",
]

DEFAULT_FEATURES = [
    "minimal_warnings",
    "strict_warnings",
    "treat_warnings_as_errors",
]
