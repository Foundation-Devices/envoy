#!/bin/bash

# SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Maestro iOS Test Runner for Envoy
# Usage: ./run_ios_maestro.sh [test_name.yaml]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TESTS_DIR="$PROJECT_ROOT/integration_test/maestro_tests"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Envoy Maestro iOS Test Runner ===${NC}"

# Check if running on macOS
if [[ "$(uname -s)" != "Darwin" ]]; then
    echo -e "${RED}Error: This script must be run on macOS for iOS testing${NC}"
    exit 1
fi

# Check if maestro is installed
if ! command -v maestro &> /dev/null; then
    echo -e "${YELLOW}Maestro not found. Installing...${NC}"
    curl -Ls "https://get.maestro.mobile.dev" | bash
    export PATH="$PATH:$HOME/.maestro/bin"
fi

# Check if idb is installed (required for iOS)
if ! command -v idb &> /dev/null; then
    echo -e "${YELLOW}idb not found. Installing...${NC}"
    brew tap facebook/fb
    brew install idb-companion
    pip3 install fb-idb
fi

# Get connected iOS device
DEVICE_ID=$(xcrun xctrace list devices 2>&1 | grep -v "Simulator" | grep "iPhone\|iPad" | head -1 | awk -F'[()]' '{print $(NF-1)}')

if [ -z "$DEVICE_ID" ]; then
    echo -e "${RED}Error: No iOS device found. Please connect an iPhone/iPad.${NC}"
    exit 1
fi

echo -e "${GREEN}Found iOS device: $DEVICE_ID${NC}"

# Build and install iOS app if needed
build_ios_app() {
    echo -e "${YELLOW}Building iOS app...${NC}"
    cd "$PROJECT_ROOT"
    flutter build ios --debug --no-codesign

    echo -e "${YELLOW}Installing app on device...${NC}"
    # Install using ios-deploy or xcodebuild
    if command -v ios-deploy &> /dev/null; then
        ios-deploy --bundle build/ios/Debug-iphoneos/Runner.app --id "$DEVICE_ID"
    else
        echo -e "${YELLOW}ios-deploy not found, trying xcrun...${NC}"
        xcrun devicectl device install app --device "$DEVICE_ID" build/ios/Debug-iphoneos/Runner.app
    fi
}

# Check if --build flag is passed
if [[ "$1" == "--build" ]]; then
    build_ios_app
    shift
fi

# Test runner with video recording
PASSED=0
FAILED=0
FAILED_TESTS=()

run_single_test() {
    local test_file="$1"
    local test_name
    test_name="$(basename "$test_file")"

    echo -e "${CYAN}▶ Test:${NC} ${BOLD}$test_name${NC}"

    # Stream output and print only completed commands
    local EXIT_CODE=0
    while IFS= read -r line; do
        if [[ "$line" == *"✓"* ]]; then
            cmd=$(echo "$line" | sed 's/.*✓ //')
            echo -e "  ${GREEN}✓${NC} $cmd"
        elif [[ "$line" == *"✗"* ]]; then
            cmd=$(echo "$line" | sed 's/.*✗ //')
            echo -e "  ${RED}✗${NC} $cmd"
        fi
    done < <(maestro --device "$DEVICE_ID" test "$test_file" 2>&1; echo "EXIT_CODE:$?")

    # Extract exit code from last line
    if [[ "$line" == "EXIT_CODE:"* ]]; then
        EXIT_CODE="${line#EXIT_CODE:}"
    fi

    if [ "$EXIT_CODE" -eq 0 ]; then
        echo -e "${GREEN}✓ PASSED: $test_name${NC}"
        ((PASSED++))
    else
        echo -e "${RED}✗ FAILED: $test_name${NC}"
        ((FAILED++))
        FAILED_TESTS+=("$test_name")
    fi
    echo ""
}

# Check if a specific test was provided
if [ -n "$1" ]; then
    TEST_FILE="$TESTS_DIR/$1"
    if [ ! -f "$TEST_FILE" ]; then
        echo -e "${RED}Error: Test file not found: $TEST_FILE${NC}"
        exit 1
    fi
    run_single_test "$TEST_FILE"
else
    # Run all tests in the folder
    echo -e "${YELLOW}Running all tests on device $DEVICE_ID${NC}"
    for test_file in "$TESTS_DIR"/*.yaml; do
        if [ -f "$test_file" ]; then
            run_single_test "$test_file"
        fi
    done
fi

# Summary
echo ""
echo -e "${GREEN}=== Test Summary ===${NC}"
echo -e "Total: $((PASSED + FAILED))"
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"

if [ ${#FAILED_TESTS[@]} -gt 0 ]; then
    echo -e "${RED}Failed tests:${NC}"
    for test in "${FAILED_TESTS[@]}"; do
        echo -e "  ${RED}•${NC} $test"
    done
fi

if [ $FAILED -gt 0 ]; then
    exit 1
fi

exit 0