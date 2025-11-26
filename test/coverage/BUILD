cc_library(
    name = "coverage_lib",
    srcs = ["coverage.cpp"],
    hdrs = ["coverage.h"],
    deps = ["//greeting:greeting"],
)

cc_binary(
    name = "coverage",
    srcs = ["main.cpp"],
    deps = [
        ":coverage_lib",
    ],
)

cc_test(
    name = "coverage_test",
    srcs = ["coverage_test.cpp"],
    deps = [
        ":coverage_lib",
        "//greeting:greeting",
        "@googletest//:gtest",
        "@googletest//:gtest_main",
    ],
    size="small",
)

# Test suite for all components (individual tests)
test_suite(
    name = "all_tests",
    tests = [
        ":coverage_test",
    ],
)
