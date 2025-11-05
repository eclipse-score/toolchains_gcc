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

1. Minimal warning flags — enables a basic set of compiler warnings (e.g., `-Wall, -Wextra`)
2. Strict warning flags — enables a more aggressive set of warnings (e.g., `-Wpedantic`)
3. A `treat warnings as errors` flags — promotes all warnings to errors (e.g., `-Werror`)

Consumers can disable any of these features by prefixing the feature name with a dash (e.g., `-minimal_warnings`). When a feature is disabled this way, neither the default nor any user-defined flags associated with it will be applied.
Additionally, consumers can adjust the compiler's warning behavior by adding custom flags or disabling specific warnings using the `-Wno-` prefix.
These features provide fine-grained control over the compiler's warning policy.

To set wanted flags, the following API needs to be used:
```python
gcc = use_extension("@score_toolchains_gcc//extentions:gcc.bzl", "gcc")
gcc.extra_features(
    features = [
        "minimal_warnings",
        "-treat_warnings_as_errors",
    ],
)
gcc.warning_flags(
    minimal_warnings = ["-Wno-error=deprecated-declarations"],
    strict_warnings = ["-Wno-bool-compare"],
    treat_warnings_as_errors = ["-Werror"],
)
use_repo(gcc, "gcc_toolchain", "gcc_toolchain_gcc")
```
* `extra_features` - Enables or disables features listed by the consumer.
* `warning_flags` - Sets compiler flags for the features that are currently enabled.

### Using WORKSPACE file
The same approuch needs to be done when configuring toolchain over WORKSPACE file:
```python
load("@score_toolchains_gcc//rules:gcc.bzl", "gcc_toolchain")
gcc_toolchain(
    name = "gcc_toolchain",
    gcc_repo = "gcc_toolchain_gcc",
    extra_features = [
        "minimal_warnings",
        "-treat_warnings_as_errors",
    ],
    warning_flags = {
        "minimal_warnings": ["-Wno-error=deprecated-declarations"],
        "strict_warnings": ["-Wno-bool-compare"],
        "treat_warnings_as_errors": ["-Werror"],
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
