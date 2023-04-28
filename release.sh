#!/bin/bash

# SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Exit if anything fails
set -e

# Get the version
version=$1

cd release

for filename in *.apk; do
    zip "envoy-apk-$version.zip" "$filename"
done

for filename in *.aab; do
    zip "envoy-aab-$version.zip" "$filename"
done

for filename in *.ipa; do
    zip "envoy-ipa-$version.zip" "$filename"
done

for filename in *.zip; do
    sha256sum "$filename" >> envoy-manifest.txt
done

gpg --output envoy-manifest.txt.asc --detach-sign envoy-manifest.txt
