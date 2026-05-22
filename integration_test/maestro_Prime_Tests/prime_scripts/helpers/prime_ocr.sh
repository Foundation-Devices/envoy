#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Cross-platform OCR dispatcher used by the Prime test helpers.
#
#   macOS: uses Apple's Vision framework via scripts/prime_ocr.swift
#          (high accuracy, no installs needed).
#   Linux: uses tesseract (apt-get install tesseract-ocr) for the same
#          job. Lower accuracy than Vision but works in CI containers.
#
# Both backends produce the same line-based output format so the calling
# helpers don't need to care which is in use.
#
# Usage:
#   prime_ocr.sh <image>           # one recognized text per line
#   prime_ocr.sh <image> --pos     # tab-separated: x\ty\tw\th\ttext

set -euo pipefail

usage() {
    echo "usage: prime_ocr.sh <image> [--pos]" >&2
    exit 2
}

[ $# -ge 1 ] || usage
IMG="$1"
EMIT_POS=0
[ "${2:-}" = "--pos" ] && EMIT_POS=1

PLATFORM="$(uname -s)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "$PLATFORM" in
    Darwin)
        if [ "$EMIT_POS" = "1" ]; then
            exec swift "$SCRIPT_DIR/prime_ocr.swift" "$IMG" --pos
        else
            exec swift "$SCRIPT_DIR/prime_ocr.swift" "$IMG"
        fi
        ;;

    Linux)
        if ! command -v tesseract >/dev/null 2>&1; then
            echo "prime_ocr: tesseract not installed; on Debian/Ubuntu run:" >&2
            echo "  sudo apt-get install -y tesseract-ocr" >&2
            exit 1
        fi
        if [ "$EMIT_POS" = "1" ]; then
            # Tesseract TSV columns (level=5 is WORD):
            #   level page block par line word left top width height conf text
            # We emit Vision-compatible:  x  y  w  h  text
            # and drop entries with confidence <= 30 (clearly noise).
            tesseract "$IMG" stdout tsv 2>/dev/null \
              | awk -F'\t' 'NR > 1 && $1 == 5 && $11 > 30 && $12 != "" {
                    print $7"\t"$8"\t"$9"\t"$10"\t"$12
                }'
        else
            tesseract "$IMG" stdout 2>/dev/null
        fi
        ;;

    *)
        echo "prime_ocr: unsupported platform: $PLATFORM" >&2
        exit 1
        ;;
esac
