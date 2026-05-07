#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Tap (X, Y), wait WAIT_MS, then screenshot to PATH. Useful for
# verifying a tap actually changed the screen.
#
# How to use
#   From shell:
#     ./prime-tap-screenshot.sh 240 400                            # default 800ms wait
#     ./prime-tap-screenshot.sh 240 400 1500 /tmp/foo.png          # custom wait + path
#
#   From Maestro YAML (via prime_tap_screenshot.js):
#     - runScript:
#         file: prime_scripts/prime_tap_screenshot.js
#         env:
#           X: "240"
#           Y: "400"
#           WAIT_MS: "800"        # optional
#           PATH: "/tmp/foo.png"  # optional
#
# defaults: WAIT_MS=800  PATH=/tmp/prime-bridge-shot.png

set -euo pipefail

KEYOS_DEV_DIR="${KEYOS_DEV_DIR:-$HOME/KeyOS-dev}"
PD="$KEYOS_DEV_DIR/target/release/passport-drive"

X=$1; Y=$2
WAIT=${3:-800}
OUT=${4:-/tmp/prime-bridge-shot.png}

exec "$PD" tap-screenshot "$X" "$Y" -w "$WAIT" -o "$OUT"
