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

        # Keep Flutter explicit even though the package comes from pinned nixpkgs.
        # Bump this alongside flake.lock when intentionally updating Flutter.
        flutterVersion = "3.44.2";
        flutterPinned =
          assert lib.assertMsg (pkgs.flutter.version == flutterVersion)
            "Expected Flutter ${flutterVersion}, but nixpkgs provides ${pkgs.flutter.version}. Update flutterVersion or pin nixpkgs to a matching revision.";
          pkgs.flutter;
        flutterRustBridgeCodegen = pkgs.flutter_rust_bridge_codegen.overrideAttrs (_: rec {
          version = "2.11.1";
          src = pkgs.fetchFromGitHub {
            owner = "fzyzcjy";
            repo = "flutter_rust_bridge";
            tag = "v${version}";
            hash = "sha256-Us+LwT6tjBcTl2xclVsiLauSlIO8w+PiokpiDB+h1fI=";
            fetchSubmodules = true;
          };
          cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
            inherit src;
            hash = "sha256-pxEwcLiRB95UBfXb+JgS8duEXiZUApH/C8Exus5TkfU=";
          };
        });

        # Android SDK configuration
        androidComposition = pkgs.androidenv.composeAndroidPackages {
          cmdLineToolsVersion = "8.0";
          toolsVersion = "26.1.1";
          platformToolsVersion = "35.0.2";
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
            "28.2.13676358"
          ];
          useGoogleAPIs = false;
          useGoogleTVAddOns = false;
          includeExtras = [
            "extras;google;gcm"
          ];
        };

        # Nixpkgs adds legacy i686 compatibility libraries to every Android
        # build-tools package on x86_64 Linux. The current Android tools are
        # 64-bit, and Docker Desktop's Rosetta backend cannot build i686 Nix
        # derivations. Keep the regular development SDK unchanged, but avoid
        # those unused compatibility derivations in the canonical container.
        reproducibleAndroidPkgs = pkgs.extend (final: previous: {
          pkgsi686Linux = previous.pkgsi686Linux // {
            inherit (final) glibc zlib ncurses5;
          };
        });
        reproducibleAndroidEnv = reproducibleAndroidPkgs.callPackage
          (nixpkgs + "/pkgs/development/mobile/androidenv/default.nix")
          { pkgs = reproducibleAndroidPkgs; };
        reproducibleAndroidComposition = reproducibleAndroidEnv.composeAndroidPackages {
          cmdLineToolsVersion = "8.0";
          # The obsolete pre-cmdline SDK tools bundle contains 32-bit Linux
          # binaries. Flutter and Gradle only require cmdline-tools here.
          toolsVersion = null;
          platformToolsVersion = "35.0.2";
          buildToolsVersions = [
            "30.0.3"
            "33.0.1"
            "34.0.0"
            "35.0.0"
          ];
          includeEmulator = false;
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
          abiVersions = [ "arm64-v8a" ];
          cmakeVersions = [
            "3.10.2"
            "3.18.1"
            "3.22.1"
          ];
          includeNDK = true;
          ndkVersions = [
            "25.1.8937393"
            "27.0.12077973"
            "28.2.13676358"
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
          sha256 = "sha256-2eWc3xVTKqg5wKSHGwt1XoM/kUBC6y3MWfKg74Zn+fY=";
        };
        reproducibleRustToolchain = fenix.packages.${system}.fromToolchainFile {
          file = builtins.toFile "envoy-reproducible-rust-toolchain.toml" ''
            [toolchain]
            channel = "1.91.0"
            profile = "minimal"
            targets = ["aarch64-linux-android"]
          '';
          sha256 = "sha256-2eWc3xVTKqg5wKSHGwt1XoM/kUBC6y3MWfKg74Zn+fY=";
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

        flutter-wrapper = pkgs.writeShellScriptBin "flutter" ''
          if [ "$(uname -s)" = "Darwin" ]; then
            export FLUTTER_ROOT="${flutterPinned}"
            export PATH="${flutterPinned}/bin:${rustToolchain}/bin:${rustup-shim}/bin:${pkgs.rsync}/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

            # Keep Xcode/SwiftPM on Apple's compiler toolchain while still using
            # the Nix-provided Flutter, Rust, and GNU rsync binaries.
            unset NIX_CFLAGS_COMPILE NIX_CFLAGS_COMPILE_FOR_TARGET
            unset NIX_LDFLAGS NIX_LDFLAGS_FOR_TARGET
            unset CC CXX LD AR AS NM RANLIB STRIP OBJCOPY OBJDUMP SIZE
          fi

          exec ${flutterPinned}/bin/flutter "$@"
        '';

        reproducibleFlutterWrapper = pkgs.writeShellScriptBin "flutter" ''
          exec ${flutterPinned}/bin/flutter "$@"
        '';

        # rive_native invokes the BSD/macOS-style `shasum -a 512` command
        # while downloading its pinned Android artifacts. Minimal Linux images
        # provide GNU sha512sum instead, so expose the interface Rive expects
        # without adding an unpinned host dependency.
        shasumCompat = pkgs.writeShellScriptBin "shasum" ''
          set -eu

          algorithm=1
          if [ "''${1:-}" = "-a" ]; then
            [ $# -ge 2 ] || {
              echo "shasum: -a requires an algorithm" >&2
              exit 2
            }
            algorithm=$2
            shift 2
          fi

          case "$algorithm" in
            1|224|256|384|512) ;;
            *)
              echo "shasum: unsupported algorithm: $algorithm" >&2
              exit 2
              ;;
          esac

          exec ${pkgs.coreutils}/bin/sha"$algorithm"sum "$@"
        '';

        buildInputs =
          with pkgs;
          [
            # Rust tools
            rustToolchain
            rustup-shim # fake rustup for Cargokit (see shim definition above)
            rust-bindgen
            cargo-expand

            # Flutter
            flutter-wrapper
            flutterPinned
            dart
            android-tools
            bundletool
            flutterRustBridgeCodegen
            jdk17
            python3

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
            # Flutter's iOS build uses rsync --chmod before codesigning frameworks.
            # GNU rsync honors it; Apple's openrsync can leave Nix-store copies read-only.
            rsync

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

        # Keep the canonical Android environment free of desktop Linux,
        # Android Studio, and 32-bit host dependencies. Besides reducing the
        # public verifier download, this allows linux/amd64 Nix to run through
        # Rosetta on Apple silicon without requesting a 32-bit personality.
        reproducibleAndroidInputs =
          with pkgs;
          [
            reproducibleRustToolchain
            rustup-shim
            rust-bindgen
            reproducibleFlutterWrapper
            flutterPinned
            dart
            android-tools
            bundletool
            jdk17
            python3
            git
            which
            bash
            clang
            cmake
            openssl
            perl
            llvm
            unzip
            rsync
            shasumCompat
            gnumake
            pkg-config
            reproducibleAndroidComposition.androidsdk
          ]
          ++ lib.optionals (pkgs.stdenv.hostPlatform.system == "x86_64-linux") [
            glibc
            glibc.dev
            glibc.static
            libcxx
            sqlite
            sqlite.dev
            pcre2
            pcre2.dev
          ];
      in
      {
        customPackages = buildInputs;
        devShells.default = pkgs.mkShell {
          inherit buildInputs;
          shellHook = ''
            # Flutter setup
            export FLUTTER_ROOT="${flutterPinned}"
            export PATH="${flutter-wrapper}/bin:$FLUTTER_ROOT/bin:$PATH"

            # Remove rustup from PATH to use Nix Rust
            export PATH=$(echo $PATH | tr ':' '\n' | grep -v ".cargo/bin" | tr '\n' ':')

            echo "Envoy Development Environment"
            echo "==========================================="
            echo "Rust: $(rustc --version)"
            echo "Flutter: $(flutter --version | head -1)"
            echo "Dart: $(dart --version)"
            echo "Java: $(java --version)"

            # darwin xcode
            ${lib.optionalString pkgs.stdenv.isDarwin "unset DEVELOPER_DIR DEVELOPER_DIR_FOR_TARGET SDKROOT SDKROOT_FOR_TARGET"}
            ${lib.optionalString pkgs.stdenv.isDarwin "export DEVELOPER_DIR=\"$(xcode-select -p)\""}
            ${lib.optionalString pkgs.stdenv.isDarwin "export CARGO_TARGET_AARCH64_APPLE_DARWIN_LINKER=/usr/bin/clang"}

            # Android SDK and NDK configuration
            export ANDROID_SDK_ROOT="${androidComposition.androidsdk}/libexec/android-sdk"
            export ANDROID_HOME="$ANDROID_SDK_ROOT"
            export ANDROID_NDK_ROOT="$ANDROID_SDK_ROOT/ndk/25.1.8937393"
            export NDK_HOME="$ANDROID_NDK_ROOT"

            # Add Android tools to PATH
            # Prefer current build tools and Nix's SDK wrappers. Keep the
            # legacy tools directories last so their Java-8-only apkanalyzer
            # cannot shadow the Java-17-compatible wrapper.
            export PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/build-tools/35.0.0:$ANDROID_SDK_ROOT/platform-tools:$PATH:$ANDROID_SDK_ROOT/tools:$ANDROID_SDK_ROOT/tools/bin"
          '';
        };

        devShells.reproducibleAndroid = pkgs.mkShell {
          buildInputs = reproducibleAndroidInputs;
          shellHook = ''
            export FLUTTER_ROOT="${flutterPinned}"
            export PATH="${reproducibleFlutterWrapper}/bin:$FLUTTER_ROOT/bin:$PATH"
            export PATH=$(echo $PATH | tr ':' '\n' | grep -v ".cargo/bin" | tr '\n' ':')

            export ANDROID_SDK_ROOT="${reproducibleAndroidComposition.androidsdk}/libexec/android-sdk"
            export ANDROID_HOME="$ANDROID_SDK_ROOT"
            export ANDROID_NDK_ROOT="$ANDROID_SDK_ROOT/ndk/28.2.13676358"
            export NDK_HOME="$ANDROID_NDK_ROOT"
            export PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/build-tools/35.0.0:$ANDROID_SDK_ROOT/platform-tools:$PATH:$ANDROID_SDK_ROOT/tools:$ANDROID_SDK_ROOT/tools/bin"
          '';
        };
      }
    );
}
