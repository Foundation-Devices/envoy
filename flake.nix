# SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

{
  description = "Rust + Flutter development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
        };
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Rust tools
            rustup
            rustc
            cargo
            rustfmt
            clippy
            rust-analyzer

            # Flutter
            flutter
            dart
            android-studio
            android-tools
            flutter_rust_bridge_codegen

            # Development tools
            which
            bash
            clang
            cmake
            openssl
            llvm
            reuse
            jdk17

            # D-Bus and related libraries
            dbus
            pkg-config

            # Necessary for secure storage on Linux
            libsecret
            libsecret.dev

            # Linux build GUI
            glib
            gtk3
            libsysprof-capture

            # Linux build QR scanning
            zbar

            # Linux build storage
            xdg-user-dirs
          ];

          shellHook = ''
            echo "Envoy Development Environment"
            echo "==========================================="
            echo "Rust: $(rustc --version)"
            echo "Flutter: $(flutter --version | head -1)"
            echo "Dart: $(dart --version)"

            # Set JAVA_HOME explicitly
            export JAVA_HOME="${pkgs.jdk17}"
            export ANDROID_JAVA_HOME="$JAVA_HOME"
            echo "Java: $(java --version)"

            # Flutter setup
            export FLUTTER_ROOT="${pkgs.flutter}"
            export PATH="$FLUTTER_ROOT/bin:$PATH"

            # Android setup
            export ANDROID_HOME="$HOME/Android/Sdk"
            export ANDROID_SDK_ROOT="$ANDROID_HOME"
            export ANDROID_NDK_ROOT="$ANDROID_HOME/ndk/24.0.8215888"

            # Configure Flutter to use our chosen JDK
            flutter config --jdk-dir="${pkgs.jdk17}"

            # Set LLVM path for ffigen
            export LLVM_PATH="${pkgs.libclang.lib}/lib/libclang.so"

            echo ""
            echo "💡 Run 'flutter doctor' to check setup"
          '';
        };
      }
    );
}