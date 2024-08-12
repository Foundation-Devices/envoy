// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/main.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screenshot/screenshot.dart';
import 'connect_passport_via_recovery.dart';
import 'edit_account_name.dart';

void main() {
  testWidgets('edit device name', (tester) async {
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

      await setUpWalletFromSeedViaMagicRecover(tester, seed);

      final devicesButton = find.text('Devices');
      await tester.tap(devicesButton);
      await tester.pumpAndSettle();

      // Input text without tapping Save
      await openDeviceCard(tester, "Passport");
      await openDotsMenu(tester);
      await openEditDevice(tester);
      await enterTextInField(tester, find.byType(TextField), 'New Passport name');
      await exitEditName(tester);
      await checkName(tester, 'Passport'); // check if the name is the same

      // Test for input name longer than the allowed maximum
      await openDotsMenu(tester);
      await openEditDevice(tester);
      await enterTextInField(tester, find.byType(TextField), 'Twenty one characters plus ten'); // 30 chars
      await saveName(tester);
      await checkName(
          tester, 'Twenty one character'); // it needs to cut text (chars 20/20)

      // Reset the device name to its initial value
      await openDotsMenu(tester);
      await openEditDevice(tester);
      await enterTextInField(tester, find.byType(TextField), 'Passport');
      await saveName(tester);
    } finally {
      // Restore the original FlutterError.onError handler after the test.
      FlutterError.onError = originalOnError;
    }
  });
}

Future<void> openDeviceCard(WidgetTester tester, String deviceName) async {
  await tester.pump();
  final deviceCard = find.text(deviceName);
  expect(deviceCard, findsOneWidget);

  await tester.tap(deviceCard);
  await tester.pump(Durations.long2);
}

Future<void> openEditDevice(WidgetTester tester) async {
  await tester.pump();
  final editNameButton = find.text('EDIT DEVICE NAME');
  expect(editNameButton, findsOneWidget);

  await tester.tap(editNameButton);
  await tester.pump(Durations.long2);
}
