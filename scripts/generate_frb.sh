#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later
set -e

# Check for fvm based flutter installation
if command -v fvm &> /dev/null; then
    FLUTTER="fvm flutter"
    echo "FVM detected, using fvm flutter"
else
    FLUTTER="flutter"
fi

echo "using flutter $FLUTTER"
# Define packages that need FRB generation
PACKAGES=(
#    "packages/foundation_api"
#    "packages/ngwallet"
    "packages/bluart"
#    "packages/shards"
#    "packages/http_tor"
)

for PACKAGE_DIR in "${PACKAGES[@]}"; do
    echo "Generating bindings for $PACKAGE_DIR..."

    cd "$PACKAGE_DIR"
    # get pub packages
    if command -v fvm &> /dev/null; then
        fvm flutter pub get
    else
        flutter pub get
    fi

    echo "Removing old generated files..."
    rm -f rust/frb_generated.rs
    rm -rf lib/src/rust
    mkdir -p lib/src/rust

    # Generate FRB
    flutter_rust_bridge_codegen generate

    echo "Building Rust library..."
    cargo build --manifest-path=rust/Cargo.toml

    # if pubspec.yaml contains build_runner, run build_runner
    if [ -f "pubspec.yaml" ] && grep -E "^\s*build_runner:" pubspec.yaml; then
         echo "Running build_runner..."
        if command -v fvm &> /dev/null; then
            fvm flutter pub run build_runner build --delete-conflicting-outputs
            fvm dart format .
        else
            flutter pub run build_runner build --delete-conflicting-outputs
            dart format .
        fi
    fi

    echo "Formatting generated files..."

    # Return to root directory
    cd - > /dev/null

    echo "Completed $PACKAGE_DIR"
done

echo "FRB generated successfully!"


