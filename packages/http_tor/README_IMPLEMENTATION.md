<!--
SPDX-FileCopyrightText: 2025 Foundation Devices Inc.

SPDX-License-Identifier: GPL-3.0-or-later
-->

# HTTP Tor Implementation

This document describes the implementation of the HTTP Tor package using Flutter Rust Bridge.

## Changes Made

1. **Updated Cargo.toml**
   - Added necessary dependencies:
     - reqwest (with socks and blocking features)
     - tokio (with full features)
     - lazy_static
     - log
     - anyhow (for error handling)

2. **Created http.rs in api directory**
   - Implemented the following functions from http_tor_legacy:
     - `http_get_file`: Download a file with progress tracking
     - `http_request`: Make HTTP requests (GET/POST) through Tor
     - `http_get_ip`: Get the public IP address
     - `http_hello`: Test function for HTTP over Tor
   - Adapted the implementation to use Flutter Rust Bridge:
     - Used proper Rust types (String, Vec<u8>, HashMap) instead of C-style pointers
     - Used Result<T> for error handling instead of custom error handling
     - Used StreamSink for progress updates instead of allo-isolate
     - Added proper documentation comments
     - Added #[flutter_rust_bridge::frb] attributes to exposed functions

3. **Updated mod.rs**
   - Added export for the http module

## Next Steps

To complete the implementation, the following steps would be needed:

1. **Fix Workspace Configuration**
   - The root Cargo.toml workspace configuration references a non-existent path:
     `/home/igor/Code/envoy-dev/packages/http_tor/native/*/Cargo.toml`
   - This needs to be updated to point to the correct path:
     `/home/igor/Code/envoy-dev/packages/http_tor/rust/Cargo.toml`

2. **Regenerate Dart Bindings**
   - After fixing the workspace configuration, run:
     ```
     cd packages/http_tor
     flutter pub get
     flutter_rust_bridge_codegen generate
     ```

3. **Update the generate_frb.sh Script**
   - Add "packages/http_tor" to the PACKAGES array in scripts/generate_frb.sh
   - This will ensure that the bindings are regenerated when the script is run

4. **Test the Implementation**
   - Create tests to verify that the new implementation works as expected
   - Check for any regressions or issues

## Implementation Details

### Key Differences from http_tor_legacy

1. **Type System**
   - http_tor_legacy: Uses C-style FFI with raw pointers
   - http_tor: Uses proper Rust types with Flutter Rust Bridge

2. **Error Handling**
   - http_tor_legacy: Custom error handling mechanism with thread_local storage
   - http_tor: Uses Rust's Result type for error handling

3. **Progress Updates**
   - http_tor_legacy: Uses allo-isolate for progress updates
   - http_tor: Uses Flutter Rust Bridge's StreamSink for progress updates

4. **Function Signatures**
   - http_tor_legacy: C-style function signatures with raw pointers
   - http_tor: Rust-style function signatures with proper types

### Example: http_get_file

**http_tor_legacy (C-style FFI):**
```rust
#[no_mangle]
pub unsafe extern "C" fn http_get_file(
    path: *const c_char,
    url: *const c_char,
    tor_port: i32,
    isolate_port: i64,
) -> *mut JoinHandle<()> {
    // Implementation with C-style pointers
}
```

**http_tor (Flutter Rust Bridge):**
```rust
#[flutter_rust_bridge::frb]
pub async fn http_get_file(
    path: String,
    url: String,
    tor_port: i32,
    progress_sink: StreamSink<String>,
) -> Result<()> {
    // Implementation with proper Rust types
}
```

## Maintenance Considerations

1. **Dependency Updates**
   - Keep the dependencies in Cargo.toml up to date
   - Pay special attention to the reqwest and tokio versions

2. **Flutter Rust Bridge Updates**
   - When updating Flutter Rust Bridge, regenerate the bindings
   - Test thoroughly after updates

3. **Error Handling**
   - The new implementation uses anyhow for error handling
   - Make sure errors are properly propagated to the Dart side

4. **Async Functions**
   - Some functions are async (http_get_file) while others are sync
   - Consider making all functions async for consistency