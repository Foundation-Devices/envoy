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

if [[ $# -ne 4 ]]; then
    echo "Usage: $0 GENERATED_DIRECTORY SUPPLIED.aab APK_INPUT file|directory" >&2
    exit 2
fi

generated_directory=$1
supplied_aab=$2
apk_input=$3
apk_input_kind=$4
generated_aab="$generated_directory/app-release.aab"
generated_apk="$generated_directory/app-release.apk"
generated_splits="$generated_directory/app-release-apks/splits"

[[ -n ${IN_NIX_SHELL:-} ]] || fail "verification must run inside 'nix develop'"
[[ -f $generated_aab ]] || fail "generated AAB not found: $generated_aab"
[[ -f $generated_apk ]] || fail "generated APK not found: $generated_apk"
[[ -f $supplied_aab ]] || fail "supplied AAB not found: $supplied_aab"
[[ $apk_input_kind == file || $apk_input_kind == directory ]] ||
    fail "APK input kind must be file or directory"

python3 "$script_dir/validate_android_artifacts.py" \
    "$generated_aab" \
    "$generated_apk" \
    "$repository_root" \
    --manifest "$generated_directory/release-manifest.json" \
    --label generated
python3 "$script_dir/validate_android_artifacts.py" \
    "$supplied_aab" \
    "$apk_input" \
    "$repository_root"

comparison_failed=0
if ! python3 "$script_dir/aabdiff.py" "$generated_aab" "$supplied_aab"; then
    comparison_failed=1
fi

if [[ $apk_input_kind == file ]]; then
    if ! python3 "$script_dir/apkdiff.py" "$generated_apk" "$apk_input"; then
        comparison_failed=1
    fi
else
    [[ -d $generated_splits ]] ||
        fail "generated split APK directory not found: $generated_splits"
    if ! python3 "$script_dir/compare_apk_sets.py" \
        "$generated_splits" \
        "$apk_input" \
        --allow-rebuilt-extra \
        --repository "$repository_root"; then
        comparison_failed=1
    fi
fi

if [[ $comparison_failed -ne 0 ]]; then
    fail "one or more supplied artifacts do not match the generated source build"
fi

echo "All supplied Android artifacts match the generated source build"
