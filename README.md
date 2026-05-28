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

FRB packages: `backup`, `foundation_api`, `http_tor`, `ngwallet`, `shards`, `ur`

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

## Review guidelines

You are reviewing a PR in Envoy, Foundation Devices' Bitcoin wallet mobile app (Flutter/Dart UI, Rust core via FFI, iOS + Android, companion to the Passport hardware wallet).

### Related repositories

Other Foundation Devices repos Envoy depends on or talks to. Consult them when a diff touches the integration surface; assume the contract on the other side is fixed unless the PR description says otherwise.

- [`foundation-api`](https://github.com/Foundation-Devices/foundation-api) — Rust monorepo for the device-to-device API built on Blockchain Commons' GSTP. Defines Quantum Link (QL) messages, the Beefcake Transfer Protocol (BTP) for MTU-sized chunking, and BLE/SE abstractions. Envoy wraps it as the `foundation_api` FRB package and uses it to talk to Passport over BLE.
- [`ngwallet`](https://github.com/Foundation-Devices/ngwallet) — Foundation's next-gen Bitcoin wallet core, built on a Foundation-forked BDK. Owns the wallet logic: account/key derivation, PSBT construction and signing, fee handling, RBF, UTXO selection, `sign_message`. Envoy wraps it as the `ngwallet` FRB package; every transaction Envoy builds or signs flows through it.
- [`envoy-server`](https://github.com/Foundation-Devices/envoy-server) — Private Rust + Axum backend Envoy calls into. Two responsibilities: (1) serve Passport firmware release metadata (verified via GitHub webhook HMAC), and (2) act as the encrypted backup gateway against S3 or local storage.
- [`backup-server`](https://github.com/Foundation-Devices/backup-server) — Private Rust + Axum service for encrypted backup storage using post-quantum signatures (`libcrux-ml-dsa` / ML-DSA). Sits alongside or augments `envoy-server`'s backup path.

### Review scope

First, check whether you have reviewed this PR before — look for earlier reviews or review comments you authored on it.

- If this is your first review: review the entire diff and raise every issue you find. Be thorough; this is the moment to surface everything about the existing code, because later reviews will not revisit it.
- If you have reviewed this PR before: comment only on what changed in the commits pushed since your last review. Do not raise new issues about code that was already present at your previous review, even if you only noticed it now. If the new commits resolve earlier findings, you may note that briefly.

### How to comment

Give every finding a priority — the reviewer triages from it, and any finding promoted to a Linear ticket inherits it:

- **Urgent** — must fix before merge: a correctness, security, or data-loss bug.
- **High** — should fix before merge: likely to bite, but not catastrophic.
- **Medium** — worth fixing; can be deferred to a follow-up ticket.
- **Low** — minor; nice-to-have.

Lead every inline comment with the priority in brackets, then a prefix that signals the action expected:

- *(no prefix)* — change this, or justify why not.
- `Optional:` — an improvement; can be dismissed without justification.
- `Note:` — FYI only, no action required.

For example: `[Urgent] <problem>. <fix>.` or `[Low] Optional: <suggestion>.` or `[Medium] Note: <observation>.`

Do not resolve your own comments — leave that to the human reviewer or the PR author.

### What to look for

Urgent:

- Anything that could leak, log, or weaken handling of seeds, xprivs, descriptors, PSBTs, BIP39 words, or session secrets. Includes logging, crash reports, analytics, screenshots, clipboard, deep links, and accidental serialisation.
- Incorrect Bitcoin maths: fee calculation, sat/byte vs sat/vB, dust thresholds, change derivation, address-type assumptions, signature/PSBT round-trips.
- FFI boundary bugs across the Dart ↔ Rust seam: lifetime/ownership, nullability, blocking the UI isolate, missing `dispose`, leaks of pointers or `Box`-ed values, panics not converted to errors.
- Concurrency bugs around BLE (connect/disconnect/reconnect, GATT writes, queue ordering) and around wallet sync.
- Android permissions regressions, especially BLE on Android 11+ (`BLUETOOTH_CONNECT`/`SCAN`, location prompt skips, foreground service requirements) and iOS Bluetooth state restoration / background modes.

High:

- Missing or incorrect error handling on network, BLE, or FFI calls that could land the user in a stuck UI state.
- State management mistakes (Riverpod/Provider): rebuild loops, stale references after hot reload, accidental `watch` in `build` that triggers infinite rebuilds.
- i18n strings hard-coded in English in user-facing widgets that should go through the localisation pipeline (`just copy`).
- Obvious perf cliffs on lower-end Android (heavy work on the UI isolate, large `setState` blasts, missing `const`).

Medium:

- Latent bugs that only trigger under uncommon conditions, or error paths that leave the user without a way to recover.
- Missing test coverage on a non-critical path the PR changes.
- New TODOs or technical debt added without a tracking ticket.

Low:

- Typos in user-facing strings, dartdoc/rustdoc, or code comments.

### Do not comment on

- Formatting / style — `dart format` and the linter cover it.
- Renames or comment rewording.
- Speculative refactors ("you could extract this...") unless the code as written is wrong.
- Things the PR author explicitly called out in the description.

Skip preamble. Skip "great work!". Skip emoji. One short paragraph per finding: state the problem, then the fix. End with a one-sentence verdict, then the findings grouped Urgent, then High, then Medium, then Low. If you find nothing to flag, still post that verdict as a short written comment (for example, "Reviewed the diff — no issues found.") rather than only a reaction or emoji.
