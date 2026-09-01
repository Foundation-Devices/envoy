#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
# SPDX-License-Identifier: GPL-3.0-or-later

"""Compare rebuilt and supplied Android App Bundle payloads."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import struct
import subprocess
import sys
import zipfile
from collections import defaultdict
from pathlib import Path

sys.dont_write_bytecode = True

from apkdiff import (
    _elf_section_differences,
    _is_ignored_entry,
    _print_diff,
    _tool_path,
)


R8_METADATA_ENTRY = "BUNDLE-METADATA/com.android.tools/r8.json"
RESOURCE_TABLE_ENTRY = "base/resources.pb"
R8_HOST_SPECIFIC_COMPILATION_FIELDS = {
    "buildTimeNs",
    "numberOfThreads",
}


def _entry_digests(path: Path) -> dict[str, list[str]]:
    result: dict[str, list[str]] = defaultdict(list)
    with zipfile.ZipFile(path) as archive:
        for info in archive.infolist():
            if info.is_dir() or _is_ignored_entry(info.filename):
                continue
            with archive.open(info) as entry:
                result[info.filename].append(hashlib.sha256(entry.read()).hexdigest())
    return result


def _entry_bytes(path: Path, name: str) -> bytes:
    with zipfile.ZipFile(path) as archive:
        return archive.read(name)


def _normalized_r8_metadata(data: bytes) -> str:
    metadata = json.loads(data)
    compilation = metadata.get("compilation")
    if isinstance(compilation, dict):
        for field in R8_HOST_SPECIFIC_COMPILATION_FIELDS:
            compilation.pop(field, None)
    return json.dumps(metadata, sort_keys=True, separators=(",", ":"))


def _resource_dump(bundle: Path, bundletool: str) -> list[str]:
    process = subprocess.run(
        [bundletool, "dump", "resources", f"--bundle={bundle}", "--values"],
        check=True,
        capture_output=True,
        text=True,
    )
    return process.stdout.strip().splitlines()


def compare_aabs(
    rebuilt_aab: Path,
    supplied_aab: Path,
    *,
    bundletool_path: str | None = None,
) -> bool:
    print(f"Comparing rebuilt AAB {rebuilt_aab} with supplied AAB {supplied_aab}")
    rebuilt = _entry_digests(rebuilt_aab)
    supplied = _entry_digests(supplied_aab)
    success = True

    for name in sorted(rebuilt.keys() | supplied.keys()):
        if name not in rebuilt:
            print(f"  supplied-only entry: {name}")
            success = False
            continue
        if name not in supplied:
            print(f"  rebuilt-only entry: {name}")
            success = False
            continue
        if sorted(rebuilt[name]) == sorted(supplied[name]):
            continue

        if len(rebuilt[name]) != len(supplied[name]):
            print(
                f"  entry count differs for {name}: "
                f"{len(rebuilt[name])} rebuilt, {len(supplied[name])} supplied"
            )
            success = False
            continue

        if name == R8_METADATA_ENTRY and len(rebuilt[name]) == 1:
            try:
                rebuilt_metadata = _normalized_r8_metadata(
                    _entry_bytes(rebuilt_aab, name)
                )
                supplied_metadata = _normalized_r8_metadata(
                    _entry_bytes(supplied_aab, name)
                )
            except (UnicodeDecodeError, json.JSONDecodeError) as error:
                print(f"  unable to parse R8 metadata: {error}")
            else:
                if rebuilt_metadata == supplied_metadata:
                    print(
                        "  accounted host-specific R8 compilation metrics: "
                        f"{name}"
                    )
                    continue
                print("  R8 metadata differs after compilation-metric normalization")
                _print_diff(
                    json.dumps(json.loads(rebuilt_metadata), indent=2).splitlines(),
                    json.dumps(json.loads(supplied_metadata), indent=2).splitlines(),
                )

        if name == RESOURCE_TABLE_ENTRY and len(rebuilt[name]) == 1:
            bundletool = _tool_path(bundletool_path, "bundletool")
            rebuilt_resources = _resource_dump(rebuilt_aab, bundletool)
            supplied_resources = _resource_dump(supplied_aab, bundletool)
            if rebuilt_resources == supplied_resources:
                print(f"  accounted non-runtime resource source metadata: {name}")
                continue
            print("  resource table differs after semantic decoding")
            _print_diff(rebuilt_resources, supplied_resources)

        print(f"  payload differs: {name}")
        success = False
        if name.endswith(".so") and len(rebuilt[name]) == len(supplied[name]) == 1:
            try:
                runtime, metadata = _elf_section_differences(
                    _entry_bytes(rebuilt_aab, name),
                    _entry_bytes(supplied_aab, name),
                )
                if runtime:
                    print(f"    loadable ELF sections differ: {', '.join(runtime)}")
                if metadata:
                    print(
                        "    non-loadable/debug ELF sections differ: "
                        f"{', '.join(metadata)}"
                    )
                if not runtime and not metadata:
                    print("    ELF sections match; headers, padding, or ordering differ")
            except (ValueError, struct.error) as error:
                print(f"    unable to classify ELF difference: {error}")

    if success:
        print("AAB payloads match after documented signing/metadata exclusions")
    else:
        print("AAB payloads do not match")
    return success


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("rebuilt_aab", type=Path)
    parser.add_argument("supplied_aab", type=Path)
    parser.add_argument("--bundletool")
    arguments = parser.parse_args()

    try:
        return (
            0
            if compare_aabs(
                arguments.rebuilt_aab,
                arguments.supplied_aab,
                bundletool_path=arguments.bundletool,
            )
            else 1
        )
    except (
        OSError,
        RuntimeError,
        subprocess.CalledProcessError,
        zipfile.BadZipFile,
    ) as error:
        print(f"error: {error}", file=sys.stderr)
        return os.EX_DATAERR


if __name__ == "__main__":
    raise SystemExit(main())
