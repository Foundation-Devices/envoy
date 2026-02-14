<!-- SPDX-FileCopyrightText: 2026 Foundation Devices Inc. -->
<!-- SPDX-License-Identifier: GPL-3.0-or-later -->

# Envoy

Envoy is a companion app for the Passport hardware wallet. To learn more visit [foundation.xyz/envoy](https://foundation.xyz/envoy/)

## Project Overview

Envoy is a Bitcoin wallet Flutter application with Rust backend libraries for cryptographic operations. The codebase uses Flutter Rust Bridge (FRB) to connect Dart and Rust code.

## Project Structure

```
envoy-dev/
├── lib/                    # Main Flutter app code
├── test/                   # Dart tests
├── packages/               # Internal packages (mostly Rust FFI)
│   ├── backup/             # Backup encryption (FRB)
│   ├── bluart/             # Bluetooth UR transport (FRB)
│   ├── foundation_api/     # Core crypto APIs (FRB)
│   ├── http_tor/           # HTTP over Tor (FRB)
│   ├── kebab_mcp/          # MCP server for hardware test rig
│   ├── ngwallet/           # Next-gen wallet functions (FRB)
│   ├── shards/             # Shamir secret sharing (FRB)
│   └── ur/                 # Uniform Resources encoding (FRB)
├── rust/                   # Workspace for all Rust crates
└── scripts/                # Build and utility scripts
```

## Essential Commands

### Formatting

```bash
just fmt
```

Formats both Rust (`cargo fmt`) and Dart code. The Dart formatter excludes generated files, cargokit, and FRB output.

### Localization

```bash
just copy
```

Downloads translations from Localazy and generates Dart localization files. Run this after adding new user-facing strings.

### Code Generation (Freezed, JSON serialization)

```bash
just generate
```

Runs `build_runner` for Freezed classes, JSON serialization, and other code generation.

### Flutter Rust Bridge Regeneration

```bash
./scripts/generate_frb.sh
```

**Run this when you modify Rust API code in any FRB package.** This script:
1. Regenerates Dart bindings from Rust code
2. Builds the Rust libraries
3. Runs build_runner if needed
4. Formats generated files

FRB packages: `backup`, `bluart`, `foundation_api`, `http_tor`, `ngwallet`, `shards`, `ur`

### Linting

```bash
just lint
```

Runs formatting, REUSE license check, Flutter analyze, and Cargo clippy.

### Testing

```bash
flutter test                    # Run all Dart tests
flutter test test/ur_test.dart  # Run specific test
cargo test                      # Run Rust tests
```

**Note:** Some tests require Rust libraries to be built first. Run `cargo build` before running tests that use FRB packages.

## Working with Rust/Flutter Rust Bridge

### Package Structure

Each FRB package follows this structure:
```
packages/{name}/
├── lib/
│   ├── {name}.dart           # Public Dart API
│   └── src/rust/             # Generated FRB bindings (DO NOT EDIT)
│       ├── api/              # Generated Dart wrappers
│       ├── frb_generated.dart
│       ├── frb_generated.io.dart
│       └── frb_generated.web.dart
├── rust/
│   ├── Cargo.toml
│   └── src/
│       ├── lib.rs
│       ├── api/              # Rust API code (edit this)
│       │   └── {module}.rs
│       └── frb_generated.rs  # Generated (DO NOT EDIT)
├── rust_builder/             # Cargokit build system
├── flutter_rust_bridge.yaml  # FRB configuration
└── pubspec.yaml
```

### Modifying Rust Code

1. Edit Rust files in `packages/{name}/rust/src/api/`
2. Run `./scripts/generate_frb.sh` to regenerate bindings
3. Update the Dart wrapper in `packages/{name}/lib/{name}.dart` if the API changed

### FRB Annotations

Common FRB annotations for Rust functions:
- `#[flutter_rust_bridge::frb(sync)]` - Synchronous function (blocks Dart)
- `#[flutter_rust_bridge::frb(init)]` - Initialization function
- Return `Result<T, String>` for functions that can fail

## File Exclusions

### Formatter Exclusions

The formatter (`just fmt`) excludes:
- `**/cargokit/**` - Vendored build tools
- `**/src/rust/**` - FRB-generated Dart code
- `**/*.freezed.dart`, `**/*.g.dart` - Generated files
- `**/frb_generated*` - FRB output

### Analyzer Exclusions

See `analysis_options.yaml` for full list. Key exclusions:
- All FRB packages under `packages/`
- Generated files (`*.freezed.dart`, `*.g.dart`, `frb_generated*`)
- Cargokit directories

## License Headers

All source files must have SPDX license headers. Use REUSE tool:

```bash
reuse lint                     # Check compliance
reuse addheader --license GPL-3.0-or-later --copyright "Foundation Devices Inc." <file>
```

## CI Pipeline

The CI (`ci.yml`) runs:
1. License header check (`reuse lint`)
2. Dart formatting check
3. Flutter analyze
4. Rust formatting check
5. Rust build (`cargo build`)
6. Dart tests (`flutter test`)
7. Clippy lints
8. Rust tests (`cargo test`)

## Common Issues

### Tests fail with "Failed to load dynamic library"

Build the Rust libraries first:
```bash
cargo build  # For debug
cargo build --release  # For release
```

### FRB codegen fails with "workspace" error

Make sure the package's Rust crate is listed in the root `Cargo.toml` workspace members.

### Analyzer errors in generated files

Generated files are excluded from analysis. If you see errors in `src/rust/` or `*.freezed.dart`, they're likely stale. Regenerate with `./scripts/generate_frb.sh` or `just generate`.
