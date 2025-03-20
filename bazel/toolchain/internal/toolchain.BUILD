load("@rules_cc//cc:defs.bzl", "cc_toolchain")
load(":cc_toolchain_config.bzl", "cc_toolchain_config")

filegroup(
    name = "all_files",
    srcs = [
        ":gcov",
        "@%{toolchain_gcc}//:all_files",
    ],
)

filegroup(
    name = "empty",
)

filegroup(
    name = "gcov",
    srcs = [
        "@%{toolchain_gcc}//:gcov",
    ],
)

cc_toolchain_config(
    name = "cc_toolchain_config",
    ar_binary = "@%{toolchain_gcc}//:ar",
    cc_binary = "@%{toolchain_gcc}//:gcc",
    cxx_binary = "@%{toolchain_gcc}//:gpp",
    flavour = "gcc",
    gcov_binary = "@%{toolchain_gcc}//:gcov",
    strip_binary = "@%{toolchain_gcc}//:strip",
    sysroot = "@%{toolchain_gcc}//:sysroot_dir",
    version = "12",
    extra_features = ["@@%{extra_features}"],
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
