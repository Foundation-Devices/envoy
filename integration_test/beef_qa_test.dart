// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/faucet.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/main.dart';
import 'package:envoy/ui/amount_display.dart';
import 'package:envoy/ui/home/cards/accounts/account_list_tile.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coins_switch.dart';
import 'package:envoy/ui/home/cards/accounts/detail/filter_options.dart';
import 'package:envoy/ui/routes/routes.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screenshot/screenshot.dart';
import 'util.dart';

Future<void> main() async {
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
    await resetEnvoyData();
    await initSingletons();

    group('Hot wallet tests', () {
      // These tests use wallet which is set up from zero (no need for passport account)
      testWidgets('Flow to map', (tester) async {
        await tester.pumpWidget(const EnvoyApp());

        await setUpAppFromStart(tester);
        await fromHomeToBuyOptions(tester);

        await tester.pump(Durations.long2);

        await tester.pump(Durations.long2);
        final atmTab = find.text("ATMs");

        await tester.pumpUntilFound(atmTab,
            tries: 100, duration: Durations.long2);
        await tester.pump(Durations.long2);
        expect(atmTab, findsOneWidget);
        await tester.tap(atmTab);
        await tester.pump(Durations.long2);

        final continueButtonFinder = find.text('Continue');
        expect(continueButtonFinder, findsOneWidget);
        await tester.tap(continueButtonFinder);
        await tester.pumpAndSettle();

        final iconFinder = find.byWidgetPredicate(
          (widget) => widget is EnvoyIcon && widget.icon == EnvoyIcons.plus,
        );
        expect(iconFinder, findsOneWidget);
      });

      testWidgets('About', (tester) async {
        await goBackHome(tester);

        await pressHamburgerMenu(tester);
        await goToAbout(tester);

        final appVersion = find.text('1.8.3');
        expect(appVersion, findsOneWidget);

        final showButton = find.text('Show');
        expect(showButton, findsExactly(3));
        await tester.tap(showButton.first);
        await tester.pumpAndSettle();

        final licensePage = find.text('Licenses');
        expect(licensePage, findsOneWidget);
      });
      testWidgets('Check support buttons in settings', (tester) async {
        await goBackHome(tester);

        await pressHamburgerMenu(tester);
        await goToSupport(tester);
        await goToDocumentation(tester);
        await goToTelegram(tester);
        await goToEmail(tester);
      });
      testWidgets('Flow to edit acc name', (tester) async {
        await goBackHome(tester);

        await scrollHome(tester, 300);
        await fromHomeToHotWallet(tester);
        await openDotsMenu(tester);
        await fromDotsMenuToEditName(tester);

        await enterTextInField(tester, find.byType(TextField), 'What ever');
        await exitEditName(tester);
        await checkName(
            tester, 'Mobile Wallet'); // check if the name is the same

        await openDotsMenu(tester);
        await fromDotsMenuToEditName(tester);

        await enterTextInField(tester, find.byType(TextField),
            'Twenty one characters plus ten'); // 30 chars
        await saveName(tester);
        await checkName(tester,
            'Twenty one character'); // it needs to cut text (chars 20/20)

        // Rename hot wallet back to "Mobile Wallet" if you want to repeat the test locally
        await openDotsMenu(tester);
        await fromDotsMenuToEditName(tester);

        await enterTextInField(tester, find.byType(TextField), 'Mobile Wallet');
        await saveName(tester);
      });
    });

    group('Passport wallet tests', () {
      // Below tests require already set up wallet with passport and coins
      testWidgets('Magic recovery from Foundation server', (tester) async {
        // Wallet for BEEFQA: this seed has magic recovery enabled on the Foundation server
        const List<String> seed = [
          "vault",
          "dust",
          "appear",
          "acoustic",
          "evolve",
          "monster",
          "arena",
          "injury",
          "tourist",
          "grab",
          "pair",
          "harvest"
        ];

        await tester.pumpWidget(const EnvoyApp());
        await setUpWalletFromSeedViaMagicRecover(tester, seed);
      });
      testWidgets('Edit device name', (tester) async {
        await goBackHome(tester);

        final devicesButton = find.text('Devices');
        await tester.tap(devicesButton);
        await tester.pumpAndSettle();

        // Input text without tapping Save
        await openDeviceCard(tester, "Passport");
        await openDotsMenu(tester);
        await openEditDevice(tester);

        await enterTextInField(
            tester, find.byType(TextField), 'New Passport name');
        await exitEditName(tester);
        await checkName(tester, 'Passport'); // check if the name is the same

        // Test for input name longer than the allowed maximum
        await openDotsMenu(tester);
        await openEditDevice(tester);

        await enterTextInField(tester, find.byType(TextField),
            'Twenty one characters plus ten'); // 30 chars
        await saveName(tester);
        await checkName(tester,
            'Twenty one character'); // it needs to cut text (chars 20/20)

        // Reset the device name to its initial value
        await openDotsMenu(tester);
        await openEditDevice(tester);

        await enterTextInField(tester, find.byType(TextField), 'Passport');
        await saveName(tester);
      });
      testWidgets('Edit Passport account name', (tester) async {
        await goBackHome(tester);

        const String accountPassportName = "GH TEST ACC (#1)";

        await scrollUntilVisible(
          tester,
          find.text(accountPassportName),
        );
        await openPassportAccount(tester, accountPassportName);
        await openDotsMenu(tester);
        await fromDotsMenuToEditName(tester);
        await enterTextInField(tester, find.byType(TextField), 'What ever');
        await exitEditName(tester);
        await checkName(
            tester, accountPassportName); // check if the name is the same

        await openDotsMenu(tester);
        await fromDotsMenuToEditName(tester);
        await enterTextInField(tester, find.byType(TextField),
            'Twenty one characters plus ten'); // 30 chars
        await saveName(tester);
        await checkName(tester,
            'Twenty one character'); // it needs to cut text (chars 20/20)

        // Reset the account name to its initial value
        await openDotsMenu(tester);
        await fromDotsMenuToEditName(tester);
        await enterTextInField(
            tester, find.byType(TextField), accountPassportName);
        await saveName(tester);
      });
      testWidgets('BTC/sats in App', (tester) async {
        await goBackHome(tester);

        String someValidReceiveAddress =
            'bc1qer3cxjxx6eav95ta6w4a3n7c3k254fhyud28vy';

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

        String? currentSettingsFiatCode =
            await findCurrentFiatInSettings(tester);

        // return to home
        await pressHamburgerMenu(tester);
        await pressHamburgerMenu(tester);

        /// Check that all values are in BTC in the accounts menu, (and in the activity menu)
        // I am looking only one icon, because all of them are set with the same widget
        await checkForEnvoyIcon(tester, EnvoyIcons.btc);

        // Go to Activity and check for BTC
        await findAndPressTextButton(tester, 'Activity');
        await checkForEnvoyIcon(tester, EnvoyIcons.btc);
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

        /// Repeat steps 2-8, but instead of BTC you should be seeing Sats in every step
        // return to home
        await pressHamburgerMenu(tester);
        await pressHamburgerMenu(tester);

        /// Check that all values are in BTC in the accounts menu, (and in the activity menu)
        // I am looking only one icon, because all of them are set with the same widget
        await checkForEnvoyIcon(tester, EnvoyIcons.sats);

        // Go to Activity and check for sats
        await findAndPressTextButton(tester, 'Activity');
        await checkForEnvoyIcon(tester, EnvoyIcons.sats);
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
      });
      testWidgets('Fiat in App', (tester) async {
        await goBackHome(tester);

        String someValidReceiveAddress =
            'bc1qer3cxjxx6eav95ta6w4a3n7c3k254fhyud28vy';

        /// 1) Go to settings
        await pressHamburgerMenu(tester);
        await goToSettings(tester);

        /// 2) Check that the fiat toggle exists
        bool isSettingsFiatSwitchOn =
            await isSlideSwitchOn(tester, 'Display Fiat Values');
        bool isSettingsViewSatsSwitchOn =
            await isSlideSwitchOn(tester, 'View Amount in Sats');

        /// 3) Check that it can toggle just fine, leave it enabled (leave default fiat value)
        if (!isSettingsFiatSwitchOn) {
          // find And Toggle DisplayFiat Switch
          await findAndToggleSettingsSwitch(tester, 'Display Fiat Values');
          // Wait for the LoaderGhost to disappear
          await checkAndWaitLoaderGhostInAccount(tester, 'GH TEST ACC (#1)');
        }

        String? currentSettingsFiatCode =
            await findCurrentFiatInSettings(tester);

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
        await findAndPressTextButton(tester, 'Activity');

        if (currentSettingsFiatCode != null) {
          await scrollActivityAndCheckFiat(tester, currentSettingsFiatCode);
        }

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
        // press the widget one/two times so it can circle to Fiat
        await findAndPressWidget<AmountDisplay>(tester);
        if (!isSettingsViewSatsSwitchOn) {
          await findAndPressWidget<AmountDisplay>(tester);
        }

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
      });
      testWidgets('Enable testnet', (tester) async {
        await goBackHome(tester);

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
      });
      testWidgets('Enable taproot', (tester) async {
        await goBackHome(tester);

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
      });
      testWidgets('Check Signet in App', (tester) async {
        await goBackHome(tester);

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
        await findAndTapPopUpText(tester, 'Continue');

        // Make sure Taproot is off when searching for Signet account (maybe not necessary)
        bool isSettingsTaprootSwitchOn =
            await isSlideSwitchOn(tester, 'Taproot');
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
      });
      testWidgets('Enable tor and check top shield', (tester) async {
        await goBackHome(tester);

        await findAndPressTextButton(tester, 'Privacy');

        // enable "better performance" if it is not enabled
        await enablePerformance(tester);
        // Check the shield icon after enabling performance
        await checkTorShieldIcon(tester, expectPrivacy: false);

        // Perform the required actions to change to privacy
        await enablePrivacy(tester);
        // Check the shield icon after enabling privacy

        await checkTorShieldIcon(tester, expectPrivacy: true);
      });
      testWidgets('Boost screen', (tester) async {
        await goBackHome(tester);

        const hotSignetAddress = 'tb1qt0h7r2hhphnsctj3akmusquszxvtkkupgmwrpq';
        const signetWalletAddress =
            'tb1p7n5z27jfsef6552q560y5z4a69c7ry9u5d74u0s2qelwa4dt7p5qs4ujrm';

        /// Also there should be at least 2 Coins inside the current Tag
        /// Should wait a few minutes for another test

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
      });
      testWidgets('Testnet-taproot collisions', (tester) async {
        await goBackHome(tester);

        // go to menu / settings / advanced
        await pressHamburgerMenu(tester);
        await goToSettings(tester);
        await openAdvanced(tester);

        // turn Testnet ON
        bool isSettingsTestnetSwitchOn =
            await isSlideSwitchOn(tester, 'Testnet');
        if (!isSettingsTestnetSwitchOn) {
          // find And Toggle Testnet Switch
          await findAndToggleSettingsSwitch(tester, 'Testnet');
          // exit Testnet pop-up
          final closeDialogButton = find.byIcon(Icons.close);
          await tester.tap(closeDialogButton.last);
          await tester.pump(Durations.long2);
        }

        // turn taproot ON
        bool isSettingsTaprootSwitchOn =
            await isSlideSwitchOn(tester, 'Taproot');
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

        /// 5) Make sure there is now a Testnet Taproot Passport account
        // Scroll down by 1000 pixels
        await scrollHome(tester, -1000);

        // Find all AccountListTile widgets
        accountListTileFinder = find.byType(AccountListTile);

        // Flag to track if a matching account is found
        foundTestnetTaprootAccount = false;

        // Iterate through each AccountListTile and verify the contents
        for (var i = 0; i < accountListTileFinder.evaluate().length; i++) {
          final accountBadge = accountListTileFinder.at(i);
          bool isAccTestnetTaproot = await isAccountTestnetTaproot(
              tester, accountBadge,
              isHotWallet: false);

          //if any account is Passport for Testnet Taproot, break
          if (isAccTestnetTaproot) {
            foundTestnetTaprootAccount = true;
            break;
          }
        }
        // Assert if a matching Passport account is found
        expect(foundTestnetTaprootAccount, true,
            reason:
                'Expected to find at least one Testnet Taproot account but did not.');

        // Scroll up by 1000 pixels
        await scrollHome(tester, 1000);

        /// Go to settings, disable Testnet
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
            reason:
                'Expected to find at least one Taproot account but did not.');

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
            reason:
                'Expected to find at least one Taproot account but did not.');

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

        // Scroll down by 1000 pixels
        await scrollHome(tester, -1000);

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
          bool isAccTestnetTaproot = await isAccountTestnetTaproot(
              tester, accountBadge,
              isHotWallet: false);

          //if any account is Passport for Testnet Taproot, break
          if (isAccTestnetTaproot) {
            foundTestnetTaprootAccount = true;
            break;
          }
        }
        // Assert if a matching account is found
        expect(foundTestnetTaprootAccount, true,
            reason:
                'Expected to find at least one Testnet Taproot account but did not.');
      });
      testWidgets('Switching Fiat in App', (tester) async {
        await goBackHome(tester);

        /// Open Envoy settings, enable fiat
        await findAndPressTextButton(tester, 'Privacy');
        // enable "better performance" if it is not enabled
        await enablePerformance(tester);
        // Check the shield icon after enabling performance
        await checkTorShieldIcon(tester, expectPrivacy: false);
        await findAndPressTextButton(tester, 'Accounts');

        // go to settings
        await pressHamburgerMenu(tester);
        await goToSettings(tester);

        // Check Fiat and set it to USD before testing
        bool textIsOnScreen = await findTextOnScreen(tester, 'USD');
        if (!textIsOnScreen) {
          await fromSettingsToFiatDropdown(tester);
          await findAndPressTextButton(tester, 'USD');
        }

        String? currentSettingsFiatCode =
            await findCurrentFiatInSettings(tester);

        bool isSettingsFiatSwitchOn =
            await isSlideSwitchOn(tester, 'Display Fiat Values');
        if (!isSettingsFiatSwitchOn) {
          // find And Toggle DisplayFiat Switch
          await findAndToggleSettingsSwitch(tester, 'Display Fiat Values');
        }

        currentSettingsFiatCode = await findCurrentFiatInSettings(tester);

        /// Go back to accounts menu, see the fiat values pop up - take note of the actual number being displayed
        await pressHamburgerMenu(tester); // back to settings
        await pressHamburgerMenu(tester); // back to home

        // Scroll down by 600 pixels
        await scrollHome(tester, -600);

        // Wait for the LoaderGhost to disappear
        await checkAndWaitLoaderGhostInAccount(tester, 'GH TEST ACC (#1)');

        // Check the Fiat on the screen
        if (currentSettingsFiatCode != null) {
          await tester.pump(Durations.long2);
          bool fiatCheckResult =
              await checkFiatOnCurrentScreen(tester, currentSettingsFiatCode);
          expect(fiatCheckResult, isTrue);
        }

        String usdFiatAmount =
            await extractFiatAmountFromAccount(tester, 'GH TEST ACC (#1)');

        ///Go back to settings, change from USD to JPY, for example
        await pressHamburgerMenu(tester);
        await goToSettings(tester);

        await fromSettingsToFiatDropdown(tester);
        await findAndPressTextButton(tester, 'JPY');
        currentSettingsFiatCode = await findCurrentFiatInSettings(tester);

        /// Go back to the accounts view
        await pressHamburgerMenu(tester); // back to settings
        await pressHamburgerMenu(tester); // back to home

        /// Check that all fiat values ate grayed out "loading"
        await checkAndWaitLoaderGhostInAccount(tester, 'GH TEST ACC (#1)');

        /// Check that when the number loads we get the actual JPY value, not just the same number noted in step 2 with the JPY symbol
        // Check the Fiat on the screen
        if (currentSettingsFiatCode != null) {
          await tester.pump(Durations.long2);
          bool fiatCheckResult =
              await checkFiatOnCurrentScreen(tester, currentSettingsFiatCode);
          expect(fiatCheckResult, isTrue);
        }

        String newFiatAmount =
            await extractFiatAmountFromAccount(tester, 'GH TEST ACC (#1)');
        // Check if the numbers differ from different Fiats
        expect(newFiatAmount != usdFiatAmount, isTrue);

        /// Repeat all steps over tor //////////////////////////////////////////////////

        await findAndPressTextButton(tester, 'Privacy');
        await enablePrivacy(tester);
        await findAndPressTextButton(tester, 'Accounts');
        // Check the shield icon after enabling privacy
        bool torIsConnected =
            await checkTorShieldIcon(tester, expectPrivacy: true);

        expect(torIsConnected, isTrue);

        /// Open Envoy settings, enable fiat
        await pressHamburgerMenu(tester);
        await goToSettings(tester);

        // Check Fiat and set it to USD before testing
        await fromSettingsToFiatDropdown(tester);
        await findAndPressTextButton(tester, 'USD');
        currentSettingsFiatCode = await findCurrentFiatInSettings(tester);

        isSettingsFiatSwitchOn =
            await isSlideSwitchOn(tester, 'Display Fiat Values');
        if (!isSettingsFiatSwitchOn) {
          // find And Toggle DisplayFiat Switch
          await findAndToggleSettingsSwitch(tester, 'Display Fiat Values');
        }

        currentSettingsFiatCode = await findCurrentFiatInSettings(tester);

        /// Go back to accounts menu, see the fiat values pop up - take note of the actual number being displayed
        await pressHamburgerMenu(tester); // back to settings
        await pressHamburgerMenu(tester); // back to home

        // Wait for the LoaderGhost to disappear
        await checkAndWaitLoaderGhostInAccount(tester, 'GH TEST ACC (#1)');

        // Check the Fiat on the screen
        if (currentSettingsFiatCode != null) {
          await tester.pump(Durations.long2);
          bool fiatCheckResult =
              await checkFiatOnCurrentScreen(tester, currentSettingsFiatCode);
          expect(fiatCheckResult, isTrue);
        }

        usdFiatAmount =
            await extractFiatAmountFromAccount(tester, 'GH TEST ACC (#1)');

        ///Go back to settings, change from USD to JPY, for example
        await pressHamburgerMenu(tester);
        await goToSettings(tester);

        await fromSettingsToFiatDropdown(tester);
        await findAndPressTextButton(tester, 'JPY');
        currentSettingsFiatCode = await findCurrentFiatInSettings(tester);

        /// Go back to the accounts view
        await pressHamburgerMenu(tester); // back to settings
        await pressHamburgerMenu(tester); // back to home

        /// Check that all fiat values ate grayed out "loading"
        await checkAndWaitLoaderGhostInAccount(tester, 'GH TEST ACC (#1)');

        /// Check that when the number loads we get the actual JPY value, not just the same number noted in step 2 with the JPY symbol
        // Check the Fiat on the screen
        if (currentSettingsFiatCode != null) {
          await tester.pump(Durations.long2);
          bool fiatCheckResult =
              await checkFiatOnCurrentScreen(tester, currentSettingsFiatCode);
          expect(fiatCheckResult, isTrue);
        }

        newFiatAmount =
            await extractFiatAmountFromAccount(tester, 'GH TEST ACC (#1)');
        // Check if the numbers differ from different Fiats
        expect(newFiatAmount != usdFiatAmount, isTrue);
      });
    });

    group('No account tests', () {
      // These tests don't need a Passport account
      testWidgets('Buy button', (tester) async {
        await goBackHome(tester);

        // start setup but without accounts
        await setUpFromStartNoAccounts(tester);

        await findAndPressBuyOptions(tester);
        await checkBuyOptionAndTitle(tester);
      });
    });
  } finally {
    FlutterError.onError = originalOnError;
  }
}
