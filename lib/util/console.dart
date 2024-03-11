// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/foundation.dart';

kPrint(Object? message) {
  if (kDebugMode) {
    print(message);
  }
}
