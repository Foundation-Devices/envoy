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
import 'enable_testnet_test.dart';
import 'flow_to_map_and_p2p_test.dart';

void main() {
  testWidgets('Enable taproot', (tester) async {
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

      await pressHamburgerMenu(tester);
      await goToSettings(tester);
      await openAdvanced(tester);
      bool taprootAlreadyEnabled = await isSlideSwitchOn(tester, "Taproot");
      if (taprootAlreadyEnabled) {
        // Disable it
        await findAndToggleSettingsSwitch(tester, "Taproot");
      }
      await findAndToggleSettingsSwitch(tester, "Taproot");
      await tester.pump(Durations.long2);
      final doItLaterFromDialog = find.text('Do It Later');
      final popUpText = find.text(
        'Taproot on Passport',
      );
      // Check that a pop up comes up
      await tester.pumpUntilFound(popUpText, duration: Durations.long1);
      expect(doItLaterFromDialog, findsOneWidget);

      final closeDialogButton = find.byIcon(Icons.close);
      await tester.tap(closeDialogButton.last);
      await tester.pump(Durations.long2);
      // Check that a pop up close on 'x'
      expect(popUpText, findsNothing);
      await findAndToggleSettingsSwitch(tester, "Taproot"); // Disable
      await findAndToggleSettingsSwitch(tester, "Taproot"); // Enable again

      // Check that a pop up comes up
      expect(doItLaterFromDialog, findsOneWidget);
      await tester.tap(doItLaterFromDialog);
      await tester.pump(Durations.long2);
      // Check that a pop up close on "Do It Later"
      expect(doItLaterFromDialog, findsNothing);
      await pressHamburgerMenu(tester); // back to settings menu
      await pressHamburgerMenu(tester); // back to home
      final taprootBadge = find.text('Taproot');
      // Check that a Taproot accounts is displayed
      expect(taprootBadge, findsAny);

      // Check if the Taproot account disappears after being disabled
      await pressHamburgerMenu(tester);
      await goToSettings(tester);
      await openAdvanced(tester);
      await findAndToggleSettingsSwitch(tester, "Taproot"); // Disable
      await pressHamburgerMenu(tester); // back to settings menu
      await pressHamburgerMenu(tester); // back to home
      expect(taprootBadge, findsNothing);

      // Check if "Reconnect Passport" button working
      await pressHamburgerMenu(tester);
      await goToSettings(tester);
      await openAdvanced(tester);
      await findAndToggleSettingsSwitch(tester, "Taproot"); // Enable again
      final reconnectPassportButton = find.text('Reconnect Passport');
      expect(reconnectPassportButton, findsOneWidget);
      await tester.tap(reconnectPassportButton);
      await tester.pump(Durations.long2);
      final connectPassportButton = find.text('Get Started');
      expect(connectPassportButton, findsOneWidget);
    } finally {
      // Restore the original FlutterError.onError handler after the test.
      FlutterError.onError = originalOnError;
    }
  });
}
