#!/bin/bash

# SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

# This script requires ditto-cli and jq
# sudo npm install @dittowords/cli@2.1.2 -g
# sudo apt install jq

# Exit if anything fails
set -e

# Pull from ditto
ditto-cli pull

# Clean and merge .jsons, output to l10n folder
cd ditto
jq 'with_entries(.key = "component_" + .key)' ditto-component-library__base.json > components.json
jq 'with_entries(.key = .key + "_after_onboarding")' 'Envoy + PP Clean Start__after-onboarding.json' > after-onboarding.json
jq -s '.[0] * .[1] * .[2] * .[3]' components.json 'Envoy + PP Clean Start__base.json' Envoy__base.json after-onboarding.json | \
jq 'with_entries(.value = (.value | sub("\\\\n"; "\n")))' > ../lib/l10n/intl_en.arb