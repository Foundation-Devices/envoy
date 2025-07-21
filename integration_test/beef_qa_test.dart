// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:envoy/main.dart';
import 'package:envoy/ui/amount_display.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coins_switch.dart';
import 'package:envoy/ui/home/cards/devices/devices_card.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/widgets/card_swipe_wrapper.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'util.dart';

Future<void> main() async {
  final FlutterExceptionHandler? originalOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    kPrint('FlutterError caught: ${details.exceptionAsString()}');
    if (originalOnError != null) {
      originalOnError(details);
    }
  };

  if (Platform.isLinux) {
    await resetLinuxEnvoyData();
  }

  await initSingletons(integrationTestsRunning: true);
  await resetEnvoyData();

  group('Hot wallet tests', () {
    // These tests use wallet which is set up from zero (no need for passport account)
    testWidgets('<Buy ATM filter by country first and flow to map>',
        (tester) async {
      await tester.pumpWidget(const EnvoyApp());

      await setUpAppFromStart(tester);
      await tester.pump(Durations.long2);
      await fromHomeToBuyOptions(tester, selectFirstCountryAvailable: false);

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

      await tester.pump(Durations.long2);
      await tester.pump(Durations.long2);

      final iconLocationFinder = find.byWidgetPredicate(
        (widget) => widget is EnvoyIcon && widget.icon == EnvoyIcons.location,
      );

      expect(iconLocationFinder, findsAny);
      await tester.tap(iconLocationFinder.last);
      await tester.pump(Durations.long2);
      await tester.pump(Durations.long2);

      // Check that the ATM name widget is present.
      // If found, it indicates that the map has loaded correctly for the specified region (Granada, Spain).
      final atmName = find.text("Kurant Bitcoin ATM");
      expect(atmName, findsAny);
    });
    testWidgets('<Buy button>', (tester) async {
      await goBackHome(tester);

      await findAndPressBuyOptions(tester);
      await checkBuyOptionAndTitle(tester);
    });
    testWidgets('<Buy button - enable from Settings>', (tester) async {
      await goBackHome(tester);

      // Find the Buy button (enabled in Settings by default)
      final buyButtonFinder = find.descendant(
        of: find.byType(GestureDetector),
        matching: find.text('Buy'),
      );
      expect(buyButtonFinder, findsOneWidget);

      // now turn it off from settings
      await fromHomeToAdvancedMenu(tester);
      await findAndToggleSettingsSwitch(tester, "Buy in Envoy");

      // back to Accounts
      await pressHamburgerMenu(tester);
      await pressHamburgerMenu(tester);

      expect(buyButtonFinder, findsNothing);
    });
    testWidgets('<About>', (tester) async {
      await goBackHome(tester);

      await pressHamburgerMenu(tester);
      await goToAbout(tester);

      final appVersion = find.text('2.0.0');
      expect(appVersion, findsOneWidget);

      final showButton = find.text('Show');
      expect(showButton, findsExactly(3));
      await tester.tap(showButton.first);
      await tester.pumpAndSettle();

      final licensePage = find.text('Licenses');
      expect(licensePage, findsOneWidget);
    });
    testWidgets('<Check support buttons in settings>', (tester) async {
      await goBackHome(tester);

      await pressHamburgerMenu(tester);
      await goToSupport(tester);
      // check buttons
      await goToDocumentation(tester);
      await goToCommunity(tester);
      await goToEmail(tester);
    });
    testWidgets('<Flow to edit acc name>', (tester) async {
      await goBackHome(tester);

      await fromHomeToHotWallet(tester);
      await openDotsMenu(tester);
      await fromDotsMenuToEditName(tester);

      await enterTextInField(tester, find.byType(TextField), 'What ever');
      await exitEditName(tester);
      await checkName(tester, 'Mobile Wallet'); // check if the name is the same

      await openDotsMenu(tester);
      await fromDotsMenuToEditName(tester);

      await enterTextInField(tester, find.byType(TextField),
          'Twenty one characters plus ten'); // 30 chars
      await saveName(tester);
      await checkName(
          tester, 'Twenty one character'); // it needs to cut text (chars 20/20)

      // Rename hot wallet back to "Mobile Wallet" if you want to repeat the test locally
      await openDotsMenu(tester);
      await fromDotsMenuToEditName(tester);

      await enterTextInField(tester, find.byType(TextField), 'Mobile Wallet');
      await saveName(tester);
    });
    testWidgets('<Testing Prompts for Wallets with Balances>', (tester) async {
      await goBackHome(tester);

      await clearPromptStates(tester);

      String tapTheAboveCardPrompt = "Tap the above card to receive Bitcoin.";
      Finder firstPrompt = find.text(tapTheAboveCardPrompt);
      expect(firstPrompt, findsOneWidget);

      // check Dismiss button functionality
      final dismissButton = find.text('Dismiss');
      await tester.tap(dismissButton);
      await tester.pump(Durations.long2);
      firstPrompt = find.text(tapTheAboveCardPrompt);
      expect(firstPrompt, findsNothing);

      // Clear prompt states
      await clearPromptStates(tester);
      firstPrompt = find.text(tapTheAboveCardPrompt);
      expect(firstPrompt, findsOneWidget);

      // Dismiss prompt via opening account
      await fromHomeToHotWallet(tester);
      // tap again to exit
      await fromHomeToHotWallet(tester);
      firstPrompt = find.text(tapTheAboveCardPrompt);
      expect(firstPrompt, findsNothing);

      // Clear prompt states
      await clearPromptStates(tester);
      firstPrompt = find.text(tapTheAboveCardPrompt);
      expect(firstPrompt, findsOneWidget);

      // Enable testnet
      final continueButtonFromDialog = find.text('Continue');
      await fromHomeToAdvancedMenu(tester);
      await findAndToggleSettingsSwitch(tester, "Testnet");
      await tester.tap(continueButtonFromDialog);
      await tester.pump(Durations.long2);
      await pressHamburgerMenu(tester); // back to settings menu
      await pressHamburgerMenu(tester);

      String tapTheAboveCardsPrompt =
          "Tap any of the above cards to receive Bitcoin.";
      Finder secondPrompt = find.text(tapTheAboveCardsPrompt);
      expect(secondPrompt, findsOneWidget);

      //Disable Testnet
      await fromHomeToAdvancedMenu(tester);
      await findAndToggleSettingsSwitch(tester, "Testnet");

      //Enable Signet
      await findAndToggleSettingsSwitch(tester, "Signet");
      await tester.tap(continueButtonFromDialog);
      await tester.pump(Durations.long2);
      await pressHamburgerMenu(tester);
      await pressHamburgerMenu(tester);

      secondPrompt = find.text(tapTheAboveCardsPrompt);
      expect(secondPrompt, findsOneWidget);

      //Disable Signet
      await fromHomeToAdvancedMenu(tester);
      await findAndToggleSettingsSwitch(tester, "Signet");

      //Enable Taproot
      await findAndToggleSettingsSwitch(tester, "Receive to Taproot");
      await pressHamburgerMenu(tester);
      await pressHamburgerMenu(tester);

      secondPrompt = find.text(tapTheAboveCardPrompt);
      expect(secondPrompt, findsOneWidget);

      // check Dismiss button functionality
      await tester.tap(dismissButton);
      await tester.pump(Durations.long2);
      secondPrompt = find.text(tapTheAboveCardsPrompt);
      expect(secondPrompt, findsNothing);

      // Enable Segwit
      await fromHomeToAdvancedMenu(tester);
      await findAndToggleSettingsSwitch(tester, "Receive to Taproot");
    });
    testWidgets('<Test decimal point in Send>', (tester) async {
      await goBackHome(tester);

      await pressHamburgerMenu(tester);
      await goToSettings(tester);

      bool isSettingsViewSatsSwitchOn =
          await isSlideSwitchOn(tester, 'View Amount in Sats');

      /// Check that the Amount is in BTC
      if (isSettingsViewSatsSwitchOn) {
        // find And Toggle DisplayFiat Switch
        await findAndToggleSettingsSwitch(tester, 'View Amount in Sats');
      }
      // Go back to Home
      await pressHamburgerMenu(tester);
      await pressHamburgerMenu(tester);

      await fromHomeToHotWallet(tester);

      final sendButtonText = find.text("Send");
      await tester.pumpUntilFound(sendButtonText,
          tries: 10, duration: Durations.long1);
      await tester.tap(sendButtonText.last);
      await tester.pump(Durations.long2);
      await tester.pumpAndSettle();
      await tester.pump(Durations.long2);

      await tester.drag(find.byType(Scrollable).first, const Offset(0, -200));
      await tester.pump();

      await findAndPressTextButton(tester, '.');
      await tester.pump(Durations.long2);
      // Check the main amount to see if pressing the dot was successful.
      final sendAmount = find.text("0.");
      expect(sendAmount.first, findsOneWidget);
    });
  });

  group('Passport wallet tests', () {
    // Below tests require already set up wallet with passport and coins
    testWidgets('<Magic recovery from Foundation server>', (tester) async {
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
      await setUpWalletFromSeedViaBackupFile(tester, seed);
    });
    testWidgets('<Pump until balance sync>', (tester) async {
      await checkSync(tester);
    });
    testWidgets('<Testing Prompts for Wallets with Balances>', (tester) async {
      await goBackHome(tester);

      await disableAllNetworks(tester);
      await clearPromptStates(tester);

      String tapTheAboveCardsPrompt =
          "Tap any of the above cards to receive Bitcoin.";
      Finder tapCardsPromptFinder = find.text(tapTheAboveCardsPrompt);
      expect(tapCardsPromptFinder, findsOneWidget);

      // Dismiss prompt via opening account
      await fromHomeToHotWallet(tester);
      // tap again to exit
      await fromHomeToHotWallet(tester);

      tapCardsPromptFinder = find.text(tapTheAboveCardsPrompt);
      expect(tapCardsPromptFinder, findsNothing);

      String swipeBalancePrompt = "Swipe to show and hide your balance.";
      Finder swipeBalancePromptFinder = find.text(swipeBalancePrompt);
      expect(swipeBalancePromptFinder, findsOneWidget);

      // check Dismiss button functionality
      final dismissButton = find.text('Dismiss');
      await tester.tap(dismissButton);
      await tester.pump(Durations.long2);
      swipeBalancePromptFinder = find.text(swipeBalancePrompt);
      expect(swipeBalancePromptFinder, findsNothing);

      await clearPromptStates(tester);

      // Dismiss "Tap above card to receive bitcoin" prompt
      await tester.tap(dismissButton);
      await tester.pump(Durations.long2);
      tapCardsPromptFinder = find.text(tapTheAboveCardsPrompt);
      expect(tapCardsPromptFinder, findsNothing);

      swipeBalancePromptFinder = find.text(swipeBalancePrompt);
      expect(swipeBalancePromptFinder, findsOneWidget);

      const String reorderPromptMessage =
          "Hold to drag and reorder your accounts.";
      Finder reorderPromptFinder = find.text(reorderPromptMessage);

      final walletWithBalance = find.text("GH TEST ACC (#1)");
      await tester.timedDrag(
          walletWithBalance, const Offset(-300, 0), const Duration(seconds: 1));
      await tester.pumpUntilFound(reorderPromptFinder);

      swipeBalancePromptFinder = find.text(swipeBalancePrompt);
      expect(swipeBalancePromptFinder, findsNothing);
      await tester.timedDrag(
          walletWithBalance, const Offset(-300, 0), const Duration(seconds: 1));

      await tester.tap(dismissButton);
      await tester.pump(Durations.long2);
      reorderPromptFinder = find.text(reorderPromptMessage);
      expect(tapCardsPromptFinder, findsNothing);

      await clearPromptStates(tester);

      await tester.tap(dismissButton);
      await tester.pump(Durations.long2);
      await tester.tap(dismissButton);
      await tester.pump(Durations.long2);

      reorderPromptFinder = find.text(reorderPromptMessage);
      expect(reorderPromptFinder, findsOneWidget);

      final accountText = find.text("Mobile Wallet");
      await tester.timedDrag(
          accountText.first, const Offset(0, 120), const Duration(seconds: 1));
      await tester.pump(Durations.long2);
      await Future.delayed(const Duration(seconds: 1));

      await tester.pump(Durations.long2);
      reorderPromptFinder = find.text(reorderPromptMessage);
      expect(tapCardsPromptFinder, findsNothing);
    });
    testWidgets('<Edit device name>', (tester) async {
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
      await checkName(
          tester, 'Twenty one character'); // it needs to cut text (chars 20/20)

      // Reset the device name to its initial value
      await openDotsMenu(tester);
      await openEditDevice(tester);

      await enterTextInField(tester, find.byType(TextField), 'Passport');
      await saveName(tester);
    });
    testWidgets('<Edit Passport account name>', (tester) async {
      await goBackHome(tester);

      const String accountPassportName = "GH TEST ACC (#1)";

      //  await scrollUntilVisible(
      //  tester,
      //  accountPassportName,
      // );
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
      await checkName(
          tester, 'Twenty one character'); // it needs to cut text (chars 20/20)

      // Reset the account name to its initial value
      await openDotsMenu(tester);
      await fromDotsMenuToEditName(tester);
      await enterTextInField(
          tester, find.byType(TextField), accountPassportName);
      await saveName(tester);
    });
    testWidgets('<BUY forever back loop>', (tester) async {
      await goBackHome(tester);

      await fromHomeToBuyOptions(tester);

      await findAndPressTextButton(tester, "Continue");

      // this is to choose passport account so we can see the Verify button !!!!
      await findAndPressWidget<CardSwipeWrapper>(tester, findFirst: true);
      await findLastTextButtonAndPress(tester, "GH TEST ACC (#1)");

      await findAndPressTextButton(tester, "Verify Address with Passport");
      Finder doneButton = find.text("Done");
      await tester.pumpUntilFound(doneButton);
      await findAndPressTextButton(tester, "Done");
      await pressHamburgerMenu(tester);
      await pressHamburgerMenu(tester);
      await tester.pump(Durations.long2);
      await findTextOnScreen(tester, "ACCOUNTS");
      await tester.pump(Durations.long2);
      await findTextOnScreen(tester, "Accounts");
      await tester.pump(Durations.long2);
      // Make sure you do not go back to BUY after hamburger (and closing the loop)
      await pressHamburgerMenu(tester);
      await tester.pump(Durations.long2);
      await findTextOnScreen(tester, "SETTINGS");
      await tester.pump(Durations.long2);
    });
    testWidgets('<Fiat in App>', (tester) async {
      await checkSync(tester);
      await goBackHome(tester);

      String someValidReceiveAddress =
          'bc1qy5fx88kwxd05rg5yugqcsnese0mypcjxwfur84';
      const String accountPassportName = "GH TEST ACC (#1)";

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
      }

      if (!isSettingsViewSatsSwitchOn) {
        // find And Toggle DisplayFiat Switch
        await findAndToggleSettingsSwitch(tester, 'View Amount in Sats');
      }

      String? currentSettingsFiatCode = await findCurrentFiatInSettings(tester);

      await pressHamburgerMenu(tester); // back to settings
      await pressHamburgerMenu(tester); // back to home

      // Wait for the LoaderGhost to disappear
      await checkAndWaitLoaderGhostInAccount(tester, accountPassportName);

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
      await findAndPressTextButton(tester, 'Accounts');
      await findAndPressTextButton(tester, 'Activity');

      if (currentSettingsFiatCode != null) {
        await tester.pump(Durations.long2);
        final receivedFinder = find.text("Received");
        await tester.pumpUntilFound(receivedFinder,
            tries: 100, duration: Durations.long2);
        bool fiatCheckResult =
            await checkFiatOnCurrentScreen(tester, currentSettingsFiatCode);
        expect(fiatCheckResult, isTrue);
      }

      /// in Mainet Account
      await findAndPressTextButton(tester, 'Accounts');

      await findFirstTextButtonAndPress(tester, accountPassportName);

      if (currentSettingsFiatCode != null) {
        await tester.pump(Durations.long2);
        bool fiatCheckResult =
            await checkFiatOnCurrentScreen(tester, currentSettingsFiatCode);
        expect(fiatCheckResult, isTrue);
      }

      /// in Tags
      await findAndTapActivitySlideButton(tester);

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
      // press the widget so it can circle to Sats
      //   await findAndPressWidget<AmountDisplay>(tester);

      if (currentSettingsFiatCode != null) {
        await tester.pump(Durations.long2);
        await findTextOnScreen(tester, "\$");
      }

      /// With the unit in fiat, paste a valid address, enter a valid amount, tap Confirm
      await enterTextInField(
          tester, find.byType(TextFormField), someValidReceiveAddress);

      // enter amount
      await findAndPressTextButton(tester, '5');
      await findAndPressTextButton(tester, '6');
      await findAndPressTextButton(tester, '7');

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
    testWidgets('<Test send to all address types>', (tester) async {
      await checkSync(tester);
      await goBackHome(tester);
      await disableAllNetworks(tester);

      final walletWithBalance = find.text("GH TEST ACC (#1)");
      expect(walletWithBalance, findsAny);
      await tester.tap(walletWithBalance);
      await tester.pump(Durations.long2);
      await tester.pumpAndSettle();

      final sendButtonFinder = find.text("Send");
      expect(sendButtonFinder, findsWidgets);
      await tester.tap(sendButtonFinder.last);
      await tester.pump(Durations.long2);

      // enter amount
      await findAndPressTextButton(tester, '1');
      await findAndPressTextButton(tester, '2');
      await findAndPressTextButton(tester, '3');
      await findAndPressTextButton(tester, '4');

      String p2pkhAddress = "12rYgz414HBXdhhK72BkR9VHZSU23dqqG7";
      await trySendToAddress(tester, p2pkhAddress);

      String p2shAddress = "3BY19nUKCAkrnzrgRezJoekGv4AFzsTs2z";
      await trySendToAddress(tester, p2shAddress);

      String p2wpkhAddress = "bc1qhrnucvul769yld6q09m8skwkp6zrecxhc00jcw";
      await trySendToAddress(tester, p2wpkhAddress);

      String p2trAddress =
          "bc1pgqnxzknhzyypgslhcevt96cnry4jkarv5gqp560a95uv6mzf4x7s0r67mm";
      await trySendToAddress(tester, p2trAddress);
    });
    testWidgets('<BTC/sats in App>', (tester) async {
      await checkSync(tester);

      await goBackHome(tester);

      String someValidSignetReceiveAddress =
          'tb1plhv9qthzz4trg5te27ulz6k8y46jd84azhe5fdmu6kehl9xwpp8qum6h3a';

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

      await openAdvancedMenu(tester);

      bool isSettingsSignetSwitchOn = await isSlideSwitchOn(tester, 'Signet');
      if (!isSettingsSignetSwitchOn) {
        // find And Toggle Signet Switch
        await findAndToggleSettingsSwitch(tester, 'Signet');
        // find Signet text on that pop-up
        final popUpText = find.text('Enabling Signet');
        // Check that a pop up comes up
        await tester.pumpUntilFound(popUpText, duration: Durations.long1);

        // exit Signet pop-up
        final closeDialogButton = find.byIcon(Icons.close);
        await tester.tap(closeDialogButton.last);
        await tester.pump(Durations.long2);
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
      await checkForEnvoyIcon(tester, EnvoyIcons.btc);
      //back to accounts
      await findAndPressTextButton(tester, 'Accounts');

      /// Get into an account, tap Send
      await scrollUntilVisible(
        tester,
        'Signet',
      );

      await checkSync(tester,
          waitAccSync: "Signet"); // Wait for the Signet acc to sync

      await findFirstTextButtonAndPress(tester, 'Signet');
      await findAndPressTextButton(tester, 'Send');

      /// Make sure the first proposed unit is BTC
      // function is checking icons from top to bottom so the first icon in Send needs to be BTC
      await checkForEnvoyIcon(tester, EnvoyIcons.btc);

      /// Tap the BTC number in the send screen until you get to fiat (you might need to enable fiat from settings first)
      // press the widget two times so it can circle to BTC
      await findAndPressWidget<AmountDisplay>(tester);
      await findAndPressWidget<AmountDisplay>(tester);

      if (currentSettingsFiatCode != null) {
        await tester.pump(Durations.long2);
        await findTextOnScreen(tester, "\$");
      }

      ///  Check that the number below the fiat is displayed in BTC
      await checkForEnvoyIcon(tester, EnvoyIcons.btc);

      // switch to SATS for easy input
      await findAndPressWidget<AmountDisplay>(tester);
      await tester.pump(Durations.long2);

      /// With the unit in SATS, paste a valid address, enter a valid amount, tap continue
      await enterTextInField(
          tester, find.byType(TextFormField), someValidSignetReceiveAddress);

      // enter amount in Fiat
      /// This can fail if the fee is too high (small total amount)
      await findAndPressTextButton(tester, '5');
      await findAndPressTextButton(tester, '6');
      await findAndPressTextButton(tester, '7');
      await tester.pump(Durations.long2);

      // switch back to BTC
      await findAndPressWidget<AmountDisplay>(tester);

      // go to staging
      await waitForTealTextAndTap(tester, 'Confirm');

      // now wait for it to go to staging
      final textFinder = find.text("Fee");
      await tester.pumpUntilFound(textFinder,
          tries: 100, duration: Durations.long2);

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

      /// exit from staging
      await findAndPressFirstEnvoyIcon(tester, EnvoyIcons.chevron_left);
      await tester.pump(Durations.long1);

      // go to home
      await findAndPressTextButton(tester,
          'Accounts'); // TODO: Since Send is f***ed I must go back like this
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
      await findLastTextButtonAndPress(tester, 'Activity');
      await checkForEnvoyIcon(tester, EnvoyIcons.sats);
      await findAndPressTextButton(tester,
          'Accounts'); // TODO: Since Send is f***ed I must go back like this

      /// Get into an account, tap Send
      await findFirstTextButtonAndPress(tester, 'Signet');
      await findAndPressTextButton(tester, 'Send');

      /// Make sure the first proposed unit is sats
      // function is checking icons from top to bottom so the first icon in Send needs to be sats
      await checkForEnvoyIcon(tester, EnvoyIcons.sats);

      if (currentSettingsFiatCode != null) {
        await tester.pump(Durations.long2);
        await findTextOnScreen(tester, "\$");
      }

      ///  Check that the number below the fiat is displayed in sats
      await checkForEnvoyIcon(tester, EnvoyIcons.sats);

      /// With the unit in sats, paste a valid address, enter a valid amount, tap continue
      await enterTextInField(
          tester, find.byType(TextFormField), someValidSignetReceiveAddress);

      // enter amount in SATS
      // This can fail if the fee is too high (small total amount) !!!
      await findAndPressTextButton(tester, '5');
      await findAndPressTextButton(tester, '6');
      await findAndPressTextButton(tester, '7');

      // go to staging
      await waitForTealTextAndTap(tester, 'Confirm');
      await tester.pump(Durations.long2);

      // now wait for it to go to staging
      final textFinder2 = find.text("Fee");
      await tester.pumpUntilFound(textFinder2,
          tries: 20, duration: Durations.long2);

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

      /// exit from staging
      await findAndPressFirstEnvoyIcon(tester, EnvoyIcons.chevron_left);
      await tester.pump(Durations.long1);
      await findAndPressTextButton(tester,
          'Accounts'); // TODO: Since Send is f***ed I must go back like this
    });
    testWidgets('<Enable testnet>', (tester) async {
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
    testWidgets('<Enable taproot>', (tester) async {
      await goBackHome(tester);

      await pressHamburgerMenu(tester);
      await goToSettings(tester);
      await openAdvancedMenu(tester);
      bool taprootAlreadyEnabled =
          await isSlideSwitchOn(tester, "Receive to Taproot");
      if (taprootAlreadyEnabled) {
        // Disable it
        await findAndToggleSettingsSwitch(tester, "Receive to Taproot");
      }
      await findAndToggleSettingsSwitch(tester, "Receive to Taproot");
      await tester.pump(Durations.long2);
      final confirmTextFromDialog = find.text('Confirm');

      // Check that a pop up comes up
      await tester.pumpUntilFound(confirmTextFromDialog,
          duration: Durations.long1);

      await tester.tap(confirmTextFromDialog);
      await tester.pump(Durations.long2);
      // Check that a pop up closed
      expect(confirmTextFromDialog, findsNothing);
      await findAndToggleSettingsSwitch(
          tester, "Receive to Taproot"); // Disable
      await findAndToggleSettingsSwitch(
          tester, "Receive to Taproot"); // Enable again

      // Check that a pop up comes up
      expect(confirmTextFromDialog, findsOneWidget);
      await tester.tap(confirmTextFromDialog);
      await tester.pump(Durations.long2);
      // Check that a pop up closed
      expect(confirmTextFromDialog, findsNothing);

      await pressHamburgerMenu(tester); // back to settings menu
      await pressHamburgerMenu(tester); // back to home
      await findFirstTextButtonAndPress(tester, "GH TEST ACC (#1)");
      await findAndPressTextButton(tester, "Receive");

      // copy Taproot address
      final address1 = await getAddressFromReceiveScreen(tester);

      // back to home
      await pressHamburgerMenu(tester);
      await pressHamburgerMenu(tester);
      // settings
      await pressHamburgerMenu(tester);
      await goToSettings(tester);
      await openAdvancedMenu(tester);
      await findAndToggleSettingsSwitch(
          tester, "Receive to Taproot"); // Disable
      await findFirstTextButtonAndPress(tester, "Confirm");

      await pressHamburgerMenu(tester); // back to settings menu
      await pressHamburgerMenu(tester); // back to home
      // await findFirstTextButtonAndPress(tester, "GH TEST ACC (#1)"); /// for some reason on iphone goes straight to receive screen (only in tests)
      // await findAndPressTextButton(tester, "Receive");

      // Grab the second address
      final address2 = await getAddressFromReceiveScreen(tester);

      // Compare them
      expect(address1.length < address2.length, isTrue,
          reason: 'Disabling Taproot should shorten the address format');

      // Check if "Reconnect Passport" button working
      // back to home
      await pressHamburgerMenu(tester);
      await pressHamburgerMenu(tester);
      // settings
      await pressHamburgerMenu(tester);
      await goToSettings(tester);
      await openAdvancedMenu(tester);
      await findAndToggleSettingsSwitch(
          tester, "Receive to Taproot"); // Enable again
    });
    testWidgets('<Check Signet in App>', (tester) async {
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
          await isSlideSwitchOn(tester, 'Receive to Taproot');
      if (isSettingsTaprootSwitchOn) {
        // find And Toggle Taproot Switch
        await findAndToggleSettingsSwitch(tester, 'Receive to Taproot');
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
    testWidgets('<Enable tor and check top shield>', (tester) async {
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

      // turn off Tor for next test
      await enablePerformance(tester);
      await checkTorShieldIcon(tester, expectPrivacy: false);
    });
    testWidgets('<Boost screen>', (tester) async {
      await goBackHome(tester);

      await disableAllNetworks(tester);

      //const hotSignetReceiveAddress =
      //    'tb1paj3dzfa392fp44hadwj3mnryqqurtp6qel6svyfzgelfs6j42x3q6xw9jg';
      // TODO: fill this wallet if there is no money from here https://signet257.bublina.eu.org/
      // TODO: when getting more coins you need to wait for the transaction confirmation before running the tests!!!

      const hotSignetSendAddress =
          'tb1pddwvqpcv5s4a738cs2av3x4kq3lr3kqt4w2flmpyha3srenxxseq9mlz5h'; // send coins to this address from base wallet

      await tester.pump(Durations.long2);

      await fromHomeToAdvancedMenu(tester);

      bool isSettingsSignetSwitchOn = await isSlideSwitchOn(tester, 'Signet');
      bool isSettingsTaprootSwitchOn =
          await isSlideSwitchOn(tester, 'Receive to Taproot');
      bool isSettingsViewSatsSwitchOn =
          await isSlideSwitchOn(tester, 'View Amount in Sats');

      if (!isSettingsViewSatsSwitchOn) {
        // find And Toggle DisplayFiat Switch
        await findAndToggleSettingsSwitch(tester, 'View Amount in Sats');
      }

      if (!isSettingsSignetSwitchOn) {
        // find And Toggle Signet Switch
        await tester.pump(Durations.long2);
        await findAndToggleSettingsSwitch(tester, 'Signet');
        await tester.pump(Durations.long2);
        final closeDialogButton = find.byIcon(Icons.close);
        await tester.tap(closeDialogButton.last, warnIfMissed: false);
        await tester.pump(Durations.long2);
      }

      if (!isSettingsTaprootSwitchOn) {
        // find And Toggle Taproot Switch
        await tester.pump(Durations.long2);
        await findAndToggleSettingsSwitch(tester, 'Receive to Taproot');
        await tester.pump(Durations.long2);
        await findAndPressTextButton(tester, "Confirm");
        await tester.pump(Durations.long2);
      }

      // go back to accounts
      await pressHamburgerMenu(tester);
      await pressHamburgerMenu(tester);

      await checkSync(tester, waitAccSync: "Signet");
      await tester.pump(Durations.long2);

      await sendFromBaseWallet(tester, hotSignetSendAddress);

      // go to tags
      await findAndTapActivitySlideButton(tester);

      /// lock all coins in the Untagged
      // Find all instances of the CoinTagSwitch
      Finder switchFinder = find.byType(CoinTagSwitch);

      // Check if the tag is locked
      if (switchFinder.evaluate().isNotEmpty) {
        // If there's a CoinTagSwitch, lock all of the Coins by tapping the CoinLockButton
        await findAndTapCoinLockButton(tester);
        await findAndPressTextButton(tester, 'Lock');
      }

      // go to activity
      await findAndTapActivitySlideButton(tester);
      await tester.pump(Durations.long2);
      await tester.pump(Durations.long2);

      // go to tags
      await findAndTapActivitySlideButton(tester);
      await tester.pump(Durations.long2);
      await tester.pump(Durations.long2);

      /// Check if the tag is locked (retry for good measures, it is bugged somehow)
      if (switchFinder.evaluate().isNotEmpty) {
        // If there's a CoinTagSwitch, lock all of the Coins by tapping the CoinLockButton
        await findAndTapCoinLockButton(tester);
        await findAndPressTextButton(tester, 'Lock');
      }

      // go to Activity
      await findAndTapActivitySlideButton(tester);
      await tester.pump(Durations.long2);
      await tester.pump(Durations.long2);

      await findFirstTextButtonAndPress(tester, 'Sent');

      /// Test does not press on X for some reason, it works on iOS but only sometimes
      // enter to pop-up
      // await slowSearchAndToggleText(tester, 'Boost');
      //
      // await tester.pump(const Duration(milliseconds: 1000));

      //close via X button
      // final closeDialogButton = find.byIcon(Icons.close);
      //
      //
      // await tester.pumpUntilFound(closeDialogButton.first,
      //     duration: Durations.long2, tries: 20);
      // await tester.pump(Durations.long2);
      //
      // await tester.pump(const Duration(milliseconds: 1000));

      //enter to pop-up
      await slowSearchAndToggleText(tester, 'Boost');
      await tester.pump(const Duration(milliseconds: 1000));
      //close via Continue button
      await findAndPressTextButton(tester, "Continue");
      await tester.pump(Durations.long2);

      /// go back and unlock all coins for the next test
      await pressHamburgerMenu(tester);
      await tester.pump(Durations.long2);

      // go to tags
      await findAndTapActivitySlideButton(tester);

      /// Unlock all coins in the Untagged for the next test

      // Find all instances of the CoinTagSwitch
      switchFinder = find.byType(CoinTagSwitch);
      await tester.pump(Durations.long2);

      // Check if the tag is locked
      if (switchFinder.evaluate().isEmpty) {
        // Unlock it for the next test
        await findAndTapCoinLockButton(tester);
        await findAndPressTextButton(tester, 'Unlock');
      }
    });
    testWidgets('<Receiving txs - check Boost and Cancel>', (tester) async {
      await goBackHome(tester);

      await disableAllNetworks(tester);

      //const testnetReceiveAddress =
      //    'tb1qe78y9rk4nwh9xuwmug7unpldfvpgkcqlufmgct';
      // TODO: fill this wallet if there is no money from here https://coinfaucet.eu/en/btc-testnet4/
      // TODO: when getting more coins you need to wait for the transaction confirmation before running the tests!!!

      const testnetSendAddress =
          'tb1qrjfqkufhvxexvkvss5e0ng2j5v3u0jhurcrlyk'; // send coins to this address from base wallet

      const testWallet = "Mobile Wallet";

      await tester.pump(Durations.long2);

      await fromHomeToAdvancedMenu(tester);
      await tester.pump(Durations.long2);

      bool isSettingsSignetSwitchOn = await isSlideSwitchOn(tester, 'Testnet');
      bool isSettingsTaprootSwitchOn =
          await isSlideSwitchOn(tester, 'Receive to Taproot');
      bool isSettingsViewSatsSwitchOn =
          await isSlideSwitchOn(tester, 'View Amount in Sats');

      if (!isSettingsViewSatsSwitchOn) {
        // find And Toggle DisplayFiat Switch
        await findAndToggleSettingsSwitch(tester, 'View Amount in Sats');
      }

      if (!isSettingsSignetSwitchOn) {
        // find And Toggle Testnet Switch
        await tester.pump(Durations.long2);
        await findAndToggleSettingsSwitch(tester, 'Testnet');
        await tester.pump(Durations.long2);
        final closeDialogButton = find.byIcon(Icons.close);
        await tester.tap(closeDialogButton.last, warnIfMissed: false);
        await tester.pump(Durations.long2);
      }

      if (isSettingsTaprootSwitchOn) {
        // find And Toggle Taproot Switch
        await tester.pump(Durations.long2);
        await findAndToggleSettingsSwitch(tester, 'Receive to Taproot');
        await tester.pump(Durations.long2);
        await findAndPressTextButton(tester, "Confirm");
        await tester.pump(Durations.long2);
      }

      // go back to accounts
      await pressHamburgerMenu(tester);
      await pressHamburgerMenu(tester);
      await tester.pump(Durations.long2);

      await checkSync(tester, waitAccSync: testWallet, findFirst: false);
      await tester.pump(Durations.long2);

      await sendFromBaseWallet(tester, testnetSendAddress,
          baseWallet: testWallet, findFirst: false);

      // Go back to accounts
      // await pressHamburgerMenu(tester);
      await findAndPressTextButton(tester, "Accounts");
      await tester.pump(Durations.long2);

      await findAndPressTextButton(tester, "Primary (#0)");
      await tester.pump(Durations.long2);

      // check if Received tx has boost/cancel
      await findLastTextButtonAndPress(tester, "Received");
      await tester.pump(Durations.long2);

      final boostButton = find.text('Boost');
      final cancelButton = find.text('Cancel Transaction');
      expect(boostButton, findsNothing);
      expect(cancelButton, findsNothing);
    });
    testWidgets('<Switching Fiat in App>', (tester) async {
      await goBackHome(tester);
      const String accountPassportName = "GH TEST ACC (#1)";

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
        await fromSettingsToFiatBottomSheet(tester);
        await findAndPressTextButton(tester, 'USD');
      }

      String? currentSettingsFiatCode = await findCurrentFiatInSettings(tester);

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

      // Scroll down by until text found
      await scrollUntilVisible(
        tester,
        accountPassportName,
      );

      // Wait for the LoaderGhost to disappear
      await checkAndWaitLoaderGhostInAccount(tester, accountPassportName);

      // Check the Fiat on the screen
      if (currentSettingsFiatCode != null) {
        await tester.pump(Durations.long2);
        bool fiatCheckResult =
            await checkFiatOnCurrentScreen(tester, currentSettingsFiatCode);
        expect(fiatCheckResult, isTrue);
      }

      String usdFiatAmount =
          await extractFiatAmountFromAccount(tester, accountPassportName);

      ///Go back to settings, change from USD to JPY, for example
      await pressHamburgerMenu(tester);
      await goToSettings(tester);

      await fromSettingsToFiatBottomSheet(tester);
      await findAndPressTextButton(tester, 'JPY');
      currentSettingsFiatCode = await findCurrentFiatInSettings(tester);

      /// Go back to the accounts view
      await pressHamburgerMenu(tester); // back to settings
      await pressHamburgerMenu(tester); // back to home

      /// Check that all fiat values ate grayed out "loading"
      await checkAndWaitLoaderGhostInAccount(tester, accountPassportName);

      /// Check that when the number loads we get the actual JPY value, not just the same number noted in step 2 with the JPY symbol
      // Check the Fiat on the screen
      if (currentSettingsFiatCode != null) {
        await tester.pump(Durations.long2);
        bool fiatCheckResult =
            await checkFiatOnCurrentScreen(tester, currentSettingsFiatCode);
        expect(fiatCheckResult, isTrue);
      }

      await tester.pump(Durations.long2);
      await tester.pump(Durations.long2);

      String newFiatAmount =
          await extractFiatAmountFromAccount(tester, accountPassportName);
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
      await fromSettingsToFiatBottomSheet(tester,
          currentSelection: currentSettingsFiatCode);
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
      await checkAndWaitLoaderGhostInAccount(tester, accountPassportName);

      // Check the Fiat on the screen
      if (currentSettingsFiatCode != null) {
        await tester.pump(Durations.long2);
        bool fiatCheckResult =
            await checkFiatOnCurrentScreen(tester, currentSettingsFiatCode);
        expect(fiatCheckResult, isTrue);
      }

      usdFiatAmount =
          await extractFiatAmountFromAccount(tester, accountPassportName);

      ///Go back to settings, change from USD to JPY, for example
      await pressHamburgerMenu(tester);
      await goToSettings(tester);

      await fromSettingsToFiatBottomSheet(tester);
      await findAndPressTextButton(tester, 'JPY');
      currentSettingsFiatCode = await findCurrentFiatInSettings(tester);

      /// Go back to the accounts view
      await pressHamburgerMenu(tester); // back to settings
      await pressHamburgerMenu(tester); // back to home

      /// Check that all fiat values ate grayed out "loading"
      await checkAndWaitLoaderGhostInAccount(tester, accountPassportName);

      /// Check that when the number loads we get the actual JPY value, not just the same number noted in step 2 with the JPY symbol
      // Check the Fiat on the screen
      if (currentSettingsFiatCode != null) {
        await tester.pump(Durations.long2);
        bool fiatCheckResult =
            await checkFiatOnCurrentScreen(tester, currentSettingsFiatCode);
        expect(fiatCheckResult, isTrue);
      }

      newFiatAmount =
          await extractFiatAmountFromAccount(tester, accountPassportName);
      // Check if the numbers differ from different Fiats
      expect(newFiatAmount != usdFiatAmount, isTrue);
    });
    testWidgets('<Account delete icon>', (tester) async {
      await goBackHome(tester);

      await disableAllNetworks(tester);

      const String accountPassportName = "GH TEST ACC (#1)";

      await findAndPressTextButton(tester, accountPassportName);
      await tester.pump(Durations.long2);
      // Go to Acc options
      await findAndPressIcon(tester, Icons.more_horiz_outlined);
      await findAndPressTextButton(tester, "DELETE");

      final envoyIconFinder = find.byWidgetPredicate(
        (widget) => widget is EnvoyIcon && widget.icon == EnvoyIcons.alert,
        description: 'EnvoyIcon finder == EnvoyIcons.alert',
      );

      expect(envoyIconFinder, findsOneWidget);
    });
    testWidgets('<Delete device>', (tester) async {
      await goBackHome(tester);
      String deviceName = "Passport";

      final devicesButton = find.text('Devices');
      await tester.tap(devicesButton);
      await tester.pumpAndSettle();

      await openDeviceCard(tester, deviceName);
      await openMenuAndPressDeleteDevice(tester);

      final popUpText = find.text(
        'Are you sure',
      );
      // Check that a pop up comes up
      await tester.pumpUntilFound(popUpText, duration: Durations.long1);
      final closeDialogButton = find.byIcon(Icons.close);
      await tester.tap(closeDialogButton.last);
      await tester.pump(Durations.long2);
      await tester.pump(Durations.long2);
      // Check that a pop up close on 'x'
      expect(popUpText, findsNothing);

      await openMenuAndPressDeleteDevice(tester);
      await tester.pumpUntilFound(popUpText, duration: Durations.long1);

      final deleteButtonFromDialog = find.text('Delete');
      expect(deleteButtonFromDialog, findsOneWidget);
      await tester.tap(deleteButtonFromDialog);
      await tester.pump(Durations.long2);

      await tester.pump(Durations.long2);

      // Make sure device is removed
      final emptyDevices = find.byType(GhostDevice);
      await tester.pumpUntilFound(emptyDevices);
      expect(emptyDevices, findsOne);

      // Verify that deleting the device also removes its associated accounts
      await findAndPressTextButton(tester, 'Accounts');
      await tester.pump(Durations.long2);
      final passportAccount = find.text(
        deviceName,
      );

      expect(passportAccount, findsNothing);
    });
    testWidgets('<Logs freeze>', (tester) async {
      await goBackHome(tester);

      await fromHomeToAdvancedMenu(tester);
      await tester.pump(Durations.long2);

      await findAndPressTextButton(tester, 'View Envoy Logs');
      await tester.pump(Durations.long2);

      await findAndPressIcon(tester, Icons.copy);
      //await tester.pump(const Duration(seconds: 5));

      await checkForToast(tester);
      // Perform an action that should trigger a UI update
      await findAndPressWidget<CupertinoNavigationBarBackButton>(tester);
      await tester.pump(Durations.long2);

      final newElementFinder = find.text('View Envoy Logs');

      await tester.pumpUntilFound(newElementFinder,
          duration: Durations.long1, tries: 100);
    });
  });
}
