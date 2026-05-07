#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Tap Prime's screen at (X, Y). Origin is top-left, screen is 480×800.
#
# How to use
#   From shell:
#     ./prime-tap.sh 240 400
#
#   From Maestro YAML (via prime_tap.js):
#     - runScript:
#         file: prime_scripts/prime_tap.js
#         env:
#           X: "240"
#           Y: "400"

set -euo pipefail

KEYOS_DEV_DIR="${KEYOS_DEV_DIR:-$HOME/KeyOS-dev}"
exec "$KEYOS_DEV_DIR/target/release/passport-drive" tap "$@"
