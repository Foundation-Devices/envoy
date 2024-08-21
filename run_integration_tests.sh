#!/bin/bash

# SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Iterate over each test file in integration_test_order
while IFS= read -r test_file; do
  # Skip lines that start with whitespace, #, or are empty
  if [[ -z "$test_file" ]] || [[ $test_file =~ ^[[:space:]] ]] || [[ $test_file =~ ^# ]]; then
    continue
  fi

  # Run the test for the current file
  if ! xvfb-run -a -s '-screen 0 1024x768x24 +extension GLX' flutter test "$test_file" -d linux --verbose; then
    echo "Test failed: $test_file"
    exit 1 # Exit immediately on failure
  fi
done <integration_test_order

exit 0
