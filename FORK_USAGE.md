# Using the ARM64-enabled Fork

This fork includes:
- ARM64 (aarch64) platform support
- Default toolchains pointing to `skarlsson/toolchains_gcc_packages` v0.0.2-pr3
- Both x86_64 and aarch64 GCC 12 toolchains

Until these changes are merged into the official SCORE toolchains_gcc, you can use this fork locally.

## Step 1: Clone the fork and checkout the ARM64 branch

```bash
# As a submodule
git submodule add -b arm64-from-prebuilt https://github.com/skarlsson/toolchains_gcc.git

# Or clone directly
git clone -b arm64-from-prebuilt https://github.com/skarlsson/toolchains_gcc.git
```

## Step 2: Configure MODULE.bazel

```python
module(
    name = "your_project",
    version = "0.0.1",
)

# Declare dependency on the version this fork is based on
bazel_dep(name = "score_toolchains_gcc", version = "0.5")

# Override with the local fork (e.g., cloned as submodule)
local_path_override(
    module_name = "score_toolchains_gcc",
    path = "path/to/toolchains_gcc",  # Adjust path to where you cloned the fork
)

# Use the extension - default toolchains are automatically configured
gcc = use_extension("@score_toolchains_gcc//extentions:gcc.bzl", "gcc")

# Optional: Configure warning flags and features (see test/MODULE.bazel for examples)
# gcc.warning_flags(...)
# gcc.extra_features(...)

use_repo(gcc, "gcc_toolchain_x86_64", "gcc_toolchain_aarch64")

# Register toolchains
register_toolchains(
    "@gcc_toolchain_x86_64//:host_gcc_12",
    "@gcc_toolchain_aarch64//:host_gcc_12",
)
```

## Step 3: Configure .bazelrc

Add to your project's `.bazelrc`:

```bash
# ARM64/AArch64 build configurations
build:arm64 --platforms=@score_toolchains_gcc//platforms:aarch64-linux
build:aarch64 --platforms=@score_toolchains_gcc//platforms:aarch64-linux

# Optional: explicit x86_64 configuration
build:x86_64 --platforms=@score_toolchains_gcc//platforms:x86_64-linux
```

## Step 4: Build

```bash
# For ARM64
bazel build --config=arm64 //your:target
# or
bazel build --config=aarch64 //your:target

# For x86_64 (default)
bazel build //your:target
# or explicitly
bazel build --config=x86_64 //your:target
```

## Switching back to official release

Once ARM64 support is merged and published, simply:
1. Remove the `archive_override` block
2. Update the version in `bazel_dep` to the new release
3. Keep your .bazelrc configurations - they'll continue to work!