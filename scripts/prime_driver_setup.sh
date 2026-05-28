#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Prep this host for driving Prime via passport-drive over USB.
#
# Runs on Linux and macOS:
#
#   Linux:
#     - install /etc/udev/rules.d/99-passport.rules if missing or stale
#     - find Prime's /dev/bus/usb/<bus>/<dev> via lsusb
#     - kill whichever process is holding the vendor debug interface
#       (keyos-log-viewer, stale passport-drive, etc.)
#
#   macOS:
#     - no udev rule needed; IOKit grants vendor-interface access by default
#     - confirm Prime is enumerated via system_profiler
#     - pkill known libusb holders by name (less precise than Linux's
#       fuser-based detection, but Prime only has a couple of candidates)
#
# Resolves the KeyOS-dev checkout from $KEYOS_DEV_DIR (env override) or
# falls back to $HOME/KeyOS-dev. The udev-rule source comes from
# utils/passport-drive/99-passport.rules in that checkout.
#
# Usage:  ./prime_driver_setup.sh

set -euo pipefail

KEYOS_DEV_DIR="${KEYOS_DEV_DIR:-$HOME/KeyOS-dev}"
RULE_SRC="$KEYOS_DEV_DIR/utils/passport-drive/99-passport.rules"

# Process names to kill — only ones that talk to Prime's vendor interface
# via libusb. Add new ones here if you start using more host-side tools.
HOLDER_NAMES=(keyos-log-viewer passport-drive)

# --------------------------------------------------------------------
# Helpers
# --------------------------------------------------------------------
log()  { echo "==> $*"; }
warn() { echo "!! $*" >&2; }

kill_holders_by_name() {
    local killed_any=0
    for NAME in "${HOLDER_NAMES[@]}"; do
        if pgrep -x "$NAME" >/dev/null 2>&1; then
            log "killing $NAME"
            pkill -x "$NAME" || true
            killed_any=1
        fi
    done
    if [[ $killed_any -eq 1 ]]; then
        sleep 0.5
    fi
}

# --------------------------------------------------------------------
# Linux path
# --------------------------------------------------------------------
setup_linux() {
    local RULE_DST="/etc/udev/rules.d/99-passport.rules"

    if [[ ! -f "$RULE_SRC" ]]; then
        warn "$RULE_SRC not found — set KEYOS_DEV_DIR or check the source tree"
        exit 1
    fi

    if [[ -f "$RULE_DST" ]] && cmp -s "$RULE_SRC" "$RULE_DST"; then
        log "udev rule already installed and current"
    else
        log "installing udev rule (sudo)"
        sudo cp "$RULE_SRC" "$RULE_DST"
        sudo udevadm control --reload-rules
        sudo udevadm trigger
        log "(unplug and replug Prime if this is the first install)"
    fi

    local PRIME_LINE
    PRIME_LINE=$(lsusb | grep -E '1307:0165|2c97:7000' | head -1 || true)
    if [[ -z "$PRIME_LINE" ]]; then
        warn "Prime not detected via lsusb — plugged in? USB enabled in Settings?"
        exit 1
    fi
    local BUS DEV USB_PATH
    BUS=$(awk '{print $2}' <<<"$PRIME_LINE")
    DEV=$(awk '{print $4}' <<<"$PRIME_LINE" | tr -d :)
    USB_PATH="/dev/bus/usb/$BUS/$DEV"
    log "Prime at $USB_PATH"

    local HOLDERS
    HOLDERS=$(sudo fuser "$USB_PATH" 2>/dev/null | tr -s ' ' | sed 's/^ *//' || true)

    if [[ -z "$HOLDERS" ]]; then
        log "no process holding the USB device — ready"
        return 0
    fi

    log "processes holding $USB_PATH:"
    for PID in $HOLDERS; do
        local NAME
        NAME=$(ps -p "$PID" -o comm= 2>/dev/null || echo unknown)
        echo "    PID $PID ($NAME)"
    done

    log "killing them"
    sudo kill $HOLDERS 2>/dev/null || true
    sleep 0.5

    local STILL
    STILL=$(sudo fuser "$USB_PATH" 2>/dev/null | tr -s ' ' | sed 's/^ *//' || true)
    if [[ -n "$STILL" ]]; then
        warn "still held: $STILL — try sudo kill -9 $STILL"
        exit 1
    fi
    log "ready — vendor interface free"
}

# --------------------------------------------------------------------
# macOS path
# --------------------------------------------------------------------
setup_macos() {
    log "macOS: no udev rule needed (IOKit handles permissions)"

    # Confirm Prime is enumerated. ioreg is faster than system_profiler and
    # doesn't suffer from the silent-empty-output failures we've seen on some
    # macs. VID 4871 = 0x1307 (Foundation); 11415 = 0x2c97 (legacy).
    if ! ioreg -p IOUSB -l 2>/dev/null | grep -qE '"idVendor" = (4871|11415)\b'; then
        warn "Prime not detected — plugged in? USB enabled in Settings?"
        exit 1
    fi
    log "Prime detected"

    # Can't query "who holds this USB device" precisely on macOS without
    # IOKit-level tooling. Instead kill the known set by name.
    kill_holders_by_name
    log "ready — known holders killed (if any were running)"
}

# --------------------------------------------------------------------
# Dispatch
# --------------------------------------------------------------------
case "$(uname -s)" in
    Linux*)  setup_linux ;;
    Darwin*) setup_macos ;;
    *)       warn "unsupported OS: $(uname -s)"; exit 1 ;;
esac
