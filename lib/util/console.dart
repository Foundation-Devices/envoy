// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/foundation.dart';

const bool isTest = bool.fromEnvironment('IS_TEST', defaultValue: true);

// A debug printing utility that prints the given message and optional stack trace in debug mode.
void kPrint(Object? message, {StackTrace? stackTrace}) {
  if (isTest) return; // silence all prints during integration tests

  if (!kReleaseMode || !kProfileMode) {
    // ignore: avoid_print
    print(message);
    // If a stackTrace is provided, print the stack trace
    if (stackTrace != null) {
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
