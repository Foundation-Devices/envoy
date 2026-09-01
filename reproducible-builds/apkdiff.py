#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

"""Compare rebuilt and supplied APK payloads."""

from __future__ import annotations

import argparse
import difflib
import hashlib
import shutil
import struct
import subprocess
import sys
import xml.etree.ElementTree as ET
import zipfile
from collections import Counter, defaultdict
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable


ANDROID_NAMESPACE = "http://schemas.android.com/apk/res/android"
ANDROID_NAME = f"{{{ANDROID_NAMESPACE}}}name"
ANDROID_MIN_SDK = f"{{{ANDROID_NAMESPACE}}}minSdkVersion"

IGNORED_ENTRIES = {
    "META-INF/MANIFEST.MF",
    "META-INF/code_transparency_signed.jwt",
    "stamp-cert-sha256",
}
SIGNATURE_SUFFIXES = (".DSA", ".EC", ".RSA", ".SF")
PLAY_MANIFEST_METADATA = {
    "com.android.stamp.source",
    "com.android.stamp.type",
    "com.android.vending.derived.apk.id",
}
ELF_METADATA_SECTIONS = {
    ".comment",
    ".gnu_debuglink",
    ".note.gnu.build-id",
    ".note.gnu.property",
}
SHF_ALLOC = 0x2
SHT_NOBITS = 8


@dataclass(frozen=True)
class EntryDigest:
    digest: str
    info: zipfile.ZipInfo


@dataclass(frozen=True)
class ElfSection:
    name: str
    section_type: int
    flags: int
    size: int
    digest: str

    @property
    def is_runtime_content(self) -> bool:
        return bool(self.flags & SHF_ALLOC) and self.name not in ELF_METADATA_SECTIONS


def _tool_path(explicit_path: str | None, name: str) -> str:
    if explicit_path:
        return explicit_path
    discovered = shutil.which(name)
    if discovered:
        return discovered
    raise RuntimeError(f"{name} was not found; run this command inside 'nix develop'")


def _is_ignored_entry(name: str) -> bool:
    if name in IGNORED_ENTRIES:
        return True
    upper_name = name.upper()
    return upper_name.startswith("META-INF/") and upper_name.endswith(
        SIGNATURE_SUFFIXES
    )


def archive_payload_digest(path: Path) -> str:
    """Hash archive names and contents without ZIP metadata or signatures."""

    entries: list[tuple[str, str]] = []
    with zipfile.ZipFile(path) as archive:
        for info in archive.infolist():
            if info.is_dir() or _is_ignored_entry(info.filename):
                continue
            with archive.open(info) as entry:
                digest = hashlib.sha256(entry.read()).hexdigest()
            entries.append((info.filename, digest))

    result = hashlib.sha256()
    for name, digest in sorted(entries):
        result.update(name.encode("utf-8"))
        result.update(b"\0")
        result.update(digest.encode("ascii"))
        result.update(b"\n")
    return result.hexdigest()


def _entry_digests(
    archive: zipfile.ZipFile,
) -> dict[str, list[EntryDigest]]:
    result: dict[str, list[EntryDigest]] = defaultdict(list)
    for info in archive.infolist():
        if info.is_dir() or _is_ignored_entry(info.filename):
            continue
        with archive.open(info) as entry:
            digest = hashlib.sha256(entry.read()).hexdigest()
        result[info.filename].append(EntryDigest(digest=digest, info=info))
    return result


def _strip_xml_whitespace(element: ET.Element) -> None:
    if element.text is not None and not element.text.strip():
        element.text = None
    if element.tail is not None and not element.tail.strip():
        element.tail = None
    for child in element:
        _strip_xml_whitespace(child)


def _normalize_manifest(apk: Path, apkanalyzer: str) -> str:
    process = subprocess.run(
        [apkanalyzer, "manifest", "print", str(apk)],
        check=True,
        capture_output=True,
        text=True,
    )
    root = ET.fromstring(process.stdout)

    for parent in root.iter():
        for child in list(parent):
            if child.tag.endswith("meta-data") and child.get(ANDROID_NAME) in (
                PLAY_MANIFEST_METADATA
            ):
                parent.remove(child)

    for element in root.iter():
        if element.tag.endswith("uses-sdk"):
            element.attrib.pop(ANDROID_MIN_SDK, None)
        sorted_attributes = sorted(element.attrib.items())
        element.attrib.clear()
        element.attrib.update(sorted_attributes)

    _strip_xml_whitespace(root)
    ET.indent(root, space="  ")
    return ET.tostring(root, encoding="unicode")


def _resource_dump(apk: Path, aapt2: str) -> list[str]:
    process = subprocess.run(
        [aapt2, "dump", "resources", str(apk)],
        check=True,
        capture_output=True,
        text=True,
    )
    return process.stdout.strip().splitlines()


def _print_diff(first: Iterable[str], second: Iterable[str], limit: int = 200) -> None:
    diff = difflib.unified_diff(
        list(first),
        list(second),
        fromfile="rebuilt",
        tofile="supplied",
        lineterm="",
    )
    for index, line in enumerate(diff):
        if index >= limit:
            print(f"  ... diff truncated after {limit} lines")
            break
        print(f"  {line}")


def _parse_elf_sections(data: bytes) -> list[ElfSection]:
    if len(data) < 64 or data[:4] != b"\x7fELF":
        raise ValueError("not an ELF file")

    elf_class = data[4]
    byte_order = data[5]
    endian = "<" if byte_order == 1 else ">" if byte_order == 2 else None
    if endian is None:
        raise ValueError("unsupported ELF byte order")

    if elf_class == 2:
        section_offset = struct.unpack_from(f"{endian}Q", data, 40)[0]
        section_entry_size = struct.unpack_from(f"{endian}H", data, 58)[0]
        section_count = struct.unpack_from(f"{endian}H", data, 60)[0]
        string_index = struct.unpack_from(f"{endian}H", data, 62)[0]
        section_format = f"{endian}IIQQQQIIQQ"
    elif elf_class == 1:
        section_offset = struct.unpack_from(f"{endian}I", data, 32)[0]
        section_entry_size = struct.unpack_from(f"{endian}H", data, 46)[0]
        section_count = struct.unpack_from(f"{endian}H", data, 48)[0]
        string_index = struct.unpack_from(f"{endian}H", data, 50)[0]
        section_format = f"{endian}IIIIIIIIII"
    else:
        raise ValueError("unsupported ELF class")

    expected_entry_size = struct.calcsize(section_format)
    if section_entry_size < expected_entry_size:
        raise ValueError("invalid ELF section header size")

    def read_header(index: int) -> tuple[int, ...]:
        offset = section_offset + index * section_entry_size
        if offset + expected_entry_size > len(data):
            raise ValueError("ELF section header is outside the file")
        return struct.unpack_from(section_format, data, offset)

    first_header = read_header(0)
    if section_count == 0:
        section_count = first_header[5]
    if string_index == 0xFFFF:
        string_index = first_header[6]

    headers = [read_header(index) for index in range(section_count)]
    if string_index >= len(headers):
        raise ValueError("invalid ELF section-name table")

    string_header = headers[string_index]
    string_offset, string_size = string_header[4], string_header[5]
    string_table = data[string_offset : string_offset + string_size]

    def section_name(offset: int) -> str:
        if offset >= len(string_table):
            return f"<invalid-name-{offset}>"
        terminator = string_table.find(b"\0", offset)
        if terminator < 0:
            terminator = len(string_table)
        return string_table[offset:terminator].decode("utf-8", errors="replace")

    sections: list[ElfSection] = []
    for header in headers:
        name_offset, section_type, flags = header[0], header[1], header[2]
        content_offset, content_size = header[4], header[5]
        if section_type == SHT_NOBITS:
            content = f"NOBITS:{content_size}".encode("ascii")
        else:
            content = data[content_offset : content_offset + content_size]
        sections.append(
            ElfSection(
                name=section_name(name_offset),
                section_type=section_type,
                flags=flags,
                size=content_size,
                digest=hashlib.sha256(content).hexdigest(),
            )
        )
    return sections


def _elf_section_differences(first: bytes, second: bytes) -> tuple[list[str], list[str]]:
    first_sections = {section.name: section for section in _parse_elf_sections(first)}
    second_sections = {section.name: section for section in _parse_elf_sections(second)}
    differing_names: list[str] = []

    for name in sorted(first_sections.keys() | second_sections.keys()):
        if first_sections.get(name) != second_sections.get(name):
            differing_names.append(name or "<null>")

    runtime: list[str] = []
    metadata: list[str] = []
    for name in differing_names:
        first_section = first_sections.get("" if name == "<null>" else name)
        second_section = second_sections.get("" if name == "<null>" else name)
        if (first_section and first_section.is_runtime_content) or (
            second_section and second_section.is_runtime_content
        ):
            runtime.append(name)
        else:
            metadata.append(name)
    return runtime, metadata


def _read_entry(archive: zipfile.ZipFile, digest: EntryDigest) -> bytes:
    with archive.open(digest.info) as entry:
        return entry.read()


def compare_apks(
    rebuilt_apk: Path,
    supplied_apk: Path,
    *,
    aapt2_path: str | None = None,
    apkanalyzer_path: str | None = None,
) -> bool:
    print(f"Comparing rebuilt APK {rebuilt_apk} with supplied APK {supplied_apk}")
    success = True

    with zipfile.ZipFile(rebuilt_apk) as rebuilt_archive, zipfile.ZipFile(
        supplied_apk
    ) as supplied_archive:
        rebuilt = _entry_digests(rebuilt_archive)
        supplied = _entry_digests(supplied_archive)

        rebuilt_counts = Counter(
            {name: len(entries) for name, entries in rebuilt.items()}
        )
        supplied_counts = Counter(
            {name: len(entries) for name, entries in supplied.items()}
        )

        for name in sorted(rebuilt_counts.keys() | supplied_counts.keys()):
            if rebuilt_counts[name] != supplied_counts[name]:
                print(
                    f"  entry count differs for {name}: "
                    f"{rebuilt_counts[name]} rebuilt, {supplied_counts[name]} supplied"
                )
                success = False

        for name in sorted(rebuilt.keys() & supplied.keys()):
            rebuilt_entries = rebuilt[name]
            supplied_entries = supplied[name]
            if len(rebuilt_entries) != len(supplied_entries):
                continue

            rebuilt_hashes = sorted(entry.digest for entry in rebuilt_entries)
            supplied_hashes = sorted(entry.digest for entry in supplied_entries)
            if rebuilt_hashes == supplied_hashes:
                continue

            if name == "AndroidManifest.xml" and len(rebuilt_entries) == 1:
                apkanalyzer = _tool_path(apkanalyzer_path, "apkanalyzer")
                rebuilt_manifest = _normalize_manifest(rebuilt_apk, apkanalyzer)
                supplied_manifest = _normalize_manifest(supplied_apk, apkanalyzer)
                if rebuilt_manifest == supplied_manifest:
                    continue
                print("  AndroidManifest.xml differs after Play metadata normalization")
                _print_diff(
                    rebuilt_manifest.splitlines(), supplied_manifest.splitlines()
                )
                success = False
                continue

            if name == "resources.arsc" and len(rebuilt_entries) == 1:
                aapt2 = _tool_path(aapt2_path, "aapt2")
                rebuilt_resources = _resource_dump(rebuilt_apk, aapt2)
                supplied_resources = _resource_dump(supplied_apk, aapt2)
                if rebuilt_resources == supplied_resources:
                    continue
                print("  resources.arsc differs after semantic decoding")
                _print_diff(rebuilt_resources, supplied_resources)
                success = False
                continue

            print(f"  payload differs: {name}")
            success = False

            if name.endswith(".so") and len(rebuilt_entries) == 1:
                rebuilt_bytes = _read_entry(rebuilt_archive, rebuilt_entries[0])
                supplied_bytes = _read_entry(supplied_archive, supplied_entries[0])
                try:
                    runtime, metadata = _elf_section_differences(
                        rebuilt_bytes, supplied_bytes
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
        print("APKs match after documented Play signing/metadata exclusions")
    else:
        print("APKs do not match")
    return success


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("rebuilt_apk", type=Path)
    parser.add_argument("supplied_apk", type=Path)
    parser.add_argument("--aapt2")
    parser.add_argument("--apkanalyzer")
    arguments = parser.parse_args()

    try:
        matches = compare_apks(
            arguments.rebuilt_apk,
            arguments.supplied_apk,
            aapt2_path=arguments.aapt2,
            apkanalyzer_path=arguments.apkanalyzer,
        )
    except (OSError, RuntimeError, subprocess.CalledProcessError, zipfile.BadZipFile) as error:
        print(f"error: {error}", file=sys.stderr)
        return 2
    return 0 if matches else 1


if __name__ == "__main__":
    raise SystemExit(main())
