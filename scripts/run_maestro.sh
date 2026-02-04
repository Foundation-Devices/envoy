#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -o pipefail

# ------------------------------------------------------------
# OS Detection
# ------------------------------------------------------------
OS="$(uname -s)"
case "$OS" in
    Linux*)
        PLATFORM="linux"
        ;;
    Darwin*)
        PLATFORM="mac"
        ;;
    *)
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac

# ------------------------------------------------------------
# Paths
# ------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TESTS_DIR="$PROJECT_ROOT/integration_test/maestro_tests"
VIDEO_OUTPUT_DIR="$PROJECT_ROOT/maestro_videos"

DEVICE_ID=""
TEST_ARG=""
BUILD_APP=false

# ------------------------------------------------------------
# Commands (override here if needed later)
# ------------------------------------------------------------
ADB_CMD="adb"
MAESTRO_CMD="maestro"

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
    echo -e "${BLUE}║${NC}${BOLD}         Envoy Maestro Android Test Runner                 ${NC}${BLUE}║${NC}"
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
# Argument Parsing
# ------------------------------------------------------------
while [[ $# -gt 0 ]]; do
    case "$1" in
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

print_header

# ------------------------------------------------------------
# Maestro Check (macOS PATH fix)
# ------------------------------------------------------------
if ! command -v maestro >/dev/null 2>&1; then
    if [ -x "$HOME/.maestro/bin/maestro" ]; then
        export PATH="$HOME/.maestro/bin:$PATH"
    else
        echo -e "${RED}✗ Error: Maestro is not installed or not in PATH${NC}"
        echo -e "  Install with: ${CYAN}curl -Ls https://get.maestro.mobile.dev | bash${NC}"
        exit 1
    fi
fi

# ------------------------------------------------------------
# ADB Check (macOS & Linux)
# ------------------------------------------------------------
if ! command -v adb >/dev/null 2>&1; then
    if [ "$PLATFORM" = "mac" ]; then
        ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-$HOME/Library/Android/sdk}"

        if [ -x "$ANDROID_SDK_ROOT/platform-tools/adb" ]; then
            export PATH="$ANDROID_SDK_ROOT/platform-tools:$PATH"
        else
            echo -e "${RED}✗ Error: adb not found${NC}"
            echo -e "${CYAN}Fix:${NC} Install Android Platform Tools:"
            echo -e "  ${CYAN}brew install android-platform-tools${NC}"
            echo -e "  or ensure Android Studio SDK is installed"
            exit 1
        fi
    else
        echo -e "${RED}✗ Error: adb not found in PATH${NC}"
        exit 1
    fi
fi

ADB_CMD="$(command -v adb)"
echo -e "${GREEN}✓${NC} adb found: $ADB_CMD"


echo -e "${GREEN}✓${NC} Maestro found: $(command -v maestro)"
echo -e "${GREEN}✓${NC} Platform: $PLATFORM"
echo -e "${GREEN}✓${NC} Tests directory: $TESTS_DIR"

# ------------------------------------------------------------
# Video Output Directory
# ------------------------------------------------------------
mkdir -p "$VIDEO_OUTPUT_DIR"
echo -e "${GREEN}✓${NC} Video output directory: $VIDEO_OUTPUT_DIR"

# ------------------------------------------------------------
# Device Detection
# ------------------------------------------------------------
if [ -z "$DEVICE_ID" ]; then
    DEVICE_ID=$($ADB_CMD devices | awk '$2=="device"{print $1; exit}')
fi

if [ -z "$DEVICE_ID" ]; then
    echo -e "${RED}✗ Error: No Android device found${NC}"
    exit 1
fi

echo -e "${GREEN}✓${NC} Using device: $DEVICE_ID"

# ------------------------------------------------------------
# Build & Install (optional)
# ------------------------------------------------------------
if [ "$BUILD_APP" = true ]; then
    echo ""
    echo -e "${YELLOW}Building Android APK...${NC}"
    cd "$PROJECT_ROOT" || exit 1

    flutter build apk --debug || {
        echo -e "${RED}✗ Build failed${NC}"
        exit 1
    }

    echo -e "${YELLOW}Installing APK...${NC}"
    $ADB_CMD -s "$DEVICE_ID" install -r build/app/outputs/flutter-apk/app-debug.apk || {
        echo -e "${RED}✗ Install failed${NC}"
        exit 1
    }

    echo -e "${GREEN}✓${NC} APK installed"
fi

# ------------------------------------------------------------
# Test Runner
# ------------------------------------------------------------
PASSED=0
FAILED=0
FAILED_TESTS=()

run_single_test() {
    local test_file="$1"
    local test_name
    test_name="$(basename "$test_file" .yaml)"
    local timestamp
    timestamp="$(date +%Y%m%d-%H%M%S)"
    local video_file="$VIDEO_OUTPUT_DIR/${test_name}-${timestamp}.mp4"

    print_test_start "$test_name"

    OUTPUT=$(maestro record --device "$DEVICE_ID" "$test_file" --output "$video_file" 2>&1)
    EXIT_CODE=$?

    if [ $EXIT_CODE -eq 0 ]; then
        print_test_success "$test_name"
        ((PASSED++))
        # Remove video for passed tests to save space
        rm -f "$video_file"
    else
        print_test_failure "$test_name" "$OUTPUT"
        ((FAILED++))
        FAILED_TESTS+=("$test_name")
        echo -e "${YELLOW}Video saved:${NC} $video_file"
    fi
}

if [ -n "$TEST_ARG" ]; then
    TEST_FILE="$TESTS_DIR/$TEST_ARG"
    [ -f "$TEST_FILE" ] || {
        echo -e "${RED}✗ Test not found: $TEST_FILE${NC}"
        exit 1
    }
    run_single_test "$TEST_FILE"
else
    echo ""
    echo -e "${YELLOW}Running all tests...${NC}"
    echo -e "${CYAN}DEBUG: Test files found:${NC}"
    ls -1 "$TESTS_DIR"/*.yaml 2>&1 || echo "No files found!"
    echo ""
    for test_file in "$TESTS_DIR"/*.yaml; do
        [ -f "$test_file" ] && run_single_test "$test_file"
    done
fi

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
# Cleanup
# ------------------------------------------------------------
echo -e "${YELLOW}Uninstalling app...${NC}"
$ADB_CMD -s "$DEVICE_ID" uninstall com.foundationdevices.envoy >/dev/null 2>&1 || true

if [ $FAILED -gt 0 ]; then
    exit 1
fi

exit 0
