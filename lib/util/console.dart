// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/foundation.dart';

// A debug printing utility that prints the given message and optional stack trace in debug mode.
kPrint(Object? message, {StackTrace? stackTrace}) {
  if (kDebugMode) {
    print(message);
    // If a stackTrace is provided, print the stack trace
    if (stackTrace != null) {
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
