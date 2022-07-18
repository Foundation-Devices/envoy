#!/bin/bash

# SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Exit if anything fails
set -e

# Add Android toolchain
rustup target add aarch64-linux-android

# Required for Cargo to build libtor-sys
export PATH=$PATH:$ANDROID_SDK_ROOT/ndk/22.1.7171670/toolchains/llvm/prebuilt/linux-x86_64/bin/
cargo build --target=aarch64-linux-android