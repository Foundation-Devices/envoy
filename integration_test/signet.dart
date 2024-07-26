// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/main.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screenshot/screenshot.dart';
import 'enable_testnet_test.dart';
import 'flow_to_map_and_p2p_test.dart';
import 'check_fiat_in_app.dart';

void main() {
  testWidgets('check Signet in App', (tester) async {
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

      await fromHomeToAdvancedMenu(tester);

      bool isSettingsSignetSwitchOn = await isSlideSwitchOn(tester, 'Signet');
      if (!isSettingsSignetSwitchOn) {
        // find And Toggle Signet Switch
        await findAndToggleSettingsSwitch(tester, 'Signet');
      } else {
        // if it is already ON turn it OFF and ON again so that the pop-up shows up
        await findAndToggleSettingsSwitch(tester, 'Signet');
        await findAndToggleSettingsSwitch(tester, 'Signet');
      }

      // find Signet text on that pop-up
      final popUpText = find.text('Enabling Signet');
      // Check that a pop up comes up
      await tester.pumpUntilFound(popUpText, duration: Durations.long1);

      // exit Signet pop-up
      final closeDialogButton = find.byIcon(Icons.close);
      await tester.tap(closeDialogButton.last);
      await tester.pump(Durations.long2);

      // Tap the toggle to disable Signet
      await findAndToggleSettingsSwitch(tester, 'Signet');
      await tester.pump(Durations.long2);
      // Tap it again to enable it
      await findAndToggleSettingsSwitch(tester, 'Signet');

      //
      // Make sure that the hyperlink in the pop up works // TODO
      //

      // In the pop up now tap Continue to make sure that the button works
      // find Signet text on that pop-up
      final continueButton = find.text('Continue');
      // Check that a pop up comes up
      await tester.pumpUntilFound(continueButton, duration: Durations.long1);
      await tester.tap(continueButton.last);
      await tester.pump(Durations.long2);

      // Make sure Taproot is off when searching for Signet account (maybe not necessary)
      bool isSettingsTaprootSwitchOn = await isSlideSwitchOn(tester, 'Taproot');
      if (isSettingsTaprootSwitchOn) {
        // find And Toggle Taproot Switch
        await findAndToggleSettingsSwitch(tester, 'Taproot');
      }

      // Go back to the Accounts view
      await pressHamburgerMenu(tester);
      await pressHamburgerMenu(tester);

      // Check that a Signet hot wallet account is displayed
      await tester.pump();
      var signetTextAccount = find.text('Signet');
      expect(signetTextAccount, findsOneWidget);

      // Go back to settings, tap Signet switch again to disable it
      await fromHomeToAdvancedMenu(tester);

      isSettingsSignetSwitchOn = await isSlideSwitchOn(tester, 'Signet');
      // tap to disable Signet
      if (isSettingsSignetSwitchOn) {
        // find And Toggle Signet Switch
        await findAndToggleSettingsSwitch(tester, 'Signet');
      }

      // Go back to the accounts view and make sure that the account disappeared
      await pressHamburgerMenu(tester); // back to settings
      await pressHamburgerMenu(tester); // back to home

      await tester.pump();
      signetTextAccount = find.text('Signet');
      expect(signetTextAccount, findsNothing);

      // Note: The "ramp" widget is only supported on Android and iOS platforms,
      // so there is no reliable way to verify its functionality in this test.
    } finally {
      // Restore the original FlutterError.onError handler after the test.
      FlutterError.onError = originalOnError;
    }
  });
}
