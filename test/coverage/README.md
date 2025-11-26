Sample to generate coverage data
================================

This directory contains a sample C++ project with test coverage capabilities using Bazel and GCC's gcov/lcov tools.

## Prerequisites

Ensure you have the following tools installed:
- Bazel
- lcov (Linux Test Project coverage tools)

On Ubuntu/Debian:
```bash
sudo apt-get install lcov
```

## Running Tests with Coverage

### Step 1: Run tests with coverage collection

To generate coverage data for the `all_tests` target, run:

```bash
$ bazel coverage --combined_report=lcov --subcommands -- //:all_tests
```

### Step 2: View coverage summary with lcov

To get a quick coverage summary using lcov, you need to find the generated coverage files and use lcov:

```bash
$ lcov --summary --rc branch_coverage=1 bazel-out/_coverage/_coverage_report.dat
Summary coverage rate:
  lines......: 100.0% (10 of 10 lines)
  functions..: 100.0% (2 of 2 functions)
  branches...: 100.0% (4 of 4 branches)
```

Alternatively, you can use the coverage files directly from the bazel-out directory:

```bash
# Find all .gcno and .gcda files
find -L bazel-out/ -name "*.gcda" -o -name "*.gcno" | head -10

# Generate coverage info file
lcov --capture --directory bazel-out --output-file coverage.info

# Show coverage summary
lcov --summary coverage.info
```
