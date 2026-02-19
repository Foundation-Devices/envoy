#!/bin/bash

# SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Format Dart files excluding cargokit and generated files

set -e

cd "$(dirname "$0")/.."

# Find all Dart files excluding:
# - cargokit directories (vendored third-party code)
# - .dart_tool directories
# - generated files (frb_generated, *.freezed.*, *.g.dart, etc.)
# - build directory

find . -name "*.dart" \
    -not -path "*/cargokit/*" \
    -not -path "*/.dart_tool/*" \
    -not -path "*/build/*" \
    -not -path "*/.symlinks/*" \
    -not -path "*/src/rust/*" \
    -not -name "*.freezed.dart" \
    -not -name "*.g.dart" \
    -not -name "frb_generated*.dart" \
    -print0 | xargs -0 dart format "$@"
