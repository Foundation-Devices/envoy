#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Capture the Prime "Seed Words" screen and OCR the 12 BIP-39 words into a
# plain text file (one word per line, ordered 1..12). OCR backend is
# dispatched by scripts/prime_ocr.sh (Vision on macOS, tesseract on Linux).
#
# How to use
#   ./prime-seeds.sh                   # writes /tmp/prime-seeds.txt, prints to stdout
#   ./prime-seeds.sh -o /tmp/x.txt     # custom output path
#
# The Prime must be displaying the "Seed Words" screen (12 words in a 2×6 grid).
# Run during the onboarding flow right after "Continue" on the warning modal.

set -euo pipefail

KEYOS_DEV_DIR="${KEYOS_DEV_DIR:-$HOME/KeyOS-dev}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Platform-dispatching OCR helper lives alongside this script.
OCR_CMD="$SCRIPT_DIR/prime_ocr.sh"

OUT="/tmp/prime-seeds.txt"
TIMEOUT_S=10
while [ "$#" -gt 0 ]; do
    case "$1" in
        -o)        OUT="$2"; shift 2 ;;
        --timeout) TIMEOUT_S="$2"; shift 2 ;;
        *)         echo "usage: prime-seeds.sh [-o output.txt] [--timeout SECONDS]" >&2; exit 2 ;;
    esac
done

# Stable path so the screenshot survives the script exit and can be
# inspected after a failure. Old screenshot is removed at the start of
# every invocation so a stale one from a previous run can't be mistaken
# for the current one.
SHOT="/tmp/prime-seeds-shot.png"
rm -f "$SHOT"

# Retry up to TIMEOUT_S seconds: the test may race the Seed Words screen's
# render (animation in-progress, async wallet generation, USB still re-
# enumerating after a Prime reboot). Each attempt = one screenshot + OCR.
last_count=0
last_shot_err=""
LAST_RAW=""
for attempt in $(seq 1 "$TIMEOUT_S"); do
    if ! shot_err=$("$KEYOS_DEV_DIR/target/release/passport-drive" screenshot -o "$SHOT" 2>&1 >/dev/null); then
        last_shot_err="attempt $attempt: screenshot failed: $shot_err"
        echo "$last_shot_err" >&2
        [ "$attempt" -lt "$TIMEOUT_S" ] && sleep 1
        continue
    fi

    # Stash the raw position-tagged OCR so we can print it for diagnostics
    # if the pipeline doesn't yield exactly 12 words.
    LAST_RAW=$("$OCR_CMD" "$SHOT" --pos)
    printf '%s\n' "$LAST_RAW" \
      | awk -F'\t' '
          # columns: x  y  w  h  text  → strip leading "N." from text
          { sub(/^[0-9]+\.?[ ]*/, "", $5); if ($5 ~ /^[a-z]+$/) print $1"\t"$2"\t"$5 }' \
      | awk -F'\t' '
          $2>100 && $2<700 {
            row = int($2 / 60)
            if ($1 < 240) left[row]=$3
            else          right[row]=$3
            if (row > maxr) maxr = row
          }
          END {
            for (r=0; r<=maxr; r++) if (left[r])  print left[r]
            for (r=0; r<=maxr; r++) if (right[r]) print right[r]
          }' \
      > "$OUT"

    last_count=$(wc -l < "$OUT" | tr -d ' ')
    if [ "$last_count" -eq 12 ]; then
        echo "prime-seeds: captured 12 words on attempt $attempt" >&2
        cat "$OUT"
        exit 0
    fi

    echo "prime-seeds: attempt $attempt got $last_count words, retrying..." >&2
    [ "$attempt" -lt "$TIMEOUT_S" ] && sleep 1
done

echo "prime-seeds: expected 12 words, got $last_count after ${TIMEOUT_S}s (saved to $OUT)" >&2
[ -n "$last_shot_err" ] && echo "last screenshot error: $last_shot_err" >&2
echo "last partial output:" >&2
cat "$OUT" >&2
echo "raw OCR (x  y  w  h  text) from last successful screenshot:" >&2
printf '%s\n' "$LAST_RAW" | sed 's/^/  /' >&2
exit 1
