# Using the S-CORE Host GCC C++ Toolchains

This guide explains how to use the GCC C++ Toolchain provided in S-CORE GCC Toolchain repository. The toolchain supports Linux-based GCC cross-compilation and is designed to integrate easily into Bazel-based C++ projects. 

> NOTE: The support for WORKSPACE file servers only as backup for projects/modules that are currently migrating to bzlmod and such should not be used in newly established projects.

## Declaring the Toolchain as a Dependency (via bzlmod)

To include the toolchain in any project (module), a project needs to declare dependency to the toolchain. This is done by updating projects MODULE.bazel file:
```python
# MODULE.bazel

bazel_dep(name = "score_toolchains_gcc", version = "X.Y") # where the X and Y are version numbers.
```

## Declaring the Toolchain as a Dependency (via WORKSPACE)
To include the toolchain in any project, a project WORKSPACE file needs to collect all dependency which toolchain has:
```python
# WORKSPACE

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
http_archive(name = "score_toolchains_gcc", . . .)

load("@score_toolchains_gcc//:deps.bzl", "toolchain_gcc_dependencies")
toolchain_gcc_dependencies()
``` 

## Configuring the toolchain to a project needs
The `score_toolchains_gcc` module currently supports only GNU GCC version **12.2.0**. Support for multiple GCC versions is planned, with future versions expected to be selectable via an extended toolchain interface. As of now, version 12.2.0 is the sole supported target.

The module exposes an API that allows consumers to enable or disable specific toolchain behaviors related to compilation diagnostics.
By default, the toolchain activates the following features using predefined compiler flags:

1. Minimal warning flags — Enables a basic set of compiler warnings (e.g., `-Wall`) which cannot be disabled by consumers.
2. Strict warning flags — Enables a more aggressive set of warnings (e.g., `-Wextra`, `-Wpedantic`) which may be disabled by consumers if desired. 
3. A `treat warnings as errors` flags — Promotes all warnings to errors using -Werror and exceptions like -Wno-error=deprecated-declarations.

Consumers can modify features by adding or removing them in the module configuration.
To disable a feature, prefix its name with a dash (e.g., `-strict_warnings`).
However, the following features are protected and cannot be disabled:
- `minimal_warnings`
- `treat_warnings_as_errors`

When a feature is disabled, neither the default nor any user-defined flags associated with it will be applied.

Consumers can provide custom compiler warning flags through the additional_warnings feature.
This feature accepts a list of flags following any of these patterns: `-W<warning-name>`, `-Wno-<warning-name>`, and `-Wno-error=<warning-name>`.

Important restrictions:
- Warnings enabled by minimal_warnings cannot be disabled.
- Warnings enabled by -Wall cannot be disabled or converted back to non-errors.
- Attempts to use `-Wno-error` for any protected warning will fail.

To set wanted flags, the following API needs to be used:
```python
gcc = use_extension("@score_toolchains_gcc//extentions:gcc.bzl", "gcc")
gcc.extra_features(
    features = [
        "-strict_warnings",
        "additional_warnings"
    ],
)
gcc.warning_flags(
    additional_warnings = ["-Wno-bool-compare"],
)
use_repo(gcc, "gcc_toolchain", "gcc_toolchain_gcc")
```
* `extra_features` - Enables or disables features listed by the consumer.
* `warning_flags` - Sets additional compiler flags for the feature `additional_warnings` when it is enabled.

### Using WORKSPACE file
The same approuch needs to be done when configuring toolchain over WORKSPACE file:
```python
load("@score_toolchains_gcc//rules:gcc.bzl", "gcc_toolchain")
gcc_toolchain(
    name = "gcc_toolchain",
    gcc_repo = "gcc_toolchain_gcc",
    extra_features = [
        "-strict_warnings",
        "additional_warnings",
    ],
    warning_flags = {
        "additional_warnings": ["-Wno-bool-compare"],
    },
)
```

## Toolchain Registration
Toolchain registration can be performed either directly in a MODULE.bazel file or globally through .bazelrc.
When registering in MODULE.bazel:
```python
register_toolchains("@gcc_toolchain//:host_gcc_12")
```
Or when registering globally:
```bash
build --extra_toolchains=@gcc_toolchain//:host_gcc_12
```

## Example Usage
A minimal Bazel project demonstrating use of the toolchain can be found in the [test/](https://github.com/eclipse-score/toolchains_gcc/tree/main/bazel/test) directory of this module.

##  Compatibility
✅ Bazel version 6.x or newer (with Bzlmod enabled)

✅ Linux hosts

⚠️ Native support for macOS and Windows is currently not provided
