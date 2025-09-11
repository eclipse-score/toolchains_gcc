# Examples of Minimal Bazel project using GNU GCC host toolchain with different config settings

### Building code host gcc toolchain

```bash
bazel build //:main_cpp
```

### Building code arm64 gcc toolchain
```bash
bazel build --config=arm64 //:main_cpp
#or 
bazel build --config=aarch64 //:main_cpp
```

### Building code with host gcc toolchain and enabled pthread

```bash
bazel build //:main_pthread_cpp --features=use_pthread
```

