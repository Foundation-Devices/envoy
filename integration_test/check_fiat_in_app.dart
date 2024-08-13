// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/main.dart';
import 'package:envoy/ui/amount_display.dart';
import 'package:envoy/ui/home/cards/accounts/detail/filter_options.dart';
import 'package:envoy/ui/home/settings/setting_toggle.dart';
import 'package:envoy/ui/home/top_bar_home.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screenshot/screenshot.dart';
import 'btc_sats.dart';
import 'check_for_toast.dart';
import 'connect_passport_via_recovery.dart';
import 'edit_account_name.dart';
import 'flow_to_map_and_p2p_test.dart';
import 'switch_fiat_currency.dart';

String someValidReceiveAddress = 'bc1qer3cxjxx6eav95ta6w4a3n7c3k254fhyud28vy';

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

      await setUpWalletFromSeedViaMagicRecover(tester, seed);

      /// 1) Go to settings
      await pressHamburgerMenu(tester);
      await goToSettings(tester);

      /// 2) Check that the fiat toggle exists
      bool isSettingsFiatSwitchOn =
          await isSlideSwitchOn(tester, 'Display Fiat Values');

      /// 3) Check that it can toggle just fine, leave it enabled (leave default fiat value)
      if (!isSettingsFiatSwitchOn) {
        // find And Toggle DisplayFiat Switch
        await findAndToggleSettingsSwitch(tester, 'Display Fiat Values');
        // Wait for the LoaderGhost to disappear
        await checkAndWaitLoaderGhostInAccount(tester, 'GH TEST ACC (#1)');
      }

      String? currentSettingsFiatCode = await findCurrentFiatInSettings(tester);

      await pressHamburgerMenu(tester); // back to settings
      await pressHamburgerMenu(tester); // back to home

      /// Check that this actions makes the fiat values display across the app
      /// Home
      if (currentSettingsFiatCode != null) {
        await tester.pump(Durations.long2);
        bool fiatCheckResult =
            await checkFiatOnCurrentScreen(tester, currentSettingsFiatCode);
        expect(fiatCheckResult, isTrue);
      }

      /// in Activity
      // await findAndPressTextButton(tester, 'Activity'); // TODO: uncomment when transaction is made
      //
      // if (currentSettingsFiatCode != null) {
      //   await tester.pump(Durations.long2);
      //   bool fiatCheckResult =
      //   await checkFiatOnCurrentScreen(tester, currentSettingsFiatCode);
      //   expect(fiatCheckResult, isTrue);
      // }

      /// in Mainet Account
      await findAndPressTextButton(tester, 'Accounts');

      // Scroll down by 600 pixels
      await scrollHome(tester, -600);

      await findFirstTextButtonAndPress(tester, 'GH TEST ACC (#1)');

      if (currentSettingsFiatCode != null) {
        await tester.pump(Durations.long2);
        bool fiatCheckResult =
            await checkFiatOnCurrentScreen(tester, currentSettingsFiatCode);
        expect(fiatCheckResult, isTrue);
      }

      /// in Tags
      await findAndPressWidget<SlidingToggle>(tester);

      if (currentSettingsFiatCode != null) {
        await tester.pump(Durations.long2);
        bool fiatCheckResult =
            await checkFiatOnCurrentScreen(tester, currentSettingsFiatCode);
        expect(fiatCheckResult, isTrue);
      }

      /// in Tag details
      await findAndPressTextButton(tester, 'Untagged');

      if (currentSettingsFiatCode != null) {
        await tester.pump(Durations.long2);
        bool fiatCheckResult =
            await checkFiatOnCurrentScreen(tester, currentSettingsFiatCode);
        expect(fiatCheckResult, isTrue);
      }

      // back to home
      await pressHamburgerMenu(tester);

      /// in Send
      await findAndPressTextButton(tester, 'Send');
      // press the widget two times so it can circle to Fiat
      await findAndPressWidget<AmountDisplay>(tester);
      await findAndPressWidget<AmountDisplay>(tester);

      if (currentSettingsFiatCode != null) {
        await tester.pump(Durations.long2);
        bool fiatCheckResult =
            await checkFiatOnCurrentScreen(tester, currentSettingsFiatCode);
        expect(fiatCheckResult, isTrue);
      }

      /// With the unit in fiat, paste a valid address, enter a valid amount, tap continue
      await enterTextInField(
          tester, find.byType(TextFormField), someValidReceiveAddress);

      // enter amount in Fiat
      /// This can fail if the fee is too high (small total amount)
      await findAndPressTextButton(tester, '1');
      await findAndPressTextButton(tester, '.');
      await findAndPressTextButton(tester, '1');

      // go to staging
      await waitForTealTextAndTap(tester, 'Confirm');

      // now wait for it to go to staging
      final textFinder = find.text("Fee");
      await tester.pumpUntilFound(textFinder,
          tries: 20, duration: Durations.long2);

      if (currentSettingsFiatCode != null) {
        await tester.pump(Durations.long2);
        bool fiatCheckResult =
            await checkFiatOnCurrentScreen(tester, currentSettingsFiatCode);
        expect(fiatCheckResult, isTrue);
      }
      await tester.pump(Durations.long2);

      /// in staging details
      // go to staging details
      await findAndPressTextButton(tester, 'Show details');

      if (currentSettingsFiatCode != null) {
        await tester.pump(Durations.long2);
        bool fiatCheckResult =
            await checkFiatOnCurrentScreen(tester, currentSettingsFiatCode);
        expect(fiatCheckResult, isTrue);
      }

      // 5) Close the app, reopen it // TODO: unable to do this
      // 6) Check that the toggle remains switched on

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
  return null;
}

Future<bool> checkFiatOnCurrentScreen(
    WidgetTester tester, String currentFiatCode) async {
  FiatCurrency? fiatCurrency = getFiatCurrencyByCode(currentFiatCode);
  if (fiatCurrency != null) {
    String? screenSymbol =
        await findSymbolOnScreen(tester, fiatCurrency.symbol);
    return screenSymbol == fiatCurrency.symbol;
  }
  return false;
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
  return null;
}

Future<void> pressHamburgerMenu(WidgetTester tester) async {
  // check if the toast pop-up is there before pressing on to the tob bar
  await checkForToast(tester);
  // go with top bar hamburger button
  await tester.pump();
  final hamburgerIcon = find.byType(HamburgerMenu);
  expect(hamburgerIcon, findsOneWidget);

  await tester.tap(hamburgerIcon, warnIfMissed: false);
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
