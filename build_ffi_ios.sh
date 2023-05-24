#!/bin/bash

# SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Exit if anything fails
set -e

# iOS
rustup install 1.69.0
rustup +1.69.0 target add aarch64-apple-ios
cargo +1.69.0 build --target=aarch64-apple-ios
cargo +1.69.0 build --target=aarch64-apple-ios --release

# iOS simulator
# (This'll work when https://github.com/alexcrichton/openssl-src-rs/pull/131 is merged/released)
rustup +1.69.0 target add aarch64-apple-ios-sim
cargo +1.69.0 build --target=aarch64-apple-ios-sim

# Workaround to not being able to specify --crate-type=staticlib on a virtual package
# Having the dynamic libraries in these folders results in a runtime error
rm target/aarch64-apple-ios/debug/*.dylib
rm target/aarch64-apple-ios/release/*.dylib
rm target/aarch64-apple-ios-sim/debug/*.dylib

