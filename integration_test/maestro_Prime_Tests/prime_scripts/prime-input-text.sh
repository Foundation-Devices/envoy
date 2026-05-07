#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Type text into Prime's currently focused input field.
#
# How to use
#   From shell:
#     ./prime-input-text.sh "hello world"
#
#   From Maestro YAML (via prime_input_text.js):
#     - runScript:
#         file: prime_scripts/prime_input_text.js
#         env:
#           TEXT: "hello world"

set -euo pipefail

KEYOS_DEV_DIR="${KEYOS_DEV_DIR:-$HOME/KeyOS-dev}"
exec "$KEYOS_DEV_DIR/target/release/passport-drive" input-text "$@"
