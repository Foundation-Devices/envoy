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
# REQUIREMENT: KeyOS-dev must already be cloned at $KEYOS_DEV_DIR (default
# ~/KeyOS-dev) — we build/flash from it and won't clone it for you. The branch
# checkout within that repo is automatic.
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
# Plain function instead of `declare -A` so this runs on macOS's stock bash 3.2,
# which has no associative arrays. Returns non-zero for an unknown digit.
keypad_coord() {
    case "$1" in
        1) echo "80 520"  ;; 2) echo "240 520" ;; 3) echo "400 520" ;;
        4) echo "80 600"  ;; 5) echo "240 600" ;; 6) echo "400 600" ;;
        7) echo "80 680"  ;; 8) echo "240 680" ;; 9) echo "400 680" ;;
        0) echo "240 760" ;;
        *) return 1 ;;
    esac
}

log()  { echo "==> $*"; }
warn() { echo "!! $*" >&2; }

# --------------------------------------------------------------------
# Toolchain setup
# --------------------------------------------------------------------
# Uses a plain rustup + brew toolchain. The pinned nightly channel is read
# from rust-toolchain.toml and exported as RUSTUP_TOOLCHAIN for every build
# sub-invocation, because the host's default toolchain may be `stable` and
# rust-toolchain.toml's directory override does NOT propagate to all of
# xtask's sub-cargos — that's the cryptic "could not find specification for
# target armv7a-unknown-xous-elf" failure.
keyos_pinned_toolchain() {
    local f="$KEYOS_DEV_DIR/rust-toolchain.toml"
    [[ -f "$f" ]] && awk -F'"' '/^[[:space:]]*channel[[:space:]]*=/ { print $2; exit }' "$f"
}

# Filled in by ensure_bare_toolchain. keyos_run uses it.
BARE_TOOLCHAIN_CHANNEL=""

# Make the bare toolchain ready. Auto-provides what's cheap (rustup target add,
# scripts/install-stdlib.sh for the Xous std). For tools that require sudo /
# brew cask / cargo install (arm-none-eabi-gcc, cosign2, protoc), checks
# presence and prints the exact command to install. Aborts the script if any
# required piece is missing.
ensure_bare_toolchain() {
    local channel
    channel="$(keyos_pinned_toolchain)"
    if [[ -z "$channel" ]]; then
        warn "could not read toolchain channel from $KEYOS_DEV_DIR/rust-toolchain.toml"
        exit 1
    fi

    if ! command -v rustup >/dev/null 2>&1; then
        warn "rustup not found — install from https://rustup.rs"
        exit 1
    fi

    # The bootloader target. Cheap; just install it if missing.
    if ! ( cd "$KEYOS_DEV_DIR" && rustup target list --installed 2>/dev/null \
            | grep -qx armv7a-none-eabi ); then
        log "installing rust target armv7a-none-eabi for $channel"
        ( cd "$KEYOS_DEV_DIR" && rustup target add armv7a-none-eabi )
    fi

    # The Xous std (armv7a-unknown-xous-elf). Auto-discovered by rustc via
    # <sysroot>/lib/rustlib/<target>/target.json — never appears in `rustc
    # --print target-list`. If the cfg probe errors, install-stdlib.sh
    # downloads the prebuilt sysroot zip and unzips it into the toolchain.
    if ! ( cd "$KEYOS_DEV_DIR" && RUSTUP_TOOLCHAIN="$channel" \
            rustc --print cfg --target armv7a-unknown-xous-elf >/dev/null 2>&1 ); then
        if [[ ! -x "$KEYOS_DEV_DIR/scripts/install-stdlib.sh" ]]; then
            warn "scripts/install-stdlib.sh not found in $KEYOS_DEV_DIR"
            exit 1
        fi
        log "Xous std not in $channel sysroot — running scripts/install-stdlib.sh"
        ( cd "$KEYOS_DEV_DIR" && RUSTUP_TOOLCHAIN="$channel" \
            ./scripts/install-stdlib.sh ) || {
                warn "scripts/install-stdlib.sh failed"
                exit 1
            }
    fi

    # Host tools we don't auto-install (each one is sudo / brew cask / a long
    # cargo build). If any are missing, print the exact one-liner and bail.
    local missing=()
    command -v arm-none-eabi-gcc >/dev/null 2>&1 \
        || missing+=("arm-none-eabi-gcc   →  brew install --cask gcc-arm-embedded")
    command -v cosign2 >/dev/null 2>&1 \
        || missing+=("cosign2             →  cd \$KEYOS_DEV_DIR && cargo install --path imports/cosign2/cosign2-bin")
    command -v protoc >/dev/null 2>&1 \
        || missing+=("protoc              →  brew install protobuf")

    if [[ ${#missing[@]} -gt 0 ]]; then
        warn "bare toolchain is missing host tools:"
        printf '  - %s\n' "${missing[@]}" >&2
        exit 1
    fi

    BARE_TOOLCHAIN_CHANNEL="$channel"
    log "bare toolchain ready (RUSTUP_TOOLCHAIN=$BARE_TOOLCHAIN_CHANNEL)"
}

# Run a build/flash command inside the KeyOS-dev checkout with the pinned
# nightly forced. Only build/flash go through this — passport-drive device
# commands run the prebuilt binary directly.
keyos_run() {
    ( cd "$KEYOS_DEV_DIR" \
        && RUSTUP_TOOLCHAIN="$BARE_TOOLCHAIN_CHANNEL" "$@" )
}

# --------------------------------------------------------------------
# Preconditions
# --------------------------------------------------------------------
if [[ ! -d "$KEYOS_DEV_DIR" ]]; then
    warn "KeyOS-dev checkout not found at $KEYOS_DEV_DIR — set KEYOS_DEV_DIR"
    exit 1
fi

# fail-videos lives next to scripts/. Resolve once and wipe any stale build
# log from a previous failed run — symmetric with how run_maestro.sh wipes
# per-test .log / .png / Prime screenshots at the start of each run.
ENVOY_DEV_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FAIL_VIDEOS_DIR="$ENVOY_DEV_DIR/fail-videos"
mkdir -p "$FAIL_VIDEOS_DIR"
rm -f "$FAIL_VIDEOS_DIR/keyos-build.log"

# Set up the bare toolchain before any keyos_run — exits if prereqs missing.
ensure_bare_toolchain

if [[ ! -x "$PD" ]]; then
    log "passport-drive not built — building it (cargo build --release -p passport-drive)"
    keyos_run cargo build --release -p passport-drive
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

# Stash any local edits in KeyOS-dev (tracked + untracked) before we change
# branches, so in-progress work isn't blown away by `git checkout`. We do NOT
# auto-pop afterwards: this is a flash rig, the local tree should reflect what
# we just flashed, and an auto-pop could conflict against the new tip. The
# stash is labeled and stays around for manual recovery:
#     git -C $KEYOS_DEV_DIR stash list
#     git -C $KEYOS_DEV_DIR stash pop stash@{N}
if [[ -n "$(git -C "$KEYOS_DEV_DIR" status --porcelain)" ]]; then
    stash_msg="keyos_flash_if_new auto-stash $(date '+%Y-%m-%d %H:%M:%S')"
    log "local edits in KeyOS-dev — stashing as \"$stash_msg\" (recover with: git -C $KEYOS_DEV_DIR stash list)"
    git -C "$KEYOS_DEV_DIR" stash push --include-untracked -m "$stash_msg" >/dev/null
fi

git -C "$KEYOS_DEV_DIR" checkout "$MAIN_BRANCH"
# Fast-forward to the remote tip if this branch tracks one; a local-only branch
# under test is used exactly as checked out.
if git -C "$KEYOS_DEV_DIR" rev-parse --verify --quiet "origin/$MAIN_BRANCH^{commit}" >/dev/null; then
    git -C "$KEYOS_DEV_DIR" pull --ff-only origin "$MAIN_BRANCH"
fi

# Quiet build: capture all output to a scratch log; on success only print
# "✓ done" and delete the scratch file, on failure dump the tail in the
# runner's terminal AND move the full log into fail-videos/ so it ships with
# the GitHub artifact bundle alongside test logs/videos/screenshots. Stable
# filename, wiped at start of every run — no per-run loose files.
build_log_tmp="$(mktemp -t keyos-build-XXXXXX).log"
log "Building KeyOS... (this will take a while — live output: $build_log_tmp)"
if keyos_run just build-all >"$build_log_tmp" 2>&1; then
    log "✓ KeyOS built"
    rm -f "$build_log_tmp"
else
    build_log_kept="$FAIL_VIDEOS_DIR/keyos-build.log"
    mv "$build_log_tmp" "$build_log_kept"
    warn "✗ KeyOS build FAILED — last 40 lines:"
    tail -40 "$build_log_kept" >&2
    warn "full build log preserved at: $build_log_kept"
    exit 1
fi

# --------------------------------------------------------------------
# 3. Enter SAM-BA over USB, then flash
# --------------------------------------------------------------------
log "rebooting Prime into SAM-BA mode (software, over usb-debug)"
"$PD" reboot-samba

# `just flash` (no --switch) waits for the SAM-BA device that's now present,
# flashes, verifies, and reboots the device back into normal mode itself.
log "flashing (just flash) — waits for SAM-BA, flashes, reboots to normal"
keyos_run just flash

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
# Settle delay before every interaction in this section so the Prime has time
# to render each screen transition before we drive the next tap/swipe — the
# device sometimes paints slower than passport-drive can dispatch input.
# Matches the TAP_SETTLE_SECONDS the prime-bridge uses for normal taps.
UNLOCK_SETTLE_S="${PRIME_UNLOCK_SETTLE_S:-0.8}"

log "unlocking: swipe up"
sleep "$UNLOCK_SETTLE_S"
"$PD" swipe "$SWIPE_SX" "$SWIPE_SY" "$SWIPE_EX" "$SWIPE_EY"
sleep 1

log "entering PIN"
for (( i = 0; i < ${#PIN}; i++ )); do
    digit="${PIN:$i:1}"
    if ! coord="$(keypad_coord "$digit")"; then
        warn "no keypad coordinate for digit '$digit'"
        exit 1
    fi
    sleep "$UNLOCK_SETTLE_S"
    # shellcheck disable=SC2086
    "$PD" tap $coord
done

log "tapping Done"
sleep "$UNLOCK_SETTLE_S"
"$PD" tap "$DONE_X" "$DONE_Y"

# Record the commit we just flashed so the next run skips when nothing changed.
# Only reached on success (set -e aborts earlier on any failure).
flashed_sha="$(git -C "$KEYOS_DEV_DIR" rev-parse HEAD)"
mkdir -p "$(dirname "$STATE_FILE")"
echo "$flashed_sha" > "$STATE_FILE"
log "recorded flashed commit ${flashed_sha:0:12} -> $STATE_FILE"

log "device updated and unlocked — ready to run tests"
