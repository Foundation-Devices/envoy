#!/usr/bin/env python3

# SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
# SPDX-License-Identifier: GPL-3.0-or-later

"""Make package:jni's Android native library reproducible.

package:jni 1.0.0 lets the Android linker generate the default GNU build ID for
libdartjni.so. That ID changes when the absolute build directory changes, so
the same committed source built in CI and in the isolated verifier produces
otherwise-identical ELF content with a different `.note.gnu.build-id`. Because
libdartjni.so and its debug-symbol payload are shipped in the AAB/APK, strict
artifact verification then fails.

Apply `--build-id=none` before compilation instead of modifying or ignoring the
finished library. This removes only the unstable note while keeping the runtime
payload subject to strict comparison. The patch is deliberately restricted to
the reviewed jni version and exact CMake block, so a dependency update fails
closed and requires the patch to be reviewed again.

 report:
https://github.com/dart-lang/native/issues/3263

Equivalent workaround confirmed by the F-Droid verifier:
https://github.com/Scriptbash/Wispar/issues/399
https://github.com/Scriptbash/Wispar/pull/401
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path
from urllib.parse import unquote, urljoin, urlparse


EXPECTED_JNI_VERSION = "1.0.0"
ORIGINAL_ANDROID_BLOCK = """\tif (ANDROID)
\t\ttarget_link_libraries(jni log)
\t\ttarget_link_options(jni PRIVATE "-Wl,-z,max-page-size=16384")
"""
# Prevent the path-dependent note from being emitted at link time. Do not strip
# or rewrite the finished ELF: all loadable/runtime sections must remain under
# strict artifact comparison.
REPRODUCIBLE_ANDROID_BLOCK = """\tif (ANDROID)
\t\ttarget_link_libraries(jni log)
\t\ttarget_link_options(jni PRIVATE "-Wl,-z,max-page-size=16384" "-Wl,--build-id=none")
"""


def fail(message: str) -> None:
    raise SystemExit(f"error: {message}")


def package_root(package_config: Path, package_name: str) -> Path:
    config = json.loads(package_config.read_text(encoding="utf-8"))
    root_uri = next(
        (
            package.get("rootUri")
            for package in config.get("packages", [])
            if package.get("name") == package_name
        ),
        None,
    )
    if not root_uri:
        fail(f"package:{package_name} was not found in {package_config}")

    config_directory_uri = package_config.parent.resolve().as_uri() + "/"
    parsed = urlparse(urljoin(config_directory_uri, root_uri))
    if parsed.scheme != "file":
        fail(f"package:{package_name} does not resolve to a local file URI")
    return Path(unquote(parsed.path))


def package_version(pubspec: Path) -> str:
    match = re.search(
        r"^version:\s*['\"]?([^'\"\s]+)",
        pubspec.read_text(encoding="utf-8"),
        flags=re.MULTILINE,
    )
    if not match:
        fail(f"could not read the package version from {pubspec}")
    return match.group(1)


def main() -> None:
    if len(sys.argv) != 2:
        fail(f"usage: {Path(sys.argv[0]).name} PACKAGE_CONFIG_JSON")

    package_config = Path(sys.argv[1])
    if not package_config.is_file():
        fail(f"package configuration not found: {package_config}")

    jni_root = package_root(package_config, "jni")
    jni_pubspec = jni_root / "pubspec.yaml"
    jni_cmake = jni_root / "src" / "CMakeLists.txt"
    if not jni_pubspec.is_file() or not jni_cmake.is_file():
        fail(f"package:jni build inputs are incomplete below {jni_root}")

    version = package_version(jni_pubspec)
    if version != EXPECTED_JNI_VERSION:
        fail(
            f"package:jni {version} is not the reviewed {EXPECTED_JNI_VERSION}; "
            "review its Android build before updating the patch"
        )

    cmake = jni_cmake.read_text(encoding="utf-8")
    if REPRODUCIBLE_ANDROID_BLOCK in cmake:
        print(f"package:jni {version} reproducible build-ID patch already applied")
        return
    if ORIGINAL_ANDROID_BLOCK not in cmake:
        fail(
            "package:jni CMake no longer matches the reviewed 1.0.0 source; "
            "review the reproducible build-ID patch"
        )

    jni_cmake.write_text(
        cmake.replace(ORIGINAL_ANDROID_BLOCK, REPRODUCIBLE_ANDROID_BLOCK, 1),
        encoding="utf-8",
    )
    print(f"patched package:jni {version} to omit its Android GNU build ID")


if __name__ == "__main__":
    main()
