#!/bin/bash

# SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Define the list of test groups
test_groups=("Passport wallet tests")
# Get the current platform (Linux, iOS, etc.)
platform=$(uname -s)

# Print the detected platform for debugging
echo "Detected platform: $platform"

# Iterate over each test group
for group_name in "${test_groups[@]}"; do
  echo "Running tests for group: $group_name on platform $platform"

# Run tests for the current test group on the specified platform.
  if [[ "$platform" == "Linux" ]]; then
    # Run the test for Linux
    if ! flutter test --plain-name "$group_name" --dart-define=IS_TEST=true linux integration_test/beef_qa_test.dart; then
      echo "Test failed in group: $group_name on Linux"
      exit 1 # Exit immediately on failure
    fi
  elif [[ "$platform" == "Darwin" ]]; then
    # flutter build ios # mby a fix for a missing file
    # Device ID for iPhone 15
    device_id="00008120-001C348421C3A01E"
    # Run the test for iOS
    if ! flutter test --plain-name "$group_name" -d $device_id --dart-define=IS_TEST=true ios integration_test/beef_qa_test.dart; then
      echo "Test failed in group: $group_name on iOS"
      exit 1 # Exit immediately on failure
    fi
  else
    echo "Unsupported platform: $platform."
    exit 1
  fi
done

exit 0
