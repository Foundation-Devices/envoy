#!/bin/bash

# SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Exit if anything fails
set -e

# iOS
rustup target add aarch64-apple-ios
cargo build --target=aarch64-apple-ios

# iOS simulator
# (This'll work when https://github.com/alexcrichton/openssl-src-rs/pull/131 is merged/released)
#rustup target add aarch64-apple-ios-sim
#cargo build --target=aarch64-apple-ios-sim