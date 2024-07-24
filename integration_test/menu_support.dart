// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/main.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screenshot/screenshot.dart';
import 'flow_to_map_and_p2p_test.dart';
import 'check_fiat_in_app.dart';

void main() {
  testWidgets('check support buttons in settings', (tester) async {
    final FlutterExceptionHandler? originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      kPrint('FlutterError caught: ${details.exceptionAsString()}');
      if (originalOnError != null) {
        originalOnError(details);
      }
    };
    try {
      // Uncomment the line below if testing on local machine.
      //await resetEnvoyData();

      await initSingletons();
      ScreenshotController envoyScreenshotController = ScreenshotController();
      await tester.pumpWidget(Screenshot(
          controller: envoyScreenshotController, child: const EnvoyApp()));

      await setUpAppFromStart(tester);

      await pressHamburgerMenu(tester);
      await goToSupport(tester);
      await goToDocumentation(tester);
      await goToTelegram(tester);
      await goToEmail(tester);

      // Note: The "ramp" widget is only supported on Android and iOS platforms,
      // so there is no reliable way to verify its functionality in this test.
    } finally {
      // Restore the original FlutterError.onError handler after the test.
      FlutterError.onError = originalOnError;
    }
  });
}

Future<void> goToSupport(WidgetTester tester) async {
  await tester.pump();
  final supportButton = find.text('SUPPORT');
  expect(supportButton, findsOneWidget);

  await tester.tap(supportButton);
  await tester.pump(Durations.long2);
}

Future<void> goToDocumentation(WidgetTester tester) async {
  await tester.pump();
  final documentationButton = find.text('DOCUMENTATION');
  expect(documentationButton, findsOneWidget);

  await tester.tap(documentationButton);
  await tester.pump(Durations.long2);
}

Future<void> goToTelegram(WidgetTester tester) async {
  await tester.pump();
  final telegramButton = find.text('TELEGRAM');
  expect(telegramButton, findsOneWidget);

  await tester.tap(telegramButton);
  await tester.pump(Durations.long2);
}

Future<void> goToEmail(WidgetTester tester) async {
  await tester.pump();
  final emailButton = find.text('EMAIL');
  expect(emailButton, findsOneWidget);

  await tester.tap(emailButton);
  await tester.pump(Durations.long2);
}
