// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/main.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screenshot/screenshot.dart';
import 'edit_account_name.dart';

const String accountPassportName = "Primary (#0)";

void main() {
  testWidgets('Edit Passport account name', (tester) async {
    final FlutterExceptionHandler? originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      kPrint('FlutterError caught: ${details.exceptionAsString()}');
      if (originalOnError != null) {
        originalOnError(details);
      }
    };
    try {
      // Uncomment the line below if testing on local machine.
      // await resetEnvoyData();

      await initSingletons();
      ScreenshotController envoyScreenshotController = ScreenshotController();
      await tester.pumpWidget(Screenshot(
          controller: envoyScreenshotController, child: const EnvoyApp()));

      // await setUpWalletFromSeedViaMagicRecover(tester, seed);

      await openPassportAccount(tester);
      await openDotsMenu(tester);
      await fromDotsMenuToEditName(tester);
      await enterTextInField(tester, find.byType(TextField), 'What ever');
      await exitEditName(tester);
      await checkName(
          tester, accountPassportName); // check if the name is the same

      await openDotsMenu(tester);
      await fromDotsMenuToEditName(tester);
      await enterTextInField(tester, find.byType(TextField),
          'Twenty one characters plus ten'); // 30 chars
      await saveName(tester);
      await checkName(
          tester, 'Twenty one character'); // it needs to cut text (chars 20/20)

      // Reset the account name to its initial value
      await openDotsMenu(tester);
      await fromDotsMenuToEditName(tester);
      await enterTextInField(
          tester, find.byType(TextField), accountPassportName);
      await saveName(tester);
    } finally {
      // Restore the original FlutterError.onError handler after the test.
      FlutterError.onError = originalOnError;
    }
  });
}

Future<void> openPassportAccount(WidgetTester tester) async {
  await tester.pump();
  final hotWalletButton = find.text(accountPassportName);
  expect(hotWalletButton, findsOneWidget);

  await tester.tap(hotWalletButton);
  await tester.pump(Durations.long2);
}
