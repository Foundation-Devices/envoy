#!/bin/bash

# SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Initialize exit code
exit_code=0
failed_tests=()

# Iterate over each test file in integration_test_order
while IFS= read -r test_file; do
  # Skip lines that start with whitespace, #, or are empty
  if [[ -z "$test_file" ]] || [[ $test_file =~ ^[[:space:]] ]] || [[ $test_file =~ ^# ]]; then
    continue
  fi

  # Run the test for the current file
  if ! xvfb-run -a -s '-screen 0 1024x768x24 +extension GLX' flutter test "$test_file" -d linux --verbose; then
    exit_code=1
    failed_tests+=("$test_file") # Collect the names of failed tests
  fi
done <integration_test_order

# Print summary of failed tests, if any
if [ ${#failed_tests[@]} -ne 0 ]; then
  echo "The following tests failed:"
  for test in "${failed_tests[@]}"; do
    echo "$test"
  done
fi

# Exit with the appropriate code
exit $exit_code
