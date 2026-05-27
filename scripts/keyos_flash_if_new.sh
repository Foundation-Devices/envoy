#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Flash the Prime with the latest KeyOS-dev main *only if* it carries a newer
# KeyOS version than the device currently runs. Intended as a pre-test step:
#
#   - Same version  -> exit 0 immediately; the caller runs the tests normally.
#   - Newer version -> pull main, `just build-all`, enter SAM-BA over USB
#                      (software, via passport-drive), `just flash`, wait for
#                      the device to boot, then unlock it (swipe up + PIN + Done)
#                      so it lands on the home screen ready for tests.
#
# Everything goes through the passport-drive CLI, so the prime-bridge does NOT
# need to be running yet. Resolves the KeyOS-dev checkout from $KEYOS_DEV_DIR
# (falling back to ~/KeyOS-dev), matching prime_driver_setup.sh / prime_bridge.sh.
#
# Usage:  ./scripts/keyos_flash_if_new.sh
#
# Exit codes:  0 = up to date OR update+unlock succeeded (safe to run tests)
#              non-zero = something failed (caller should abort).

set -euo pipefail

# --------------------------------------------------------------------
# Config (override via env)
# --------------------------------------------------------------------
KEYOS_DEV_DIR="${KEYOS_DEV_DIR:-$HOME/KeyOS-dev}"
MAIN_BRANCH="${KEYOS_MAIN_BRANCH:-dev-v1.3.0}"
PD="$KEYOS_DEV_DIR/target/release/passport-drive"

# Records the commit SHA we last flashed, so we only reflash when origin/<main>
# has moved. Lives outside the repo so it survives `git` operations; must be a
# persistent path (NOT /tmp, which clears on reboot and would reflash every boot).
STATE_FILE="${KEYOS_FLASHED_SHA_FILE:-$HOME/.cache/keyos-flashed-sha}"

PIN="${PRIME_PIN:-123456}"

# Post-update unlock screen geometry (screen is 480x800, origin top-left).
# The PIN-pad coordinates are taken from the existing onboarding flow
# (integration_test/maestro_Prime_Tests/(01) primeOnboarding.yaml) so 1-6 are
# known-good; 7/8/9/0 are extrapolated one row down. The swipe-up and the
# settle delays are best-effort — verify them against the actual unlock screen
# and override via env if the layout differs.
SWIPE_SX="${PRIME_SWIPE_SX:-240}"; SWIPE_SY="${PRIME_SWIPE_SY:-650}"
SWIPE_EX="${PRIME_SWIPE_EX:-240}"; SWIPE_EY="${PRIME_SWIPE_EY:-200}"
DONE_X="${PRIME_DONE_X:-400}";     DONE_Y="${PRIME_DONE_Y:-740}"
BOOT_TIMEOUT_S="${PRIME_BOOT_TIMEOUT_S:-120}"
BOOT_SETTLE_S="${PRIME_BOOT_SETTLE_S:-5}"

# PIN digit -> "X Y" on the keypad. 1-6 verified from onboarding; 7-9,0 guessed.
declare -A KEYPAD=(
    [1]="80 520"  [2]="240 520" [3]="400 520"
    [4]="80 600"  [5]="240 600" [6]="400 600"
    [7]="80 680"  [8]="240 680" [9]="400 680"
    [0]="240 760"
)

log()  { echo "==> $*"; }
warn() { echo "!! $*" >&2; }

# --------------------------------------------------------------------
# Preconditions
# --------------------------------------------------------------------
if [[ ! -d "$KEYOS_DEV_DIR" ]]; then
    warn "KeyOS-dev checkout not found at $KEYOS_DEV_DIR — set KEYOS_DEV_DIR"
    exit 1
fi

if [[ ! -x "$PD" ]]; then
    log "passport-drive not built — building it (cargo build --release -p passport-drive)"
    ( cd "$KEYOS_DEV_DIR" && cargo build --release -p passport-drive )
fi

# --------------------------------------------------------------------
# 1. New commits since the last flash?
# --------------------------------------------------------------------
# The keyos_version the device reports (passport-drive get-version) is a frozen
# semver ("1.3.0") — it doesn't change across dev commits, so it can't tell us
# whether main moved. The git SHA the firmware was built from isn't exposed over
# USB either (it only lands in the kernel serial log). So we track the commit we
# last flashed in $STATE_FILE and compare it to origin/<main>'s current HEAD: any
# new commit -> reflash. On a dedicated rig where this script is the only thing
# that flashes the device, that host-side record is the practical source of truth.
# Resolve the target branch. Prefer origin/<branch>, but fall back to a local
# branch so KEYOS_MAIN_BRANCH can point at an unpushed feature branch (e.g.
# samba-usb-debug) for a one-off test run.
log "resolving branch '$MAIN_BRANCH'"
git -C "$KEYOS_DEV_DIR" fetch --quiet origin "$MAIN_BRANCH" 2>/dev/null \
    || log "origin has no '$MAIN_BRANCH' — looking for a local branch"

if git -C "$KEYOS_DEV_DIR" rev-parse --verify --quiet "origin/$MAIN_BRANCH^{commit}" >/dev/null; then
    target_ref="origin/$MAIN_BRANCH"
elif git -C "$KEYOS_DEV_DIR" rev-parse --verify --quiet "refs/heads/$MAIN_BRANCH^{commit}" >/dev/null; then
    target_ref="$MAIN_BRANCH"
else
    warn "branch '$MAIN_BRANCH' not found on origin or locally"
    exit 1
fi

target_sha="$(git -C "$KEYOS_DEV_DIR" rev-parse "$target_ref")"
last_flashed="$(cat "$STATE_FILE" 2>/dev/null || true)"

last_flashed_display="${last_flashed:0:12}"
log "$target_ref @ ${target_sha:0:12}   last flashed: ${last_flashed_display:-<none>}"

if [[ -n "$last_flashed" && "$last_flashed" == "$target_sha" ]]; then
    log "no new commits since last flash — running tests normally"
    exit 0
fi

# --------------------------------------------------------------------
# 2. Check out + build
# --------------------------------------------------------------------
log "new commit on $MAIN_BRANCH (${target_sha:0:12}) — updating"
git -C "$KEYOS_DEV_DIR" checkout "$MAIN_BRANCH"
# Fast-forward to the remote tip if this branch tracks one; a local-only branch
# under test is used exactly as checked out.
if git -C "$KEYOS_DEV_DIR" rev-parse --verify --quiet "origin/$MAIN_BRANCH^{commit}" >/dev/null; then
    git -C "$KEYOS_DEV_DIR" pull --ff-only origin "$MAIN_BRANCH"
fi

log "building firmware (just build-all) — this takes a while"
( cd "$KEYOS_DEV_DIR" && just build-all )

# --------------------------------------------------------------------
# 3. Enter SAM-BA over USB, then flash
# --------------------------------------------------------------------
log "rebooting Prime into SAM-BA mode (software, over usb-debug)"
"$PD" reboot-samba

# `just flash` (no --switch) waits for the SAM-BA device that's now present,
# flashes, verifies, and reboots the device back into normal mode itself.
log "flashing (just flash) — waits for SAM-BA, flashes, reboots to normal"
( cd "$KEYOS_DEV_DIR" && just flash )

# --------------------------------------------------------------------
# 4. Wait for the device to come back up in normal mode
# --------------------------------------------------------------------
log "waiting for device to boot (up to ${BOOT_TIMEOUT_S}s)"
booted=0
for (( t = 0; t < BOOT_TIMEOUT_S; t += 2 )); do
    if "$PD" get-version >/dev/null 2>&1; then booted=1; break; fi
    sleep 2
done
if [[ "$booted" -ne 1 ]]; then
    warn "device did not report a version within ${BOOT_TIMEOUT_S}s after flashing"
    exit 1
fi
# Let the UI settle on the unlock screen before driving it.
sleep "$BOOT_SETTLE_S"

# --------------------------------------------------------------------
# 5. Unlock: swipe up, enter PIN, tap Done
# --------------------------------------------------------------------
log "unlocking: swipe up"
"$PD" swipe "$SWIPE_SX" "$SWIPE_SY" "$SWIPE_EX" "$SWIPE_EY"
sleep 1

log "entering PIN"
for (( i = 0; i < ${#PIN}; i++ )); do
    digit="${PIN:$i:1}"
    coord="${KEYPAD[$digit]:-}"
    if [[ -z "$coord" ]]; then
        warn "no keypad coordinate for digit '$digit'"
        exit 1
    fi
    # shellcheck disable=SC2086
    "$PD" tap $coord
done

log "tapping Done"
"$PD" tap "$DONE_X" "$DONE_Y"

# Record the commit we just flashed so the next run skips when nothing changed.
# Only reached on success (set -e aborts earlier on any failure).
flashed_sha="$(git -C "$KEYOS_DEV_DIR" rev-parse HEAD)"
mkdir -p "$(dirname "$STATE_FILE")"
echo "$flashed_sha" > "$STATE_FILE"
log "recorded flashed commit ${flashed_sha:0:12} -> $STATE_FILE"

log "device updated and unlocked — ready to run tests"
