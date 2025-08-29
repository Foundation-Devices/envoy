// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/foundation.dart';

// A debug printing utility that prints the given message and optional stack trace in debug mode.
void kPrint(Object? message, {StackTrace? stackTrace}) {
  _kPrintImpl(message, stackTrace: stackTrace, silenceInTests: false);
}

// A debug printing utility that prints the given message except in the integration tests
void kPrintTestSilent(Object? message, {StackTrace? stackTrace}) {
  _kPrintImpl(message, stackTrace: stackTrace, silenceInTests: true);
}

// Internal implementation
void _kPrintImpl(Object? message,
    {StackTrace? stackTrace, required bool silenceInTests}) {
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
