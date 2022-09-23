#!/bin/bash

# SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

# This script requires ditto-cli
# sudo npm install @dittowords/cli@2.1.2 -g

# Exit if anything fails
set -e

# Pull from ditto
ditto-cli pull

# Clean and merge .jsons, output to l10n folder
cd ditto/ditto-to-arb
cargo run > ../../lib/l10n/intl_en.arb