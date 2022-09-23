#!/bin/bash

# SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Exit if anything fails
set -e

# Get the version
version=$(grep 'version: ' pubspec.yaml | sed 's/version: //')

cd release

for filename in *.zip; do
    mv "$filename" "envoy-$filename-$version.zip"
done

for filename in *.zip; do
    sha256sum "$filename" >> envoy-manifest.txt
done

gpg --output envoy-manifest.txt.asc --detach-sign envoy-manifest.txt