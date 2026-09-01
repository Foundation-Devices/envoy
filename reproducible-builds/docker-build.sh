#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
# SPDX-License-Identifier: GPL-3.0-or-later

set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
repository_root=$(cd "$script_dir/.." && pwd -P)
docker_image=${ENVOY_REPRODUCIBLE_DOCKER_IMAGE:-envoy-reproducible-android:local}
docker_container_name=envoy-reproducible-android-build
docker_cache_volume=envoy-reproducible-build-cache
output_directory="$script_dir/generated"

fail() {
    echo "error: $*" >&2
    exit 1
}

resolve_docker() {
    if [[ -n ${DOCKER:-} ]]; then
        printf '%s\n' "$DOCKER"
    elif command -v docker >/dev/null; then
        command -v docker
    elif [[ -x /Applications/Docker.app/Contents/Resources/bin/docker ]]; then
        printf '%s\n' /Applications/Docker.app/Contents/Resources/bin/docker
    else
        return 1
    fi
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --output-directory)
            [[ $# -ge 2 ]] || fail "--output-directory requires a path"
            output_directory=$2
            shift 2
            ;;
        --help|-h)
            cat <<'EOF'
Usage: reproducible-builds/docker-build.sh [--output-directory DIRECTORY]

Builds the unsigned Envoy AAB and its universal and split APKs in pinned
linux/amd64 Docker and Nix. Artifacts default to reproducible-builds/generated.
EOF
            exit 0
            ;;
        *)
            fail "unknown argument: $1"
            ;;
    esac
done

docker_binary=$(resolve_docker) || fail "Docker was not found"
export PATH="$(dirname "$docker_binary"):$PATH"
"$docker_binary" info >/dev/null 2>&1 || fail "the Docker daemon is not running"
[[ $(git -C "$repository_root" status --porcelain) == "" ]] ||
    fail "reproducible builds require a clean checkout"

active_cache_users=$("$docker_binary" ps \
    --filter "volume=$docker_cache_volume" \
    --format '{{.Names}}')
if [[ -n $active_cache_users ]]; then
    fail "another reproducible Android build is already running: $active_cache_users. Wait for it to finish before retrying"
fi
if "$docker_binary" container inspect "$docker_container_name" >/dev/null 2>&1; then
    fail "the stopped container $docker_container_name still exists; inspect or remove it before retrying"
fi

if [[ $output_directory != /* ]]; then
    output_directory="$repository_root/$output_directory"
fi
mkdir -p "$output_directory" "$repository_root/build/reproducible"
output_directory=$(cd "$output_directory" && pwd -P)

temporary_output=$(mktemp -d "$repository_root/build/reproducible/docker-output.XXXXXX")
cleanup() {
    rm -f \
        "$temporary_output/app-release.aab" \
        "$temporary_output/app-release.apk" \
        "$temporary_output/release-manifest.json"
    rm -rf "$temporary_output/app-release-apks"
    rmdir "$temporary_output" 2>/dev/null || true
}
trap cleanup EXIT

"$docker_binary" build \
    --platform linux/amd64 \
    --tag "$docker_image" \
    --file "$script_dir/Dockerfile" \
    "$script_dir"

"$docker_binary" run --rm \
    --name "$docker_container_name" \
    --platform linux/amd64 \
    --mount "type=bind,source=$repository_root,target=/workspace,readonly" \
    --mount "type=bind,source=$temporary_output,target=/output" \
    --mount "type=volume,source=envoy-reproducible-nix-store,target=/nix" \
    --mount "type=volume,source=$docker_cache_volume,target=/cache" \
    --env ENVOY_REPRODUCIBLE_CACHE_ROOT=/cache \
    --env ENVOY_REPRODUCIBLE_BUILD_JOBS="${ENVOY_REPRODUCIBLE_BUILD_JOBS:-2}" \
    --env "ENVOY_REPRODUCIBLE_GRADLE_OPTS=${ENVOY_REPRODUCIBLE_GRADLE_OPTS:--Dorg.gradle.jvmargs=-Xmx4g -Dfile.encoding=UTF-8 -Dorg.gradle.workers.max=1 -Dorg.gradle.parallel=false -Dorg.gradle.daemon=false}" \
    --env XDG_CACHE_HOME=/cache/xdg \
    --env ENVOY_HOST_UID="$(id -u)" \
    --env ENVOY_HOST_GID="$(id -g)" \
    --workdir /workspace \
    "$docker_image" \
    bash -lc '
        set -euo pipefail
        ./reproducible-builds/build.sh --output /output/app-release.aab

        universal_apks=/tmp/envoy-generated-universal.apks
        aapt2_path=$(nix develop .#reproducibleAndroid --command \
            sh -c "command -v aapt2")
        nix develop .#reproducibleAndroid --command bundletool build-apks \
            --bundle=/output/app-release.aab \
            --output="$universal_apks" \
            --mode=universal \
            --aapt2="$aapt2_path"
        nix develop .#reproducibleAndroid --command \
            unzip -p "$universal_apks" universal.apk >/output/app-release.apk

        nix develop .#reproducibleAndroid --command bundletool build-apks \
            --bundle=/output/app-release.aab \
            --output=/output/app-release-apks \
            --output-format=DIRECTORY \
            --aapt2="$aapt2_path"

        nix develop .#reproducibleAndroid --command \
            python3 reproducible-builds/release_manifest.py \
            --aab /output/app-release.aab \
            --apk /output/app-release.apk \
            --output /output/release-manifest.json

        chown -R "$ENVOY_HOST_UID:$ENVOY_HOST_GID" /output
    '

for generated_file in app-release.aab app-release.apk release-manifest.json; do
    [[ -f $temporary_output/$generated_file ]] ||
        fail "Docker did not produce $generated_file"
done
[[ -d $temporary_output/app-release-apks/splits ]] ||
    fail "Docker did not produce the split APK set"

for generated_file in app-release.aab app-release.apk release-manifest.json; do
    mv "$temporary_output/$generated_file" "$output_directory/$generated_file"
done
rm -rf "$output_directory/app-release-apks"
mv "$temporary_output/app-release-apks" "$output_directory/app-release-apks"

echo "Generated Android artifacts in $output_directory"
echo "  AAB: $output_directory/app-release.aab"
echo "  universal APK: $output_directory/app-release.apk"
echo "  split APKs: $output_directory/app-release-apks/splits"
echo "  manifest: $output_directory/release-manifest.json"
