<!-- SPDX-FileCopyrightText: 2026 Foundation Devices Inc. -->
<!-- SPDX-License-Identifier: GPL-3.0-or-later -->

# Reproducible Android builds

This directory contains the canonical Envoy Android build and the tools used to
compare it with the APK splits delivered by Google Play.

The verification proves that a tagged source revision produces the same APK
payload as the application installed from Play. Complete APK files are not
expected to have the same SHA-256 digest: public rebuilds are unsigned, while
Google signs delivered APKs with the Play App Signing key and may add narrowly
defined manifest metadata.

## Canonical build environment

The release build platform is x86_64 Linux. `flake.nix` and `flake.lock` pin the
Flutter, Dart, Rust, Java, Android SDK/NDK, `bundletool`, and other build tools.
The build wrapper checks out the selected commit at a deterministic path below
`/tmp/envoy-reproducible-build`, uses stable cache paths, disables incremental
Rust compilation, and remaps embedded Rust source paths.

Install Nix with flakes enabled, check out the exact release tag, and run:

```bash
just reproducible-build
```

or directly:

```bash
./reproducible-builds/build.sh
```

The unsigned result is written to:

```text
build/reproducible/app-release.aab
```

The canonical build uses the current committed `HEAD`; uncommitted source
changes are not included. A release tag such as `v2.3.3` must point to the exact
commit that was built. The release manifest records the complete Flutter
version, including its build component (for example `2.3.3+5`), so verifiers
can reject a tag or checkout with mismatched Android version metadata.

## Generate verification artifacts with Docker

Docker provides the canonical x86_64 Linux host on Linux, Intel macOS, and
Apple silicon macOS. 

Generate the public unsigned AAB, universal APK, and complete split APK set:

```bash
just build-android-artifacts
```

The reusable results are written below `reproducible-builds/generated/`:

```text
app-release.aab
app-release.apk
app-release-apks/splits/
release-manifest.json
```

The Dockerfile pins its base image by digest and the wrapper explicitly selects
`linux/amd64`. The Nix store and build caches are retained in Docker volumes;
all compiler and Android tool versions still come from `flake.lock`. The image
disables Nix's nested sandbox and syscall filter because Docker supplies the
isolation boundary and Rosetta cannot install Nix's Linux seccomp filter.

The canonical build applies a version- and source-checked patch to
`package:jni` 1.0.0 inside its dedicated Pub cache. The patch passes
`-Wl,--build-id=none` only when linking Android's `libdartjni.so`. Its GNU
build ID otherwise changes between independent builds even when every other
linked byte is identical. This is tracked upstream as
[`dart-lang/native#3263`](https://github.com/dart-lang/native/issues/3263).
No Envoy or Rust native-library build ID is changed.

The Java runtime is also restricted to one visible processor during the
canonical build. AGP sizes R8's internal executor from the processors visible
to Java rather than Gradle's worker limit. Different executor sizes can produce
different `baseline.prof` method sets while leaving `classes.dex` unchanged.
Pinning the Java processor count makes profile rewriting use the same serial
configuration on CI and independent Docker rebuilds. This does not restrict
Cargo; Rust parallelism remains controlled separately by
`ENVOY_REPRODUCIBLE_BUILD_JOBS`.

Docker is used only by this generation command. The generated directory is
ignored by Git and can be reused for any number of comparisons against the same
source revision.

## Verify supplied AAB/APK files locally

After generation finishes, verification runs locally through the pinned Nix
tools. It does not invoke Docker, rebuild the application, connect to a device,
or download Play artifacts. Supply the release AAB and either its universal APK
or a directory containing the complete Play split set:

```bash
just verify-android-artifacts \
  /path/to/local-app-release.aab \
  /path/to/local-app-release.apk
```

For Play split APKs already downloaded into a directory:

```bash
just verify-android-artifacts \
  /path/to/local-app-release.aab \
  /path/to/play-apks
```

The direct verification command accepts an optional generated-artifact
directory:

```bash
./reproducible-builds/verify-android-artifacts.sh \
  supplied-app-release.aab supplied-app-release.apk \
  reproducible-builds/generated
```

The verifier:

1. Checks that the generated and supplied artifacts have Envoy's application
   ID, version name, and version code declared by the checked-out source.
2. Compares the generated AAB payload with the supplied AAB payload, excluding
   signing entries and ZIP container metadata.
3. For one supplied APK file, compares the generated universal APK. For an APK
   directory, compares matching manifest split IDs from the generated set.
4. Ignores signing entries, source stamps, documented Play manifest metadata,
   host-specific R8 compilation metrics, and non-runtime AAPT source metadata,
   and diagnoses native-library differences by ELF section.

Docker generation defaults to one Cargo/Gradle worker and a 4 GiB Gradle
heap. Ensure Docker can access at least 10 GiB of memory; Docker Engine on
Linux shares the host's memory, while Docker Desktop requires configuring the
VM limit. Smaller limits can either terminate Gradle or leave too little Java
heap for Android's Jetifier transforms. The first Apple-silicon build is slow
because the x86_64 compiler runs through emulation. With at least 12 GiB
available to Docker, additional Cargo jobs can be enabled with
`ENVOY_REPRODUCIBLE_BUILD_JOBS=2` or higher.

Supplying the AAB and APK downloaded from the GitHub release verifies those CI
artifacts against the previously generated independent source rebuild.
Supplying APK splits obtained from Play additionally verifies what Play
delivered.

Use the complete split set for full Play verification. A lone `base.apk` can
only prove that the base split matches; it cannot verify language, density, or
CPU architecture splits.

You can compare two individual APKs directly:

```bash
python3 reproducible-builds/apkdiff.py rebuilt.apk supplied.apk
```

## Release provenance

The Android release workflow writes `release-manifest.json` next to the AAB. It
contains the exact Git commit, complete application version, Android version
code, source timestamp, `flake.lock` hash, and full-file and canonical payload
hashes for both the signed AAB and signed universal APK. Payload hashes exclude
signing entries and ZIP metadata.
