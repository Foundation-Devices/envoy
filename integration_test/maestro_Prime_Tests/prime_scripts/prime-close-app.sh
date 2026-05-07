#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Close (graceful) an app on Prime by PID via gui-server.
# Find the PID from `passport-drive logs` or the app manager state.
#
# How to use
#   From shell:
#     ./prime-close-app.sh 40
#
#   From Maestro YAML (via prime_close_app.js):
#     - runScript:
#         file: prime_scripts/prime_close_app.js
#         env:
#           PID: "40"

set -euo pipefail

KEYOS_DEV_DIR="${KEYOS_DEV_DIR:-$HOME/KeyOS-dev}"
exec "$KEYOS_DEV_DIR/target/release/passport-drive" close-app "$@"
