// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/main.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screenshot/screenshot.dart';
import 'check_fiat_in_app.dart';
import 'connect_passport_via_recovery.dart';
import 'flow_to_map_and_p2p_test.dart';

void main() {
  testWidgets('Enable testnet', (tester) async {
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

      // Recover wallet with Passport accounts
      await setUpWalletFromSeedViaMagicRecover(tester, seed);

      await fromHomeToAdvancedMenu(tester);
      bool testnetAlreadyEnabled = await isSlideSwitchOn(tester, "Testnet");
      if (testnetAlreadyEnabled) {
        // Disable it
        await findAndToggleSettingsSwitch(tester, "Testnet");
      }
      await findAndToggleSettingsSwitch(tester, "Testnet");
      await tester.pump(Durations.long2);
      final continueButtonFromDialog = find.text('Continue');
      final popUpText = find.text(
        'Enabling Testnet',
      );
      // Check that a pop up comes up
      await tester.pumpUntilFound(popUpText, duration: Durations.long1);
      expect(continueButtonFromDialog, findsOneWidget);

      final closeDialogButton = find.byIcon(Icons.close);
      await tester.tap(closeDialogButton.last);
      await tester.pump(Durations.long2);
      // Check that a pop up close on 'x'
      expect(popUpText, findsNothing);
      await findAndToggleSettingsSwitch(tester, "Testnet"); // Disable
      await findAndToggleSettingsSwitch(tester, "Testnet"); // Enable again

      // Check that a pop up comes up
      expect(continueButtonFromDialog, findsOneWidget);
      await tester.tap(continueButtonFromDialog);
      await tester.pump(Durations.long2);
      // Check that a pop up close on Continue
      expect(continueButtonFromDialog, findsNothing);
      await pressHamburgerMenu(tester); // back to settings menu
      await pressHamburgerMenu(tester); // back to home
      final testnetAccountBadge = find.text('Testnet');
      // Check that a Testnet accounts is displayed
      expect(testnetAccountBadge, findsAtLeast(2));

      // Go to setting and disable it
      await fromHomeToAdvancedMenu(tester);
      await findAndToggleSettingsSwitch(tester, "Testnet"); // Disable
      await pressHamburgerMenu(tester); // back to settings menu
      await pressHamburgerMenu(tester); // back to home
      expect(testnetAccountBadge, findsNothing);

      // Go to settings and enable it again
      await fromHomeToAdvancedMenu(tester);
      await findAndToggleSettingsSwitch(tester, "Testnet"); // Enable again
      await tester.tap(continueButtonFromDialog);
      await tester.pump(Durations.long2);
      await pressHamburgerMenu(tester); // back to settings menu
      await pressHamburgerMenu(tester); // back to home
      // Ensure there are at least two badges: one for the passport and one for the hot testnet wallet.
      expect(testnetAccountBadge, findsAtLeast(2));
    } finally {
      // Restore the original FlutterError.onError handler after the test.
      FlutterError.onError = originalOnError;
    }
  });
}

Future<void> openAdvanced(WidgetTester tester) async {
  await tester.pump();
  final advancedButton = find.text('Advanced');
  expect(advancedButton, findsOneWidget);

  await tester.tap(advancedButton);
  await tester.pump(Durations.long2);
}

Future<void> fromHomeToAdvancedMenu(WidgetTester tester) async {
  await pressHamburgerMenu(tester);
  await goToSettings(tester);
  await openAdvanced(tester);
}
