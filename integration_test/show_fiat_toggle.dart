// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/main.dart';
import 'package:envoy/ui/home/top_bar_home.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screenshot/screenshot.dart';
import 'flow_to_map_and_p2p_test.dart';

void main() {
  testWidgets('show fiat toggle', (tester) async {
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

      //await setUpAppFromStart(tester); // TODO

      await fromHomeToSettings(tester);
      await fromSettingsToSettings(tester);
      await fromSettingsToFiatDropdown(tester);

      // Note: The "ramp" widget is only supported on Android and iOS platforms,
      // so there is no reliable way to verify its functionality in this test.
    } finally {
      // Restore the original FlutterError.onError handler after the test.
      FlutterError.onError = originalOnError;
    }
  });
}

Future<void> fromHomeToSettings(WidgetTester tester) async {
  await tester.pump();
  final hamburgerIcon = find.byType(HamburgerMenu);
  expect(hamburgerIcon, findsOneWidget);

  await tester.tap(hamburgerIcon);
  await tester.pump(Durations.long2);
}

Future<void> fromSettingsToSettings(WidgetTester tester) async {
  await tester.pump();
  final settingsButton = find.text('SETTINGS');
  expect(settingsButton, findsOneWidget);

  await tester.tap(settingsButton);
  await tester.pump(Durations.long2);
}

Future<void> findCurrentFiatInSettings(WidgetTester tester) async { // TODO: from here
  await tester.pump();
  final settingsButton = find.text('SETTINGS');
  expect(settingsButton, findsOneWidget);

  await tester.tap(settingsButton);
  await tester.pump(Durations.long2);
}



Future<void> fromSettingsToFiatDropdown(WidgetTester tester) async {
  await tester.pump();
  final dropdownButton = find.byType(DropdownButton<String>);
  expect(dropdownButton, findsOneWidget);

  await tester.tap(dropdownButton);
  await tester.pump(Durations.long2);
}

