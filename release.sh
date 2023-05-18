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
    mv "$filename" "envoy-$version.apk"
    #zip "envoy-apk-$version.zip" "$filename"
done

for filename in *.aab; do
    mv "$filename" "envoy-$version.aab"
    #zip "envoy-aab-$version.zip" "$filename"
done

for filename in *.ipa; do
    mv "$filename" "envoy-$version.ipa"
    #zip "envoy-ipa-$version.zip" "$filename"
done

for filename in *.apk *.aab *.ipa; do
    sha256sum "$filename" >> envoy-manifest.txt
done

gpg --output envoy-manifest.txt.asc --detach-sign envoy-manifest.txt
