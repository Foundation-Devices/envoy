// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/main.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screenshot/screenshot.dart';
import 'flow_to_map_and_p2p_test.dart';

void main() {
  testWidgets('flow to ramp', (tester) async {
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
      // await resetEnvoyData();

      await initSingletons();
      ScreenshotController envoyScreenshotController = ScreenshotController();
      await tester.pumpWidget(Screenshot(
          controller: envoyScreenshotController, child: const EnvoyApp()));

      await setUpAppFromStart(tester);

      await fromHomeToBuyOptions(tester);
      final rampTab = find.text('Buy in Envoy');
      expect(rampTab, findsOneWidget);
      await tester.tap(rampTab);
      await tester.pump(Durations.long2);

      final continueButtonFinder = find.text('Continue');
      expect(continueButtonFinder, findsOneWidget);
      await tester.tap(continueButtonFinder);
      await tester.pump(Durations.long2);

      final title = find.text("Where should the Bitcoin be sent?");
      expect(title, findsOneWidget);
      await tester.tap(continueButtonFinder);
      await tester.pump(Durations.long2);

      final titleModalDialog = find.text("Leaving Envoy");
      expect(titleModalDialog, findsOneWidget);

      // Note: The "ramp" widget is only supported on Android and iOS platforms,
      // so there is no reliable way to verify its functionality in this test.
    } finally {
      // Restore the original FlutterError.onError handler after the test.
      FlutterError.onError = originalOnError;
    }
  });
}
