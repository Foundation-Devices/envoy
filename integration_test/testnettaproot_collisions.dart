// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/main.dart';
import 'package:envoy/ui/home/cards/accounts/account_list_tile.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
      // Uncomment the line below if testing on local machine.
      //await resetEnvoyData();

      await initSingletons();
      ScreenshotController envoyScreenshotController = ScreenshotController();
      await tester.pumpWidget(Screenshot(
          controller: envoyScreenshotController, child: const EnvoyApp()));

      //await setUpAppFromStart(tester); // TODO

      // go to menu / settings / advance
      await pressHamburgerMenu(tester);
      await goToSettings(tester);
      await openAdvanced(tester);

      // turn Testnet ON
      // bool isSettingsTestnetSwitchOn = await isSlideSwitchOn(tester, 'Testnet');
      // if (!isSettingsTestnetSwitchOn) {
      //   // find And Toggle Signet Switch
      //   await findAndToggleSettingsSwitch(tester, 'Testnet');
      // }

      // exit Testnet pop-up
      final closeDialogButton = find.byIcon(Icons.close);
      await tester.tap(closeDialogButton.last);
      await tester.pump(Durations.long2);

      // turn taproot ON
      //bool isSettingsTaprootSwitchOn = await isSlideSwitchOn(tester, 'Taproot');
      // if (!isSettingsTaprootSwitchOn) {
      //   // find And Toggle Taproot Switch
      //   await findAndToggleSettingsSwitch(tester, 'Taproot');
      // }

      // Go back to the Accounts view
      await pressHamburgerMenu(tester);
      await pressHamburgerMenu(tester);

      // Ensure the screen is fully rendered.
      await tester.pumpAndSettle();
      // Find all AccountListTile widgets.
      final accountListTileFinder = find.byType(AccountListTile);
      // Iterate through each AccountListTile and verify the contents.
      for (var i = 0; i < accountListTileFinder.evaluate().length; i++) {
        final accountListTile = accountListTileFinder.at(i);
        await verifyHotAccountContents(tester, accountListTile);
      }

      // 3) Make sure there is a hot wallet account for Testnet Taproot
      //
      // 4) Pair a testnet Passport account
      //
      // 5) Make sure there is now a Testnet Taproot Passport account
      //
      // 6) Go to settings, disable Testnet
      //
      // 7) Go to accounts, make sure both Testnet Taproot accounts disappeared
      //
      // 8) Go to settings, enable Testnet, disable Taproot
      //
      // 9) Go to accounts, make sure both Testnet Taproot account are still not there
      //
      // 10) Go to settings, enable Taproot
      //
      // 11) Go to Accounts, make sure both testnet Taproot accounts show up again

      // Note: The "ramp" widget is only supported on Android and iOS platforms,
      // so there is no reliable way to verify its functionality in this test.
    } finally {
      // Restore the original FlutterError.onError handler after the test.
      FlutterError.onError = originalOnError;
    }
  });
}

Future<void> verifyHotAccountContents(
    WidgetTester tester, Finder accountListTile) async {
  // Check for the presence of 'testnet' or 'taproot' text within the tile.
  expect(
    find
            .descendant(of: accountListTile, matching: find.text('Testnet'))
            .evaluate()
            .isNotEmpty ||
        find
            .descendant(of: accountListTile, matching: find.text('Taproot'))
            .evaluate()
            .isNotEmpty,
    isTrue,
    reason: 'AccountListTile should contain "Testnet" or "Taproot" text',
  );

  // Check for the presence of the specific icon within the tile.
  expect(
    find.descendant(
      of: accountListTile,
      matching: find.byWidgetPredicate(
        (Widget widget) =>
            widget is SvgPicture && widget.key == const Key('ic_wallet_coins'),
      ),
    ),
    findsOneWidget,
    reason: 'AccountListTile should contain the specified icon',
  );
}

Future<void> openAdvanced(WidgetTester tester) async {
  await tester.pump();
  final advancedButton = find.text('Advanced');
  expect(advancedButton, findsOneWidget);

  await tester.tap(advancedButton);
  await tester.pump(Durations.long2);
}
