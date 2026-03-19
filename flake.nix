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

        # Fake rustup shim so Cargokit doesn't explode on CI.
        #
        # Cargokit (the Flutter<->Rust bridge build tool) hardcodes calls to
        # `rustup` everywhere: resolving the binary, listing toolchains/targets,
        # and running builds via `rustup run <toolchain> cargo build ...`.
        # Since we use fenix (Nix-managed Rust), there's no real rustup.
        #
        # This shim pretends to be rustup just enough to keep Cargokit happy:
        #   - "toolchain list/install" -> reports "stable" as installed
        #   - "target list --installed" -> discovers targets from the Nix sysroot
        #   - "target add / component add" -> no-ops (Nix already has everything)
        #   - "run <toolchain> <cmd> <args...>" -> drops the rustup wrapper and
        #     just execs the command directly with Nix-provided tools
        rustup-shim = pkgs.writeShellScriptBin "rustup" ''
          case "''${1:-}" in
            # Cargokit calls `rustup toolchain list` to discover installed
            # toolchains, then filters for lines starting with
            # "stable|beta|nightly". We report "stable" so it's satisfied.
            toolchain)
              case "''${2:-}" in
                list)
                  echo "stable (default)"
                  exit 0
                  ;;
                install)
                  # Already managed by Nix, nothing to do.
                  echo "rustup shim: toolchain already provided by Nix, skipping install"
                  exit 0
                  ;;
              esac
              ;;

            # Cargokit calls `rustup target list --toolchain <t> --installed`
            # to check which cross-compilation targets are available.
            # We look at the actual Nix sysroot to report real installed targets.
            target)
              case "''${2:-}" in
                list)
                  sysroot=$(rustc --print sysroot)
                  # Each installed target has a lib dir under sysroot/lib/rustlib/<triple>/
                  for dir in "$sysroot"/lib/rustlib/*/lib; do
                    if [ -d "$dir" ]; then
                      basename "$(dirname "$dir")"
                    fi
                  done
                  exit 0
                  ;;
                add)
                  # Already managed by Nix, nothing to do.
                  echo "rustup shim: target already provided by Nix, skipping add"
                  exit 0
                  ;;
              esac
              ;;

            # Cargokit calls `rustup component add rust-src --toolchain nightly`
            # for -Z build-std support. Nix already includes rust-src if specified
            # in rust-toolchain.toml, so this is a no-op.
            component)
              echo "rustup shim: component already provided by Nix, skipping"
              exit 0
              ;;

            # This is the big one. Cargokit runs all builds through:
            #   rustup run <toolchain> cargo build <args...>
            # We just strip "run <toolchain>" and exec the rest directly,
            # since Nix already has the right cargo/rustc on PATH.
            run)
              shift  # drop "run"
              shift  # drop toolchain name (e.g. "stable")
              exec "$@"
              ;;
          esac

          echo "rustup shim: unhandled command: $*" >&2
          exit 1
        '';

        buildInputs =
          with pkgs;
          [
            # Rust tools
            rustToolchain
            rustup-shim # fake rustup for Cargokit (see shim definition above)
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
