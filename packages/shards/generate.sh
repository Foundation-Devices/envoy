#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2025 Foundation Devices Inc
# SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

rm rust/frb_generated.rs
rm lib/src/rust -r
mkdir -p lib/src/rust

set -e

flutter_rust_bridge_codegen generate
cargo build --manifest-path=rust/Cargo.toml

flutter pub run build_runner build --delete-conflicting-outputs