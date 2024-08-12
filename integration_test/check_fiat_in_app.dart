// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/main.dart';
import 'package:envoy/ui/home/settings/setting_toggle.dart';
import 'package:envoy/ui/home/top_bar_home.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screenshot/screenshot.dart';
import 'check_for_toast.dart';
import 'flow_to_map_and_p2p_test.dart';

void main() {
  testWidgets('check Fiat in App', (tester) async {
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
      await goToSettings(tester);

      bool isSettingsFiatSwitchOn =
          await isSlideSwitchOn(tester, 'Display Fiat Values');
      if (!isSettingsFiatSwitchOn) {
        // find And Toggle DisplayFiat Switch
        await findAndToggleSettingsSwitch(tester, 'Display Fiat Values');
      }

      String? currentSettingsFiatCode = await findCurrentFiatInSettings(tester);

      await pressHamburgerMenu(tester); // back to settings
      await pressHamburgerMenu(tester); // back to home

      if (currentSettingsFiatCode != null) {
        await tester.pump(Durations.long2);
        bool fiatCheckResult =
            await checkFiatOnCurrentScreen(tester, currentSettingsFiatCode);
        expect(fiatCheckResult, isTrue);
      }

      //await fromSettingsToFiatDropdown(tester); // if you want to open the dropdown and switch the Fiat

      // Note: The "ramp" widget is only supported on Android and iOS platforms,
      // so there is no reliable way to verify its functionality in this test.
    } finally {
      // Restore the original FlutterError.onError handler after the test.
      FlutterError.onError = originalOnError;
    }
  });
}

FiatCurrency? getFiatCurrencyByCode(String code) {
  for (var fiatCurrency in supportedFiat) {
    if (fiatCurrency.code == code) {
      return fiatCurrency;
    }
  }
  return null; // Return null if no matching FiatCurrency is found
}

Future<bool> checkFiatOnCurrentScreen(
    WidgetTester tester, String currentFiatCode) async {
  FiatCurrency? fiatCurrency = getFiatCurrencyByCode(currentFiatCode);
  if (fiatCurrency != null) {
    String? screenSymbol =
        await findSymbolOnScreen(tester, fiatCurrency.symbol);
    return screenSymbol == fiatCurrency.symbol;
  }
  return false; // Return false if fiatCurrency is null
}

Future<String?> findSymbolOnScreen(
    WidgetTester tester, String fiatSymbol) async {
  final finder = find.text(fiatSymbol);

  // Wait until the symbol appears on the screen or timeout after 30 seconds
  final end = DateTime.now().add(const Duration(seconds: 30));
  while (DateTime.now().isBefore(end)) {
    await tester.pump();
    if (tester.any(finder)) {
      return fiatSymbol;
    }
  }
  return null; // Return null if no matching symbol is found
}

Future<void> pressHamburgerMenu(WidgetTester tester) async {
  // check if the toast pop-up is there before pressing on to the tob bar
  await checkForToast(tester);
  // go with top bar hamburger button
  await tester.pump();
  final hamburgerIcon = find.byType(HamburgerMenu);
  expect(hamburgerIcon, findsOneWidget);

  await tester.tap(hamburgerIcon);
  await tester.pump(Durations.long2);
}

Future<void> goToSettings(WidgetTester tester) async {
  await tester.pump();
  final settingsButton = find.text('SETTINGS');
  expect(settingsButton, findsOneWidget);

  await tester.tap(settingsButton);
  await tester.pump(Durations.long2);
}

Future<String?> findCurrentFiatInSettings(WidgetTester tester) async {
  await tester.pump();
  final dropdownFiatFinder = find.byType(DropdownButton<String>);
  expect(dropdownFiatFinder, findsOneWidget);

  // Retrieve the DropdownButton widget
  final dropdownFiatWidget =
      tester.widget<DropdownButton<String>>(dropdownFiatFinder);

  // Get the currently selected value
  final currentFiat = dropdownFiatWidget.value;
  await tester.pump(Durations.long2);

  return currentFiat;
}

Future<bool> isSlideSwitchOn(WidgetTester tester, String listTileText) async {
  await tester.pump();

  // Find the ListTile widget containing the text "Display Fiat Values"
  final listTileFinder = find.ancestor(
      of: find.text(listTileText), matching: find.byType(ListTile));
  expect(listTileFinder, findsOneWidget);

  // Find the SettingToggle widget within the ListTile
  final settingToggleFinder =
      find.descendant(of: listTileFinder, matching: find.byType(SettingToggle));
  expect(settingToggleFinder, findsOneWidget);

  // Retrieve the SettingToggle widget
  final settingToggleWidget = tester.widget<SettingToggle>(settingToggleFinder);

  // Return the state of the switch using the getter function
  return settingToggleWidget.getter();
}

Future<void> findAndToggleSettingsSwitch(
    WidgetTester tester, String listTileText) async {
  await tester.pump();

  // Find the ListTile widget containing the text "Display Fiat Values"
  final listTileFinder = find.ancestor(
      of: find.text(listTileText), matching: find.byType(ListTile));
  expect(listTileFinder, findsOneWidget);

  // Find the SettingToggle widget within the ListTile
  final switchFinder =
      find.descendant(of: listTileFinder, matching: find.byType(SettingToggle));
  expect(switchFinder, findsOneWidget);

  // Tap the switch to toggle it
  await tester.tap(switchFinder);
  await tester.pump(Durations.long2);
}

Future<void> fromSettingsToFiatDropdown(WidgetTester tester) async {
  await tester.pump();
  final dropdownButton = find.byType(DropdownButton<String>);
  expect(dropdownButton, findsOneWidget);

  await tester.tap(dropdownButton);
  await tester.pump(Durations.long2);
}
