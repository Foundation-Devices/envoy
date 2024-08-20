// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/main.dart';
import 'package:envoy/ui/onboard/manual/widgets/mnemonic_grid_widget.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screenshot/screenshot.dart';
import 'flow_to_map_and_p2p_test.dart';

// Wallet for BEEFQA: this seed has magic recovery enabled on the Foundation server
const List<String> seed = [
  "vault",
  "dust",
  "appear",
  "acoustic",
  "evolve",
  "monster",
  "arena",
  "injury",
  "tourist",
  "grab",
  "pair",
  "harvest"
];

void main() {
  testWidgets('magic recovery from Foundation server', (tester) async {
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

      await setUpWalletFromSeedViaMagicRecover(tester, seed);
    } finally {
      FlutterError.onError = originalOnError;
    }
  });
}

Future<void> setUpWalletFromSeedViaMagicRecover(
    WidgetTester tester, List<String> seed) async {
  await tester.pump();

  final setUpButtonFinder = find.text('Set Up Envoy Wallet');
  expect(setUpButtonFinder, findsOneWidget);
  await tester.tap(setUpButtonFinder);
  await tester.pump(const Duration(milliseconds: 500));

  final continueButtonFinder = find.text('Continue');
  expect(continueButtonFinder, findsOneWidget);
  await tester.tap(continueButtonFinder);
  await tester.pump(const Duration(milliseconds: 500));

  final manuallyConfigureSeedWords = find.text('Manually Configure Seed Words');
  expect(manuallyConfigureSeedWords, findsOneWidget);
  await tester.tap(manuallyConfigureSeedWords);
  await tester.pump(const Duration(milliseconds: 500));

  final importSeedButton = find.text('Import Seed');
  expect(importSeedButton, findsOneWidget);
  await tester.tap(importSeedButton);
  await tester.pump(const Duration(milliseconds: 1500));

  final import12SeedButton = find.text('12 Word Seed');
  expect(import12SeedButton, findsOneWidget);
  await tester.tap(import12SeedButton);
  await tester.pump(const Duration(milliseconds: 1500));

  final mnemonicInput = find.byType(MnemonicInput);
  expect(mnemonicInput, findsExactly(12));

  await enterSeedWords(seed, tester, mnemonicInput);

  // just tap somewhere on screen after entering seed
  final title = find.text('Enter Your Seed');
  expect(title, findsOneWidget);
  await tester.tap(title);
  await tester.pump(const Duration(milliseconds: 1500));

  final doneButton = find.text('Done');
  expect(doneButton, findsOneWidget);
  await tester.tap(doneButton);
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pumpAndSettle();

  final restoreButtonFromDialog = find.text('Restore');
  await tester.pumpUntilFound(restoreButtonFromDialog,
      duration: Durations.long1, tries: 100);
  expect(restoreButtonFromDialog, findsOneWidget);
  await tester.tap(restoreButtonFromDialog);
  await tester.pump(Durations.long2);
  await tester.pumpAndSettle();

  final successMessage = find.text("Your Wallet Is Ready");
  expect(successMessage, findsOneWidget);
  expect(continueButtonFinder, findsOneWidget);
  await tester.tap(continueButtonFinder);
  await tester.pump(const Duration(milliseconds: 500));

  // Scroll down by 600 pixels
  await scrollHome(tester, -600);

  // search for passport account
  final passportAccount = find.text("Passport");

  // Ensure at least one instance of the text is found
  expect(passportAccount, findsWidgets);
  await tester.pumpAndSettle();
}

Future<void> enterSeedWords(
    List<String> seed, WidgetTester tester, Finder finder) async {
  if (seed.length != 12) {
    throw ArgumentError('List must contain exactly 12 strings.');
  }
  for (int i = 0; i < seed.length; i++) {
    await tester.tap(finder.at(i), warnIfMissed: false);
    await tester.pump(Durations.long2);
    await tester.enterText(finder.at(i), seed[i]);
    await tester.pump(Durations.long2);
  }
}

Future<void> scrollHome(WidgetTester tester, double pixels) async {
  // Perform the drag operation on the ReorderableListView by the specified number of pixels
  await tester.drag(find.byType(ReorderableListView), Offset(0, pixels));
  await tester.pumpAndSettle();
}

Future<void> scrollUntilVisible(WidgetTester tester, Finder finder,
    {int maxScrolls = 50, double scrollIncrement = -100}) async {
  for (int i = 0; i < maxScrolls; i++) {
    // Try to find the widget
    if (finder.evaluate().isNotEmpty) {
      return; // Widget found, stop scrolling
    }

    await scrollHome(tester, scrollIncrement);
  }

  // Optionally, you could throw an exception if the widget isn't found after maxScrolls
  throw Exception('Widget not found after scrolling $maxScrolls times.');
}
