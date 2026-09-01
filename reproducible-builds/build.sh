#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
repository_root=$(cd "$script_dir/.." && pwd -P)

fail() {
    echo "error: $*" >&2
    exit 1
}

require_canonical_host() {
    if [[ $(uname -s) != "Linux" || $(uname -m) != "x86_64" ]]; then
        fail "the canonical Android release builder requires x86_64 Linux"
    fi
}

build_inside_nix() {
    require_canonical_host

    [[ -n ${IN_NIX_SHELL:-} ]] || fail "the inner build must run inside 'nix develop'"
    [[ $(git -C "$repository_root" status --porcelain --untracked-files=no) == "" ]] ||
        fail "the canonical source checkout contains tracked modifications"

    reproducible_cache_root=${ENVOY_REPRODUCIBLE_CACHE_ROOT:-/tmp/envoy-reproducible-cache}
    mkdir -p \
        "$reproducible_cache_root/cargo" \
        "$reproducible_cache_root/gradle" \
        "$reproducible_cache_root/pub" \
        "$reproducible_cache_root/tmp"

    export CARGO_HOME="$reproducible_cache_root/cargo"
    export CARGO_INCREMENTAL=0
    # Cargo also strips host-side procedural macros in a release build. That
    # corrupts dylibs with some macOS strip versions and is redundant because
    # Android performs the final, consistent device-library strip below.
    export CARGO_PROFILE_RELEASE_STRIP=none
    export GRADLE_USER_HOME="$reproducible_cache_root/gradle"
    export PUB_CACHE="$reproducible_cache_root/pub"
    export TMPDIR="$reproducible_cache_root/tmp"
    export SOURCE_DATE_EPOCH
    SOURCE_DATE_EPOCH=$(git -C "$repository_root" show -s --format=%ct HEAD)
    export TZ=UTC
    export LANG=C.UTF-8
    export LC_ALL=C.UTF-8

    # AGP sizes R8's internal executor from Runtime.availableProcessors(),
    # independently of Gradle's worker limit. Different processor counts can
    # change the compiled baseline.prof even when classes.dex is identical.
    # A single visible processor also removes scheduling as an input to R8's
    # profile rewriting while leaving Cargo's worker setting independent.
    export JAVA_TOOL_OPTIONS="-XX:ActiveProcessorCount=1"

    rust_flag_separator=$(printf '\037')
    export CARGO_ENCODED_RUSTFLAGS="--remap-path-prefix${rust_flag_separator}${repository_root}=/project${rust_flag_separator}--remap-path-prefix${rust_flag_separator}${CARGO_HOME}=/cargo${rust_flag_separator}--remap-path-prefix${rust_flag_separator}${PUB_CACHE}=/pub"

    cd "$repository_root"
    flutter pub get --enforce-lockfile
    python3 "$script_dir/patch-jni-build-id.py" \
        "$repository_root/.dart_tool/package_config.json"

    if [[ ${ENVOY_REPRODUCIBLE_SIGNED:-0} == "1" ]]; then
        [[ -f android/key.jks ]] || fail "the requested signing key was not copied into the canonical checkout"
        [[ -n ${KEY_PASSWORD:-} ]] || fail "KEY_PASSWORD is required for a signed build"
        [[ -n ${ALIAS_PASSWORD:-} ]] || fail "ALIAS_PASSWORD is required for a signed build"
        flutter build appbundle --release --target-platform android-arm64
    else
        ORG_GRADLE_PROJECT_nosign=true \
            flutter build appbundle --release --target-platform android-arm64
    fi

    built_bundle="$repository_root/build/app/outputs/bundle/release/app-release.aab"
    [[ -f $built_bundle ]] || fail "Flutter did not produce $built_bundle"

    [[ $(git status --porcelain --untracked-files=no) == "" ]] ||
        fail "the build modified tracked source files"
}

if [[ ${ENVOY_REPRODUCIBLE_INNER:-0} == "1" ]]; then
    build_inside_nix
    exit 0
fi

output_path="$repository_root/build/reproducible/app-release.aab"
signing_key=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --output)
            [[ $# -ge 2 ]] || fail "--output requires a path"
            output_path=$2
            shift 2
            ;;
        --signing-key)
            [[ $# -ge 2 ]] || fail "--signing-key requires a path"
            signing_key=$2
            shift 2
            ;;
        --help|-h)
            cat <<'EOF'
Usage: reproducible-builds/build.sh [--output PATH] [--signing-key KEYSTORE]

Builds Envoy from the current committed revision in a canonical x86_64-linux
Nix environment. The public build is unsigned unless --signing-key is supplied.
EOF
            exit 0
            ;;
        *)
            fail "unknown argument: $1"
            ;;
    esac
done

require_canonical_host
command -v nix >/dev/null || fail "Nix is required"
command -v git >/dev/null || fail "Git is required"

[[ $(git -C "$repository_root" status --porcelain) == "" ]] ||
    fail "reproducible builds require a clean checkout"

commit=$(git -C "$repository_root" rev-parse HEAD)
canonical_base=${ENVOY_REPRODUCIBLE_WORK_ROOT:-/tmp/envoy-reproducible-build}
canonical_parent="$canonical_base/$commit"
canonical_source="$canonical_parent/project"
marker_file="$canonical_parent/.envoy-reproducible-build"

[[ ! -e $canonical_parent ]] ||
    fail "$canonical_parent already exists; remove this previous reproducible-build workspace and retry"

mkdir -p "$canonical_parent"
printf '%s\n' "$commit" >"$marker_file"

cleanup_canonical_checkout() {
    if [[ ${ENVOY_KEEP_REPRODUCIBLE_WORKDIR:-0} == "1" ]]; then
        echo "Canonical checkout retained at $canonical_parent"
        return
    fi

    if [[ -f $marker_file ]] && [[ $(<"$marker_file") == "$commit" ]]; then
        rm -rf "$canonical_parent"
    fi
}
trap cleanup_canonical_checkout EXIT

git clone --quiet --no-local --no-checkout "$repository_root" "$canonical_source"
git -C "$canonical_source" checkout --quiet --detach "$commit"

signed_build=0
if [[ -n $signing_key ]]; then
    signing_key=$(cd "$(dirname "$signing_key")" && pwd -P)/$(basename "$signing_key")
    [[ -f $signing_key ]] || fail "signing key not found: $signing_key"
    cp "$signing_key" "$canonical_source/android/key.jks"
    signed_build=1
fi

canonical_aapt2=$(nix develop "$canonical_source#reproducibleAndroid" --command \
    sh -c 'command -v aapt2')
[[ -x $canonical_aapt2 ]] || fail "the canonical Nix environment did not provide aapt2"
compatibility_perl=$(nix develop "$repository_root#reproducibleAndroid" --command \
    sh -c 'command -v perl')
[[ -x $compatibility_perl ]] || fail "the reproducible Nix environment did not provide perl"
compatibility_bin=$(dirname "$compatibility_perl")
build_jobs=${ENVOY_REPRODUCIBLE_BUILD_JOBS:-}
if [[ -n $build_jobs && ! $build_jobs =~ ^[1-9][0-9]*$ ]]; then
    fail "ENVOY_REPRODUCIBLE_BUILD_JOBS must be a positive integer"
fi
gradle_options=${ENVOY_REPRODUCIBLE_GRADLE_OPTS:-}

# AGP normally downloads and launches its Maven aapt2 binary. That binary
# expects an FHS dynamic loader at /lib64 on Linux, which is unavailable in the
# NixOS-based Docker image (and fails under Rosetta on Apple silicon). Gradle's
# documented project-property override keeps resource compilation on the
# pinned, Nix-patched aapt2 from flake.nix instead.
nix develop "$canonical_source#reproducibleAndroid" --command \
    bash -c '
        set -euo pipefail
        export PATH="$1:$PATH"
        if [[ -n $2 ]]; then
            export CARGO_BUILD_JOBS="$2"
        fi
        if [[ -n $3 ]]; then
            export GRADLE_OPTS="$3"
        fi
        exec env \
            ENVOY_REPRODUCIBLE_INNER=1 \
            ENVOY_REPRODUCIBLE_SIGNED="$4" \
            "ORG_GRADLE_PROJECT_android.aapt2FromMavenOverride=$5" \
            "$6"
    ' bash \
    "$compatibility_bin" \
    "$build_jobs" \
    "$gradle_options" \
    "$signed_build" \
    "$canonical_aapt2" \
    "$canonical_source/reproducible-builds/build.sh"

canonical_bundle="$canonical_source/build/app/outputs/bundle/release/app-release.aab"
[[ -f $canonical_bundle ]] || fail "canonical build did not produce an AAB"

if [[ $output_path != /* ]]; then
    output_path="$repository_root/$output_path"
fi
mkdir -p "$(dirname "$output_path")"
cp "$canonical_bundle" "$output_path"

echo "Built $output_path"
sha256sum "$output_path"
