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