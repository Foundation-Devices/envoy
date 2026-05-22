#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Swipe from (SX, SY) to (EX, EY). Optional STEPS controls drag granularity
# (default 15 — passport-drive's default).
#
# How to use
#   From shell:
#     ./prime-swipe.sh 240 600 240 200          # swipe up
#     ./prime-swipe.sh 240 600 240 200 30       # slower swipe with 30 steps
#
#   From Maestro YAML (via prime_swipe.js):
#     - runScript:
#         file: prime_scripts/interactions/prime_swipe.js
#         env:
#           SX: "240"
#           SY: "600"
#           EX: "240"
#           EY: "200"
#           STEPS: "15"   # optional

set -euo pipefail

KEYOS_DEV_DIR="${KEYOS_DEV_DIR:-$HOME/KeyOS-dev}"
PD="$KEYOS_DEV_DIR/target/release/passport-drive"

SX=$1; SY=$2; EX=$3; EY=$4; STEPS=${5:-}

if [[ -n "$STEPS" ]]; then
    exec "$PD" swipe "$SX" "$SY" "$EX" "$EY" -s "$STEPS"
else
    exec "$PD" swipe "$SX" "$SY" "$EX" "$EY"
fi
