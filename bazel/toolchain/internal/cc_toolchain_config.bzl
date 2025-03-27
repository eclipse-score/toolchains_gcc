"""C/C++ toolchain definition"""

load("@bazel_tools//tools/build_defs/cc:action_names.bzl", "ACTION_NAMES")
load(
    "@bazel_tools//tools/cpp:cc_toolchain_config_lib.bzl",
    "action_config",
    "feature",
    "flag_group",
    "flag_set",
    "tool",
    "tool_path",
    "with_feature_set",
)

load("@score_toolchains_gcc//:provider.bzl", "FeatureListInfo")

all_cpp_compile_actions = [
    ACTION_NAMES.cpp_compile,
    ACTION_NAMES.linkstamp_compile,
    ACTION_NAMES.cpp_header_parsing,
    ACTION_NAMES.cpp_module_compile,
    ACTION_NAMES.cpp_module_codegen,
    ACTION_NAMES.clif_match,
    ACTION_NAMES.lto_backend,
]

all_c_compile_actions = [
    ACTION_NAMES.c_compile,
]

all_assemble_actions = [
    ACTION_NAMES.assemble,
    ACTION_NAMES.preprocess_assemble,
]

all_compile_actions = all_c_compile_actions + all_cpp_compile_actions + all_assemble_actions

all_link_actions = [
    ACTION_NAMES.cpp_link_executable,
    ACTION_NAMES.cpp_link_dynamic_library,
    ACTION_NAMES.cpp_link_nodeps_dynamic_library,
]

all_actions = all_compile_actions + all_link_actions + [
    ACTION_NAMES.strip,
    ACTION_NAMES.cpp_link_static_library,
]

def _impl(ctx):
    dbg_feature = feature(name = "dbg")
    opt_feature = feature(name = "opt")

    assemble_action = action_config(
        action_name = ACTION_NAMES.assemble,
        tools = [tool(tool = ctx.executable.cc_binary)],
    )
    preprocess_assemble_action = action_config(
        action_name = ACTION_NAMES.preprocess_assemble,
        tools = [tool(tool = ctx.executable.cc_binary)],
    )
    c_compile_action = action_config(
        action_name = ACTION_NAMES.c_compile,
        tools = [tool(tool = ctx.executable.cc_binary)],
    )
    cpp_compile_action = action_config(
        action_name = ACTION_NAMES.cpp_compile,
        tools = [tool(tool = ctx.executable.cxx_binary)],
    )
    cpp_link_executable_action = action_config(
        action_name = ACTION_NAMES.cpp_link_executable,
        tools = [tool(tool = ctx.executable.cxx_binary)],
    )
    cpp_link_dynamic_library_action = action_config(
        action_name = ACTION_NAMES.cpp_link_dynamic_library,
        tools = [tool(tool = ctx.executable.cxx_binary)],
    )
    cpp_link_nodeps_dynamic_library_action = action_config(
        action_name = ACTION_NAMES.cpp_link_nodeps_dynamic_library,
        tools = [tool(tool = ctx.executable.cxx_binary)],
    )
    cpp_link_static_library_action = action_config(
        action_name = ACTION_NAMES.cpp_link_static_library,
        tools = [tool(tool = ctx.executable.ar_binary)],
        implies = ["archiver_flags"],
    )
    strip_action = action_config(
        action_name = ACTION_NAMES.strip,
        tools = [tool(tool = ctx.executable.strip_binary)],
        flag_sets = [
            flag_set(
                flag_groups = [
                    flag_group(
                        flags = [
                            "-g",
                            "-p",
                        ],
                    ),
                    flag_group(
                        iterate_over = "stripopts",
                        flags = ["%{stripopts}"],
                    ),
                    flag_group(
                        flags = [
                            "%{input_file}",
                            "%{output_file}",
                        ],
                    ),
                ],
            ),
        ],
    )

    action_configs = [
        assemble_action,
        c_compile_action,
        cpp_compile_action,
        cpp_link_dynamic_library_action,
        cpp_link_executable_action,
        cpp_link_nodeps_dynamic_library_action,
        cpp_link_static_library_action,
        preprocess_assemble_action,
        strip_action,
    ]

    compile_flags = [
        "-D__DATE__=\"redacted\"",
        "-D__TIMESTAMP__=\"redacted\"",
        "-D__TIME__=\"redacted\"",
        "-Wno-builtin-macro-redefined",
        "-no-canonical-prefixes",
    ]

    if ctx.attr.flavour == "gcc":
        compile_flags.append("-fno-canonical-system-headers")

    unfiltered_compile_flags_feature = feature(
        name = "unfiltered_compile_flags",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = all_c_compile_actions + all_cpp_compile_actions,
                flag_groups = [
                    flag_group(
                        flags = compile_flags,
                    ),
                ],
            ),
        ],
    )

    default_compile_flags_feature = feature(
        name = "default_compile_flags",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = all_compile_actions,
                flag_groups = [
                    flag_group(
                        flags = [
                            "-m64",
                        ],
                    ),
                ],
            ),
            flag_set(
                actions = all_cpp_compile_actions,
                flag_groups = [
                    flag_group(
                        flags = [
                            "-std=c++17",
                        ],
                    ),
                ],
                with_features = [
                    with_feature_set(not_features = ["c++17", "c++20"]),
                ],
            ),
            flag_set(
                actions = all_c_compile_actions,
                flag_groups = [
                    flag_group(
                        flags = [
                            "-std=c11",
                        ],
                    ),
                ],
            ),
            flag_set(
                actions = all_compile_actions,
                flag_groups = [
                    flag_group(
                        flags = [
                            "-Og",
                            "-g3",
                        ],
                    ),
                ],
                with_features = [with_feature_set(features = ["dbg"])],
            ),
            flag_set(
                actions = all_compile_actions,
                flag_groups = [
                    flag_group(
                        flags = [
                            "-O2",
                            "-DNDEBUG",
                        ],
                    ),
                ],
                with_features = [with_feature_set(features = ["opt"])],
            ),
        ],
    )

    linker_flags = [
        "-static-libstdc++",
        "-static-libgcc",
    ]

    if ctx.attr.flavour == "clang":
        linker_flags.append("-fuse-ld=lld")
        linker_flags.append("-l:libc++abi.a")

    default_link_flags_feature = feature(
        name = "default_link_flags",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = all_link_actions,
                flag_groups = [
                    flag_group(flags = linker_flags),
                ],
            ),
        ],
    )

    minimal_warnings_feature = feature(
        name = "minimal_warnings",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = all_compile_actions,
                flag_groups = [
                    flag_group(
                        flags = [
                            "-Wall",
                            "-Wno-error=deprecated-declarations",
                        ],
                    ),
                ],
                with_features = [
                    with_feature_set(not_features = ["third_party_warnings"]),
                ],
            ),
        ],
    )

    strict_warnings_feature = feature(
        name = "strict_warnings",
        implies = ["minimal_warnings"],
        flag_sets = [
            flag_set(
                actions = all_compile_actions,
                flag_groups = [
                    flag_group(
                        flags = [
                            "-Wextra",
                            "-Wpedantic",
                        ],
                    ),
                ],
                with_features = [
                    with_feature_set(not_features = ["third_party_warnings"]),
                ],
            ),
            flag_set(
                actions = all_cpp_compile_actions,
                flag_groups = [],
                with_features = [
                    with_feature_set(not_features = ["third_party_warnings"]),
                ],
            ),
            flag_set(
                actions = all_c_compile_actions,
                flag_groups = [],
                with_features = [
                    with_feature_set(not_features = ["third_party_warnings"]),
                ],
            ),
        ],
    )

    treat_warnings_as_errors_feature = feature(
        name = "treat_warnings_as_errors",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = all_compile_actions,
                flag_groups = [
                    flag_group(
                        flags = [
                            "-Werror",
                        ],
                    ),
                ],
                with_features = [
                    with_feature_set(not_features = ["third_party_warnings"]),
                ],
            ),
        ],
    )

    third_party_warnings_feature = feature(
        name = "third_party_warnings",
        flag_sets = [
            flag_set(
                actions = all_compile_actions,
                flag_groups = [],
            ),
        ],
    )

    cxx17_feature = feature(
        name = "c++17",
        provides = ["cxx_std"],
        flag_sets = [
            flag_set(
                actions = all_cpp_compile_actions,
                flag_groups = [
                    flag_group(flags = ["-std=c++17"]),
                ],
            ),
        ],
    )

    cxx20_feature = feature(
        name = "c++20",
        provides = ["cxx_std"],
        flag_sets = [
            flag_set(
                actions = all_cpp_compile_actions,
                flag_groups = [
                    flag_group(flags = ["-std=c++20"]),
                ],
            ),
        ],
    )

    supports_pic_feature = feature(name = "supports_pic", enabled = True)

    coverage_feature = feature(
        name = "coverage",
        provides = ["profile"],
        flag_sets = [
            flag_set(
                actions = [
                    ACTION_NAMES.preprocess_assemble,
                    ACTION_NAMES.c_compile,
                    ACTION_NAMES.cpp_compile,
                    ACTION_NAMES.cpp_header_parsing,
                    ACTION_NAMES.cpp_module_compile,
                ],
                flag_groups = ([
                    flag_group(["-fprofile-arcs", "-ftest-coverage"]),
                ]),
            ),
            flag_set(
                actions = all_link_actions,
                flag_groups = ([
                    flag_group(["-fprofile-arcs", "-ftest-coverage", "-lgcov"]),
                ]),
            ),
        ],
    )

    # The order of the features is relevant, they are applied in this specific order.
    # A command line parameter from a feature at the end of the list will appear
    # after a command line parameter from a feature at the beginning of the list.

    extra_top_features = []
    extra_bottom_features = []

    features = [
        dbg_feature,
        default_compile_flags_feature,
        cxx17_feature,
        cxx20_feature,
        default_link_flags_feature,
        minimal_warnings_feature,
        opt_feature,
        strict_warnings_feature,
        supports_pic_feature,
        treat_warnings_as_errors_feature,
        third_party_warnings_feature,
        unfiltered_compile_flags_feature,
    ]

    if ctx.attr.flavour == "gcc":
        features += [coverage_feature]

    cxx_builtin_include_directories = [
    ]

    toolchain_full_name = "%s-%s" % (ctx.attr.flavour, ctx.attr.version)
    tool_paths = []

    return cc_common.create_cc_toolchain_config_info(
        ctx = ctx,
        abi_version = toolchain_full_name,
        abi_libc_version = "unknown",
        builtin_sysroot = ctx.file.sysroot.path,
        compiler = ctx.attr.flavour,
        cxx_builtin_include_directories = cxx_builtin_include_directories,
        features =  extra_top_features + features + extra_bottom_features,
        action_configs = action_configs,
        host_system_name = "local",
        target_system_name = "x86_64-linux",
        target_cpu = "x86_64",
        target_libc = "unknown",
        toolchain_identifier = toolchain_full_name,
        tool_paths = tool_paths,
    )

cc_toolchain_config = rule(
    implementation = _impl,
    provides = [CcToolchainConfigInfo],
    attrs = {
        "ar_binary": attr.label(allow_single_file = True, executable = True, cfg = "exec", mandatory = True),
        "cc_binary": attr.label(allow_single_file = True, executable = True, cfg = "exec", mandatory = True),
        "cxx_binary": attr.label(allow_single_file = True, executable = True, cfg = "exec", mandatory = True),
        "extra_features": attr.label_list(default = []),
        "gcov_binary": attr.label(allow_single_file = True, executable = True, cfg = "exec", mandatory = True),
        "flavour": attr.string(mandatory = True),
        "strip_binary": attr.label(allow_single_file = True, executable = True, cfg = "exec", mandatory = True),
        "sysroot": attr.label(allow_single_file = True, mandatory = True),
        "version": attr.string(mandatory = True),
    },
)
