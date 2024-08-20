#!/bin/bash

# SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Initialize exit code
exit_code=0

# Iterate over each test file in integration_test_order
while IFS= read -r test_file; do
    # Skip lines that start with #
    if [[ $test_file =~ ^# ]]; then
        continue
    fi

  # Run the test for the current file
  if ! xvfb-run -a -s '-screen 0 1024x768x24 +extension GLX' flutter test "$test_file" -d linux --verbose; then
    exit_code=1
  fi
done <integration_test_order

# Exit with the appropriate code
exit $exit_code
