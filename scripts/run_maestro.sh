#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -o pipefail

# Force line-buffered stdout in CI (otherwise output gets block-buffered)
if [ -n "$CI" ] && command -v stdbuf >/dev/null 2>&1 && [ -z "$_LINE_BUFFERED" ]; then
    export _LINE_BUFFERED=1
    exec stdbuf -oL "$0" "$@"
fi

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
HOT_WALLET_TESTS_DIR="$PROJECT_ROOT/integration_test/maestro_Hot_Wallet_Tests"
PASSPORT_WALLET_TESTS_DIR="$PROJECT_ROOT/integration_test/maestro_Passport_Wallet_Tests"

FAIL_VIDEOS_DIR="$PROJECT_ROOT/fail-videos"
mkdir -p "$FAIL_VIDEOS_DIR"
APP_ID="com.foundationdevices.envoy"

DEVICE_ID=""
TEST_ARG=""
BUILD_APP=false
KEBAB_PID=""

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
    local test_file="$3"
    local group_name="$4"

    echo ""
    echo -e "${RED}✗ FAILED:${NC} ${BOLD}$test_name${NC}"
    echo -e "${RED}  Group:${NC}  $group_name"

    # Extract the failed command from maestro output
    local failed_cmd=""
    failed_cmd=$(echo "$output" | grep -iE "element not visible|not visible|unable to find|not found|timed out|assertion.*failed|could not|couldn't" | head -1)

    if [ -z "$failed_cmd" ]; then
        failed_cmd=$(echo "$output" | sed -n '/Failed at/,+3p' | head -4)
    fi

    # Try to find the line number in the YAML file
    if [ -n "$failed_cmd" ] && [ -f "$test_file" ]; then
        local search_term=""
        # Try quoted text first: "some text"
        search_term=$(echo "$failed_cmd" | grep -oE '"[^"]+"' | head -1 | tr -d '"')
        # Try text after common patterns
        if [ -z "$search_term" ]; then
            search_term=$(echo "$failed_cmd" | sed -n 's/.*[Nn]ot [Vv]isible[: ]*//p' | head -1 | xargs)
        fi
        if [ -z "$search_term" ]; then
            # "Element not found: Text matching regex: Proceed with Cancellation"
            search_term=$(echo "$failed_cmd" | sed -n 's/.*[Nn]ot [Ff]ound.*regex[: ]*//p' | head -1 | xargs)
        fi
        if [ -z "$search_term" ]; then
            search_term=$(echo "$failed_cmd" | sed -n 's/.*[Nn]ot [Ff]ound[: ]*//p' | head -1 | xargs)
        fi
        if [ -z "$search_term" ]; then
            search_term=$(echo "$failed_cmd" | sed -n 's/.*[Uu]nable to find[: ]*//p' | head -1 | xargs)
        fi
        if [ -z "$search_term" ]; then
            search_term=$(echo "$failed_cmd" | sed -n 's/.*[Tt]imed out[: ]*//p' | head -1 | xargs)
        fi

        if [ -n "$search_term" ]; then
            local line_match=""
            line_match=$(grep -n "$search_term" "$test_file" | head -1)
            if [ -n "$line_match" ]; then
                local line_num="${line_match%%:*}"
                local line_content="${line_match#*:}"
                echo -e "${RED}  Line $line_num:${NC} $line_content"
            fi
        fi
    fi

    # Print the reason from maestro
    if [ -n "$failed_cmd" ]; then
        echo -e "${RED}  Reason:${NC} $failed_cmd"
    else
        # Fallback: last meaningful lines
        echo -e "${RED}  Output:${NC}"
        echo "$output" | grep -v '^$' | tail -5 | sed 's/^/    /'
    fi
    echo ""
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
# Export ANDROID_HOME so Maestro can find the Android SDK and adb
if [ -z "$ANDROID_HOME" ]; then
    if [ "$PLATFORM" = "linux" ] && [ -d "$HOME/Android/Sdk" ]; then
        export ANDROID_HOME="$HOME/Android/Sdk"
    elif [ "$PLATFORM" = "mac" ] && [ -d "$HOME/Library/Android/sdk" ]; then
        export ANDROID_HOME="$HOME/Library/Android/sdk"
    else
        export ANDROID_HOME="$(dirname "$(dirname "$ADB_CMD")")"
    fi
fi
echo -e "${GREEN}✓${NC} adb found: $ADB_CMD"
echo -e "${GREEN}✓${NC} ANDROID_HOME: $ANDROID_HOME"


echo -e "${GREEN}✓${NC} Maestro found: $(command -v maestro)"
echo -e "${GREEN}✓${NC} Platform: $PLATFORM"
echo -e "${GREEN}✓${NC} Hot Wallet tests: $HOT_WALLET_TESTS_DIR"
echo -e "${GREEN}✓${NC} Passport Wallet tests: $PASSPORT_WALLET_TESTS_DIR"

# ------------------------------------------------------------
# Kill ALL Maestro processes
# ------------------------------------------------------------
# Build a list of ancestor PIDs so we don't kill ourselves or parent chain (just, shell, etc.)
_EXCLUDE_PIDS="$$"
_PID=$PPID
while [ "${_PID:-1}" -gt 1 ]; do
    _EXCLUDE_PIDS="$_EXCLUDE_PIDS|$_PID"
    _PID=$(ps -o ppid= -p "$_PID" 2>/dev/null | tr -d ' ')
done
MAESTRO_PIDS=$(pgrep -f "maestro" 2>/dev/null | grep -vE "^($_EXCLUDE_PIDS)$" || true)
if [ -n "$MAESTRO_PIDS" ]; then
    echo -e "${YELLOW}Killing all Maestro processes (PIDs: $MAESTRO_PIDS)...${NC}"
    echo "$MAESTRO_PIDS" | xargs kill -9 2>/dev/null || true
    sleep 2
fi

# Restart ADB server to clear any stale connections
echo -e "${YELLOW}Restarting ADB server...${NC}"
$ADB_CMD kill-server 2>/dev/null || true
sleep 2
$ADB_CMD start-server 2>/dev/null || true
sleep 3

# ------------------------------------------------------------
# Device Detection (after ADB restart so device is fresh)
# ------------------------------------------------------------
if [ -z "$DEVICE_ID" ]; then
    DEVICE_ID=$($ADB_CMD devices | awk '$2=="device"{print $1; exit}')
fi

if [ -z "$DEVICE_ID" ]; then
    echo -e "${RED}✗ Error: No Android device found${NC}"
    exit 1
fi

echo -e "${GREEN}✓${NC} Using device: $DEVICE_ID"

# Clear stale ADB port forwards
$ADB_CMD -s "$DEVICE_ID" forward --remove-all 2>/dev/null
echo -e "${GREEN}✓${NC} Cleared stale ADB port forwards"

# ------------------------------------------------------------
# Uninstall existing app for a clean install
# ------------------------------------------------------------
echo -e "${YELLOW}Uninstalling existing app...${NC}"
$ADB_CMD -s "$DEVICE_ID" uninstall "$APP_ID" 2>/dev/null || true
echo -e "${GREEN}✓${NC} App uninstalled (clean slate)"

# ------------------------------------------------------------
# Build & Install (optional)
# ------------------------------------------------------------
if [ "$BUILD_APP" = true ]; then
    echo ""
    echo -e "${YELLOW}Building Android APK...${NC}"
    cd "$PROJECT_ROOT" || exit 1

    flutter build apk --debug --dart-define=IS_MAESTRO_TEST=true || {
        echo -e "${RED}✗ Build failed${NC}"
        exit 1
    }

    echo -e "${YELLOW}Installing APK...${NC}"
    $ADB_CMD -s "$DEVICE_ID" install build/app/outputs/flutter-apk/app-debug.apk || {
        echo -e "${RED}✗ Install failed${NC}"
        exit 1
    }

    echo -e "${GREEN}✓${NC} APK installed"

    # Launch app after clean install and wait for cold start to finish
    echo -e "${YELLOW}Launching app (cold start after clean install)...${NC}"
    $ADB_CMD -s "$DEVICE_ID" shell monkey -p "$APP_ID" -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1
    sleep 25
    echo -e "${GREEN}✓${NC} App ready"
fi

# ------------------------------------------------------------
# Video Recording Helpers
# ------------------------------------------------------------
RECORDING_LOOP_PID=""
RECORDING_STOP_FLAG=""

start_screen_recording() {
    # Clean up any previous segments on device
    $ADB_CMD -s "$DEVICE_ID" shell "rm -f /sdcard/fail_seg_*.mp4" 2>/dev/null

    # Create a stop-flag path (file does NOT exist yet — its creation signals "stop")
    RECORDING_STOP_FLAG=$(mktemp -u /tmp/maestro_stop_flag.XXXXXX)
    rm -f "$RECORDING_STOP_FLAG"

    # Background loop that records in 170-second chunks
    (
        SEG=0
        while [ ! -f "$RECORDING_STOP_FLAG" ]; do
            SEG=$((SEG + 1))
            SEG_NUM=$(printf "%03d" "$SEG")
            $ADB_CMD -s "$DEVICE_ID" shell screenrecord --time-limit 170 "/sdcard/fail_seg_${SEG_NUM}.mp4" 2>/dev/null
        done
    ) &
    RECORDING_LOOP_PID=$!
    echo -e "${CYAN}  ▶ Screen recording started (PID: $RECORDING_LOOP_PID)${NC}"
}

stop_screen_recording() {
    local test_name="$1"
    local temp_dir
    temp_dir=$(mktemp -d)

    # Signal the loop to stop — it will exit after the current screenrecord ends
    # instead of starting a new (corrupt) segment
    if [ -n "$RECORDING_STOP_FLAG" ]; then
        touch "$RECORDING_STOP_FLAG"
    fi

    # Send SIGINT to screenrecord on device so it finalizes the mp4 properly
    $ADB_CMD -s "$DEVICE_ID" shell pkill -2 -f screenrecord 2>/dev/null
    sleep 5

    # The loop should have exited (flag file exists), clean up just in case
    if [ -n "$RECORDING_LOOP_PID" ]; then
        kill "$RECORDING_LOOP_PID" 2>/dev/null
        wait "$RECORDING_LOOP_PID" 2>/dev/null
        RECORDING_LOOP_PID=""
    fi

    # Clean up flag file
    rm -f "$RECORDING_STOP_FLAG"
    RECORDING_STOP_FLAG=""

    # Pull all segments from device
    local segments=()
    for seg_path in $($ADB_CMD -s "$DEVICE_ID" shell "ls /sdcard/fail_seg_*.mp4 2>/dev/null" | tr -d '\r'); do
        local seg_name
        seg_name=$(basename "$seg_path")
        $ADB_CMD -s "$DEVICE_ID" pull "$seg_path" "$temp_dir/$seg_name" >/dev/null 2>&1
        segments+=("$temp_dir/$seg_name")
    done

    if [ ${#segments[@]} -eq 0 ]; then
        echo -e "${YELLOW}  ⚠ No video segments captured${NC}"
        rm -rf "$temp_dir"
        return
    fi

    # Merge segments or use last one
    local output_file="$FAIL_VIDEOS_DIR/${test_name}.mp4"
    if [ ${#segments[@]} -eq 1 ]; then
        cp "${segments[0]}" "$output_file"
    elif command -v ffmpeg >/dev/null 2>&1; then
        # Create concat list for ffmpeg
        local concat_list="$temp_dir/concat.txt"
        for seg in "${segments[@]}"; do
            echo "file '$seg'" >> "$concat_list"
        done
        ffmpeg -y -f concat -safe 0 -i "$concat_list" -c copy "$output_file" >/dev/null 2>&1
        if [ $? -ne 0 ]; then
            # Fallback: use the last segment
            cp "${segments[${#segments[@]}-1]}" "$output_file"
        fi
    else
        # No ffmpeg, use the last segment
        cp "${segments[${#segments[@]}-1]}" "$output_file"
    fi

    # Clean up
    $ADB_CMD -s "$DEVICE_ID" shell "rm -f /sdcard/fail_seg_*.mp4" 2>/dev/null
    rm -rf "$temp_dir"

    echo -e "${CYAN}  ▶ Failure video saved: $output_file${NC}"
}

retry_failed_test() {
    local test_file="$1"
    local is_last_test="$2"
    local test_name
    test_name="$(basename "$test_file" .yaml)"
    # Sanitize: replace spaces, parens, and special chars with underscores
    test_name=$(echo "$test_name" | sed 's/[^a-zA-Z0-9._-]/_/g')

    echo -e "${YELLOW}  ▶ Re-running failed test with video recording...${NC}"

    # Restart the app without clearing state
    $ADB_CMD -s "$DEVICE_ID" shell am force-stop "$APP_ID"
    $ADB_CMD -s "$DEVICE_ID" shell monkey -p "$APP_ID" -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1
    echo -e "${CYAN}  ▶ App restarted, waiting 15s for full launch...${NC}"
    sleep 15

    # Start recording
    start_screen_recording

    # Re-run the failed test and capture exit code
    RETRY_OUTPUT=$(maestro --device "$DEVICE_ID" test "$test_file" 2>&1)
    local retry_exit=$?

    # Stop recording and save video
    stop_screen_recording "$test_name"

    if [ $retry_exit -eq 0 ]; then
        # Retry passed — was a flaky failure, delete the video
        echo -e "${GREEN}  ✓ Retry PASSED (flaky failure)${NC}"
        rm -f "$FAIL_VIDEOS_DIR/${test_name}.mp4"
    else
        echo -e "${RED}  ✗ Retry also FAILED${NC}"
    fi

    # Only relaunch app if this is not the last test in the group
    if [ "$is_last_test" != "true" ]; then
        echo -e "${CYAN}  ▶ Relaunching app for next test...${NC}"
        $ADB_CMD -s "$DEVICE_ID" shell am force-stop "$APP_ID"
        $ADB_CMD -s "$DEVICE_ID" shell monkey -p "$APP_ID" -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1
        sleep 15
    fi

    return $retry_exit
}

# ------------------------------------------------------------
# Kebab HTTP Bridge
# ------------------------------------------------------------
start_kebab_bridge() {
    if lsof -i :7555 >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Kebab bridge already running on port 7555"
        return
    fi

    echo -e "${YELLOW}Starting Kebab HTTP bridge...${NC}"
    "$SCRIPT_DIR/kebab_server.sh" &
    KEBAB_PID=$!
    # Wait for the server to be ready
    for i in $(seq 1 10); do
        if curl -s http://localhost:7555/home >/dev/null 2>&1; then
            echo -e "${GREEN}✓${NC} Kebab bridge started (PID: $KEBAB_PID)"
            return
        fi
        sleep 1
    done
    echo -e "${YELLOW}⚠ Kebab bridge may not be ready — kebab commands might fail${NC}"
}

stop_kebab_bridge() {
    if [ -n "$KEBAB_PID" ]; then
        kill "$KEBAB_PID" 2>/dev/null
        wait "$KEBAB_PID" 2>/dev/null
        echo -e "${GREEN}✓${NC} Kebab bridge stopped"
    fi
}

start_kebab_bridge

# ------------------------------------------------------------
# Test Runner
# ------------------------------------------------------------
PASSED=0
FAILED=0
FAILED_TESTS=()
FLAKY_TESTS=()

run_single_test() {
    local test_file="$1"
    local group_name="$2"
    local is_last_test="$3"
    local test_name
    test_name="$(basename "$test_file")"

    print_test_start "$test_name"

    OUTPUT=$(maestro --device "$DEVICE_ID" test "$test_file" 2>&1)
    EXIT_CODE=$?

    if [ $EXIT_CODE -eq 0 ]; then
        print_test_success "$test_name"
        ((PASSED++))
    else
        print_test_failure "$test_name" "$OUTPUT" "$test_file" "$group_name"
        # Retry once with video recording
        if retry_failed_test "$test_file" "$is_last_test"; then
            # Passed on retry — count as passed but mark flaky
            echo -e "${YELLOW}  ⚠ Flaky:${NC} $test_name"
            ((PASSED++))
            FLAKY_TESTS+=("$test_name")
        else
            ((FAILED++))
            FAILED_TESTS+=("$test_name")
        fi
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
        run_single_test "$TEST_FILE" "$group_name" "true"
    else
        echo -e "${CYAN}Test files found:${NC}"
        ls -1 "$tests_dir"/*.yaml 2>&1 || echo "No files found!"
        echo ""
        # Collect test files into an array to detect the last one
        local test_files=()
        for test_file in "$tests_dir"/*.yaml; do
            [ -f "$test_file" ] && test_files+=("$test_file")
        done
        local total=${#test_files[@]}
        local idx=0
        for test_file in "${test_files[@]}"; do
            ((idx++))
            local is_last="false"
            [ "$idx" -eq "$total" ] && is_last="true"
            run_single_test "$test_file" "$group_name" "$is_last"
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

if [ ${#FLAKY_TESTS[@]} -gt 0 ]; then
    echo -e "${YELLOW}Flaky tests (passed on retry):${NC}"
    for test in "${FLAKY_TESTS[@]}"; do
        echo -e "  ${YELLOW}⚠${NC} $test"
    done
    echo ""
fi

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
stop_kebab_bridge

echo -e "${YELLOW}Uninstalling app...${NC}"
$ADB_CMD -s "$DEVICE_ID" uninstall com.foundationdevices.envoy >/dev/null 2>&1 || true

if [ $FAILED -gt 0 ]; then
    exit 1
fi

exit 0
