#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Press + release Prime's power button (wakes the screen if asleep,
# sleeps it if awake).
#
# How to use
#   From shell:
#     ./prime-power.sh
#
#   From Maestro YAML (via prime_power.js):
#     - runScript: prime_scripts/interactions/prime_power.js

set -euo pipefail

KEYOS_DEV_DIR="${KEYOS_DEV_DIR:-$HOME/KeyOS-dev}"
exec "$KEYOS_DEV_DIR/target/release/passport-drive" power
