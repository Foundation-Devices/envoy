#!/bin/bash

# SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Exit if anything fails
set -e

# macOS
if [[ $OSTYPE == 'darwin'* ]]; then
  rustup +1.69.0 target add aarch64-apple-darwin
  cargo +1.69.0 build --target=aarch64-apple-darwin

  ./build_ffi_ios.sh

  exit 0
fi

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

# TODO: find a way to fix this:
# For some reason cbindgen generates a full-blown C++ templated type for a raw pointer to a Rust Mutex
# I reckon it should output an opaque pointer instead. Not sure why it's doing this. It's set to C
# Using this workaround for now:
sed -i 's/Mutex<Wallet<Tree>>/const char/g' packages/wallet/native/wallet-ffi/target/wallet-ffi.hpp

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
