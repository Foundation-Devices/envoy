#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

"""Validate Android release identity and write artifact provenance."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import shutil
import subprocess
import sys
import xml.etree.ElementTree as ET
import zipfile
from pathlib import Path

sys.dont_write_bytecode = True

from apkdiff import ANDROID_NAMESPACE, archive_payload_digest


PACKAGE_NAME = "com.foundationdevices.envoy"
VERSION_PATTERN = re.compile(
    r"^version:\s*(?P<major>\d+)\.(?P<minor>\d+)\.(?P<patch>\d+)\+(?P<build>\d+)\s*$",
    re.MULTILINE,
)


def _sha256(path: Path) -> str:
    result = hashlib.sha256()
    with path.open("rb") as source:
        for chunk in iter(lambda: source.read(1024 * 1024), b""):
            result.update(chunk)
    return result.hexdigest()


def _pubspec_version(pubspec: Path) -> tuple[str, str, int]:
    match = VERSION_PATTERN.search(pubspec.read_text(encoding="utf-8"))
    if not match:
        raise RuntimeError(f"unable to parse version from {pubspec}")

    major = int(match.group("major"))
    minor = int(match.group("minor"))
    patch = int(match.group("patch"))
    build = int(match.group("build"))
    version_name = f"{major}.{minor}.{patch}"
    full_version = f"{version_name}+{build}"
    version_code = major * 1_000_000 + minor * 10_000 + patch * 100 + build
    return version_name, full_version, version_code


def _apk_identity(apk: Path, apkanalyzer: str) -> tuple[str, str, int]:
    process = subprocess.run(
        [apkanalyzer, "manifest", "print", str(apk)],
        check=True,
        capture_output=True,
        text=True,
    )
    root = ET.fromstring(process.stdout)
    android_version_name = f"{{{ANDROID_NAMESPACE}}}versionName"
    android_version_code = f"{{{ANDROID_NAMESPACE}}}versionCode"
    package_name = root.get("package") or ""
    version_name = root.get(android_version_name) or ""
    raw_version_code = root.get(android_version_code) or ""
    try:
        version_code = int(raw_version_code)
    except ValueError as error:
        raise RuntimeError(f"invalid APK versionCode: {raw_version_code!r}") from error
    return package_name, version_name, version_code


def _git_output(repository: Path, *arguments: str) -> str:
    process = subprocess.run(
        ["git", "-C", str(repository), *arguments],
        check=True,
        capture_output=True,
        text=True,
    )
    return process.stdout.strip()


def main() -> int:
    script_directory = Path(__file__).resolve().parent
    default_repository = script_directory.parent

    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--aab", required=True, type=Path)
    parser.add_argument("--apk", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--repository", type=Path, default=default_repository)
    parser.add_argument("--commit")
    parser.add_argument("--tag")
    parser.add_argument("--apkanalyzer")
    arguments = parser.parse_args()

    try:
        apkanalyzer = arguments.apkanalyzer or shutil.which("apkanalyzer")
        if not apkanalyzer:
            raise RuntimeError(
                "apkanalyzer was not found; run this command inside 'nix develop'"
            )

        repository = arguments.repository.resolve()
        version_name, full_version, expected_version_code = _pubspec_version(
            repository / "pubspec.yaml"
        )
        package_name, apk_version_name, apk_version_code = _apk_identity(
            arguments.apk, apkanalyzer
        )

        if package_name != PACKAGE_NAME:
            raise RuntimeError(
                f"APK package is {package_name!r}, expected {PACKAGE_NAME!r}"
            )
        if apk_version_name != version_name:
            raise RuntimeError(
                f"APK versionName is {apk_version_name!r}, expected {version_name!r}"
            )
        if apk_version_code != expected_version_code:
            raise RuntimeError(
                f"APK versionCode is {apk_version_code}, expected {expected_version_code}"
        )

        if arguments.tag:
            expected_tag = f"v{version_name}"
            if arguments.tag != expected_tag:
                raise RuntimeError(
                    f"release tag is {arguments.tag!r}, expected {expected_tag!r}"
                )

        commit = arguments.commit or _git_output(repository, "rev-parse", "HEAD")
        checked_out_commit = _git_output(repository, "rev-parse", "HEAD")
        if commit != checked_out_commit:
            raise RuntimeError(
                f"release commit {commit} does not match checkout {checked_out_commit}"
            )

        source_date_epoch = int(
            _git_output(repository, "show", "-s", "--format=%ct", commit)
        )
        manifest = {
            "aabPayloadSha256": archive_payload_digest(arguments.aab),
            "aabSha256": _sha256(arguments.aab),
            "apkPayloadSha256": archive_payload_digest(arguments.apk),
            "apkSha256": _sha256(arguments.apk),
            "applicationId": PACKAGE_NAME,
            "flakeLockSha256": _sha256(repository / "flake.lock"),
            "gitCommit": commit,
            "sourceDateEpoch": source_date_epoch,
            "version": full_version,
            "versionCode": expected_version_code,
            "versionName": version_name,
        }

        arguments.output.parent.mkdir(parents=True, exist_ok=True)
        arguments.output.write_text(
            json.dumps(manifest, indent=2, sort_keys=True) + "\n", encoding="utf-8"
        )
        print(f"Wrote {arguments.output}")
        print(json.dumps(manifest, indent=2, sort_keys=True))
        return 0
    except (
        OSError,
        RuntimeError,
        subprocess.CalledProcessError,
        ET.ParseError,
        zipfile.BadZipFile,
    ) as error:
        print(f"error: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
