#!/bin/bash

# SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Exit if anything fails
set -e

# Required for Cargo to build libtor-sys
export PATH=$PATH:$ANDROID_SDK_ROOT/ndk/24.0.8215888/toolchains/llvm/prebuilt/linux-x86_64/bin/
export AR=llvm-ar
export RANLIB=llvm-ranlib
export CC=aarch64-linux-android30-clang
export CXX=aarch64-linux-android30-clang++

rustup target add aarch64-linux-android
cargo build --target=aarch64-linux-android
cargo build --target=aarch64-linux-android --release