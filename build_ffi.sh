#!/bin/bash

# SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Exit if anything fails
set -e

# Add all the supported target toolchains
rustup target add x86_64-unknown-linux-gnu
#rustup target add wasm32-unknown-unknown

# Create C bindings to help with the iOS integration
#if ! command -v cbindgen &> /dev/null
#then
#    cargo install cbindgen
#fi
#cbindgen ./native/ur-ffi/src/lib.rs -c cbindgen.toml | grep -v \#include >> ./bindings.h

# Compile for desktop
cargo build

# Generate Dart FFI for each package
cd packages
for package in *; do
  cd "$package"
  dart run ffigen
  cd ..
done
cd ..

# Compile for Android
./build_ffi_android.sh
./build_ffi_android_x86.sh

# Compile for macOS
if [[ $OSTYPE == 'darwin'* ]]; then
  rustup target add x86_64-apple-darwin
  cargo build --target=x86_64-apple-darwin

  rustup target add aarch64-apple-darwin
  cargo build --target=aarch64-apple-darwin

  ./build_ffi_ios.sh
fi

# Use gradle to build against the NDK for now, see how it works out
# cargo build --target=aarch64-linux-android

# Disable web for now

## Compile for web
#cargo build  --target=wasm32-unknown-unknown
#
## Move to web dir
#mkdir -p ./web/assets
#cp ./target/wasm32-unknown-unknown/debug/ur_ffi.wasm ./web/assets
#
#if ! command -v wasm-bindgen &> /dev/null
#then
#    cargo install wasm-bindgen-cli
#fi
#wasm-bindgen web/assets/ur_ffi.wasm --out-dir ./web/assets/ --target web
