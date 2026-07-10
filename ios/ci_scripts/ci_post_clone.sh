#!/usr/bin/env bash

set -euo pipefail

FLUTTER_VERSION="3.44.2"
FLUTTER_DIR="$HOME/flutter"
IOS_RUST_TARGET="aarch64-apple-ios"

# The default execution directory of this script is the ci_scripts directory.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="${CI_WORKSPACE:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
cd "$REPO_ROOT"

RUST_TOOLCHAIN="$(awk -F '"' '/^channel =/ { print $2; exit }' rust-toolchain.toml)"
if [[ -z "$RUST_TOOLCHAIN" ]]; then
  echo "Unable to read Rust toolchain channel from rust-toolchain.toml" >&2
  exit 1
fi

# Install Flutter using the same pinned version as the repo's Nix environment.
if [[ -d "$FLUTTER_DIR/.git" ]]; then
  git -C "$FLUTTER_DIR" fetch --depth 1 origin "$FLUTTER_VERSION"
  git -C "$FLUTTER_DIR" checkout --force FETCH_HEAD
else
  git clone https://github.com/flutter/flutter.git --depth 1 -b "$FLUTTER_VERSION" "$FLUTTER_DIR"
fi

export PATH="$FLUTTER_DIR/bin:$PATH"

# Install Flutter artifacts and dependencies needed by the Xcode archive.
flutter precache --ios
flutter pub get

# Install native build dependencies.
export HOMEBREW_NO_AUTO_UPDATE=1
brew install cocoapods automake libtool curl

# Install Rust and honor the repo-pinned toolchain for Cargokit during archive.
if [[ ! -x "$HOME/.cargo/bin/rustup" ]]; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain "$RUST_TOOLCHAIN"
fi
export PATH="$HOME/.cargo/bin:$PATH"

rustup toolchain install "$RUST_TOOLCHAIN"
rustup default "$RUST_TOOLCHAIN"
rustup component add rust-src --toolchain "$RUST_TOOLCHAIN"
rustup target add "$IOS_RUST_TARGET" --toolchain "$RUST_TOOLCHAIN"

# Install CocoaPods dependencies.
pod install --project-directory=ios

# Generate Flutter's Xcode configuration without doing Xcode Cloud's archive work twice.
flutter build ios --release --config-only
