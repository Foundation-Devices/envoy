#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Screenshot the Prime, OCR it, and assert that a given text appears on
# screen. Polls every second up to a timeout so transient screens (mid-
# transition, async loads) don't false-fail.
#
# How to use
#   ./prime-assert-visible.sh "Create PIN"
#   ./prime-assert-visible.sh "Word #[0-9]+" --regex
#   ./prime-assert-visible.sh "Verify Seed Words" --timeout 10
#
# Matching is case-sensitive substring by default. Use --regex for full
# regex matching (extended regex, via grep -E). The check passes if ANY
# OCR'd line on the screen matches.
#
# Exits 0 on match; exits 1 with a diagnostic (dump of every OCR'd line)
# on miss so failures are easy to diagnose.

set -euo pipefail

KEYOS_DEV_DIR="${KEYOS_DEV_DIR:-$HOME/KeyOS-dev}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OCR_CMD="$SCRIPT_DIR/prime_ocr.sh"

TEXT=""
USE_REGEX=0
TIMEOUT_S=5
while [ "$#" -gt 0 ]; do
    case "$1" in
        --regex)   USE_REGEX=1; shift ;;
        --timeout) TIMEOUT_S="$2"; shift 2 ;;
        -h|--help)
            sed -n '8,22p' "$0"; exit 0 ;;
        *)
            if [ -z "$TEXT" ]; then TEXT="$1"; shift
            else echo "prime-assert-visible: unexpected arg: $1" >&2; exit 2
            fi ;;
    esac
done

[ -n "$TEXT" ] || { echo "prime-assert-visible: missing required <text> argument" >&2; exit 2; }

# Stable path so the screenshot survives the script exit and can be
# inspected after a failure. Old screenshot is removed at the start of
# every invocation.
SHOT="/tmp/prime-assert-shot.png"
rm -f "$SHOT"
LAST_OCR=""
LAST_ERR=""

for attempt in $(seq 1 "$TIMEOUT_S"); do
    # Don't let `set -e` kill us — USB may still be enumerating after a
    # Prime reboot. Capture errors so the loop can retry.
    if ! shot_err=$("$KEYOS_DEV_DIR/target/release/passport-drive" screenshot -o "$SHOT" 2>&1 >/dev/null); then
        LAST_ERR="attempt $attempt: screenshot failed: $shot_err"
        echo "$LAST_ERR" >&2
        [ "$attempt" -lt "$TIMEOUT_S" ] && sleep 1
        continue
    fi

    if ! LAST_OCR=$("$OCR_CMD" "$SHOT" 2>&1); then
        LAST_ERR="attempt $attempt: OCR failed: $LAST_OCR"
        echo "$LAST_ERR" >&2
        [ "$attempt" -lt "$TIMEOUT_S" ] && sleep 1
        continue
    fi

    if [ "$USE_REGEX" = "1" ]; then
        if printf '%s\n' "$LAST_OCR" | grep -Eq -- "$TEXT"; then
            echo "prime-assert-visible: matched \"$TEXT\" (regex) on attempt $attempt"
            exit 0
        fi
    else
        if printf '%s\n' "$LAST_OCR" | grep -Fq -- "$TEXT"; then
            echo "prime-assert-visible: matched \"$TEXT\" on attempt $attempt"
            exit 0
        fi
    fi

    [ "$attempt" -lt "$TIMEOUT_S" ] && sleep 1
done

echo "prime-assert-visible: \"$TEXT\" NOT visible after ${TIMEOUT_S}s" >&2
if [ -n "$LAST_OCR" ]; then
    echo "OCR'd lines from the last successful screenshot:" >&2
    printf '%s\n' "$LAST_OCR" | sed 's/^/  /' >&2
fi
if [ -n "$LAST_ERR" ]; then
    echo "Last error from a failed attempt: $LAST_ERR" >&2
fi
exit 1
