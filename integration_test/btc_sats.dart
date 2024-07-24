// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/main.dart';
import 'package:envoy/ui/address_entry.dart';
import 'package:envoy/ui/amount_display.dart';
import 'package:envoy/ui/amount_entry.dart';
import 'package:envoy/ui/components/button.dart';
import 'package:envoy/ui/home/cards/accounts/spend/tx_review.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/home/settings/setting_toggle.dart';
import 'package:envoy/ui/home/top_bar_home.dart';
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

      // await setUpWalletFromSeedViaMagicRecover(tester,seed);//TODO

      /// Go to setting and enable fiat, we will need this later
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

      // Go to Activity and check for BTC
      await findAndPressTextButton(tester, 'Activity');
      await checkForEnvoyIcon(tester, EnvoyIcons.btc);
      //back to accounts
      await findAndPressTextButton(tester, 'Accounts');

      /// Get into an account, tap Send
      await findAndPressTextButton(
          tester, 'Primary (#0)'); // TODO: change the account
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
      await findAndPressTextButton(tester, 'Confirm');

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

      /// Cancel the transaction and go back to settings, now toggle Sats
      await findAndPressEnvoyIcon(tester, EnvoyIcons.chevron_left);

      // await tester.pump(); // TODO: Does not work on this pop-up?
      // final tapButtonText = find.text('Cancel Transaction');
      // await tester.pumpUntilFound(tapButtonText, duration: Durations.long1);
      // await tester.tap(tapButtonText.last);
      // await tester.pump(Durations.long2);

      //await findAndTapPopUpText(tester, 'Cancel Transaction'); // TODO: Does not work on this pop-up?

// TODO

      //
      // 10) Close the app, reopen the app // TODO: Can't do this
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

Future<void> findAndPressEnvoyIcon(
    WidgetTester tester, EnvoyIcons expectedIcon) async {
  // Use the existing function to find the EnvoyIcon
  final iconFinder = await checkForEnvoyIcon(tester, expectedIcon);

  // Tap the widget
  await tester.tap(iconFinder);
  await tester.pumpAndSettle(); // Allow any resulting animations to complete
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
