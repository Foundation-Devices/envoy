// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/main.dart';
import 'package:envoy/ui/amount_display.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screenshot/screenshot.dart';
import 'check_fiat_in_app.dart';
import 'connect_passport_via_recovery.dart';
import 'edit_account_name.dart';
import 'flow_to_map_and_p2p_test.dart';
import 'signet.dart';

String someValidReceiveAddress = 'bc1qer3cxjxx6eav95ta6w4a3n7c3k254fhyud28vy';

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

      await setUpWalletFromSeedViaMagicRecover(tester, seed);

      /// Go to setting and enable fiat, we will need this later
      await pressHamburgerMenu(tester);
      await goToSettings(tester);

      bool isSettingsFiatSwitchOn =
          await isSlideSwitchOn(tester, 'Display Fiat Values');
      if (!isSettingsFiatSwitchOn) {
        // find And Toggle DisplayFiat Switch
        await findAndToggleSettingsSwitch(tester, 'Display Fiat Values');
      }

      // make sure BTC is ON
      bool isSettingsViewSatsSwitchOn =
          await isSlideSwitchOn(tester, 'View Amount in Sats');
      if (isSettingsViewSatsSwitchOn) {
        // find And Toggle DisplayFiat Switch
        await findAndToggleSettingsSwitch(tester, 'View Amount in Sats');
      }

      String? currentSettingsFiatCode = await findCurrentFiatInSettings(tester);

      // return to home
      await pressHamburgerMenu(tester);
      await pressHamburgerMenu(tester);

      /// Check that all values are in BTC in the accounts menu, (and in the activity menu)
      // I am looking only one icon, because all of them are set with the same widget
      await checkForEnvoyIcon(tester, EnvoyIcons.btc);

      // Go to Activity and check for BTC
      await findAndPressTextButton(tester, 'Activity');
      await checkForEnvoyIcon(
          tester,
          EnvoyIcons
              .btc); // TODO: why does it pass if there is no icon on the screen
      //back to accounts
      await findAndPressTextButton(tester, 'Accounts');

      // Scroll down by 600 pixels
      await scrollHome(tester, -600);

      /// Get into an account, tap Send
      await findFirstTextButtonAndPress(tester, 'GH TEST ACC (#1)');
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
          tries: 10, duration: Durations.long2);

      /// Check that in the Send review table all units are in BTC (and fiat)
      // function is checking icons for BTC
      await checkForEnvoyIcon(tester, EnvoyIcons.btc);

      // check if the fiat on the screen is the same one in the settings
      if (currentSettingsFiatCode != null) {
        await tester.pump(Durations.long2);
        bool fiatCheckResult =
            await checkFiatOnCurrentScreen(tester, currentSettingsFiatCode);
        expect(fiatCheckResult, isTrue);
      }
      await tester.pump(Durations.long2);

      /// Cancel the transaction and go back to settings, now toggle Sats
      await findAndPressEnvoyIcon(tester, EnvoyIcons.chevron_left);

      await findAndTapPopUpText(tester, 'Cancel Transaction');
      // go to home
      await findAndPressTextButton(tester, 'Accounts');
      await pressHamburgerMenu(tester);
      await goToSettings(tester);

      // turn SATS view ON
      isSettingsViewSatsSwitchOn =
          await isSlideSwitchOn(tester, 'View Amount in Sats');
      if (!isSettingsViewSatsSwitchOn) {
        // find And Toggle DisplayFiat Switch
        await findAndToggleSettingsSwitch(tester, 'View Amount in Sats');
      }

      // 10) Close the app, reopen the app // TODO: Can't do this
      //
      // 11) Go to settings, check that killing the app didn't disable the Sats toggle

      /// Repeat steps 2-8, but instead of BTC you should be seeing Sats in every step
      // return to home
      await pressHamburgerMenu(tester);
      await pressHamburgerMenu(tester);

      /// Check that all values are in BTC in the accounts menu, (and in the activity menu)
      // I am looking only one icon, because all of them are set with the same widget
      await checkForEnvoyIcon(tester, EnvoyIcons.sats);

      // Go to Activity and check for sats
      await findAndPressTextButton(tester, 'Activity');
      await checkForEnvoyIcon(
          tester,
          EnvoyIcons
              .sats); // TODO: why does it pass if there is no icon on the screen
      //back to accounts
      await findAndPressTextButton(tester, 'Accounts');

      /// Get into an account, tap Send
      await findFirstTextButtonAndPress(tester, 'GH TEST ACC (#1)');
      await findAndPressTextButton(tester, 'Send');

      /// Make sure the first proposed unit is sats
      // function is checking icons from top to bottom so the first icon in Send needs to be sats
      await checkForEnvoyIcon(tester, EnvoyIcons.sats);

      // check if the fiat on the screen is the same one in the settings
      if (currentSettingsFiatCode != null) {
        await tester.pump(Durations.long2);
        bool fiatCheckResult =
            await checkFiatOnCurrentScreen(tester, currentSettingsFiatCode);
        expect(fiatCheckResult, isTrue);
      }

      ///  Check that the number below the fiat is displayed in sats
      await checkForEnvoyIcon(tester, EnvoyIcons.sats);

      /// With the unit in fiat, paste a valid address, enter a valid amount, tap continue
      await enterTextInField(
          tester, find.byType(TextFormField), someValidReceiveAddress);

      // enter amount in Fiat
      // This can fail if the fee is too high (small total amount) !!!
      await findAndPressTextButton(tester, '1');
      await findAndPressTextButton(tester, '.');
      await findAndPressTextButton(tester, '1');

      // go to staging
      await waitForTealTextAndTap(tester, 'Confirm');

      // now wait for it to go to staging
      final textFinder2 = find.text("Fee");
      await tester.pumpUntilFound(textFinder2,
          tries: 10, duration: Durations.long2);

      /// Check that in the Send review table all units are in sats (and fiat)
      // function is checking icons for sats
      await checkForEnvoyIcon(tester, EnvoyIcons.sats);

      // check if the fiat on the screen is the same one in the settings
      if (currentSettingsFiatCode != null) {
        await tester.pump(Durations.long2);
        bool fiatCheckResult =
            await checkFiatOnCurrentScreen(tester, currentSettingsFiatCode);
        expect(fiatCheckResult, isTrue);
      }

      // Note: The "ramp" widget is only supported on Android and iOS platforms,
      // so there is no reliable way to verify its functionality in this test.
    } finally {
      // Restore the original FlutterError.onError handler after the test.
      FlutterError.onError = originalOnError;
    }
  });
}

Future<void> waitForTealTextAndTap(
    WidgetTester tester, String textToFind) async {
  // Define the Teal color you want to check for
  const Color expectedColor = EnvoyColors.accentPrimary;

  // Finder for the text widget
  final Finder textFinder = find.text(textToFind);

  // Wait until the text is found
  await tester.pumpUntilFound(textFinder, tries: 20, duration: Durations.long2);

  // Set the maximum number of retries to wait for the text to turn Teal
  const int maxRetries = 10;
  int retryCount = 0;

  // Loop until the text's color is Teal or the maximum retries are reached
  bool isTeal = false;
  while (!isTeal && retryCount < maxRetries) {
    // Get the Text widget
    final Text textWidget = tester.widget<Text>(textFinder);

    // Check the color of the Text widget
    if (textWidget.style?.color == expectedColor) {
      isTeal = true;
    } else {
      // If not Teal, wait a bit and try again
      await tester.pump(const Duration(milliseconds: 1000));
      retryCount++;
    }
  }

  // If the text is Teal, tap it
  if (isTeal) {
    await tester.tap(textFinder);
    await tester.pump(Durations.long2);
  } else {
    throw Exception("Text did not turn teal after $maxRetries attempts");
  }

  await tester.pump(Durations.long2);
}

Future<void> findAndPressEnvoyIcon(
    WidgetTester tester, EnvoyIcons expectedIcon) async {
  // Use the existing function to find the EnvoyIcon
  final iconFinder = await checkForEnvoyIcon(tester, expectedIcon);

  await tester.tap(iconFinder.first);
  await tester.pump(Durations.long2);
}

Future<Finder> checkForEnvoyIcon(
    WidgetTester tester, EnvoyIcons expectedIcon) async {
  final iconFinder = find.byWidgetPredicate(
    (widget) => widget is EnvoyIcon && widget.icon == expectedIcon,
  );
  await tester.pumpUntilFound(iconFinder, tries: 10, duration: Durations.long2);

  return iconFinder;
}

Future<void> findAndPressTextButton(
    WidgetTester tester, String buttonText) async {
  await tester.pump(Durations.long2);
  final textButton = find.text(buttonText);
  expect(textButton, findsOneWidget);

  await tester.tap(textButton);
  await tester.pump(Durations.long2);
}

Future<void> findFirstTextButtonAndPress(
    WidgetTester tester, String buttonText) async {
  await tester.pumpAndSettle();

  // Find all widgets that match the text
  final textButtons = find.text(buttonText);

  // Ensure at least one widget is found
  expect(textButtons, findsWidgets);

  // Tap the first widget that matches
  await tester.tap(textButtons.first);
  await tester.pumpAndSettle();
}

Future<void> findAndPressWidget<T extends Widget>(WidgetTester tester) async {
  await tester.pumpAndSettle(); // Initial pump to settle the widget tree

  // Find the widget of type T
  final widgetFinder = find.byType(T);
  expect(widgetFinder, findsOneWidget);
  await tester.tap(widgetFinder);

  await tester.pumpAndSettle();
}
