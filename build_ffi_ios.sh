#!/bin/bash

# Exit if anything fails
set -e

# iOS
rustup target add aarch64-apple-ios
cargo build --target=aarch64-apple-ios

# iOS simulator
# (This'll work when https://github.com/alexcrichton/openssl-src-rs/pull/131 is merged/released)
#rustup target add aarch64-apple-ios-sim
#cargo build --target=aarch64-apple-ios-sim