#!/bin/bash

# SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Standalone Activity-row alignment check (no app instrumentation needed).
#
# Drives the app to the Activity tab with the suite's navigation-only flow
# ("(03) activityAlignmentFiatOn.yaml"), dumps the accessibility tree with
# `maestro hierarchy`, and compares the bounds of the first row's
# left/right columns in scripts/alignment/check_activity_alignment.py.
#
# Because it only reads the regular accessibility tree, this works against
# ANY installed build — including release builds — with no test
# instrumentation in the app. It is the standalone counterpart of the
# (03) post-check that run_maestro.sh performs inside the suite.
#
# Prerequisites: the app is installed and onboarded with at least one
# transaction visible in Activity (balance not hidden), adb + maestro on
# PATH, and an English-locale device (titles are matched by text).
#
# Usage: ./run_alignment_check.sh [--device DEVICE_ID] [--skip-nav]
#   --skip-nav  don't run the navigation flow; assume the Activity tab is
#               already on screen (useful when iterating on the checker)

set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# Same navigation flow the suite uses; it contains no launchApp (the suite
# runner owns the app lifecycle), so this script foregrounds the app first.
NAV_FLOW="$PROJECT_ROOT/integration_test/maestro_Passport_Wallet_Tests/(03) activityAlignmentFiatOn.yaml"
APP_ID="com.foundationdevices.envoy"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

DEVICE_ID=""
SKIP_NAV=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --device)
            DEVICE_ID="$2"
            shift 2
            ;;
        --skip-nav)
            SKIP_NAV=true
            shift
            ;;
        *)
            echo -e "${RED}Unknown argument: $1${NC}"
            exit 2
            ;;
    esac
done

for cmd in adb maestro python3; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        # maestro lives in ~/.maestro/bin on the runners
        if [ "$cmd" = "maestro" ] && [ -x "$HOME/.maestro/bin/maestro" ]; then
            export PATH="$HOME/.maestro/bin:$PATH"
            continue
        fi
        echo -e "${RED}✗ Error: $cmd not found in PATH${NC}"
        exit 2
    fi
done

if [ -z "$DEVICE_ID" ]; then
    DEVICE_ID=$(adb devices | awk '$2=="device"{print $1; exit}')
fi
if [ -z "$DEVICE_ID" ]; then
    echo -e "${RED}✗ Error: no Android device/emulator connected${NC}"
    exit 2
fi
echo -e "${GREEN}✓${NC} Using device: $DEVICE_ID"

# Hierarchy bounds are physical pixels; the checker scales its logical-px
# tolerances by devicePixelRatio = density / 160. Prefer the override
# density if one is set (e.g. via `adb shell wm density NNN`).
DENSITY=$(adb -s "$DEVICE_ID" shell wm density \
    | sed -n 's/.*Override density: \([0-9]*\).*/\1/p;
              s/.*Physical density: \([0-9]*\).*/\1/p' | tail -1)
if [ -z "$DENSITY" ]; then
    echo -e "${YELLOW}! Could not read device density, assuming 160 (scale 1.0)${NC}"
    DENSITY=160
fi
SCALE=$(awk "BEGIN { printf \"%.4f\", $DENSITY / 160 }")
echo -e "${GREEN}✓${NC} Device density: $DENSITY (scale $SCALE)"

if [ "$SKIP_NAV" = false ]; then
    echo -e "${YELLOW}▶ Launching app...${NC}"
    adb -s "$DEVICE_ID" shell monkey -p "$APP_ID" \
        -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1
    sleep 10
    echo -e "${YELLOW}▶ Navigating to the Activity tab...${NC}"
    if ! maestro --device "$DEVICE_ID" test "$NAV_FLOW"; then
        echo -e "${RED}✗ Navigation flow failed — cannot reach the Activity tab${NC}"
        exit 2
    fi
fi

echo -e "${YELLOW}▶ Dumping view hierarchy...${NC}"
HIERARCHY=$(maestro --device "$DEVICE_ID" hierarchy 2>/dev/null)
if [ -z "$HIERARCHY" ]; then
    echo -e "${RED}✗ 'maestro hierarchy' produced no output${NC}"
    exit 2
fi

echo -e "${YELLOW}▶ Checking alignment...${NC}"
if echo "$HIERARCHY" | python3 "$SCRIPT_DIR/check_activity_alignment.py" \
    --density-scale "$SCALE"; then
    echo -e "${GREEN}✓ PASSED:${NC} Activity alignment check"
else
    rc=$?
    echo -e "${RED}✗ FAILED:${NC} Activity alignment check (exit $rc)"
    exit $rc
fi
