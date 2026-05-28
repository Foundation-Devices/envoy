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
PRIME_TESTS_DIR="$PROJECT_ROOT/integration_test/maestro_Prime_Tests"

FAIL_VIDEOS_DIR="$PROJECT_ROOT/fail-videos"
mkdir -p "$FAIL_VIDEOS_DIR"
APP_ID="com.foundationdevices.envoy"

DEVICE_ID=""
TEST_ARG=""
BUILD_APP=false
KEBAB_PID=""
PRIME_PID=""

# On macOS workstations the KeyOS-dev checkout often lives on an external
# drive rather than under $HOME. If KEYOS_DEV_DIR isn't already set and the
# external location exists, prefer it so the spawned prime_bridge inherits
# the correct path. No-op on Linux/CI and when $HOME/KeyOS-dev is used.
if [ "$PLATFORM" = "mac" ] && [ -z "${KEYOS_DEV_DIR:-}" ] && [ -d /Volumes/External2TB/KeyOS-dev ]; then
    export KEYOS_DEV_DIR=/Volumes/External2TB/KeyOS-dev
fi

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

    # Always dump the full captured output to a log file so the user can
    # see exactly what Maestro said when the pattern-extractors below miss.
    local log_path="$FAIL_VIDEOS_DIR/${test_name%.yaml}.log"
    mkdir -p "$FAIL_VIDEOS_DIR"
    printf '%s\n' "$output" > "$log_path"

    # Snapshot the most recent Prime screenshot from the FIRST-attempt run
    # into fail-videos/ so it ships with the GitHub artifact bundle. The
    # retry that follows will overwrite /tmp/prime-*-shot.png — we copy
    # here, before that happens, so the saved image reflects what the
    # Prime actually looked like at the moment the original assertion or
    # OCR step failed.
    local screenshot_path="$FAIL_VIDEOS_DIR/${test_name%.yaml}.png"
    local last_shot
    last_shot=$(ls -t /tmp/prime-*-shot.png 2>/dev/null | head -1)
    if [ -n "$last_shot" ] && [ -f "$last_shot" ]; then
        cp "$last_shot" "$screenshot_path"
    fi

    # Extract the failed command from maestro output. Several layers so a
    # benign description ("Run flow when ... is not visible") in a
    # COMPLETED step doesn't get mistaken for the actual error.
    #
    #   Tier 1: a line ending in "... FAILED" — Maestro's canonical
    #           per-step failure marker. Most reliable.
    #   Tier 2: explicit error-prefix lines like "Element not found:" or
    #           "Assertion is false:" or "[prime_*]" from our JS shims.
    #   Tier 3: loose phrase matches as a last resort (these can grab
    #           benign runFlow descriptions, so they're least preferred).
    local failed_cmd=""
    failed_cmd=$(echo "$output" | grep -E '\.\.\. FAILED$' | head -1)

    if [ -z "$failed_cmd" ]; then
        failed_cmd=$(echo "$output" \
            | grep -E '^(Element (not found|not visible)|Error:|Assertion is false|Caused by:|\[prime_)' \
            | head -1)
    fi

    if [ -z "$failed_cmd" ]; then
        failed_cmd=$(echo "$output" \
            | grep -iE 'unable to find|timed out|could not|couldn'\''t|throw|exception' \
            | head -1)
    fi

    if [ -z "$failed_cmd" ]; then
        failed_cmd=$(echo "$output" | sed -n '/Failed at/,+3p' | head -4)
    fi

    # Pull the failed-action block (the line ending in "... FAILED" plus a
    # few preceding lines) for cases where the selector spans multi-line
    # text, e.g. `Assert that "Passport Prime\nPassport Prime" is
    # visible... FAILED`. grep -B grabs the context window.
    local failed_block=""
    failed_block=$(echo "$output" | grep -B 3 -m 1 -E '\.\.\. FAILED$' || true)

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
        # If we caught a "... FAILED" line, show the surrounding action
        # block too — that's how multi-line selectors (e.g. assertions on
        # text that spans two lines) become readable instead of being
        # truncated mid-quote.
        if [ -n "$failed_block" ]; then
            echo -e "${RED}  Failed action:${NC}"
            echo "$failed_block" | sed 's/^/    /'
        fi
    else
        # Fallback: last meaningful lines (more context than before, since
        # Maestro's trailing promo banner takes ~5 lines and would otherwise
        # crowd out the real error).
        echo -e "${RED}  Output (last 40 lines):${NC}"
        echo "$output" | grep -v '^$' | tail -40 | sed 's/^/    /'
    fi
    echo -e "${YELLOW}  Full log:${NC} $log_path"
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

# ------------------------------------------------------------
# Tesseract (Linux only — macOS uses Vision via prime_ocr.swift)
# ------------------------------------------------------------
# Prime helpers (prime-seeds.sh, prime-verify-step.sh, prime-assert-visible.sh)
# OCR the Prime screen. On Linux that's tesseract; if it's missing we try to
# install it best-effort with apt-get. Non-Debian distros are left to the
# user with a clear message.
if [ "$PLATFORM" = "linux" ] && ! command -v tesseract >/dev/null 2>&1; then
    echo -e "${YELLOW}Tesseract not installed — Prime OCR helpers need it.${NC}"
    if command -v apt-get >/dev/null 2>&1; then
        echo -e "${YELLOW}Installing tesseract-ocr (sudo)...${NC}"
        if sudo apt-get update -qq && sudo apt-get install -y tesseract-ocr; then
            echo -e "${GREEN}✓${NC} tesseract installed"
        else
            echo -e "${RED}✗ apt-get install tesseract-ocr failed${NC}"
            exit 1
        fi
    else
        echo -e "${RED}✗ tesseract not found and apt-get is unavailable.${NC}"
        echo -e "  Install it manually for your distro, e.g.:"
        echo -e "    Fedora:  ${CYAN}sudo dnf install tesseract${NC}"
        echo -e "    Arch:    ${CYAN}sudo pacman -S tesseract${NC}"
        echo -e "    Alpine:  ${CYAN}sudo apk add tesseract-ocr${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}✓${NC} Maestro found: $(command -v maestro)"
echo -e "${GREEN}✓${NC} Platform: $PLATFORM"
echo -e "${GREEN}✓${NC} Hot Wallet tests: $HOT_WALLET_TESTS_DIR"
echo -e "${GREEN}✓${NC} Passport Wallet tests: $PASSPORT_WALLET_TESTS_DIR"
echo -e "${GREEN}✓${NC} Prime tests: $PRIME_TESTS_DIR"

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

    # Android can persist runtime permission grants across uninstall/reinstall
    # for the same signature. Revoke explicitly so the runtime dialogs that
    # the Maestro flows interact with always appear on a fresh install.
    echo -e "${YELLOW}Revoking runtime permissions for clean dialog state...${NC}"
    for perm in \
        android.permission.CAMERA \
        android.permission.ACCESS_FINE_LOCATION \
        android.permission.ACCESS_COARSE_LOCATION \
        android.permission.BLUETOOTH_SCAN \
        android.permission.BLUETOOTH_CONNECT \
        android.permission.POST_NOTIFICATIONS; do
        $ADB_CMD -s "$DEVICE_ID" shell pm revoke "$APP_ID" "$perm" 2>/dev/null || true
    done
    echo -e "${GREEN}✓${NC} Runtime permissions revoked"

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
            check_kebab_subscribed
            return
        fi
        sleep 1
    done
    echo -e "${YELLOW}⚠ Kebab bridge may not be ready — kebab commands might fail${NC}"
}

# The HTTP bridge happily ACKs every command (it just publishes to MQTT),
# so /home returning 200 only proves the broker is reachable — not that the
# physical kebab is listening. This walks the broker's $SYS topics to count
# real subscribers; if zero, every command will be a no-op even though the
# test logs say "OK". Best-effort: skipped silently if mosquitto_sub isn't
# installed.
check_kebab_subscribed() {
    if ! command -v mosquitto_sub >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠ mosquitto_sub not installed — skipping subscriber check${NC}"
        return
    fi
    local subs
    subs=$(mosquitto_sub -h 127.0.0.1 -p 1235 \
                -t '$SYS/broker/subscriptions/count' -C 1 -W 2 2>/dev/null || echo "")
    if [ -z "$subs" ]; then
        echo -e "${YELLOW}⚠ Could not query MQTT broker — kebab subscription status unknown${NC}"
    elif [ "$subs" -ge 1 ] 2>/dev/null; then
        echo -e "${GREEN}✓${NC} Kebab is subscribed to MQTT (${subs} active subscriptions)"
    else
        echo -e "${RED}⚠ Kebab is NOT subscribed to MQTT — commands will be silently dropped${NC}"
        echo -e "${YELLOW}  power-cycle the kebab or check its network/USB tether${NC}"
    fi
}

stop_kebab_bridge() {
    if [ -n "$KEBAB_PID" ]; then
        kill "$KEBAB_PID" 2>/dev/null
        wait "$KEBAB_PID" 2>/dev/null
        echo -e "${GREEN}✓${NC} Kebab bridge stopped"
    fi
}

# ------------------------------------------------------------
# Prime HTTP Bridge (passport-drive)
# ------------------------------------------------------------
# Lets Maestro flows drive Prime via runScript JS by hitting the bridge.
# Starts best-effort: if Prime isn't connected or USB setup fails, warn
# and continue — tests that don't touch Prime still work.
start_prime_bridge() {
    if [ -x "$SCRIPT_DIR/prime_driver_setup.sh" ]; then
        echo -e "${YELLOW}Preparing Prime USB interface...${NC}"
        if ! "$SCRIPT_DIR/prime_driver_setup.sh"; then
            echo -e "${YELLOW}⚠ prime-driver-setup failed — Prime tests will not work${NC}"
            return
        fi
    fi

    # If port 7556 is already bound, free it (stale bridge from previous run)
    if lsof -i :7556 >/dev/null 2>&1; then
        local stale
        stale=$(lsof -tiTCP:7556 2>/dev/null)
        if [ -n "$stale" ]; then
            echo -e "${YELLOW}Killing stale Prime bridge on port 7556 (PIDs: $stale)${NC}"
            kill $stale 2>/dev/null || true
            sleep 0.5
        fi
    fi

    echo -e "${YELLOW}Starting Prime HTTP bridge...${NC}"
    "$SCRIPT_DIR/prime_bridge.sh" &
    PRIME_PID=$!

    for i in $(seq 1 10); do
        if curl -s http://localhost:7556/prime/screenshot >/dev/null 2>&1; then
            echo -e "${GREEN}✓${NC} Prime bridge started (PID: $PRIME_PID)"
            return
        fi
        sleep 1
    done
    echo -e "${YELLOW}⚠ Prime bridge may not be ready — Prime commands might fail${NC}"
}

stop_prime_bridge() {
    if [ -n "$PRIME_PID" ]; then
        kill "$PRIME_PID" 2>/dev/null
        wait "$PRIME_PID" 2>/dev/null
        echo -e "${GREEN}✓${NC} Prime bridge stopped"
    fi
}

# ------------------------------------------------------------
# Cleanup trap — fires on normal exit and on SIGINT/SIGTERM, so the
# Kebab motors don't stay energized if a Prime test run is interrupted.
# ------------------------------------------------------------
KEBAB_WAKE_ACTIVE=0

sleep_kebab_motors() {
    [ "$KEBAB_WAKE_ACTIVE" = "1" ] || return 0
    echo -e "${YELLOW}Sleeping Kebab motors...${NC}"
    if curl -s -o /dev/null --max-time 3 http://localhost:7555/disable_motors; then
        echo -e "${GREEN}✓${NC} Kebab motors sleeping"
    else
        echo -e "${YELLOW}⚠ Kebab sleep request failed${NC}"
    fi
    KEBAB_WAKE_ACTIVE=0
}

cleanup_prime_tmp() {
    # Sweep stable-path artifacts from the previous run so they don't
    # linger or get confused with the current run's output. The helper
    # screenshots are stable-path (prime-{seeds,verify,assert}-shot.png)
    # rather than mktemp so users can inspect them after a failure — they
    # survive their own script's exit, but get wiped here on the next run.
    rm -f /tmp/prime-bridge-shot.png \
          /tmp/prime-seeds.txt \
          /tmp/prime-seeds-shot.png \
          /tmp/prime-verify-shot.png \
          /tmp/prime-assert-shot.png \
          /tmp/prime-verify-last-n.txt
}

CLEANED_UP=0
cleanup() {
    # Order matters: send the sleep command before killing the HTTP bridge.
    # NOTE: Prime tmp screenshots are intentionally NOT deleted here — they
    # survive the run so a failure can be inspected after the fact. The
    # next run wipes them before it starts (see call below).
    [ "$CLEANED_UP" = "1" ] && return
    CLEANED_UP=1
    sleep_kebab_motors
    stop_prime_bridge
    stop_kebab_bridge
}

# Ctrl-C / SIGTERM handler. Without this, the default INT trap (`cleanup`)
# would run but bash would continue into the next test_loop iteration —
# meaning a Ctrl-C during one test silently started the next one. We also
# force-disable motors here regardless of KEBAB_WAKE_ACTIVE: the firmware
# re-energizes steppers whenever a position command arrives, so the flag
# isn't a reliable signal of current motor state.
on_interrupt() {
    echo ""
    echo -e "${RED}Interrupted — stopping tests and cleaning up...${NC}"
    curl -s -o /dev/null --max-time 3 http://localhost:7555/disable_motors 2>/dev/null || true
    cleanup
    exit 130
}

trap cleanup EXIT
trap on_interrupt INT TERM

# Wipe stable-path artifacts from the *previous* run before anything new
# happens this run. Screenshots etc. survive their own run for inspection;
# the cleanup is here rather than in the exit trap.
cleanup_prime_tmp

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

    # Wipe any stale .log / .png from a previous run so the files in
    # fail-videos/ always reflect *this* run (present only if this run
    # failed).
    rm -f "$FAIL_VIDEOS_DIR/${test_name%.yaml}.log" \
          "$FAIL_VIDEOS_DIR/${test_name%.yaml}.png"

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

# ------------------------------------------------------------
# Pre-position the Kebab rig at FaceTesterPos2 so it's visually aligned
# from the start of the run, then disable motors. The Hot Wallet and
# Passport Wallet groups don't drive the kebab, so there's no reason to
# leave the steppers energized for that stretch. The Prime group's pre-
# wake (below) re-energizes when it's actually needed.
# ------------------------------------------------------------
echo -e "${YELLOW}Pre-positioning Kebab at FaceTesterPos2...${NC}"
if curl -s -o /dev/null --max-time 5 http://localhost:7555/wake; then
    if curl -s -o /dev/null --max-time 10 http://localhost:7555/face_tester_2; then
        echo -e "${GREEN}✓${NC} Kebab parked at FaceTesterPos2"
    else
        echo -e "${YELLOW}⚠ face_tester_2 failed — rig may be at home${NC}"
    fi
    if curl -s -o /dev/null --max-time 5 http://localhost:7555/disable_motors; then
        echo -e "${GREEN}✓${NC} Kebab motors disabled for non-Prime groups"
    else
        echo -e "${YELLOW}⚠ disable_motors failed — motors may stay energized${NC}"
    fi
else
    echo -e "${YELLOW}⚠ Kebab wake request failed — continuing${NC}"
fi

# --- Group 1: Hot Wallet Tests ---
run_test_group "Hot Wallet Tests" "$HOT_WALLET_TESTS_DIR"

# --- Group 2: Passport Wallet Tests ---
run_test_group "Passport Wallet Tests" "$PASSPORT_WALLET_TESTS_DIR"

# --- Group 3: Prime Tests (cross-device, Android + Prime via passport-drive) ---
# Prime setup happens here, AFTER the phone-only groups above — so a run that
# only touches Hot Wallet / Passport Wallet never pays for (or depends on) the
# Prime rig.
#
# 1) Reflash KeyOS if the chosen branch moved since the last flash. This is a
#    no-op (fast SHA check, exit 0) when nothing changed, so it's safe to run
#    unconditionally — no flag needed. Pick a branch with KEYOS_MAIN_BRANCH.
#    Must run BEFORE the prime bridge binds the USB vendor interface, since
#    flashing drives passport-drive directly and needs exclusive access.
KEYOS_BRANCH="${KEYOS_MAIN_BRANCH:-dev-v1.3.0}"
# Export so keyos_flash_if_new.sh inherits the exact same branch — the banner
# below and the actual flash stay in lockstep.
export KEYOS_MAIN_BRANCH="$KEYOS_BRANCH"
KEYOS_DIR="${KEYOS_DEV_DIR:-$HOME/KeyOS-dev}"
KEYOS_STATE="${KEYOS_FLASHED_SHA_FILE:-$HOME/.cache/keyos-flashed-sha}"

git -C "$KEYOS_DIR" fetch --quiet origin "$KEYOS_BRANCH" 2>/dev/null || true
# Keep BOTH short (for display) and full SHAs (for the equality check the
# flash script does — it stores/compares full SHAs in $KEYOS_STATE).
KEYOS_UPCOMING_FULL=""
if git -C "$KEYOS_DIR" rev-parse --verify --quiet "origin/$KEYOS_BRANCH^{commit}" >/dev/null 2>&1; then
    KEYOS_UPCOMING="$(git -C "$KEYOS_DIR" rev-parse --short "origin/$KEYOS_BRANCH")"
    KEYOS_UPCOMING_FULL="$(git -C "$KEYOS_DIR" rev-parse "origin/$KEYOS_BRANCH")"
elif git -C "$KEYOS_DIR" rev-parse --verify --quiet "refs/heads/$KEYOS_BRANCH^{commit}" >/dev/null 2>&1; then
    KEYOS_UPCOMING="$(git -C "$KEYOS_DIR" rev-parse --short "$KEYOS_BRANCH")"
    KEYOS_UPCOMING_FULL="$(git -C "$KEYOS_DIR" rev-parse "$KEYOS_BRANCH")"
else
    KEYOS_UPCOMING="<branch not found>"
fi
KEYOS_SAVED_FULL="$(cat "$KEYOS_STATE" 2>/dev/null || true)"
KEYOS_SAVED="${KEYOS_SAVED_FULL:0:12}"

# Status line: predicts what the flash script will do. Uses FULL SHAs so it
# matches keyos_flash_if_new.sh's actual diff check (the short forms have
# different widths and can't be compared directly).
if [ -z "$KEYOS_UPCOMING_FULL" ]; then
    KEYOS_STATUS="✗ BRANCH NOT FOUND — flash will abort"
elif [ -z "$KEYOS_SAVED_FULL" ]; then
    KEYOS_STATUS="⚡ FIRST FLASH — no SHA recorded yet, will flash"
elif [ "$KEYOS_SAVED_FULL" = "$KEYOS_UPCOMING_FULL" ]; then
    KEYOS_STATUS="✓ UP TO DATE — no flash needed"
else
    KEYOS_STATUS="⚡ FLASH NEEDED — branch has new commits"
fi

echo ""
echo -e "${GREEN}${BOLD}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}${BOLD}║                  K E Y O S   F L A S H                   ║${NC}"
echo -e "${GREEN}${BOLD}╠══════════════════════════════════════════════════════════╣${NC}"
echo -e "${GREEN}${BOLD}║  BRANCH      : ${KEYOS_BRANCH}${NC}"
echo -e "${GREEN}${BOLD}║  SAVED  SHA  : ${KEYOS_SAVED:-<none>}${NC}"
echo -e "${GREEN}${BOLD}║  UPCOMING SHA: ${KEYOS_UPCOMING}${NC}"
echo -e "${GREEN}${BOLD}║  STATUS      : ${KEYOS_STATUS}${NC}"
echo -e "${GREEN}${BOLD}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${BLUE}Checking KeyOS-dev for new commits to flash...${NC}"
# Free the USB vendor interface first (kills stale holders), same as the bridge.
[ -x "$SCRIPT_DIR/prime_driver_setup.sh" ] && "$SCRIPT_DIR/prime_driver_setup.sh" || true
if ! "$SCRIPT_DIR/keyos_flash_if_new.sh"; then
    echo -e "${RED}✗ KeyOS update/flash failed — aborting before Prime tests${NC}"
    exit 1
fi

# 2) Bring up the prime bridge now that any flashing is done.
start_prime_bridge

# 3) Wake the Kebab motors (enable → home → park at FaceTesterPos2) before the
# group, and sleep them again after, so the steppers aren't energized while
# idle between runs. The cleanup trap above guarantees the sleep command
# is sent even if the script is interrupted mid-group.
echo -e "${YELLOW}Waking Kebab motors for Prime tests...${NC}"
if curl -s -o /dev/null --max-time 5 http://localhost:7555/wake; then
    KEBAB_WAKE_ACTIVE=1
    echo -e "${GREEN}✓${NC} Kebab motors awake"
    # Firmware's `wake` only enables steppers and homes — it does NOT park at
    # FaceTesterPos2. Issue an explicit face_tester_2 so the rig ends up in
    # the intended ready pose with motors still energized.
    if curl -s -o /dev/null --max-time 10 http://localhost:7555/face_tester_2; then
        echo -e "${GREEN}✓${NC} Kebab parked at FaceTesterPos2"
    else
        echo -e "${YELLOW}⚠ Kebab face_tester_2 request failed — rig left at home${NC}"
    fi
else
    echo -e "${YELLOW}⚠ Kebab wake request failed — continuing${NC}"
fi

run_test_group "Prime Tests" "$PRIME_TESTS_DIR"

sleep_kebab_motors

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
# Cleanup — bridges + Kebab sleep are handled by the EXIT trap above.
# ------------------------------------------------------------

echo -e "${YELLOW}Uninstalling app...${NC}"
$ADB_CMD -s "$DEVICE_ID" uninstall com.foundationdevices.envoy >/dev/null 2>&1 || true

if [ $FAILED -gt 0 ]; then
    exit 1
fi

exit 0
