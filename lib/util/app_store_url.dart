// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

String getAppStoreUrl() {
  if (Platform.isAndroid) {
    return "https://play.google.com/store/apps/details?id=com.foundationdevices.envoy";
  } else {
    return "https://apps.apple.com/us/app/envoy-by-foundation/id1584811818";
  }
}
