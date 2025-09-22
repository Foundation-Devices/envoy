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
            android_sdk.accept_license = true;
          };
        };

        # Android SDK configuration
        androidComposition = pkgs.androidenv.composeAndroidPackages {
          cmdLineToolsVersion = "8.0";
          toolsVersion = "26.1.1";
          platformToolsVersion = "34.0.5";
          buildToolsVersions = [ "30.0.3" "33.0.1" "34.0.0" "35.0.0" ];
          includeEmulator = false;
          emulatorVersion = "31.3.10";
          platformVersions = [ "28" "29" "30" "31" "33" "34" "35" "36" ];
          includeSources = false;
          includeSystemImages = false;
          systemImageTypes = [ "google_apis_playstore" ];
          abiVersions = [ "armeabi-v7a" "arm64-v8a" ];
          cmakeVersions = [ "3.10.2" "3.18.1" "3.22.1" ];
          includeNDK = true;
          ndkVersions = [ "25.1.8937393" "27.0.12077973" ];
          useGoogleAPIs = false;
          useGoogleTVAddOns = false;
          includeExtras = [
            "extras;google;gcm"
          ];
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
            rust-bindgen

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
            go

            # Build tools - Essential for CMake
            gnumake
            gcc
            binutils

            # 32-bit development headers for gnu/stubs-32.h
            glibc.dev
            glibc_multi.dev

            # pthread and threading support
            libpthread-stubs

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

            # Android SDK and NDK
            androidComposition.androidsdk
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

            # Flutter setup - use Flutter from the PR
            export FLUTTER_ROOT="${pkgs.flutter}"
            export PATH="$FLUTTER_ROOT/bin:$PATH"

            # Set LLVM path for ffigen
            export LLVM_PATH="${pkgs.libclang.lib}/lib/libclang.so"

            # Android SDK and NDK configuration
            export ANDROID_SDK_ROOT="${androidComposition.androidsdk}/libexec/android-sdk"
            export ANDROID_HOME="$ANDROID_SDK_ROOT"
            export ANDROID_NDK_ROOT="$ANDROID_SDK_ROOT/ndk/25.1.8937393"
            export NDK_HOME="$ANDROID_NDK_ROOT"
            
            # Add Android tools to PATH
            export PATH="$ANDROID_SDK_ROOT/tools:$ANDROID_SDK_ROOT/tools/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH"
            
            # Set CMAKE_MAKE_PROGRAM to fix the build program issue
            #export CMAKE_MAKE_PROGRAM="${pkgs.gnumake}/bin/make"

            echo "Android SDK: $ANDROID_SDK_ROOT"
            echo "Android NDK: $ANDROID_NDK_ROOT"
            echo "CMake Make Program: $CMAKE_MAKE_PROGRAM"

            echo ""
            echo "💡 Run 'flutter doctor' to check setup"
          '';
        };
      }
    );
}