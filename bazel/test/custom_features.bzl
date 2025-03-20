load("@score_toolchains_gcc//:provider.bzl", "FeatureListInfo")
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

def _impl(ctx):
    """ TODO: Write docstrings
    """
    compile_flags = [
        "-D__DATE__=\"redacted\"",
        "-D__TIMESTAMP__=\"redacted\"",
        "-D__TIME__=\"redacted\"",
        "-Wno-builtin-macro-redefined",
        "-no-canonical-prefixes",
        "-fno-canonical-system-headers",
    ]

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
    return FeatureListInfo(top_features=[unfiltered_compile_flags_feature])

custom_features = rule(
    implementation = _impl,
    attrs = {},
)
