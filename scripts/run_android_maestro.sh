#!/bin/bash

# SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Maestro Android Test Runner for Envoy
# Usage: ./run_android_maestro.sh [--device <device_id>] [test_name.yaml]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TESTS_DIR="$PROJECT_ROOT/integration_test/maestro_tests"
DEVICE_ID=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

print_header() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}${BOLD}         Envoy Maestro Android Test Runner                 ${NC}${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_test_start() {
    local test_name=$1
    echo ""
    echo -e "${CYAN}┌────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC} ${YELLOW}▶ Running:${NC} ${BOLD}$test_name${NC}"
    echo -e "${CYAN}└────────────────────────────────────────────────────────────┘${NC}"
}

print_test_success() {
    local test_name=$1
    echo -e "${GREEN}✓ PASSED:${NC} $test_name"
}

print_test_failure() {
    local test_name=$1
    local output=$2
    echo -e "${RED}✗ FAILED:${NC} $test_name"
    echo ""
    echo -e "${RED}─────────────────── Error Details ───────────────────${NC}"

    # Extract and display failure information
    if echo "$output" | grep -q "Failed at"; then
        echo "$output" | grep -A 5 "Failed at"
    elif echo "$output" | grep -q "Error"; then
        echo "$output" | grep -i "error" | head -10
    else
        echo "$output" | tail -20
    fi

    echo -e "${RED}─────────────────────────────────────────────────────${NC}"
}

print_summary() {
    local passed=$1
    local failed=$2
    local total=$((passed + failed))

    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}${BOLD}                      Test Summary                          ${NC}${BLUE}║${NC}"
    echo -e "${BLUE}╠════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${BLUE}║${NC}  Total:  $total                                                 ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}  ${GREEN}Passed: $passed${NC}                                                 ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC}  ${RED}Failed: $failed${NC}                                                 ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_header

# Parse arguments
BUILD_APP=false
while [[ $# -gt 0 ]]; do
    case $1 in
        --device)
            DEVICE_ID="$2"
            shift 2
            ;;
        --build)
            BUILD_APP=true
            shift
            ;;
        *)
            TEST_ARG="$1"
            shift
            ;;
    esac
done

# Check if maestro is installed
if ! command -v maestro &> /dev/null; then
    echo -e "${RED}✗ Error: Maestro is not installed or not in PATH${NC}"
    echo -e "  Install it with: ${CYAN}curl -Ls https://get.maestro.mobile.dev | bash${NC}"
    exit 1
fi

echo -e "${GREEN}✓${NC} Maestro found: $(which maestro)"
echo -e "${GREEN}✓${NC} Tests directory: $TESTS_DIR"

# Auto-detect device if not specified
if [ -z "$DEVICE_ID" ]; then
    DEVICE_ID=$(adb devices | grep -w "device" | head -1 | awk '{print $1}')
    if [ -z "$DEVICE_ID" ]; then
        echo -e "${RED}✗ Error: No Android device found. Please connect a device.${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}✓${NC} Using device: $DEVICE_ID"

# Build and install app if requested
if [ "$BUILD_APP" = true ]; then
    echo ""
    echo -e "${YELLOW}Building Android APK...${NC}"
    cd "$PROJECT_ROOT"
    flutter build apk --debug

    if [ $? -ne 0 ]; then
        echo -e "${RED}✗ Error: Failed to build APK${NC}"
        exit 1
    fi

    echo -e "${YELLOW}Installing APK on device $DEVICE_ID...${NC}"
    adb -s "$DEVICE_ID" install -r build/app/outputs/flutter-apk/app-debug.apk

    if [ $? -ne 0 ]; then
        echo -e "${RED}✗ Error: Failed to install APK${NC}"
        exit 1
    fi

    echo -e "${GREEN}✓${NC} APK installed successfully"
    echo ""
fi

# Build maestro command with device
MAESTRO_CMD="maestro --device $DEVICE_ID"

PASSED=0
FAILED=0
FAILED_TESTS=()

run_single_test() {
    local test_file=$1
    local test_name=$(basename "$test_file")

    print_test_start "$test_name"

    # Run maestro and capture output
    OUTPUT=$($MAESTRO_CMD test "$test_file" 2>&1)
    EXIT_CODE=$?

    if [ $EXIT_CODE -eq 0 ]; then
        print_test_success "$test_name"
        ((PASSED++))
    else
        print_test_failure "$test_name" "$OUTPUT"
        ((FAILED++))
        FAILED_TESTS+=("$test_name")
    fi

    return $EXIT_CODE
}

# Check if a specific test was provided
if [ -n "$TEST_ARG" ]; then
    TEST_FILE="$TESTS_DIR/$TEST_ARG"
    if [ ! -f "$TEST_FILE" ]; then
        echo -e "${RED}✗ Error: Test file not found: $TEST_FILE${NC}"
        exit 1
    fi
    run_single_test "$TEST_FILE"
else
    # Run all tests in the folder
    echo ""
    echo -e "${YELLOW}Running all tests in: $TESTS_DIR${NC}"

    for test_file in "$TESTS_DIR"/*.yaml; do
        if [ -f "$test_file" ]; then
            run_single_test "$test_file"
        fi
    done
fi

print_summary $PASSED $FAILED

# Print failed tests list if any
if [ ${#FAILED_TESTS[@]} -gt 0 ]; then
    echo -e "${RED}Failed tests:${NC}"
    for test in "${FAILED_TESTS[@]}"; do
        echo -e "  ${RED}•${NC} $test"
    done
    echo ""
fi

# Uninstall app after tests
echo -e "${YELLOW}Uninstalling app...${NC}"
adb -s "$DEVICE_ID" uninstall com.foundationdevices.envoy > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} App uninstalled"
else
    echo -e "${YELLOW}⚠${NC} App was not installed or already removed"
fi

if [ ${#FAILED_TESTS[@]} -gt 0 ]; then
    exit 1
fi

exit 0
