# SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later
{
  description = "Rust + Flutter development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    fenix.url = "github:nix-community/fenix";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      fenix,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            android_sdk.accept_license = true;
          };
        };

        inherit (nixpkgs) lib;

        # Android SDK configuration
        androidComposition = pkgs.androidenv.composeAndroidPackages {
          cmdLineToolsVersion = "8.0";
          toolsVersion = "26.1.1";
          platformToolsVersion = "34.0.5";
          buildToolsVersions = [
            "30.0.3"
            "33.0.1"
            "34.0.0"
            "35.0.0"
          ];
          includeEmulator = false;
          emulatorVersion = "31.3.10";
          platformVersions = [
            "28"
            "29"
            "30"
            "31"
            "33"
            "34"
            "35"
            "36"
          ];
          includeSources = false;
          includeSystemImages = false;
          systemImageTypes = [ "google_apis_playstore" ];
          abiVersions = [ "arm64-v8a" ]; # Only 64-bit ARM
          cmakeVersions = [
            "3.10.2"
            "3.18.1"
            "3.22.1"
          ];
          includeNDK = true;
          ndkVersions = [
            "25.1.8937393"
            "27.0.12077973"
          ];
          useGoogleAPIs = false;
          useGoogleTVAddOns = false;
          includeExtras = [
            "extras;google;gcm"
          ];
        };

        darwinPackages =
          let
            xcodeenv = import (nixpkgs + "/pkgs/development/mobile/xcodeenv") { inherit (pkgs) callPackage; };
          in
          lib.optionals pkgs.stdenv.isDarwin [
            (xcodeenv.composeXcodeWrapper { versions = [ "16.0" ]; })
          ];

        rustToolchain = fenix.packages.${system}.fromToolchainFile {
          file = ./rust-toolchain.toml;
          sha256 = "sha256-SJwZ8g0zF2WrKDVmHrVG3pD2RGoQeo24MEXnNx5FyuI=";
        };

        # Localazy CLI wrapper using npx
        localazy-cli = pkgs.writeShellScriptBin "localazy" ''
          exec ${pkgs.nodejs}/bin/npx @localazy/cli "$@"
        '';

        buildInputs =
          with pkgs;
          [
            # Rust tools
            rustToolchain
            rust-bindgen

            # Flutter
            flutter
            dart
            android-tools
            flutter_rust_bridge_codegen
            jdk17

            # Development tools
            which
            bash
            clang
            cmake
            openssl
            llvm
            reuse
            go
            unzip
            nodejs

            # Localazy CLI
            localazy-cli

            # Build tools - multiStdenv provides better cross-compilation support
            gnumake
            pkg-config

            # pthread and threading support
            libpthread-stubs

            # D-Bus and related libraries
            dbus

            # Android SDK and NDK (for when you do need Android builds)
            androidComposition.androidsdk
          ]
          ++ lib.optionals (pkgs.stdenv.hostPlatform.system == "x86_64-linux") [
            # x86_64-linux specific packages
            android-studio

            # Essential C/C++ development libraries and headers
            glibc
            glibc.dev
            glibc.static
            multiStdenv.cc.cc.lib
            libcxx

            # Add 32-bit libraries for cross-compilation support
            pkgsi686Linux.glibc
            pkgsi686Linux.glibc.dev

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

            # Text processing and internationalization libraries
            libthai
            libthai.dev
            libdatrie
            libdatrie.dev

            # Cryptographic libraries
            libgcrypt
            libgcrypt.dev
            libgpg-error
            libgpg-error.dev

            # X11 libraries for GUI support
            xorg.libXdmcp
            xorg.libXdmcp.dev

            # Add xkbcommon for keyboard input handling
            libxkbcommon
            libxkbcommon.dev

            # Compression libraries
            libdeflate
            lerc
            lerc.dev
            xz
            xz.dev
            zstd
            zstd.dev

            # System utilities
            util-linux
            util-linux.dev
            libselinux
            libselinux.dev
            libsepol
            libsepol.dev
            libwebp

            # Add SQLite and PCRE2 for Rust dependencies
            sqlite
            sqlite.dev
            pcre2
            pcre2.dev
          ]
          ++ darwinPackages;
      in
      {
        customPackages = buildInputs;
        devShells.default = pkgs.mkShell {
          inherit buildInputs;
          shellHook = ''
            echo "Envoy Development Environment"
            echo "==========================================="
            echo "Rust: $(rustc --version)"
            echo "Flutter: $(flutter --version | head -1)"
            echo "Dart: $(dart --version)"
            echo "Java: $(java --version)"

            # Flutter setup
            export FLUTTER_ROOT="${pkgs.flutter}"
            export PATH="$FLUTTER_ROOT/bin:$PATH"

            # Remove rustup from PATH to use Nix Rust
            export PATH=$(echo $PATH | tr ':' '\n' | grep -v ".cargo/bin" | tr '\n' ':')

            # darwin xcode
            ${lib.optionalString pkgs.stdenv.isDarwin "unset DEVELOPER_DIR && unset SDKROOT"}
            ${lib.optionalString pkgs.stdenv.isDarwin "export DEVELOPER_DIR=\"$(xcode-select -p)\""}

            # Android SDK and NDK configuration
            export ANDROID_SDK_ROOT="${androidComposition.androidsdk}/libexec/android-sdk"
            export ANDROID_HOME="$ANDROID_SDK_ROOT"
            export ANDROID_NDK_ROOT="$ANDROID_SDK_ROOT/ndk/25.1.8937393"
            export NDK_HOME="$ANDROID_NDK_ROOT"

            # Add Android tools to PATH
            export PATH="$ANDROID_SDK_ROOT/tools:$ANDROID_SDK_ROOT/tools/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH"
          '';
        };
      }
    );
}
