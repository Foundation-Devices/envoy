// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/main.dart';
import 'package:envoy/ui/home/cards/accounts/account_list_tile.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screenshot/screenshot.dart';
import 'flow_to_map_and_p2p_test.dart';
import 'check_fiat_in_app.dart';

void main() {
  testWidgets('check testnet-taproot colisions', (tester) async {
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
      //await resetEnvoyData();

      await initSingletons();
      ScreenshotController envoyScreenshotController = ScreenshotController();
      await tester.pumpWidget(Screenshot(
          controller: envoyScreenshotController, child: const EnvoyApp()));

      await setUpAppFromStart(tester);

      // go to menu / settings / advanced
      await pressHamburgerMenu(tester);
      await goToSettings(tester);
      await openAdvanced(tester);

      // turn Testnet ON
      bool isSettingsTestnetSwitchOn = await isSlideSwitchOn(tester, 'Testnet');
      if (!isSettingsTestnetSwitchOn) {
        // find And Toggle Testnet Switch
        await findAndToggleSettingsSwitch(tester, 'Testnet');
        // exit Testnet pop-up
        final closeDialogButton = find.byIcon(Icons.close);
        await tester.tap(closeDialogButton.last);
        await tester.pump(Durations.long2);
      }

      // turn taproot ON
      bool isSettingsTaprootSwitchOn = await isSlideSwitchOn(tester, 'Taproot');
      if (!isSettingsTaprootSwitchOn) {
        // find And Toggle Taproot Switch
        await findAndToggleSettingsSwitch(tester, 'Taproot');
      }

      // Go back to the Accounts view
      await pressHamburgerMenu(tester);
      await pressHamburgerMenu(tester);

      // Make sure there is a hot wallet account for Testnet Taproot
      // Ensure the screen is fully rendered
      await tester.pumpAndSettle();

      // Find all AccountListTile widgets
      var accountListTileFinder = find.byType(AccountListTile);

      // Flag to track if a matching account is found
      bool foundTestnetTaprootAccount = false;

      // Iterate through each AccountListTile and verify the contents
      for (var i = 0; i < accountListTileFinder.evaluate().length; i++) {
        final accountBadge = accountListTileFinder.at(i);
        bool isAccTestnetTaproot =
            await isAccountTestnetTaproot(tester, accountBadge);

        //if any account is hot wallet for Testnet Taproot, break
        if (isAccTestnetTaproot) {
          foundTestnetTaprootAccount = true;
          break;
        }
      }
      // Assert if a matching account is found
      expect(foundTestnetTaprootAccount, true,
          reason:
              'Expected to find at least one Testnet Taproot account but did not.');

      // 4) Pair a testnet Passport account //TODO
      //
      // 5) Make sure there is now a Testnet Taproot Passport account //TODO
      //

      // Go to settings, disable Testnet
      // go to menu / settings / advanced
      await pressHamburgerMenu(tester);
      await goToSettings(tester);
      await openAdvanced(tester);

      /// turn Testnet OFF
      isSettingsTestnetSwitchOn = await isSlideSwitchOn(tester, 'Testnet');
      if (isSettingsTestnetSwitchOn) {
        // find And Toggle Testnet Switch
        await findAndToggleSettingsSwitch(tester, 'Testnet');
      }

      // Go back to the Accounts view
      await pressHamburgerMenu(tester);
      await pressHamburgerMenu(tester);

      // Go to accounts, make sure both Testnet Taproot accounts disappeared
      // Ensure the screen is fully rendered
      await tester.pumpAndSettle();

      // Find all AccountListTile widgets
      accountListTileFinder = find.byType(AccountListTile);

      // Flag to track if a Taproot account is found
      bool foundTaprootAccount = false;

      // Iterate through each AccountListTile and verify the contents
      for (var i = 0; i < accountListTileFinder.evaluate().length; i++) {
        final accountBadge = accountListTileFinder.at(i);
        bool isTestnetAccount = await isAccountTestnet(tester, accountBadge);
        bool isAccTestnetTaproot =
            await isAccountTestnetTaproot(tester, accountBadge);
        bool isTaprootAccount = await isAccountTaproot(tester, accountBadge);

        // Check if the current account is a Taproot account
        if (isTaprootAccount) {
          foundTaprootAccount = true;
        }

        // Check if all testnet-taproot accounts are gone
        expect(isAccTestnetTaproot, false);
        // Check if all testnet accounts are gone
        expect(isTestnetAccount, false);
      }
      //check if any account is taproot
      expect(foundTaprootAccount, true,
          reason: 'Expected to find at least one Taproot account but did not.');

      /// Go to settings, enable Testnet, disable Taproot
      // go to menu / settings / advanced
      await pressHamburgerMenu(tester);
      await goToSettings(tester);
      await openAdvanced(tester);

      // turn Testnet ON
      isSettingsTestnetSwitchOn = await isSlideSwitchOn(tester, 'Testnet');
      if (!isSettingsTestnetSwitchOn) {
        // find And Toggle Testnet Switch
        await findAndToggleSettingsSwitch(tester, 'Testnet');
        // exit Testnet pop-up
        final closeDialogButton = find.byIcon(Icons.close);
        await tester.tap(closeDialogButton.last);
        await tester.pump(Durations.long2);
      }

      // disable Taproot
      isSettingsTaprootSwitchOn = await isSlideSwitchOn(tester, 'Taproot');
      if (isSettingsTaprootSwitchOn) {
        // find And Toggle Taproot Switch
        await findAndToggleSettingsSwitch(tester, 'Taproot');
      }

      // Go to accounts, make sure both Testnet Taproot accounts disappeared
      // Ensure the screen is fully rendered
      await tester.pumpAndSettle();

      // Find all AccountListTile widgets
      accountListTileFinder = find.byType(AccountListTile);

      // Flag to track if a Taproot account is found
      bool foundTestnetAccount = false;

      // Iterate through each AccountListTile and verify the contents
      for (var i = 0; i < accountListTileFinder.evaluate().length; i++) {
        final accountBadge = accountListTileFinder.at(i);
        bool isTestnetAccount = await isAccountTestnet(tester, accountBadge);
        bool isAccTestnetTaproot =
            await isAccountTestnetTaproot(tester, accountBadge);
        bool isTaprootAccount = await isAccountTaproot(tester, accountBadge);

        // Check if the current account is a Taproot account
        if (isTestnetAccount) {
          foundTestnetAccount = true;
        }
        // Check if all testnet-taproot accounts are gone
        expect(isAccTestnetTaproot, false);
        // Check if all testnet accounts are gone
        expect(isTaprootAccount, false);
      }
      //check if any account is testnet
      expect(foundTestnetAccount, true,
          reason: 'Expected to find at least one Taproot account but did not.');

      /// Go to settings, enable Taproot
      // go to menu / settings / advanced
      await pressHamburgerMenu(tester);
      await goToSettings(tester);
      await openAdvanced(tester);

      // turn taproot ON
      isSettingsTaprootSwitchOn = await isSlideSwitchOn(tester, 'Taproot');
      if (!isSettingsTaprootSwitchOn) {
        // find And Toggle Taproot Switch
        await findAndToggleSettingsSwitch(tester, 'Taproot');
      }

      // Go back to the Accounts view
      await pressHamburgerMenu(tester);
      await pressHamburgerMenu(tester);

      // Go to Accounts, make sure both testnet Taproot accounts show up again
      // Ensure the screen is fully rendered
      await tester.pumpAndSettle();

      // Find all AccountListTile widgets
      accountListTileFinder = find.byType(AccountListTile);

      // Flag to track if a matching account is found
      foundTestnetTaprootAccount = false;

      // Iterate through each AccountListTile and verify the contents
      for (var i = 0; i < accountListTileFinder.evaluate().length; i++) {
        final accountBadge = accountListTileFinder.at(i);
        bool isAccTestnetTaproot =
            await isAccountTestnetTaproot(tester, accountBadge);

        //if any account is hot wallet for Testnet Taproot, break
        if (isAccTestnetTaproot) {
          foundTestnetTaprootAccount = true;
          break;
        }
      }
      // Assert if a matching account is found
      expect(foundTestnetTaprootAccount, true,
          reason:
              'Expected to find at least one Testnet Taproot account but did not.');

      // Note: The "ramp" widget is only supported on Android and iOS platforms,
      // so there is no reliable way to verify its functionality in this test.
    } finally {
      // Restore the original FlutterError.onError handler after the test.
      FlutterError.onError = originalOnError;
    }
  });
}

// Hot wallets only!
Future<bool> isAccountTestnetTaproot(
    WidgetTester tester, Finder accountListTile) async {
  await tester.pumpAndSettle();

  // Check for the presence of 'Testnet', 'Taproot', and 'Envoy' texts within the Account List.
  bool containsTestnet = find
      .descendant(
        of: accountListTile,
        matching: find.text('Testnet'),
      )
      .evaluate()
      .isNotEmpty;

  bool containsTaproot = find
      .descendant(
        of: accountListTile,
        matching: find.text('Taproot'),
      )
      .evaluate()
      .isNotEmpty;

  bool containsEnvoy = find
      .descendant(
        of: accountListTile,
        matching: find.text('Envoy'),
      )
      .evaluate()
      .isNotEmpty;

  // Return true if the account is Testnet-Taproot Hot account
  bool meetsCriteria = containsTestnet && containsTaproot && containsEnvoy;

  return meetsCriteria;
}

// Hot wallets only!
Future<bool> isAccountTestnet(
    WidgetTester tester, Finder accountListTile) async {
  await tester.pumpAndSettle();

  // Check for the presence of 'Testnet', and 'Envoy' texts within the Account List.
  bool containsTestnet = find
      .descendant(
        of: accountListTile,
        matching: find.text('Testnet'),
      )
      .evaluate()
      .isNotEmpty;

  bool containsEnvoy = find
      .descendant(
        of: accountListTile,
        matching: find.text('Envoy'),
      )
      .evaluate()
      .isNotEmpty;

  // Return true if the account is Testnet Hot account
  bool meetsCriteria = containsTestnet && containsEnvoy;

  return meetsCriteria;
}

// Hot wallets only!
Future<bool> isAccountTaproot(
    WidgetTester tester, Finder accountListTile) async {
  await tester.pumpAndSettle();

  // Check for the presence of 'Taproot', and 'Envoy' texts within the Account List.
  bool containsTaproot = find
      .descendant(
        of: accountListTile,
        matching: find.text('Taproot'),
      )
      .evaluate()
      .isNotEmpty;

  bool containsEnvoy = find
      .descendant(
        of: accountListTile,
        matching: find.text('Envoy'),
      )
      .evaluate()
      .isNotEmpty;

  // Return true if the account is Taproot Hot account
  bool meetsCriteria = containsTaproot && containsEnvoy;

  return meetsCriteria;
}

Future<void> openAdvanced(WidgetTester tester) async {
  await tester.pump();
  final advancedButton = find.text('Advanced');
  expect(advancedButton, findsOneWidget);

  await tester.tap(advancedButton);
  await tester.pump(Durations.long2);
}
