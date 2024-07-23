// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/main.dart';
import 'package:envoy/ui/amount_display.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/home/settings/setting_toggle.dart';
import 'package:envoy/ui/home/top_bar_home.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screenshot/screenshot.dart';
import 'check_fiat_in_app.dart';
import 'flow_to_map_and_p2p_test.dart';

void main() {
  testWidgets('check BTC/sats in App', (tester) async {
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

      //await setUpAppFromStart(tester); //TODO

      // Go to setting and enable fiat, we will need this later
      await pressHamburgerMenu(tester);
      await goToSettings(tester);

      bool isSettingsFiatSwitchOn =
          await isSlideSwitchOn(tester, 'Display Fiat Values');
      if (!isSettingsFiatSwitchOn) {
        // find And Toggle DisplayFiat Switch
        await findAndToggleSettingsSwitch(tester, 'Display Fiat Values');
      }

      String? currentSettingsFiatCode = await findCurrentFiatInSettings(tester);

      // return to home
      await pressHamburgerMenu(tester);
      await pressHamburgerMenu(tester);

      /// Check that all values are in BTC in the accounts menu, (and in the activity menu // TODO)
      // I am looking only one icon, because all of them are set with the same widget
      await checkForEnvoyIcon(tester, EnvoyIcons.btc);

      /// Get into an account, tap Send
      await findAndPressTextButton(tester, 'Mobile Wallet');
      await findAndPressTextButton(tester, 'Send');

      /// Make sure the first proposed unit is BTC
      // function is checking icons from top to bottom so the first icon in Send needs to be BTC
      await checkForEnvoyIcon(tester, EnvoyIcons.btc);

      /// Tap the BTC number in the send screen until you get to fiat (you might need to enable fiat from settings first)
      // press the widget two times so it can circle to Fiat
      await findAndPressWidget<AmountDisplay>(tester);
      await findAndPressWidget<AmountDisplay>(tester);

      // check if the fiat on the screen is the same one in the settings
      if (currentSettingsFiatCode != null) {
        await tester.pump(Durations.long2);
        bool fiatCheckResult =
            await checkFiatOnCurrentScreen(tester, currentSettingsFiatCode);
        expect(fiatCheckResult, isTrue);
      }

      ///  Check that the number below the fiat is displayed in BTC
      await checkForEnvoyIcon(tester, EnvoyIcons.btc);

// TODO
      // 7) With the unit in fiat, paste a valid address, enter a valid amount, tap continue
      //
      // 8) Check that in the Send review table all units are in BTC (and fiat)
      //
      // 9) Cancel the transaction and go back to settings, now toggle Sats
      //
      // 10) Close the app, reopen the app
      //
      // 11) Go to settings, check that killing the app didn't disable the Sats toggle
      //
      // 12) Repeat steps 2-8, but instead of BTC you should be seeing Sats in every step

      //await fromSettingsToFiatDropdown(tester); // if you want to open the dropdown and switch the Fiat

      // Note: The "ramp" widget is only supported on Android and iOS platforms,
      // so there is no reliable way to verify its functionality in this test.
    } finally {
      // Restore the original FlutterError.onError handler after the test.
      FlutterError.onError = originalOnError;
    }
  });
}

Future<void> checkForEnvoyIcon(
    WidgetTester tester, EnvoyIcons expectedIcon) async {
  await tester.pumpAndSettle(); // Initial pump to settle the widget tree

  // when starting the app from scratch, icons and numbers do not immediately show up
  // so we need to try to find icon a few more times
  const maxRetries = 5; // Maximum number of retries
  const retryDelay = Duration(seconds: 1); // Delay between retries

  for (int retryCount = 0; retryCount < maxRetries; retryCount++) {
    // Find all icons using a widget predicate
    final iconFinders = find.byWidgetPredicate(
      (widget) => widget is EnvoyIcon && widget.icon == expectedIcon,
    );

    // Check if the next icon is found
    if (iconFinders.evaluate().isNotEmpty) {
      // Ensure there is at least one widget
      expect(iconFinders, findsWidgets);
      return; // Exit function if at least one widget is found
    }

    // Wait for the specified delay before retrying
    await Future.delayed(retryDelay);
    await tester
        .pumpAndSettle(); // Pump and settle to allow the widget tree to update
  }

  // If the function reaches here, the icon was not found after the retries
  throw Exception(
      'Envoy icon $expectedIcon not found after $maxRetries retries');
}

Future<void> findAndPressTextButton(
    WidgetTester tester, String buttonText) async {
  await tester.pump();
  final textButton = find.text(buttonText);
  expect(textButton, findsOneWidget);

  await tester.tap(textButton);
  await tester.pump(Durations.long2);
}

Future<void> findAndPressWidget<T extends Widget>(WidgetTester tester) async {
  await tester.pumpAndSettle(); // Initial pump to settle the widget tree

  // Find the widget of type T
  final widgetFinder = find.byType(T);

  // Ensure the widget is present on the screen
  expect(widgetFinder, findsOneWidget);

  // Tap the widget
  await tester.tap(widgetFinder);

  // Allow any resulting animations to complete
  await tester.pumpAndSettle();
}
