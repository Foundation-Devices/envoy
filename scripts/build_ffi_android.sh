#!/bin/bash

# SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Exit if anything fails
set -e

API_LEVEL=30

 UNAME=$(uname)
 case "$UNAME" in
   Darwin)
     NDK_HOST="darwin-x86_64"
     ;;
   Linux)
     NDK_HOST="linux-x86_64"
     ;;
   MINGW*|MSYS*|CYGWIN*|Windows_NT)
     NDK_HOST="windows-x86_64"
     ;;
   *)
     echo "Unsupported OS: $UNAME"
     exit 1
     ;;
 esac

if [ -z "$ANDROID_NDK_ROOT" ]; then
  echo "ANDROID_NDK_ROOT not found."
  exit 1
fi

export PATH="$PATH:$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/$NDK_HOST/bin"
export CC="$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/$NDK_HOST/bin/aarch64-linux-android$API_LEVEL-clang"
export CXX="$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/$NDK_HOST/bin/aarch64-linux-android$API_LEVEL-clang++"
export AR="$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/$NDK_HOST/bin/llvm-ar"

rustup target add aarch64-linux-android
cargo build --target=aarch64-linux-android
cargo build --target=aarch64-linux-android --release