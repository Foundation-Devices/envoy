// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/foundation.dart';

// A debug printing utility with optional silenceInTests flag
void kPrint(
  Object? message, {
  StackTrace? stackTrace,
  bool silenceInTests = false,
}) {
  const bool isTest = bool.fromEnvironment('IS_TEST', defaultValue: false);

  if (isTest && silenceInTests) return; // silence if requested during tests

  if (!kReleaseMode || !kProfileMode) {
    // ignore: avoid_print
    print(message);
    // If a stackTrace is provided, print the stack trace
    if (stackTrace != null) {
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
