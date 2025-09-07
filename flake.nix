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
            sdkmanager
            openjdk11

            # Development tools
            which
            bash
            clang
            
            # D-Bus and related libraries
            dbus
            pkg-config

            # Necessary for secure storage on Linux
            libsecret
          ];

          shellHook = ''
            echo "Envoy Development Environment"
            echo "==========================================="
            echo "Rust: $(rustc --version)"
            echo "Flutter: $(flutter --version | head -1)"
            echo "Dart: $(dart --version)"

            # Flutter setup
            export FLUTTER_ROOT="${pkgs.flutter}"
            export PATH="$FLUTTER_ROOT/bin:$PATH"

            # Android setup
            export ANDROID_HOME="$HOME/Android/Sdk"
            export PATH="$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$PATH"

            echo ""
            echo "💡 Run 'flutter doctor' to check setup"
          '';
        };
      }
    );
}