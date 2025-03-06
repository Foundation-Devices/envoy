#!/usr/bin/env bash

rm lib/src/rust -r
mkdir -p lib/src/rust

set -e

flutter_rust_bridge_codegen generate


