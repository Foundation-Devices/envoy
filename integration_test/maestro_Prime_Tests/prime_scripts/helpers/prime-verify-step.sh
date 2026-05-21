#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

# One round of the Prime "Verify Seed Words" quiz:
#   1. screenshot
#   2. OCR; find the "#N" prompt and locate the correct word from the saved
#      seeds file ($PRIME_SEEDS, default /tmp/prime-seeds.txt) among the 4
#      candidate buttons
#   3. tap that word
#   4. tap the bottom "Tap on Word" / "Continue" button at (240, 745)
#
# How to use
#   ./prime-verify-step.sh                 # one round
#   for i in 1 2 3 4; do ./prime-verify-step.sh; done   # full quiz
#
# Exits non-zero with a diagnostic if the screen doesn't look like a verify
# round (no "#N" found, or the expected word isn't among the candidates).

set -euo pipefail

KEYOS_DEV_DIR="${KEYOS_DEV_DIR:-$HOME/KeyOS-dev}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OCR_CMD="$SCRIPT_DIR/prime_ocr.sh"
SEEDS_FILE="${PRIME_SEEDS:-/tmp/prime-seeds.txt}"
BOTTOM_BUTTON_X=240
BOTTOM_BUTTON_Y=745
# Candidate buttons sit in roughly y=340..510 on the 480×800 screen.
WORDS_Y_MIN=320
WORDS_Y_MAX=520

[ -r "$SEEDS_FILE" ] || { echo "missing seeds file: $SEEDS_FILE" >&2; exit 1; }

# Stable path so the screenshot survives the script exit and can be
# inspected after a failure. Old screenshot is removed at the start of
# every invocation.
SHOT="/tmp/prime-verify-shot.png"
rm -f "$SHOT"

# Retry up to TIMEOUT_S seconds: USB can hiccup right after a tap (device
# busy, partial frame, "Screenshot payload too small"), and the quiz
# screen can be mid-transition. We need both a good screenshot AND the
# "#N" prompt to be readable before proceeding.
TIMEOUT_S=10
OCR=""
N=""
last_err=""
for attempt in $(seq 1 "$TIMEOUT_S"); do
    if ! shot_err=$("$KEYOS_DEV_DIR/target/release/passport-drive" screenshot -o "$SHOT" 2>&1 >/dev/null); then
        last_err="attempt $attempt: screenshot failed: $shot_err"
        echo "$last_err" >&2
        [ "$attempt" -lt "$TIMEOUT_S" ] && sleep 1
        continue
    fi

    if ! OCR=$("$OCR_CMD" "$SHOT" --pos 2>&1); then
        last_err="attempt $attempt: OCR failed: $OCR"
        echo "$last_err" >&2
        [ "$attempt" -lt "$TIMEOUT_S" ] && sleep 1
        continue
    fi

    # Find "#N" — Vision may return it as "#4" or "# 4"; tolerate both.
    N=$(printf '%s\n' "$OCR" | awk -F'\t' '
        $5 ~ /^#[ ]*[0-9]+$/ { gsub(/[# ]/, "", $5); print $5; exit }
    ')
    [ -n "$N" ] && break

    echo "verify-step: attempt $attempt: no \"#N\" prompt yet, retrying..." >&2
    [ "$attempt" -lt "$TIMEOUT_S" ] && sleep 1
done

if [ -z "$N" ]; then
    echo "verify-step: no \"#N\" prompt on screen after ${TIMEOUT_S}s" >&2
    [ -n "$last_err" ] && echo "last error: $last_err" >&2
    exit 1
fi

WORD=$(sed -n "${N}p" "$SEEDS_FILE" | tr -d '[:space:]')
[ -n "$WORD" ] || { echo "verify-step: no word for slot #$N in $SEEDS_FILE" >&2; exit 1; }

# Find that word among the 4 candidate buttons; tap its bounding-box center.
read -r TX TY < <(printf '%s\n' "$OCR" | awk -F'\t' \
    -v word="$WORD" -v ymin="$WORDS_Y_MIN" -v ymax="$WORDS_Y_MAX" '
    $5 == word && $2 > ymin && $2 < ymax {
        cx = $1 + int($3/2)
        cy = $2 + int($4/2)
        print cx, cy
        exit
    }')

if [ -z "${TX:-}" ]; then
    echo "verify-step: word \"$WORD\" (slot #$N) not visible among candidates" >&2
    echo "OCR dump:" >&2
    printf '%s\n' "$OCR" >&2
    exit 1
fi

echo "verify-step #$N: tapping \"$WORD\" at ($TX, $TY)"
"$KEYOS_DEV_DIR/target/release/passport-drive" tap "$TX" "$TY" >/dev/null
sleep 0.4

echo "verify-step #$N: tapping bottom button ($BOTTOM_BUTTON_X, $BOTTOM_BUTTON_Y)"
"$KEYOS_DEV_DIR/target/release/passport-drive" tap "$BOTTOM_BUTTON_X" "$BOTTOM_BUTTON_Y" >/dev/null
