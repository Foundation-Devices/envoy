#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Capture Prime's screen as a 480×800 PNG.
#
# How to use
#   From shell:
#     ./prime-screenshot.sh -o /tmp/foo.png
#
#   From Maestro YAML (via prime_screenshot.js):
#     - runScript:
#         file: prime_scripts/prime_screenshot.js
#         env:
#           PATH: "/tmp/foo.png"   # optional

set -euo pipefail

KEYOS_DEV_DIR="${KEYOS_DEV_DIR:-$HOME/KeyOS-dev}"
exec "$KEYOS_DEV_DIR/target/release/passport-drive" screenshot "$@"
