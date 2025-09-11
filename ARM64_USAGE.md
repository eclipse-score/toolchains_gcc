## Using aarch64/arm64 toolchain

### In your MODULE.bazel:

```python
bazel_dep(name = "score_toolchains_gcc", version = "0.0.7")

gcc = use_extension("@score_toolchains_gcc//extentions:gcc.bzl", "gcc")
# Default toolchains for x86_64 and aarch64 are automatically configured

use_repo(gcc, "gcc_toolchain_x86_64", "gcc_toolchain_aarch64")
register_toolchains(
    "@gcc_toolchain_x86_64//:host_gcc_12",
    "@gcc_toolchain_aarch64//:host_gcc_12",
)
```

### Building for arm64:

Add to your project's `.bazelrc`:
```
# ARM64 build configuration
build:arm64 --platforms=@score_toolchains_gcc//platforms:aarch64-linux
build:aarch64 --platforms=@score_toolchains_gcc//platforms:aarch64-linux
```

Then build with:
```bash
# Using the config
bazel build --config=arm64 //your:target
# or
bazel build --config=aarch64 //your:target

# Direct platform specification (without .bazelrc)
bazel build --platforms=@score_toolchains_gcc//platforms:aarch64-linux //your:target
```

## Example

See the `test/` directory for a complete working example that supports both x86_64 and aarch64 builds.
