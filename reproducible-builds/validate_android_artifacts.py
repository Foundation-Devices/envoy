#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
# SPDX-License-Identifier: GPL-3.0-or-later

"""Validate supplied AAB and APK identities against the source checkout."""

from __future__ import annotations

import argparse
import json
import os
import shutil
import subprocess
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

sys.dont_write_bytecode = True

from apkdiff import ANDROID_NAMESPACE, _tool_path, archive_payload_digest
from compare_apk_sets import _apk_set, _validate_source_identity
from release_manifest import (
    PACKAGE_NAME,
    _apk_identity,
    _git_output,
    _pubspec_version,
    _sha256,
)


def _manifest_identity(xml: str) -> tuple[str, str, int]:
    root = ET.fromstring(xml)
    version_name_attribute = f"{{{ANDROID_NAMESPACE}}}versionName"
    version_code_attribute = f"{{{ANDROID_NAMESPACE}}}versionCode"
    package = root.get("package") or ""
    version_name = root.get(version_name_attribute) or ""
    raw_version_code = root.get(version_code_attribute) or ""
    try:
        version_code = int(raw_version_code)
    except ValueError as error:
        raise RuntimeError(f"invalid Android versionCode: {raw_version_code!r}") from error
    return package, version_name, version_code


def _aab_identity(aab: Path, bundletool: str) -> tuple[str, str, int]:
    process = subprocess.run(
        [
            bundletool,
            "dump",
            "manifest",
            f"--bundle={aab}",
            "--module=base",
        ],
        check=True,
        capture_output=True,
        text=True,
    )
    return _manifest_identity(process.stdout)


def _expect_identity(
    label: str,
    identity: tuple[str, str, int],
    expected: tuple[str, str, int],
) -> None:
    if identity != expected:
        raise RuntimeError(
            f"{label} identifies {identity[0]} {identity[1]} "
            f"(version code {identity[2]}), expected {expected[0]} "
            f"{expected[1]} (version code {expected[2]})"
        )


def _validate_manifest(
    manifest_path: Path,
    aab: Path,
    apk: Path,
    repository: Path,
    full_version: str,
    version_name: str,
    version_code: int,
) -> None:
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    commit = _git_output(repository, "rev-parse", "HEAD")
    expected = {
        "aabPayloadSha256": archive_payload_digest(aab),
        "aabSha256": _sha256(aab),
        "apkPayloadSha256": archive_payload_digest(apk),
        "apkSha256": _sha256(apk),
        "applicationId": PACKAGE_NAME,
        "flakeLockSha256": _sha256(repository / "flake.lock"),
        "gitCommit": commit,
        "sourceDateEpoch": int(
            _git_output(repository, "show", "-s", "--format=%ct", commit)
        ),
        "version": full_version,
        "versionCode": version_code,
        "versionName": version_name,
    }
    for key, expected_value in expected.items():
        if manifest.get(key) != expected_value:
            raise RuntimeError(
                f"generated manifest {key} is {manifest.get(key)!r}, "
                f"expected {expected_value!r}"
            )
    print(f"Validated generated artifact manifest for commit {commit}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("aab", type=Path)
    parser.add_argument("apk_input", type=Path)
    parser.add_argument("repository", type=Path)
    parser.add_argument("--manifest", type=Path)
    parser.add_argument("--label", default="supplied")
    arguments = parser.parse_args()

    try:
        bundletool = shutil.which("bundletool")
        if not bundletool:
            raise RuntimeError("bundletool was not found in the Nix environment")
        apkanalyzer = _tool_path(None, "apkanalyzer")
        version_name, full_version, version_code = _pubspec_version(
            arguments.repository.resolve() / "pubspec.yaml"
        )
        expected = (PACKAGE_NAME, version_name, version_code)

        if arguments.manifest:
            if not arguments.apk_input.is_file():
                raise RuntimeError("manifest validation requires one generated APK file")
            _validate_manifest(
                arguments.manifest,
                arguments.aab,
                arguments.apk_input,
                arguments.repository.resolve(),
                full_version,
                version_name,
                version_code,
            )

        _expect_identity(
            f"{arguments.label} AAB",
            _aab_identity(arguments.aab, bundletool),
            expected,
        )

        if arguments.apk_input.is_file():
            _expect_identity(
                f"{arguments.label} APK",
                _apk_identity(arguments.apk_input, apkanalyzer),
                expected,
            )
            apk_count = 1
        elif arguments.apk_input.is_dir():
            apk_set = _apk_set(arguments.apk_input, apkanalyzer)
            _validate_source_identity(
                apk_set, arguments.repository.resolve(), apkanalyzer
            )
            apk_count = len(apk_set)
        else:
            raise RuntimeError(f"APK input not found: {arguments.apk_input}")

        print(
            f"Validated {arguments.label} AAB and {apk_count} APK input(s) for "
            f"{PACKAGE_NAME} {full_version} (version code {version_code})"
        )
        return 0
    except (
        OSError,
        RuntimeError,
        subprocess.CalledProcessError,
        ET.ParseError,
        json.JSONDecodeError,
    ) as error:
        print(f"error: {error}", file=sys.stderr)
        return os.EX_DATAERR


if __name__ == "__main__":
    raise SystemExit(main())
