// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/main.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screenshot/screenshot.dart';
import 'check_fiat_in_app.dart';
import 'flow_to_map_and_p2p_test.dart';

void main() {
  testWidgets('About', (tester) async {
    // Only test the app version and Open Source Licenses page.
    // Unable to test Terms of Use and Privacy Policy as they open in an external application.

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

      await pressHamburgerMenu(tester);
      await goToAbout(tester);

      final appVersion = find.text('1.8.3');
      expect(appVersion, findsOneWidget);

      final showButton = find.text('Show');
      expect(showButton, findsExactly(3));
      await tester.tap(showButton.first);
      await tester.pumpAndSettle();

      final licensePage = find.text('Licenses');
      expect(licensePage, findsOneWidget);
    } finally {
      // Restore the original FlutterError.onError handler after the test.
      FlutterError.onError = originalOnError;
    }
  });
}

Future<void> goToAbout(WidgetTester tester) async {
  await tester.pump();
  final aboutButton = find.text('ABOUT');
  expect(aboutButton, findsOneWidget);

  await tester.tap(aboutButton);
  await tester.pump(Durations.long2);
}
