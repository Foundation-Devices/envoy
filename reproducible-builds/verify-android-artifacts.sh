#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
# SPDX-License-Identifier: GPL-3.0-or-later

set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
repository_root=$(cd "$script_dir/.." && pwd -P)

fail() {
    echo "error: $*" >&2
    exit 1
}

absolute_path() {
    local supplied_path=$1
    local supplied_directory
    if [[ -d $supplied_path ]]; then
        (cd "$supplied_path" && pwd -P)
        return
    fi
    supplied_directory=$(cd "$(dirname "$supplied_path")" && pwd -P) || return 1
    printf '%s/%s\n' "$supplied_directory" "$(basename "$supplied_path")"
}

if [[ $# -lt 2 || $# -gt 3 ]]; then
    cat >&2 <<'EOF'
Usage: reproducible-builds/verify-android-artifacts.sh \
  SUPPLIED.aab SUPPLIED.apk|APK_DIRECTORY [GENERATED_DIRECTORY]

Compares supplied Android artifacts with an existing source rebuild. Run
`just build-android-artifacts` first. The generated directory defaults to
reproducible-builds/generated.
EOF
    exit 2
fi

supplied_aab=$(absolute_path "$1") || fail "AAB directory does not exist: $1"
apk_input=$(absolute_path "$2") || fail "APK input directory does not exist: $2"
[[ -f $supplied_aab ]] || fail "AAB not found: $supplied_aab"

if [[ -f $apk_input ]]; then
    [[ $apk_input == *.apk ]] || fail "APK input must end in .apk: $apk_input"
    apk_input_kind=file
elif [[ -d $apk_input ]]; then
    first_apk=$(find "$apk_input" -type f -name '*.apk' -print -quit)
    [[ -n $first_apk ]] || fail "no APK files found below $apk_input"
    apk_input_kind=directory
else
    fail "APK input not found: $apk_input"
fi

generated_directory=${3:-$script_dir/generated}
generated_directory=$(absolute_path "$generated_directory") ||
    fail "generated artifact directory does not exist: $generated_directory"
[[ -d $generated_directory ]] ||
    fail "generated artifact directory not found: $generated_directory"
[[ -f $generated_directory/app-release.aab ]] ||
    fail "generated AAB not found; run 'just build-android-artifacts' first"
[[ -f $generated_directory/app-release.apk ]] ||
    fail "generated APK not found; run 'just build-android-artifacts' first"
[[ -f $generated_directory/release-manifest.json ]] ||
    fail "generated release manifest not found; run 'just build-android-artifacts' first"
if [[ $apk_input_kind == directory ]]; then
    [[ -d $generated_directory/app-release-apks/splits ]] ||
        fail "generated split APKs not found; run 'just build-android-artifacts' first"
fi

command -v nix >/dev/null || fail "Nix is required for artifact verification"
#[[ $(git -C "$repository_root" status --porcelain) == "" ]] ||
#    fail "source verification requires a clean checkout"

nix --extra-experimental-features "nix-command flakes" \
    develop "$repository_root#reproducibleAndroid" --command \
    "$script_dir/verify-generated-artifacts.sh" \
        "$generated_directory" \
        "$supplied_aab" \
        "$apk_input" \
        "$apk_input_kind"
