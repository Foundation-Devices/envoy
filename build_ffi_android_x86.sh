#!/bin/bash

# SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Exit if anything fails
set -e

# Add Android toolchain
rustup target add x86_64-linux-android

# Required for Cargo to build libtor-sys
export PATH=$PATH:$ANDROID_SDK_ROOT/ndk/25.1.8937393/toolchains/llvm/prebuilt/linux-x86_64/bin/
cargo build --target=x86_64-linux-android