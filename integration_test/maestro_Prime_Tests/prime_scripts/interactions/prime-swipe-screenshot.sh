#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Swipe (SX,SY)→(EX,EY), wait WAIT_MS, then screenshot to PATH.
#
# How to use
#   From shell:
#     ./prime-swipe-screenshot.sh 240 600 240 200                       # default 1000ms wait
#     ./prime-swipe-screenshot.sh 240 600 240 200 1500 /tmp/foo.png     # custom wait + path
#
#   From Maestro YAML (via prime_swipe_screenshot.js):
#     - runScript:
#         file: prime_scripts/interactions/prime_swipe_screenshot.js
#         env:
#           SX: "240"
#           SY: "600"
#           EX: "240"
#           EY: "200"
#           WAIT_MS: "1000"       # optional
#           PATH: "/tmp/foo.png"  # optional
#
# defaults: WAIT_MS=1000  PATH=/tmp/prime-bridge-shot.png

set -euo pipefail

KEYOS_DEV_DIR="${KEYOS_DEV_DIR:-$HOME/KeyOS-dev}"
PD="$KEYOS_DEV_DIR/target/release/passport-drive"

SX=$1; SY=$2; EX=$3; EY=$4
WAIT=${5:-1000}
OUT=${6:-/tmp/prime-bridge-shot.png}

exec "$PD" swipe-screenshot "$SX" "$SY" "$EX" "$EY" -w "$WAIT" -o "$OUT"
