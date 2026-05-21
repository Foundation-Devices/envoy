#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Tap Prime's screen at (X, Y). Origin is top-left, screen is 480×800.
#
# Pass the literal string `home` instead of coordinates to tap the
# capacitive home button below the LCD (sensor area x=0..199, y=850..970;
# tap lands at the center, 100, 910).
#
# How to use
#   From shell:
#     ./prime-tap.sh 240 400
#     ./prime-tap.sh home
#
#   From Maestro YAML (via prime_tap.js):
#     - runScript:
#         file: prime_scripts/interactions/prime_tap.js
#         env:
#           X: "240"
#           Y: "400"
#     - runScript:
#         file: prime_scripts/interactions/prime_tap.js
#         env:
#           X: "home"

set -euo pipefail

KEYOS_DEV_DIR="${KEYOS_DEV_DIR:-$HOME/KeyOS-dev}"

# Tiny settle delay before every tap so the previous UI transition has time
# to finish — Maestro flows can dispatch taps faster than the Prime renders.
sleep 0.4

if [ "$#" -eq 1 ] && [ "$1" = "home" ]; then
    exec "$KEYOS_DEV_DIR/target/release/passport-drive" tap 100 910
fi

exec "$KEYOS_DEV_DIR/target/release/passport-drive" tap "$@"
