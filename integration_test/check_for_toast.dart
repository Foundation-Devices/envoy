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
      // Uncomment the line below if testing on local machine.
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
  await tester.runAsync(() async {
    final iconFinder = find.byWidgetPredicate(
      (widget) =>
          widget is EnvoyIcon &&
          (widget.icon == EnvoyIcons.info || widget.icon == EnvoyIcons.alert),
    );

    //await tester.pumpUntilFound(iconFinder, tries: 10, duration: Durations.long2); // TODO: can this improve the test?

    // Check if the icon is found initially
    bool iconFound = iconFinder.evaluate().isNotEmpty;
    if (!iconFound) {
      // If the icon is not found initially, simply return
      return;
    }

    // Wait until the icon is gone
    int tries = 0;
    const maxTries = 10;
    while (iconFound && tries < maxTries) {
      await tester.pump(Durations.long2); // Wait for a certain duration
      iconFound = iconFinder.evaluate().isNotEmpty;
      tries++;
    }

    if (iconFound) {
      throw Exception('Icon is still present after maximum retries.');
    }
  });
}
