#!/bin/bash

# SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -e

# Find and increment the version number
perl -i -pe 's/^(version:\s+\d+\.\d+\.\d+\+)(\d+)$/$1.($2+1)/e' pubspec.yaml

# Commit the change
version=$(grep 'version: ' pubspec.yaml | sed 's/version: //')
git commit -m "Bump version to $version" pubspec.yaml