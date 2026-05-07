#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Tap a fixed coordinate on Prime via passport-drive.
#
# Coordinates: X = 5%, Y = 95% of a 480x800 screen → (24, 760).
# That's roughly the bottom-left back-button area on the unpaired card,
# which is what we're testing on the Maestro side.
#
# Resolves the KeyOS-dev checkout (and therefore the passport-drive binary)
# from $KEYOS_DEV_DIR (env override) or $HOME/KeyOS-dev.
#
# How to use
#   From shell:
#     ./tap-prime-button.sh                # taps once
#     ./tap-prime-button.sh -s out.png     # taps then captures a screenshot
#
#   From Maestro YAML (via tap_prime_button.js):
#     - runScript: prime_scripts/tap_prime_button.js

set -euo pipefail

KEYOS_DEV_DIR="${KEYOS_DEV_DIR:-$HOME/KeyOS-dev}"
PASSPORT_DRIVE="$KEYOS_DEV_DIR/target/release/passport-drive"

X=24
Y=760

if [[ ! -x "$PASSPORT_DRIVE" ]]; then
    echo "!! passport-drive not built at $PASSPORT_DRIVE" >&2
    echo "   build it: (cd $KEYOS_DEV_DIR && cargo build -p passport-drive --release)" >&2
    exit 1
fi

if [[ "${1:-}" == "-s" ]] && [[ -n "${2:-}" ]]; then
    echo "==> tap ($X, $Y) + screenshot → $2"
    "$PASSPORT_DRIVE" tap-screenshot "$X" "$Y" -o "$2"
else
    echo "==> tap ($X, $Y)"
    "$PASSPORT_DRIVE" tap "$X" "$Y"
fi
