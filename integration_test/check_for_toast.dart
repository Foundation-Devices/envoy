// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/main.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screenshot/screenshot.dart';
import 'flow_to_map_and_p2p_test.dart';

/// you should use this to check for the top toast pop-up before trying to press top bar buttons !!!
void main() {
  testWidgets('check for top toast', (tester) async {
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

      await checkForToast(tester);

      // Note: The "ramp" widget is only supported on Android and iOS platforms,
      // so there is no reliable way to verify its functionality in this test.
    } finally {
      // Restore the original FlutterError.onError handler after the test.
      FlutterError.onError = originalOnError;
    }
  });
}

Future<void> checkForToast(WidgetTester tester) async {
  //await tester.pumpAndSettle();

  final iconFinder = find.byWidgetPredicate(
    (widget) =>
        widget is EnvoyIcon &&
        (widget.icon == EnvoyIcons.info || widget.icon == EnvoyIcons.alert),
  );

  // Check if the icon is found initially
  bool iconInitiallyFound = iconFinder.evaluate().isNotEmpty;
  if (!iconInitiallyFound) {
    return; // Exit the test if the icon is not found initially
  } else {
    final closeToastButton = find.byIcon(Icons.close);
    await tester.tap(closeToastButton.last);
    await tester.pump(Durations.long2);
  }
}
