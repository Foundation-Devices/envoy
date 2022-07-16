#!/bin/bash

# This script requires ditto-cli and jq
# sudo npm install @dittowords/cli@2.1.2 -g
# sudo apt install jq

# Exit if anything fails
set -e

# Pull from ditto
ditto-cli pull

# Clean and merge .jsons, output to l10n folder
cd ditto
jq 'with_entries(.key = "component_" + .key)' ditto-component-library.json > components.json
jq -s '.[0] * .[1]' components.json 'Envoy + PP Clean Start.json' > ../lib/l10n/app_en.arb
