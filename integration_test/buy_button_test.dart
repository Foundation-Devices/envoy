// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/main.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screenshot/screenshot.dart';
import 'envoy_test.dart';

void main() {
  testWidgets('buy button test', (tester) async {
    final FlutterExceptionHandler? originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      kPrint('FlutterError caught: ${details.exceptionAsString()}');
      if (originalOnError != null) {
        originalOnError(details);
      }
    };
    try {
      // Uncomment the line below if you want to start from the beginning,
      // but then you MUST call setAppFromStart or setUpWalletFromSeedViaMagicRecover.
      await resetEnvoyData();

      ScreenshotController envoyScreenshotController = ScreenshotController();
      await initSingletons();
      await tester.pumpWidget(Screenshot(
          controller: envoyScreenshotController, child: const EnvoyApp()));

      // start setup but without accounts
      await setUpFromStartNoAccounts(tester);

      await findAndPressBuyOptions(tester);
      await checkBuyOptionAndTitle(tester);
    } finally {
      FlutterError.onError = originalOnError;
    }
  });
}

Future<void> findAndPressBuyOptions(WidgetTester tester) async {
  await tester.pump();

  // Find the GestureDetector containing the QrShield and Buy button text
  final buyButtonFinder = find.descendant(
    of: find.byType(GestureDetector),
    matching: find.text('Buy'),
  );
  expect(buyButtonFinder, findsOneWidget);

  // Get the parent GestureDetector widget
  final gestureDetectorFinder = find.ancestor(
    of: buyButtonFinder,
    matching: find.byType(GestureDetector),
  );
  expect(gestureDetectorFinder, findsOneWidget);

  // Tap the button
  await tester.tap(gestureDetectorFinder);
  await tester.pump(Durations.long2);
}

Future<void> checkBuyOptionAndTitle(WidgetTester tester) async {
  await tester.pump();

  // Find the GestureDetector containing the QrShield and Buy button text
  final buyButtonFinder = find.descendant(
    of: find.byType(GestureDetector),
    matching: find.text('Buy'),
  );

  // Check if the button is still there
  expect(buyButtonFinder, findsOneWidget);

  // Check if the "ACCOUNTS" title is still there
  // double check if we entered in BUY
  final accountsTitleFinder = find.text('ACCOUNTS');
  expect(accountsTitleFinder, findsOneWidget);
}

Future<void> setUpFromStartNoAccounts(WidgetTester tester) async {
  await tester.pump();

  final setUpButtonFinder = find.text('Set Up Envoy Wallet');
  expect(setUpButtonFinder, findsOneWidget);
  await tester.tap(setUpButtonFinder);
  await tester.pump(Durations.long2);

  final continueButtonFinder = find.text('Continue');
  expect(continueButtonFinder, findsOneWidget);
  await tester.tap(continueButtonFinder);
  await tester.pump(Durations.long2);

  // go to home w no accounts
  final skipButtonFinder = find.text('Skip');
  expect(skipButtonFinder, findsOneWidget);
  await tester.tap(skipButtonFinder);
  await tester.pump(Durations.long2);
}
