#!/bin/bash

# SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Maestro iOS Physical Device Test Runner for Envoy
# Uses maestro-ios-device community tool for real iPhone/iPad testing
# Usage: ./run_ios_maestro.sh [--build] [--team-id TEAM_ID] [--device DEVICE_ID] [test_name.yaml]

set -o pipefail

# ------------------------------------------------------------
# Paths
# ------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
HOT_WALLET_TESTS_DIR="$PROJECT_ROOT/integration_test/maestro_Hot_Wallet_Tests"
PASSPORT_WALLET_TESTS_DIR="$PROJECT_ROOT/integration_test/maestro_Passport_Wallet_Tests"

APP_FILE=""
BRIDGE_PID=""
DRIVER_PORT=6001
DEVICE_ID=""
TEST_ARG=""
BUILD_APP=false
TEAM_ID=""

# ------------------------------------------------------------
# Colors
# ------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ------------------------------------------------------------
# UI Helpers
# ------------------------------------------------------------
print_header() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}${BOLD}      Envoy Maestro iOS Physical Device Test Runner        ${NC}${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_test_start() {
    echo ""
    echo -e "${CYAN}┌────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC} ${YELLOW}▶ Running:${NC} ${BOLD}$1${NC}"
    echo -e "${CYAN}└────────────────────────────────────────────────────────────┘${NC}"
}

print_test_success() {
    echo -e "${GREEN}✓ PASSED:${NC} $1"
}

print_test_failure() {
    local test_name="$1"
    local output="$2"

    echo -e "${RED}✗ FAILED:${NC} $test_name"
    echo ""
    echo -e "${RED}─────────────────── Error Details ───────────────────${NC}"

    if echo "$output" | grep -q "Failed at"; then
        echo "$output" | sed -n '/Failed at/,+5p'
    elif echo "$output" | grep -qi "error"; then
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

# ------------------------------------------------------------
# Cleanup function
# ------------------------------------------------------------
cleanup() {
    echo -e "${YELLOW}Stopping test processes...${NC}"
    [ -n "$XCTEST_PID" ] && kill "$XCTEST_PID" 2>/dev/null
    [ -n "$IPROXY_PID" ] && kill "$IPROXY_PID" 2>/dev/null
    [ -n "$BRIDGE_PID" ] && kill "$BRIDGE_PID" 2>/dev/null
    wait 2>/dev/null
}

trap cleanup EXIT

# ------------------------------------------------------------
# Argument Parsing
# ------------------------------------------------------------
while [[ $# -gt 0 ]]; do
    case "$1" in
        --build)
            BUILD_APP=true
            shift
            ;;
        --team-id)
            TEAM_ID="$2"
            shift 2
            ;;
        --device)
            DEVICE_ID="$2"
            shift 2
            ;;
        *)
            TEST_ARG="$1"
            shift
            ;;
    esac
done

print_header

# ------------------------------------------------------------
# macOS Check
# ------------------------------------------------------------
if [[ "$(uname -s)" != "Darwin" ]]; then
    echo -e "${RED}✗ Error: This script must be run on macOS for iOS testing${NC}"
    exit 1
fi
echo -e "${GREEN}✓${NC} Platform: macOS"

# ------------------------------------------------------------
# Maestro Check
# ------------------------------------------------------------
if ! command -v maestro &> /dev/null; then
    if [ -x "$HOME/.maestro/bin/maestro" ]; then
        export PATH="$HOME/.maestro/bin:$PATH"
    else
        echo -e "${YELLOW}Maestro not found. Installing...${NC}"
        curl -Ls "https://get.maestro.mobile.dev" | bash
        export PATH="$HOME/.maestro/bin:$PATH"
    fi
fi
echo -e "${GREEN}✓${NC} Maestro found: $(command -v maestro)"

# ------------------------------------------------------------
# maestro-ios-device Check & Install
# ------------------------------------------------------------
if ! command -v maestro-ios-device &> /dev/null; then
    echo -e "${YELLOW}maestro-ios-device not found. Installing...${NC}"
    echo -e "${CYAN}  This enables Maestro to run on physical iOS devices${NC}"
    curl -fsSL https://raw.githubusercontent.com/devicelab-dev/maestro-ios-device/main/setup.sh | bash

    if ! command -v maestro-ios-device &> /dev/null; then
        echo -e "${RED}✗ Error: maestro-ios-device installation failed${NC}"
        echo -e "  Try manual installation: https://github.com/devicelab-dev/maestro-ios-device"
        exit 1
    fi
fi
echo -e "${GREEN}✓${NC} maestro-ios-device found: $(command -v maestro-ios-device)"

# ------------------------------------------------------------
# Get Apple Team ID
# ------------------------------------------------------------
if [ -z "$TEAM_ID" ]; then
    echo -e "${YELLOW}Detecting Apple Team ID...${NC}"
    TEAM_ID=$(security find-identity -v -p codesigning 2>/dev/null | grep "Apple Development" | head -1 | awk -F'[()]' '{print $(NF-1)}' | tr -d ' ')

    if [ -z "$TEAM_ID" ]; then
        TEAM_ID=$(security find-identity -v -p codesigning 2>/dev/null | grep "Developer" | head -1 | awk -F'[()]' '{print $(NF-1)}' | tr -d ' ')
    fi

    if [ -z "$TEAM_ID" ]; then
        echo -e "${RED}✗ Error: Could not detect Apple Team ID${NC}"
        echo -e "  Run: ${CYAN}security find-identity -v -p codesigning${NC}"
        echo -e "  Then pass it with: ${CYAN}--team-id YOUR_TEAM_ID${NC}"
        exit 1
    fi
fi
echo -e "${GREEN}✓${NC} Apple Team ID: $TEAM_ID"

# ------------------------------------------------------------
# Get Connected iOS Device
# ------------------------------------------------------------
if [ -z "$DEVICE_ID" ]; then
    echo -e "${YELLOW}Detecting connected iOS device...${NC}"
    DEVICE_ID=$(xcrun xctrace list devices 2>&1 | grep -v "Simulator" | grep -E "iPhone|iPad" | head -1 | awk -F'[()]' '{print $(NF-1)}')
fi

if [ -z "$DEVICE_ID" ]; then
    echo -e "${RED}✗ Error: No iOS device found${NC}"
    echo -e "  Please connect an iPhone/iPad via USB"
    echo -e "  Run: ${CYAN}xcrun xctrace list devices${NC} to see available devices"
    exit 1
fi

DEVICE_NAME=$(xcrun xctrace list devices 2>&1 | grep "$DEVICE_ID" | sed 's/ (.*//')
echo -e "${GREEN}✓${NC} iOS device: $DEVICE_NAME"
echo -e "${GREEN}✓${NC} Device UDID: $DEVICE_ID"
echo -e "${GREEN}✓${NC} Hot Wallet tests: $HOT_WALLET_TESTS_DIR"
echo -e "${GREEN}✓${NC} Passport Wallet tests: $PASSPORT_WALLET_TESTS_DIR"

# ------------------------------------------------------------
# Build iOS App (IPA for physical device)
# ------------------------------------------------------------
build_ios_app() {
    echo ""
    cd "$PROJECT_ROOT"

    echo -e "${YELLOW}Building iOS app for physical device...${NC}"
    flutter build ios --profile

    APP_PATH="$PROJECT_ROOT/build/ios/iphoneos/Runner.app"
    IPA_PATH="$PROJECT_ROOT/build/ios/iphoneos/Envoy.ipa"

    if [ ! -d "$APP_PATH" ]; then
        APP_PATH="$PROJECT_ROOT/build/ios/Debug-iphoneos/Runner.app"
        IPA_PATH="$PROJECT_ROOT/build/ios/Debug-iphoneos/Envoy.ipa"
    fi

    if [ ! -d "$APP_PATH" ]; then
        echo -e "${RED}✗ Error: Could not find built app at expected paths${NC}"
        echo -e "  Tried: build/ios/iphoneos/Runner.app"
        echo -e "  Tried: build/ios/Debug-iphoneos/Runner.app"
        exit 1
    fi

    echo -e "${YELLOW}Creating IPA package...${NC}"

    PAYLOAD_DIR="$PROJECT_ROOT/build/ios/Payload"
    rm -rf "$PAYLOAD_DIR"
    mkdir -p "$PAYLOAD_DIR"
    cp -r "$APP_PATH" "$PAYLOAD_DIR/"

    cd "$PROJECT_ROOT/build/ios"
    rm -f "Envoy.ipa"
    zip -r "Envoy.ipa" Payload -x "*.DS_Store"
    rm -rf "$PAYLOAD_DIR"

    APP_FILE="$PROJECT_ROOT/build/ios/Envoy.ipa"
    echo -e "${GREEN}✓${NC} IPA created: $APP_FILE"

    echo -e "${YELLOW}Installing app on device...${NC}"
    flutter install -d "$DEVICE_ID" --profile || {
        echo -e "${RED}✗ Failed to install app${NC}"
        exit 1
    }
    echo -e "${GREEN}✓${NC} App installed on device"

    cd "$PROJECT_ROOT"
}

if [ "$BUILD_APP" = true ]; then
    build_ios_app
else
    if [ -f "$PROJECT_ROOT/build/ios/Envoy.ipa" ]; then
        APP_FILE="$PROJECT_ROOT/build/ios/Envoy.ipa"
        echo -e "${GREEN}✓${NC} Using existing IPA: $APP_FILE"
    elif [ -f "$PROJECT_ROOT/build/ios/iphoneos/Envoy.ipa" ]; then
        APP_FILE="$PROJECT_ROOT/build/ios/iphoneos/Envoy.ipa"
        echo -e "${GREEN}✓${NC} Using existing IPA: $APP_FILE"
    else
        echo -e "${YELLOW}⚠ No IPA found. Some commands (clearState) may not work.${NC}"
        echo -e "  Run with ${CYAN}--build${NC} to create IPA"
    fi
fi

# ------------------------------------------------------------
# Start Device Bridge (using pre-built XCTest runner)
# ------------------------------------------------------------
echo ""
echo -e "${YELLOW}Starting iOS test bridge...${NC}"

XCTESTRUN_FILE=$(find ~/Library/Developer/Xcode/DerivedData/maestro-driver-ios* -name "*.xctestrun" 2>/dev/null | head -1)

if [ -z "$XCTESTRUN_FILE" ]; then
    echo -e "${RED}✗ Error: No pre-built XCTest runner found${NC}"
    echo -e "  Please build the maestro-driver-ios project in Xcode first:"
    echo -e "  1. Open: ${CYAN}~/.maestro/maestro-ios-xctest-runner/maestro-driver-ios.xcodeproj${NC}"
    echo -e "  2. Select your iPhone as destination"
    echo -e "  3. Press ${CYAN}Cmd+Shift+U${NC} (Build For Testing)"
    exit 1
fi

echo -e "${GREEN}✓${NC} Found XCTest runner: $(basename "$XCTESTRUN_FILE")"

echo -e "${YELLOW}Deploying test runner to device...${NC}"
xcodebuild test-without-building \
    -xctestrun "$XCTESTRUN_FILE" \
    -destination "id=$DEVICE_ID" \
    > /tmp/xctest-runner.log 2>&1 &
XCTEST_PID=$!

sleep 5

if ! kill -0 "$XCTEST_PID" 2>/dev/null; then
    echo -e "${RED}✗ Error: XCTest runner failed to start${NC}"
    cat /tmp/xctest-runner.log | tail -20
    exit 1
fi

echo -e "${YELLOW}Starting port forwarding...${NC}"
iproxy "$DRIVER_PORT" 22087 -u "$DEVICE_ID" > /tmp/iproxy.log 2>&1 &
IPROXY_PID=$!

echo -e "${YELLOW}Waiting for bridge to be ready...${NC}"
MAX_WAIT=30
WAITED=0
while ! lsof -i ":$DRIVER_PORT" >/dev/null 2>&1; do
    if ! kill -0 "$IPROXY_PID" 2>/dev/null; then
        echo -e "${RED}✗ Error: Port forwarding failed${NC}"
        cat /tmp/iproxy.log
        exit 1
    fi

    sleep 1
    WAITED=$((WAITED + 1))

    if [ $WAITED -ge $MAX_WAIT ]; then
        echo -e "${RED}✗ Error: Timeout waiting for port forwarding${NC}"
        exit 1
    fi
done

echo -e "${GREEN}✓${NC} Bridge ready on port $DRIVER_PORT"
echo -e "${GREEN}✓${NC} XCTest runner PID: $XCTEST_PID"
echo -e "${GREEN}✓${NC} Port forwarding PID: $IPROXY_PID"

# ------------------------------------------------------------
# Test Runner
# ------------------------------------------------------------
PASSED=0
FAILED=0
FAILED_TESTS=()

run_single_test() {
    local test_file="$1"
    local test_name
    test_name="$(basename "$test_file")"

    # Skip Android-specific tests
    if [[ "$test_name" == *"android"* ]] || [[ "$test_name" == *"Android"* ]]; then
        echo -e "${YELLOW}⏭ SKIPPED (Android-specific):${NC} $test_name"
        return
    fi

    print_test_start "$test_name"

    MAESTRO_ARGS="--driver-host-port $DRIVER_PORT --device $DEVICE_ID"

    if [ -n "$APP_FILE" ]; then
        MAESTRO_ARGS="$MAESTRO_ARGS --app-file $APP_FILE"
    fi

    OUTPUT=$(maestro $MAESTRO_ARGS test "$test_file" 2>&1)
    EXIT_CODE=$?

    if [ $EXIT_CODE -eq 0 ]; then
        print_test_success "$test_name"
        ((PASSED++))
    else
        print_test_failure "$test_name" "$OUTPUT"
        ((FAILED++))
        FAILED_TESTS+=("$test_name")
    fi
}

run_test_group() {
    local group_name="$1"
    local tests_dir="$2"

    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}${BOLD}  Running group: $group_name${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"

    if [ -n "$TEST_ARG" ]; then
        TEST_FILE="$tests_dir/$TEST_ARG"
        [ -f "$TEST_FILE" ] || {
            echo -e "${RED}✗ Test not found: $TEST_FILE${NC}"
            return
        }
        run_single_test "$TEST_FILE"
    else
        echo -e "${CYAN}Test files found:${NC}"
        ls -1 "$tests_dir"/*.yaml 2>&1 || echo "No files found!"
        echo ""
        for test_file in "$tests_dir"/*.yaml; do
            [ -f "$test_file" ] && run_single_test "$test_file"
        done
    fi
}

# --- Group 1: Hot Wallet Tests ---
run_test_group "Hot Wallet Tests" "$HOT_WALLET_TESTS_DIR"

# --- Group 2: Passport Wallet Tests ---
run_test_group "Passport Wallet Tests" "$PASSPORT_WALLET_TESTS_DIR"

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------
print_summary "$PASSED" "$FAILED"

if [ ${#FAILED_TESTS[@]} -gt 0 ]; then
    echo -e "${RED}Failed tests:${NC}"
    for test in "${FAILED_TESTS[@]}"; do
        echo -e "  ${RED}•${NC} $test"
    done
    echo ""
fi

# ------------------------------------------------------------
# Cleanup (handled by trap)
# ------------------------------------------------------------
echo -e "${YELLOW}Cleaning up...${NC}"

if [ $FAILED -gt 0 ]; then
    exit 1
fi

exit 0
