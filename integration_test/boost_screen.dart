// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/faucet.dart';
import 'package:envoy/main.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coin_balance_widget.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coins_switch.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screenshot/screenshot.dart';
import 'btc_sats.dart';
import 'check_fiat_in_app.dart';
import 'connect_passport_via_recovery.dart';
import 'edit_account_name.dart';
import 'enable_testnet_test.dart';
import 'flow_to_map_and_p2p_test.dart';
import 'switch_fiat_currency.dart';

const hotSignetAddress = 'tb1qt0h7r2hhphnsctj3akmusquszxvtkkupgmwrpq';
const signetWalletAddress =
    'tb1p7n5z27jfsef6552q560y5z4a69c7ry9u5d74u0s2qelwa4dt7p5qs4ujrm';

/// Also there should be at least 2 Coins inside the current Tag
/// Should wait a few minutes for another test

void main() {
  testWidgets('Boost screen', (tester) async {
    // Only test the app version and Open Source Licenses page.
    // Unable to test Terms of Use and Privacy Policy as they open in an external application.

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

      await fromHomeToAdvancedMenu(tester);

      bool isSettingsSignetSwitchOn = await isSlideSwitchOn(tester, 'Signet');
      if (!isSettingsSignetSwitchOn) {
        // find And Toggle Signet Switch
        await findAndToggleSettingsSwitch(tester, 'Signet');
      }

      // go back to accounts
      await pressHamburgerMenu(tester);
      await pressHamburgerMenu(tester);

      // go to Signet account
      await findAndPressTextButton(tester, 'Signet');

      // go to tags
      await findAndPressEnvoyIcon(tester, EnvoyIcons.tag);
      await tester.pump(Durations.long2);

      /// lock all tags in the Untagged
      // Find all instances of the CoinTagSwitch
      final Finder switchFinder = find.byType(CoinTagSwitch);

      // Check if the tag is locked
      if (switchFinder.evaluate().isNotEmpty) {
        // If there's a CoinTagSwitch, lock all of the Coins by tapping the CoinLockButton
        await findAndTapCoinLockButton(tester);
        await findAndPressTextButton(tester, 'Lock');
      }

      // go to Untagged
      await findAndPressTextButton(tester, 'Untagged');
      await tester.pump(Durations.long2);

      // unlock one Coin
      await findAndTapCoinLockButton(tester);
      await findAndPressTextButton(tester, 'Unlock');

      // toggle that coin for Send
      await findAndToggleCoinTagSwitch(tester);

      await findAndPressTextButton(tester, 'Send Selected');

      await enterTextInField(
          tester, find.byType(TextFormField), signetWalletAddress);

      await findAndPressTextButton(
          tester, 'Send Selected'); // send the whole coin

      // go to staging
      await waitForTealTextAndTap(tester, 'Confirm');
      await tester.pump(Durations.long2);

      // now wait for it to go to staging
      final textFinder = find.text("Fee");
      await tester.pumpUntilFound(textFinder,
          tries: 20, duration: Durations.long2);

      await findAndPressTextButton(tester, 'Send Transaction');

      await findAndPressTextButton(tester, 'No thanks');

      await slowSearchAndToggleText(tester, 'Continue');

      // go to activity
      await findAndPressEnvoyIcon(tester, EnvoyIcons.tag);
      await tester.pump();
      await tester.pump(Durations.long2);

      await findFirstTextButtonAndPress(tester, 'Sent');

      // check if you are out of pop-up
      await slowSearchAndToggleText(tester, 'Boost');

      await tester.pump(const Duration(milliseconds: 1000));

      //close via X button
      final closeDialogButton = find.byIcon(Icons.close);
      await tester.pumpUntilFound(closeDialogButton,
          duration: Durations.long2, tries: 200);

      await tester.pump(Durations.long2);

      await findTextOnScreen(tester, 'Boost');

      // pull some money on the end for the next test
      await getSatsFromSignetFaucet(5000, hotSignetAddress);
      await tester.pump(Durations.long2);
    } finally {
      // Restore the original FlutterError.onError handler after the test.
      FlutterError.onError = originalOnError;
    }
  });
}

Future<void> findAndTapCoinLockButton(WidgetTester tester) async {
  // Find all instances of the CoinLockButton
  final Finder lockButtonFinder = find.byType(CoinLockButton);

  // Ensure that at least one CoinLockButton is found
  expect(lockButtonFinder, findsWidgets,
      reason: "No CoinLockButton found on the screen");

  // Select the last CoinLockButton
  final Finder specificButtonFinder = lockButtonFinder.last;

  // Tap the selected button
  await tester.tap(specificButtonFinder);
  await tester.pump(); // Reflect the UI changes
  await tester.pump(Durations.long2);
}

Future<void> findAndToggleCoinTagSwitch(WidgetTester tester) async {
  // Find all instances of the CoinTagSwitch
  final Finder switchFinder = find.byType(CoinTagSwitch);

  // Ensure that at least one CoinTagSwitch is found
  expect(switchFinder, findsWidgets,
      reason: "No CoinTagSwitch found on the screen");

  // Select the last CoinTagSwitch
  final Finder specificSwitchFinder = switchFinder.last;

  // Tap the selected switch to toggle it
  await tester.tap(specificSwitchFinder);
  await tester.pump(); // Reflect the UI changes
  await tester.pump(Durations.long2);
}

Future<void> slowSearchAndToggleText(
    WidgetTester tester, String buttonText) async {
  final text = find.text(buttonText);
  await tester.pumpUntilFound(text, duration: Durations.long2, tries: 200);
  expect(text, findsOneWidget);
  await tester.tap(text);
  await tester.pump(Durations.long2);
}
