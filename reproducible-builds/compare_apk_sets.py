#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

"""Match rebuilt and supplied APKs by manifest split ID and compare each pair."""

from __future__ import annotations

import argparse
import subprocess
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

sys.dont_write_bytecode = True

from apkdiff import _tool_path, compare_apks
from release_manifest import PACKAGE_NAME, _apk_identity, _pubspec_version


def _split_id(apk: Path, apkanalyzer: str) -> str:
    process = subprocess.run(
        [apkanalyzer, "manifest", "print", str(apk)],
        check=True,
        capture_output=True,
        text=True,
    )
    root = ET.fromstring(process.stdout)
    return root.get("split") or "base"


def _apk_set(directory: Path, apkanalyzer: str) -> dict[str, Path]:
    result: dict[str, Path] = {}
    for apk in sorted(directory.rglob("*.apk")):
        split_id = _split_id(apk, apkanalyzer)
        if split_id in result:
            raise RuntimeError(
                f"duplicate split ID {split_id!r}: {result[split_id]} and {apk}"
            )
        result[split_id] = apk
    if not result:
        raise RuntimeError(f"no APK files found below {directory}")
    return result


def _validate_source_identity(
    supplied: dict[str, Path], repository: Path, apkanalyzer: str
) -> None:
    version_name, full_version, version_code = _pubspec_version(
        repository.resolve() / "pubspec.yaml"
    )
    if "base" not in supplied:
        raise RuntimeError("the supplied APK set does not contain a base split")

    for split_id, apk in supplied.items():
        package, apk_version_name, apk_version_code = _apk_identity(apk, apkanalyzer)
        if package != PACKAGE_NAME:
            raise RuntimeError(
                f"supplied split {split_id!r} has package {package!r}, "
                f"expected {PACKAGE_NAME!r}"
            )
        if apk_version_code != version_code:
            raise RuntimeError(
                f"supplied split {split_id!r} has version code {apk_version_code}, "
                f"but this checkout declares {version_code}"
            )
        # Configuration split manifests normally omit versionName; the base
        # manifest is authoritative. Reject a non-empty conflicting value.
        if apk_version_name and apk_version_name != version_name:
            raise RuntimeError(
                f"supplied split {split_id!r} has version name {apk_version_name!r}, "
                f"but this checkout declares {version_name!r}"
            )

    base_version_name = _apk_identity(supplied["base"], apkanalyzer)[1]
    if base_version_name != version_name:
        raise RuntimeError(
            f"supplied base split has version name {base_version_name!r}, "
            f"but this checkout declares {version_name!r}"
        )
    print(
        f"Supplied APKs and source both identify {PACKAGE_NAME} "
        f"{full_version} (version code {version_code})"
    )


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("rebuilt_directory", type=Path)
    parser.add_argument("supplied_directory", type=Path)
    parser.add_argument(
        "--allow-rebuilt-extra",
        action="store_true",
        help="compare only split IDs present in the supplied APK directory",
    )
    parser.add_argument(
        "--repository",
        type=Path,
        help="validate supplied APK identity against this source checkout",
    )
    parser.add_argument("--aapt2")
    parser.add_argument("--apkanalyzer")
    arguments = parser.parse_args()

    try:
        apkanalyzer = _tool_path(arguments.apkanalyzer, "apkanalyzer")
        rebuilt = _apk_set(arguments.rebuilt_directory, apkanalyzer)
        supplied = _apk_set(arguments.supplied_directory, apkanalyzer)

        if arguments.repository:
            _validate_source_identity(supplied, arguments.repository, apkanalyzer)

        success = True
        ignored_rebuilt = 0
        for split_id in sorted(rebuilt.keys() | supplied.keys()):
            if split_id not in rebuilt:
                print(f"Supplied-only split: {split_id} ({supplied[split_id]})")
                success = False
                continue
            if split_id not in supplied:
                if arguments.allow_rebuilt_extra:
                    ignored_rebuilt += 1
                    continue
                print(f"Rebuilt-only split: {split_id} ({rebuilt[split_id]})")
                success = False
                continue

            print(f"\n=== split {split_id} ===")
            if not compare_apks(
                rebuilt[split_id],
                supplied[split_id],
                aapt2_path=arguments.aapt2,
                apkanalyzer_path=apkanalyzer,
            ):
                success = False

        if success:
            print(f"\nAll {len(supplied)} supplied APK splits match")
            if ignored_rebuilt:
                print(
                    f"Ignored {ignored_rebuilt} rebuilt configuration splits "
                    "that were not present in the supplied set"
                )
            return 0
        print("\nAPK split sets do not match")
        return 1
    except (OSError, RuntimeError, subprocess.CalledProcessError, ET.ParseError) as error:
        print(f"error: {error}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
