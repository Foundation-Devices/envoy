// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/main.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screenshot/screenshot.dart';
import 'check_for_toast.dart';
import 'flow_to_map_and_p2p_test.dart';

void main() {
  testWidgets('flow to edit acc name', (tester) async {
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

      await setUpAppFromStart(tester);

      await fromHomeToHotWallet(tester);
      await openDotsMenu(tester);
      await fromDotsMenuToEditName(tester);

      await enterTextInField(tester, find.byType(TextField), 'What ever');
      await exitEditName(tester);
      await checkName(tester, 'Mobile Wallet'); // check if the name is the same

      await openDotsMenu(tester);
      await fromDotsMenuToEditName(tester);
      await enterTextInField(tester, find.byType(TextField),
          'Twenty one characters plus ten'); // 30 chars
      await saveName(tester);
      await checkName(
          tester, 'Twenty one character'); // it needs to cut text (chars 20/20)

      // Rename hot wallet back to "Mobile Wallet" if you want to repeat the test locally
      await openDotsMenu(tester);
      await fromDotsMenuToEditName(tester);

      await enterTextInField(tester, find.byType(TextField), 'Mobile Wallet');
      await saveName(tester);
    } finally {
      // Restore the original FlutterError.onError handler after the test.
      FlutterError.onError = originalOnError;
    }
  });
}

Future<void> fromHomeToHotWallet(WidgetTester tester) async {
  await tester.pump();
  final hotWalletButton = find.text('Envoy');
  expect(hotWalletButton, findsOneWidget);

  await tester.tap(hotWalletButton);
  await tester.pump(Durations.long2);
}

Future<void> openDotsMenu(WidgetTester tester) async {
  await checkForToast(tester);
  await tester.pump();
  final dotsButton = find.byIcon(Icons.more_horiz_outlined);
  expect(dotsButton, findsOneWidget);

  await tester.tap(dotsButton);
  await tester.pump(Durations.long2);
}

Future<void> fromDotsMenuToEditName(WidgetTester tester) async {
  await tester.pump();
  final editNameButton = find.text('EDIT ACCOUNT NAME');
  expect(editNameButton, findsOneWidget);

  await tester.tap(editNameButton);
  await tester.pump(Durations.long2);
}

Future<void> exitEditName(WidgetTester tester) async {
  await tester.pump();
  final exitButton = find.byIcon(Icons.close);
  expect(exitButton, findsOneWidget);

  await tester.tap(exitButton);
  await tester.pump(Durations.long2);
}

Future<void> enterTextInField(
  WidgetTester tester,
  Finder fieldFinder,
  String text,
) async {
  await tester.pump();

  final nameField = fieldFinder;
  // Ensure the widget is present on the screen
  expect(nameField, findsOneWidget);

  // Tap the field to focus it
  await tester.tap(nameField);
  await tester.pump(Durations.long2);

  // Enter text into the field
  await tester.enterText(nameField, text);
  await tester.pump(Durations.long2);
}

Future<void> saveName(WidgetTester tester) async {
  await tester.pump();
  final saveButton = find.text('Save');
  expect(saveButton, findsOneWidget);

  await tester.tap(saveButton);
  await tester.pump(Durations.long2);
}

Future<void> checkName(WidgetTester tester, String name) async {
  await tester.pump();
  final nameText = find.text(name);
  expect(nameText, findsOneWidget);
}
