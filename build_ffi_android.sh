#!/bin/bash

# SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Exit if anything fails
set -e

# Required for Cargo to build libtor-sys
export PATH=$PATH:$ANDROID_SDK_ROOT/ndk/25.1.8937393/toolchains/llvm/prebuilt/linux-x86_64/bin/

# Use specific Rust version
rustup install 1.64.0
rustup +1.64.0 target add aarch64-linux-android
cargo +1.64.0 build --target=aarch64-linux-android
cargo +1.64.0 build --target=aarch64-linux-android --release