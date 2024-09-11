#!/bin/bash

# SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Define the list of test groups
test_groups=("Hot wallet tests" "Passport wallet tests" "No account tests")

# Iterate over each test group
for group_name in "${test_groups[@]}"; do
  echo "Running tests for group: $group_name"

  # Run the test for the current group
  if ! xvfb-run -a -s '-screen 0 2000x2000x24 +extension GLX' flutter test --plain-name "$group_name" -d linux integration_test/beef_qa_test.dart --verbose; then
    echo "Test failed in group: $group_name"
    exit 1 # Exit immediately on failure
  fi
done

exit 0