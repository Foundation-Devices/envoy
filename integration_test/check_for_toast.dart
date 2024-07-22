// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/main.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/foundation.dart';
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
    await tester.pumpAndSettle();

    final iconFinder = find.byWidgetPredicate(
      (widget) => widget is EnvoyIcon && widget.icon == EnvoyIcons.info,
    );

    // Check if the icon is found initially
    bool iconInitiallyFound = iconFinder.evaluate().isNotEmpty;
    if (!iconInitiallyFound) {
      print('Icon was not found initially.');
      return; // Exit the test if the icon is not found initially
    }

    print('Icon found initially, entering wait loop.');

    const maxRetries = 10; // Maximum number of retries
    int retryCount = 0;
    bool iconStillThere = true;

    while (retryCount < maxRetries && iconStillThere) {
      // Wait for 1 second
      await Future.delayed(const Duration(seconds: 1));

      // Recheck if the icon is still there
      await tester.pumpAndSettle();
      final iconStillThereFinder = find.byWidgetPredicate(
        (widget) =>
            widget is EnvoyIcon &&
            (widget.icon == EnvoyIcons.info || widget.icon == EnvoyIcons.alert),
      );

      iconStillThere = iconStillThereFinder.evaluate().isNotEmpty;
      if (!iconStillThere) {
        print('Icon is no longer present after waiting.');
        break; // Break the loop
      } else {
        print('Icon is still present.');
        retryCount++;
      }
    }

    if (iconStillThere) {
      print('Icon was still present after the maximum wait time.');
      // Handle the case where the icon is still present after retries, if needed
    }
  });
}
