// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:envoy/main.dart';
import 'package:envoy/ui/components/amount_widget.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coin_balance_widget.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coins_switch.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';

//import 'package:envoy/ui/widgets/card_swipe_wrapper.dart';
import 'package:envoy/ui/widgets/envoy_amount_widget.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'util.dart';

Future<void> main() async {
  // Start the global timer
  final Stopwatch stopwatch = Stopwatch()..start();

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
      final stopwatch = Stopwatch()..start(); // Start timer

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
      await tester.pump(Durations.long2);
      await tester.pump(Durations.long2);
      await tester.pump(Durations.long2);

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

      // exit maps so it won't bug on the next test
      await findAndTapPopUpEnvoyIcon(tester, EnvoyIcons.close);
      await findAndPressEnvoyIcon(tester, EnvoyIcons.close);

      stopwatch.stop();
      debugPrint(
          '⏱ Test took ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} s');
    });
    testWidgets('<Buy button>', (tester) async {
      final stopwatch = Stopwatch()..start(); // Start timer
      await goBackHome(tester);

      await findAndPressBuyOptions(tester);
      await checkBuyOptionAndTitle(tester);

      stopwatch.stop();
      debugPrint(
        '⏱ Test took ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} s',
      );
    });
    testWidgets('<Buy button - enable from Settings>', (tester) async {
      final stopwatch = Stopwatch()..start(); // Start timer

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

      stopwatch.stop();
      debugPrint(
        '⏱ Test took ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} s',
      );
    });
    testWidgets('<About>', (tester) async {
      final stopwatch = Stopwatch()..start(); // Start timer

      await goBackHome(tester);

      await pressHamburgerMenu(tester);
      await goToAbout(tester);
      final version = await PackageInfo.fromPlatform();
      final appVersion =
          find.text("${version.version} (${version.buildNumber})");
      expect(appVersion, findsOneWidget);

      final showButton = find.text('Show');
      expect(showButton, findsExactly(3));
      await tester.tap(showButton.first);
      await tester.pump(Durations.long2);
      await tester.pump(Durations.long2);
      await tester.pump(Durations.long2);

      final licensePage = find.text('Licenses');
      expect(licensePage, findsOneWidget);

      stopwatch.stop();
      debugPrint(
        '⏱ Test took ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} s',
      );
    });
    testWidgets('<Check support buttons in settings>', (tester) async {
      final stopwatch = Stopwatch()..start(); // Start timer

      await goBackHome(tester);

      await pressHamburgerMenu(tester);
      await goToSupport(tester);
      // check buttons
      await goToDocumentation(tester);
      await goToCommunity(tester);
      await goToEmail(tester);

      stopwatch.stop();
      debugPrint(
        '⏱ Test took ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} s',
      );
    });
    testWidgets('<Flow to edit acc name>', (tester) async {
      final stopwatch = Stopwatch()..start(); // Start timer

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

      await goBackHome(tester); // force test to Home

      stopwatch.stop();
      debugPrint(
        '⏱ Test took ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} s',
      );
    });
    testWidgets('<Testing Prompts for Wallets with Balances>', (tester) async {
      final stopwatch = Stopwatch()..start(); // Start timer

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

      stopwatch.stop();
      debugPrint(
        '⏱ Test took ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} s',
      );
    });
    testWidgets('<Test decimal point in Send>', (tester) async {
      final stopwatch = Stopwatch()..start(); // Start timer

      await goBackHome(tester);

      await pressHamburgerMenu(tester);
      await tapSettingsButton(tester);

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
      await tester.pump(Durations.long2);
      await tester.pump(Durations.long2);

      await tester.drag(find.byType(Scrollable).first, const Offset(0, -200));
      await tester.pump();

      await findAndPressTextButton(tester, '.');
      await tester.pump(Durations.long2);
      // Check the main amount to see if pressing the dot was successful.
      final sendAmount = find.text("0.");
      expect(sendAmount.first, findsOneWidget);

      await goBackHome(tester);

      stopwatch.stop();
      debugPrint(
        '⏱ Test took ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} s',
      );
    });
    testWidgets('<Delete wallet warning pt.1>', (tester) async {
      final stopwatch = Stopwatch()..start(); // Start timer

      await goBackHome(tester);

      // go to backups
      await pressHamburgerMenu(tester);
      await tapSettingsButton(tester, buttonText: "BACKUPS");

      // press erase wallet
      await findAndPressTextButton(tester, "Erase Mobile Wallet and Backups");

      // skip two dialogs
      await findAndTapPopUpText(tester, "Continue");
      await findAndTapPopUpText(tester, "Continue");

      // check that the warning dialog did not pop
      final textFinder = find.text("Keep Your Seed Private");
      await tester.pumpUntilFound(textFinder,
          tries: 10, duration: Durations.long1);

      stopwatch.stop();
      debugPrint(
        '⏱ Test took ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} s',
      );
    });
  });

  group('Passport wallet tests', () {
    // Below tests require already set up wallet with passport and coins
    testWidgets('<Magic recovery from Foundation server>', (tester) async {
      final stopwatch = Stopwatch()..start(); // Start timer

      // Wallet for BEEFQA: this seed has magic recovery enabled on the Foundation server
      const List<String> seed = [
        "minor",
        "inspire",
        "domain",
        "sport",
        "radio",
        "put",
        "museum",
        "sure",
        "dose",
        "peanut",
        "home",
        "comfort"
      ];

      await tester.pumpWidget(const EnvoyApp());
      await setUpWalletFromSeedViaBackupFile(tester, seed);

      stopwatch.stop();
      debugPrint(
        '⏱ Test took ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} s',
      );
    });
    testWidgets('<Pump until balance sync>', (tester) async {
      final stopwatch = Stopwatch()..start(); // Start timer

      await checkSync(tester);

      stopwatch.stop();
      debugPrint(
        '⏱ Test took ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} s',
      );
    });

    testWidgets('<Activity text alignment>', (tester) async {
      final stopwatch = Stopwatch()..start();

      await goBackHome(tester);
      await checkSync(tester);
      await findAndPressTextButton(tester, "Activity");

      checkActivityAlignment(tester);

      /// Turn the Fiat OFF
      // Go to settings
      await pressHamburgerMenu(tester);
      await tapSettingsButton(tester);

      // Check that the fiat toggle exists
      bool isSettingsFiatSwitchOn =
          await isSlideSwitchOn(tester, 'Display Fiat Values');

      // If it is ON, turn it OFF
      if (isSettingsFiatSwitchOn) {
        // find And Toggle DisplayFiat Switch
        await findAndToggleSettingsSwitch(tester, 'Display Fiat Values');
      }

      // go back to Activity
      await pressHamburgerMenu(tester);
      await pressHamburgerMenu(tester);

      checkActivityAlignment(tester);

      /// Turn the Fiat back ON
      // Go to settings
      await pressHamburgerMenu(tester);
      await tapSettingsButton(tester);

      // Check that the fiat toggle exists
      isSettingsFiatSwitchOn =
          await isSlideSwitchOn(tester, 'Display Fiat Values');

      // If it is OFF, turn it ON
      if (!isSettingsFiatSwitchOn) {
        // find And Toggle DisplayFiat Switch
        await findAndToggleSettingsSwitch(tester, 'Display Fiat Values');
      }

      // go back to Home
      await goBackHome(tester);

      stopwatch.stop();
      debugPrint(
        '⏱ Test took ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} s',
      );
    });

    testWidgets('<Delete wallet warning pt.2>', (tester) async {
      final stopwatch = Stopwatch()..start(); // Start timer

      await goBackHome(tester);

      // go to backups
      await pressHamburgerMenu(tester);
      await tapSettingsButton(tester, buttonText: "BACKUPS");

      // press erase wallet
      await findAndPressTextButton(tester, "Erase Mobile Wallet");

      // skip two dialogs
      await findAndTapPopUpText(tester, "Continue");
      await findAndTapPopUpText(tester, "Continue");

      // check that the warning dialog did pop
      final warningDialogFinder = find.text("Delete Accounts anyway");
      await tester.pumpUntilFound(warningDialogFinder,
          tries: 10, duration: Durations.long1);

      stopwatch.stop();
      debugPrint(
        '⏱ Test took ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} s',
      );
    });
    testWidgets('<Test taproot modal>', (tester) async {
      final stopwatch = Stopwatch()..start(); // Start timer
      await goBackHome(tester);

      // make sure it is disabled
      await pressHamburgerMenu(tester);
      await tapSettingsButton(tester);
      await openAdvancedMenu(tester);
      bool taprootAlreadyEnabled =
          await isSlideSwitchOn(tester, "Receive to Taproot");
      if (taprootAlreadyEnabled) {
        // Disable it!
        await findAndToggleSettingsSwitch(tester, "Receive to Taproot");
        await tester.pump(Durations.extralong4);
        await tester.pump();
        await findAndPressTextButton(tester, "Confirm");
        await tester.pump(Durations.extralong4);
        await tester.pump();
      }

      const String accountPassportName = "Taproot modal test";

      // go to home
      await pressHamburgerMenu(tester);
      await pressHamburgerMenu(tester);

      /// Before enabling taproot, go to this account and tap receive, check that pop up does NOT show up
      await scrollHome(tester, -600);

      // go to acc
      await findAndPressTextButton(tester, accountPassportName);
      await findAndPressTextButton(tester, "Receive");
      await tester.pump(Durations.extralong4);
      await tester.pump();

      // find no pop-up
      final taprootFinder = find.text("Taproot on Passport");
      expect(taprootFinder, findsNothing);

      // go back
      //await pressHamburgerMenu(tester);
      await findAndPressTextButton(tester, "Accounts");
      await findAndPressTextButton(tester, accountPassportName);

      /// Then go to the descriptor and check that the pop up does NOT show up
      // open menu
      await findAndPressIcon(tester, Icons.more_horiz_outlined);
      await tester.pump(Durations.extralong4);
      await tester.pump();
      await findAndPressTextButton(tester, "SHOW DESCRIPTOR");
      await tester.pump(Durations.extralong4);
      await tester.pump();
      // find no pop-up
      expect(taprootFinder, findsNothing);

      /// Then enable taproot form settings, check the pop up shows
      // go back to settings
      //await pressHamburgerMenu(tester);
      await findAndPressTextButton(tester, "Accounts");
      await tester.pump(Durations.long2);
      await pressHamburgerMenu(tester);
      await tapSettingsButton(tester);
      await openAdvancedMenu(tester);

      // Enable it
      await findAndToggleSettingsSwitch(tester, "Receive to Taproot");
      await tester.pump(Durations.extralong4);
      await tester.pump();
      await findAndPressTextButton(tester, "Confirm");
      await tester.pump(Durations.extralong4);
      await tester.pump();

      /// Tap Do it later
      await findAndPressTextButton(tester, "Do It Later");
      await tester.pump(Durations.extralong4);
      await tester.pump();

      /// Go to this account, tap receive, check pop up shows
      // go back to accounts
      await pressHamburgerMenu(tester);
      await pressHamburgerMenu(tester);

      // go to acc
      await findAndPressTextButton(tester, accountPassportName);
      await tester.pump(Durations.extralong4);
      await tester.pump();
      await findAndPressTextButton(tester, "Receive");
      await tester.pump(Durations.extralong4);
      await tester.pump();

      /// Tap Do it later
      await findAndPressTextButton(tester, "Do It Later");
      await tester.pump(Durations.extralong4);
      await tester.pump();

      // go back to acc
      //await pressHamburgerMenu(tester);
      await findAndPressTextButton(tester, "Accounts");
      await tester.pump(Durations.long2);
      await findAndPressTextButton(tester, accountPassportName);
      await tester.pump(Durations.long2);

      /// Go to show descriptor for this account, check pop up shows
      // open menu
      await findAndPressIcon(tester, Icons.more_horiz_outlined);
      await tester.pump(Durations.extralong4);
      await tester.pump();
      await findAndPressTextButton(tester, "SHOW DESCRIPTOR");
      await tester.pump(Durations.extralong4);
      await tester.pump();

      /// Tap Do it later
      await findAndPressTextButton(tester, "Do It Later");
      await tester.pump(Durations.extralong4);
      await tester.pump();

      /// Check a segwit receive address is displayed
      // already checking this in another test

      /// Check a segwit descriptor shows
      await findTextOnScreen(tester, "Segwit");

      /// Go to another passport account paired after 2.3.0
      // go back to home
      //await pressHamburgerMenu(tester);
      await findAndPressTextButton(tester, "Accounts");
      await findAndPressTextButton(tester, "Primary (#0)");

      /// Tap receive, check that pop up does NOT show up
      await findAndPressTextButton(tester, "Receive");
      await tester.pump(Durations.extralong4);
      await tester.pump();

      // find no pop-up
      expect(taprootFinder, findsNothing);

      /// Go to descriptor, check that pop up does NOT show up
      // go back to home
      //await pressHamburgerMenu(tester);
      await findAndPressTextButton(tester, "Accounts");
      await tester.pump(Durations.long2);
      await findAndPressTextButton(tester, "Primary (#0)");
      await tester.pump(Durations.long2);

      // open menu
      await findAndPressIcon(tester, Icons.more_horiz_outlined);
      await tester.pump(Durations.extralong4);
      await tester.pump();
      await findAndPressTextButton(tester, "SHOW DESCRIPTOR");
      await tester.pump(Durations.extralong4);
      await tester.pump();
      // find no pop-up
      expect(taprootFinder, findsNothing);

      await goBackHome(tester); // force test to Home

      stopwatch.stop();
      debugPrint(
        '⏱ Test took ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} s',
      );
    });
    testWidgets('<Testing Prompts for Wallets with Balances>', (tester) async {
      final stopwatch = Stopwatch()..start(); // Start timer

      await goBackHome(tester);

      await disableAllNetworks(tester);
      await clearPromptStates(tester);

      String tapTheAboveCardsPrompt =
          "Tap any of the above cards to receive Bitcoin.";
      Finder tapCardsPromptFinder = find.text(tapTheAboveCardsPrompt);
      await tester.pumpUntilFound(tapCardsPromptFinder);

      // Dismiss prompt via opening account
      await fromHomeToHotWallet(tester);
      // tap again to exit
      await fromHomeToHotWallet(tester);

      await scrollHome(tester, -1200);
      await tester.pump(Durations.long2);
      await tester.pump(Durations.long2);
      await tester.pump(Durations.long2);

      String swipeBalancePrompt = "Swipe to show and hide your balance.";
      Finder swipeBalancePromptFinder = find.text(swipeBalancePrompt);
      await tester.pumpUntilFound(swipeBalancePromptFinder);

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
      await tester.pumpUntilFound(swipeBalancePromptFinder);

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

      await tester.pumpUntilFound(reorderPromptFinder);

      await scrollHome(tester, 1200);
      await tester.pump(Durations.long2);
      await tester.pump(Durations.long2);
      await tester.pump(Durations.long2);

      final accountText = find.text("Mobile Wallet");
      await tester.timedDrag(
          accountText.first, const Offset(0, 120), const Duration(seconds: 1));

      await tester.pump(Durations.long2);
      await Future.delayed(const Duration(seconds: 1));

      await scrollHome(tester, -1200);
      await tester.pump(Durations.long2);
      await tester.pump(Durations.long2);

      await tester.pump(Durations.long2);
      reorderPromptFinder = find.text(reorderPromptMessage);
      expect(tapCardsPromptFinder, findsNothing);

      await goBackHome(tester); // force test to Home

      stopwatch.stop();
      debugPrint(
        '⏱ Test took ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} s',
      );
    });
    testWidgets('<Edit device name>', (tester) async {
      final stopwatch = Stopwatch()..start(); // Start timer

      await goBackHome(tester);

      final devicesButton = find.text('Devices');
      await tester.tap(devicesButton);
      await tester.pump(Durations.long2);
      await tester.pump(Durations.long2);
      await tester.pump(Durations.long2);

      // Input text without tapping Save
      final firstPassport = find.text("Passport").first;
      await tester.tap(firstPassport);
      await tester.pump(Durations.long2);

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

      await goBackHome(tester); // force test to Home

      stopwatch.stop();
      debugPrint(
        '⏱ Test took ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} s',
      );
    });
    testWidgets('<Android native back>', (tester) async {
      final stopwatch = Stopwatch()..start(); // Start timer

      await goBackHome(tester);

      await pressHamburgerMenu(tester);

      // simulated native back
      await tester.binding.handlePopRoute();

      // confirm you are back to home
      await findTextOnScreen(tester, "Accounts");

      await pressHamburgerMenu(tester);

      await tapSettingsButton(tester);
      // simulated native back
      await tester.binding.handlePopRoute();
      // confirm that you are back to ENVOY
      await findTextOnScreen(tester, "ENVOY");

      await tapSettingsButton(tester, buttonText: "BACKUPS");
      // simulated native back
      await tester.binding.handlePopRoute();
      // confirm that you are back to ENVOY
      await findTextOnScreen(tester, "ENVOY");

      await tapSettingsButton(tester, buttonText: "SUPPORT");
      // simulated native back
      await tester.binding.handlePopRoute();
      // confirm that you are back to ENVOY
      await findTextOnScreen(tester, "ENVOY");

      await tapSettingsButton(tester, buttonText: "ABOUT");
      // simulated native back
      await tester.binding.handlePopRoute();
      // confirm that you are back to ENVOY
      await findTextOnScreen(tester, "ENVOY");

      await goBackHome(tester); // force test to Home

      stopwatch.stop();
      debugPrint(
        '⏱ Test took ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} s',
      );
    });
    testWidgets('<Edit Passport account name>', (tester) async {
      final stopwatch = Stopwatch()..start(); // Start timer

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

      await goBackHome(tester);

      stopwatch.stop();
      debugPrint(
        '⏱ Test took ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} s',
      );
    });
    // testWidgets('<BUY forever back loop>', (tester) async {
    //   final stopwatch = Stopwatch()..start(); // Start timer
    //
    //   await goBackHome(tester);
    //
    //   await fromHomeToBuyOptions(tester);
    //
    //   await findAndPressTextButton(tester, "Continue");
    //
    //   // this is to choose passport account so we can see the Verify button !!!!
    //   await findAndPressWidget<CardSwipeWrapper>(tester, findFirst: true);
    //   await findLastTextButtonAndPress(tester, "GH TEST ACC (#1)");
    //
    //   await findAndPressTextButton(tester, "Verify Address with Passport");
    //   Finder doneButton = find.text("Done");
    //   await tester.pumpUntilFound(doneButton);
    //   await findAndPressTextButton(tester, "Done");
    //   await pressHamburgerMenu(tester);
    //   await pressHamburgerMenu(tester);
    //   await tester.pump(Durations.long2);
    //   await findTextOnScreen(tester, "ACCOUNTS");
    //   await tester.pump(Durations.long2);
    //   await findTextOnScreen(tester, "Accounts");
    //   await tester.pump(Durations.long2);
    //   // Make sure you do not go back to BUY after hamburger (and closing the loop)
    //   await pressHamburgerMenu(tester);
    //   await tester.pump(Durations.long2);
    //   await findTextOnScreen(tester, "SETTINGS");
    //   await tester.pump(Durations.long2);
    //
    //   stopwatch.stop();
    //   debugPrint(
    //     '⏱ Test took ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} s',
    //   );
    // });
    testWidgets('<User unit preference in Send>', (tester) async {
      final stopwatch = Stopwatch()..start(); // Start timer

      String mainetReceiveAddress =
          'bc1qcjwyecualcytzgud5ruwrj642fng4tvp8nsgr2';

      await goBackHome(tester);
      await checkSync(tester);

      /// 1) Go to settings
      await pressHamburgerMenu(tester);
      await tapSettingsButton(tester);

      /// 2) Check that the fiat toggle exists
      bool isSettingsFiatSwitchOn =
          await isSlideSwitchOn(tester, 'Display Fiat Values');

      /// 3) Check that it can toggle just fine, leave it enabled (leave default fiat value)
      if (!isSettingsFiatSwitchOn) {
        // find And Toggle DisplayFiat Switch
        await findAndToggleSettingsSwitch(tester, 'Display Fiat Values');
      }

      await pressHamburgerMenu(tester); // back to settings
      await pressHamburgerMenu(tester); // back to home

      await scrollFindAndTapText(
          tester, "GH TEST ACC (#1)"); // tap first mainet acc with money

      await findAndPressTextButton(tester, "Send");

      /// change to sats
      await cycleToEnvoyIcon(tester, EnvoyIcons.sats);

      /// check if the unit is SATS (there should be 2 SATS icons on the screen)
      final satsFinder = await checkForEnvoyIcon(tester, EnvoyIcons.sats);
      expect(satsFinder, findsNWidgets(2));

      // go back
      //await pressHamburgerMenu(tester);
      await findAndPressTextButton(tester, "Accounts");
      await findAndPressTextButton(tester, "GH TEST ACC (#1)");
      await tester.pump(Durations.long1);

      await findAndPressTextButton(tester, "Send");

      /// check if the unit is SATS (there should be 2 SATS icons on the screen)
      expect(satsFinder, findsNWidgets(2));

      /// change to fiat
      await findAndPressTextButton(tester, "\$");

      // go back
      //await pressHamburgerMenu(tester);
      await findAndPressTextButton(tester, "Accounts");
      await findAndPressTextButton(tester, "GH TEST ACC (#1)");
      await tester.pump(Durations.long1);

      await findAndPressTextButton(tester, "Send");

      // check if you are entering dollars
      final dollarFinder = find.text("\$");
      expect(dollarFinder, findsNWidgets(2));

      /// change to btc
      await cycleToEnvoyIcon(tester, EnvoyIcons.btc);

      // go back
      //await pressHamburgerMenu(tester);
      await findAndPressTextButton(tester, "Accounts");
      await findAndPressTextButton(tester, "GH TEST ACC (#1)");
      await tester.pump(Durations.long1);

      await findAndPressTextButton(tester, "Send");

      /// check if the unit is BTC (there should be 2 BTC icons on the screen)
      final btcFinder = await checkForEnvoyIcon(tester, EnvoyIcons.btc);
      expect(btcFinder, findsNWidgets(2));

      /// With the unit in btc, paste a valid address, enter a valid amount, tap Confirm
      await enterTextInField(
          tester, find.byType(TextFormField), mainetReceiveAddress);

      /// change to sats so you can enter with test
      await cycleToEnvoyIcon(tester, EnvoyIcons.sats);

      // enter amount
      await findAndPressTextButton(tester, '5');
      await findAndPressTextButton(tester, '6');
      await findAndPressTextButton(tester, '7');

      /// change to btc
      await cycleToEnvoyIcon(tester, EnvoyIcons.btc);

      // go to staging
      await waitForTealTextAndTap(tester, 'Confirm');

      // now wait for it to go to staging
      final textFinder = find.text("Fee");
      await tester.pumpUntilFound(textFinder,
          tries: 20, duration: Durations.long2);

      // check if the unit in the Staging is BTC
      await checkForEnvoyIcon(tester, EnvoyIcons.btc);

      await goBackHome(tester); // force test to Home

      stopwatch.stop();
      debugPrint(
        '⏱ Test took ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} s',
      );
    });
    testWidgets('<Fiat in App>', (tester) async {
      final stopwatch = Stopwatch()..start(); // Start timer

      await checkSync(tester);
      await goBackHome(tester);

      String someValidReceiveAddress =
          'bc1qy5fx88kwxd05rg5yugqcsnese0mypcjxwfur84';
      const String accountPassportName = "GH TEST ACC (#1)";

      /// 1) Go to settings
      await pressHamburgerMenu(tester);
      await tapSettingsButton(tester);

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

      /// Check if you are entering sats
      await cycleToEnvoyIcon(tester, EnvoyIcons.sats);

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

      await goBackHome(tester); // force test to Home

      stopwatch.stop();
      debugPrint(
        '⏱ Test took ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} s',
      );
    });
    testWidgets('<Test send to all address types>', (tester) async {
      final stopwatch = Stopwatch()..start(); // Start timer

      await goBackHome(tester);
      await checkSync(tester);
      await disableAllNetworks(tester);

      final walletWithBalance = find.text("GH TEST ACC (#1)");
      expect(walletWithBalance, findsAny);
      await tester.tap(walletWithBalance);
      await tester.pump(Durations.long2);
      await tester.pump(Durations.long2);
      await tester.pump(Durations.long2);

      final sendButtonFinder = find.text("Send");
      expect(sendButtonFinder, findsWidgets);
      await tester.tap(sendButtonFinder.last);
      await tester.pump(Durations.long2);

      /// Check if you are entering sats
      await cycleToEnvoyIcon(tester, EnvoyIcons.sats);

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

      /// <Send to River all caps address> test:

      String testAddress = "BC1Q4ZE0W0A0MUVXS6NYYF6QE4JNF008KS8U0RH4KQ";

      /// Try to send
      await enterTextInField(tester, find.byType(TextFormField), testAddress);

      // go to staging
      await waitForTealTextAndTap(tester, 'Confirm');
      await tester.pump(Durations.long2);

      final textFeeFinder = find.text("Fee");
      await tester.pumpUntilFound(textFeeFinder,
          tries: 100, duration: Durations.long2);

      // Find all AmountWidgets
      final amountFinder = find.byType(AmountWidget);

      // Get the first one
      final firstAmountWidget = tester.widget<AmountWidget>(amountFinder.first);
      final firstAmountValue = firstAmountWidget.amountSats;

      // Check it’s not zero
      expect(firstAmountValue > 0, isTrue,
          reason: "First amount should not be zero, but got $firstAmountValue");

      await tester.pump(Durations.long2);

      await goBackHome(tester); // force test to Home

      stopwatch.stop();
      debugPrint(
        '⏱ Test took ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} s',
      );
    });
    testWidgets('<BTC/sats in App>', (tester) async {
      final stopwatch = Stopwatch()..start(); // Start timer

      await goBackHome(tester);
      await checkSync(tester);

      String someValidSignetReceiveAddress =
          'tb1puds2rgwgyq79xxg9es0f7cvvcqp8es75494zvucxyxrv6cl3sc3sdc9vql';

      /// Go to setting and enable fiat, we will need this later
      await pressHamburgerMenu(tester);
      await tapSettingsButton(tester);

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
        // turn it off
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

      /// This is not important anymore because of the new sendUnit (depending on the last Send selection)?
      /// Make sure the first proposed unit is BTC
      // function is checking icons from top to bottom so the first icon in Send needs to be BTC
      // await checkForEnvoyIcon(tester, EnvoyIcons.btc);

      /// Tap the BTC number in the send screen until you get to fiat (you might need to enable fiat from settings first)
      // circle to BTC
      await cycleToEnvoyIcon(tester, EnvoyIcons.btc);

      if (currentSettingsFiatCode != null) {
        await tester.pump(Durations.long2);
        await findTextOnScreen(tester, "\$");
      }

      ///  Check that the number below the fiat is displayed in BTC
      await checkForEnvoyIcon(tester, EnvoyIcons.btc);

      // switch to SATS for easy input
      await cycleToEnvoyIcon(tester, EnvoyIcons.sats);

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
      await cycleToEnvoyIcon(tester, EnvoyIcons.btc);

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
      await tapSettingsButton(tester);

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

      /// Make sure the first proposed unit is BTC (last selected in send was BTC)
      // function is checking icons from top to bottom so the first icon in Send needs to be BTC
      await checkForEnvoyIcon(tester, EnvoyIcons.btc);

      if (currentSettingsFiatCode != null) {
        await tester.pump(Durations.long2);
        await findTextOnScreen(tester, "\$");
      }

      ///  Check that the number below the fiat is displayed in btc
      await checkForEnvoyIcon(tester, EnvoyIcons.btc);

      /// With the unit in BTC, paste a valid address, enter a valid amount, tap continue
      await enterTextInField(
          tester, find.byType(TextFormField), someValidSignetReceiveAddress);

      // enter amount in SATS
      await cycleToEnvoyIcon(tester, EnvoyIcons.sats);

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

      stopwatch.stop();
      debugPrint(
        '⏱ Test took ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} s',
      );
    });
    testWidgets('<Enable testnet>', (tester) async {
      final stopwatch = Stopwatch()..start(); // Start timer

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

      await goBackHome(tester);

      stopwatch.stop();
      debugPrint(
        '⏱ Test took ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} s',
      );
    });
    testWidgets('<Enable taproot>', (tester) async {
      final stopwatch = Stopwatch()..start(); // Start timer

      await goBackHome(tester);

      await pressHamburgerMenu(tester);
      await tapSettingsButton(tester);
      await openAdvancedMenu(tester);
      bool taprootAlreadyEnabled =
          await isSlideSwitchOn(tester, "Receive to Taproot");
      if (taprootAlreadyEnabled) {
        // Disable it
        await findAndToggleSettingsSwitch(tester, "Receive to Taproot");
        await tester.pump(Durations.extralong4);
        await tester.pump();
        await findAndPressTextButton(tester, "Confirm");
        await tester.pump(Durations.extralong4);
        await tester.pump();
      }
      await findAndToggleSettingsSwitch(
          tester, "Receive to Taproot"); //enable it
      await tester.pump(Durations.extralong4);
      await tester.pump();

      final confirmTextFromDialog = find.text('Confirm');
      await tester.pump(Durations.extralong4);
      await tester.pump();
      // Check that a pop up comes up
      await tester.pumpUntilFound(confirmTextFromDialog,
          duration: Durations.extralong4);
      await tester.pump();
      await tester.tap(confirmTextFromDialog);
      await tester.pump(Durations.extralong4);
      await tester.pump();
      // Check that a pop up closed
      expect(confirmTextFromDialog, findsNothing);

      /// Tap Do it later
      await findAndPressTextButton(tester, "Do It Later");
      await tester.pump(Durations.extralong4);
      await tester.pump();

      await pressHamburgerMenu(tester); // back to settings menu
      await pressHamburgerMenu(tester); // back to home

      await findFirstTextButtonAndPress(tester, "GH TEST ACC (#1)");
      await findAndPressTextButton(tester, "Receive");
      await tester.pump(Durations.extralong4);
      await tester.pump(Durations.extralong4);
      await tester.pump();

      // refresh Receive scren
      await findAndPressTextButton(tester, "OK");
      await findAndPressTextButton(tester, "Receive");
      await pressHamburgerMenu(tester);
      await pressHamburgerMenu(tester);
      await tester.pump(Durations.long1);
      await tester.pump();
      //

      // pump until address change on screen
      final taprootFinder = find.text('bc1p');
      await tester.pumpUntilFound(taprootFinder,
          duration: Durations.long1, tries: 50);

      // copy Taproot address
      final address1 = await getAddressFromReceiveScreen(tester);
      await tester.pump(Durations.extralong4);
      await tester.pump();
      expect(address1.startsWith('bc1p'), isTrue,
          reason:
              'The first address should be a Taproot address starting with bc1p');

      // back to home
      await goBackHome(tester);
      // settings
      await pressHamburgerMenu(tester);
      await tapSettingsButton(tester);
      await openAdvancedMenu(tester);
      await findAndToggleSettingsSwitch(
          tester, "Receive to Taproot"); // Disable
      await findFirstTextButtonAndPress(tester, "Confirm");

      await pressHamburgerMenu(tester); // back to settings menu
      await pressHamburgerMenu(tester); // back to home

      await findFirstTextButtonAndPress(tester, "GH TEST ACC (#1)");

      await findAndPressTextButton(tester, "Receive");

      // refresh Receive scren
      await findAndPressTextButton(tester, "OK");
      await findAndPressTextButton(tester, "Receive");
      await pressHamburgerMenu(tester);
      await pressHamburgerMenu(tester);
      await tester.pump(Durations.long1);
      await tester.pump();
      //

      // pump until address change on screen
      final nonTaprootFinder = find.text('bc1q');
      await tester.pumpUntilFound(nonTaprootFinder,
          duration: Durations.long1, tries: 50);

      // Grab the second address
      final address2 = await getAddressFromReceiveScreen(tester);
      await tester.pump(Durations.extralong4);
      await tester.pump();
      expect(address2.startsWith('bc1q'), isTrue,
          reason:
              'The second address should be a non-Taproot address starting with bc1q, the second address: $address2');

      // back to Home
      await goBackHome(tester);
      // settings
      await pressHamburgerMenu(tester);
      await tapSettingsButton(tester);
      await openAdvancedMenu(tester);
      await findAndToggleSettingsSwitch(
          tester, "Receive to Taproot"); // Enable again

      await goBackHome(tester);

      stopwatch.stop();
      debugPrint(
        '⏱ Test took ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} s',
      );
    });
    testWidgets('<Select coin, cancel selection, check buttons>',
        (tester) async {
      final stopwatch = Stopwatch()..start(); // Start timer

      await goBackHome(tester);
      await checkSync(tester);

      // go to acc
      await findFirstTextButtonAndPress(tester, "GH TEST ACC (#1)");

      // go to tags
      await findAndTapActivitySlideButton(tester);

      final Finder lastSwitchFinder = find.byType(CoinTagSwitch).last;
      await tester.tap(lastSwitchFinder);

      await findAndTapPopUpIcon(tester, Icons.close);

      await findAndTapPopUpText(tester, "No");

      // make sure the snack is still open
      await findTextOnScreen(tester, "Selected Amount");

      await findAndPressIcon(tester, Icons.close);

      await findAndTapPopUpText(tester, "Yes");

      // make sure the snack bar closes and you can see Receive button
      await findTextOnScreen(tester, "Receive");

      stopwatch.stop();
      debugPrint(
        '⏱ Test took ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} s',
      );
    });
    testWidgets('<Tags>', (tester) async {
      final stopwatch = Stopwatch()..start(); // Start timer

      await goBackHome(tester);
      await checkSync(tester);

      // go to acc
      await findFirstTextButtonAndPress(tester, "GH TEST ACC (#1)");

      // go to tags
      await findAndTapActivitySlideButton(tester);

      /// 1) Select a coin from Untagged
      final Finder lastSwitchFinder = find.byType(CoinTagSwitch).last;
      await tester.tap(lastSwitchFinder);

      /// 2) Tap Tag selected
      await findAndPressTextButton(tester, "Tag Selected");

      /// 3) Tap "back" in the pop up
      await findAndPressTextButton(tester, "Back");

      await tester.tap(lastSwitchFinder);
      await tester.pump(Durations.long2);

      /// 4) Repeat steps 1 and 2
      await findAndPressTextButton(tester, "Tag Selected");

      /// 5) Tap Continue
      await findAndPressTextButton(tester, "Continue");

      /// 6) Tap any of the suggested tags
      await findAndPressTextButton(tester, "Expenses");

      /// 7) Tap Continue
      await findAndPressTextButton(tester, "Continue");

      /// 8) Check that the pop up closes and the coin is tagged (to avoid ENV-2434)
      // 1) Verify "Expenses" tag is visible
      await findTextOnScreen(tester, "Expenses");
      await tester.pump(Durations.long2);

      // 2) Verify "Selected Amount" is NOT on screen
      expect(find.text("Selected Amount"), findsNothing);

      // 3) Verify "Choose a Tag" is NOT on screen
      expect(find.text("Choose a Tag"), findsNothing);

      /// 9) Open the tag created
      await findAndPressTextButton(tester, "Expenses");

      /// 10) Select the coin form the tag
      await tester.tap(lastSwitchFinder);

      /// 10) Tap Retag selected
      await findAndPressTextButton(tester, "Retag Selected");

      /// 11) Tap Back in the pop up
      await findAndPressTextButton(tester, "Back");

      /// 12) Repeat steps 10 and 11
      await tester.tap(lastSwitchFinder);
      await findAndPressTextButton(tester, "Retag Selected");

      /// 13) Tap Continue in the pop up

      await findAndPressTextButton(tester, "Continue");

      /// 14) Check the bottom tray disappears (to avoid ENV-2431)
      await tester.pump(Durations.long2);
      // make sure that the snack bar is closed
      expect(find.text("Selected Amount"), findsNothing);

      /// 14) Write anything in the Choose a tag field
      await enterTextInField(tester, find.byType(TextFormField), "Whatever");

      /// 15) Tap Continue
      await findAndPressTextButton(tester, "Continue");

      await pressHamburgerMenu(tester);

      /// 16) Check the pop up closes and the coin has been tagged to the tag written in step 14
      await tester.pump(Durations.long2);
      // 1) Verify "Whatever" tag is visible
      await findTextOnScreen(tester, "Whatever");

      // 2) Verify "Selected Amount" is NOT on screen
      expect(find.text("Selected Amount"), findsNothing);

      // 3) Verify "Choose a Tag" is NOT on screen
      expect(find.text("Choose a Tag"), findsNothing);

      /// 17) Open the tag written in step 14
      await findAndPressTextButton(tester, "Whatever");

      await pumpRepeatedly(tester);

      /// 18) Tap the three dots on the top right corner
      await openDotsMenu(tester);

      await tester.pump(Durations.long2);

      /// 19) Tap Delete tag
      await findAndPressTextButton(tester, "DELETE TAG");

      /// 20) Tap Back
      await findAndPressTextButton(tester, "Back");

      /// 21) repeat steps 18 and 19
      await findAndPressTextButton(tester, "DELETE TAG");

      /// 22) Tap Delete tag
      await findAndPressTextButton(tester, "Delete Tag");

      /// 23) Check the tag disappears and the coin  is moved back to Untagged
      expect(
          find.text("Whatever"), findsNothing); // make sure the Tag is deleted
      await findTextOnScreen(tester, "Untagged");

      await goBackHome(tester); // force test to Home

      stopwatch.stop();
      debugPrint(
        '⏱ Test took ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} s',
      );
    });
    testWidgets('<Taproot address test>', (tester) async {
      final stopwatch = Stopwatch()..start(); // Start timer

      await goBackHome(tester);

      await pressHamburgerMenu(tester);
      await tapSettingsButton(tester);
      await openAdvancedMenu(tester);
      bool taprootAlreadyEnabled =
          await isSlideSwitchOn(tester, "Receive to Taproot");
      if (taprootAlreadyEnabled) {
        // Disable it
        await findAndToggleSettingsSwitch(tester, "Receive to Taproot");
      }

      await pressHamburgerMenu(tester); // back to settings menu
      await pressHamburgerMenu(tester); // back to home
      await findFirstTextButtonAndPress(tester, "GH TEST ACC (#1)");
      await findAndPressTextButton(tester, "Receive");

      await findTextOnScreen(tester, "bc1q");

      // back to account
      //await pressHamburgerMenu(tester);

      // open menu
      await findAndPressIcon(tester, Icons.more_horiz_outlined);

      await findAndPressTextButton(tester, "SHOW DESCRIPTOR");

      await findTextOnScreen(tester, "Segwit");

      // back to home
      //await pressHamburgerMenu(tester);
      //await pressHamburgerMenu(tester);
      // settings
      await pressHamburgerMenu(tester);
      await tapSettingsButton(tester);
      await openAdvancedMenu(tester);
      await findAndToggleSettingsSwitch(tester, "Receive to Taproot"); // Enable
      await findFirstTextButtonAndPress(tester, "Confirm");

      await pressHamburgerMenu(tester); // back to settings menu
      await pressHamburgerMenu(tester); // back to home

      await findLastTextButtonAndPress(tester, "Accounts");

      /// this way because nav is broken in tests

      await findFirstTextButtonAndPress(tester, "GH TEST ACC (#1)");
      await findAndPressTextButton(tester, "Receive");

      await findTextOnScreen(tester, "bc1p");

      // back to account
      //await pressHamburgerMenu(tester);

      // open menu
      await findAndPressIcon(tester, Icons.more_horiz_outlined);

      await findAndPressTextButton(tester, "SHOW DESCRIPTOR");

      await findTextOnScreen(tester, "Taproot");

      await goBackHome(tester); // force test to Home

      stopwatch.stop();
      debugPrint(
        '⏱ Test took ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} s',
      );
    });
    testWidgets('<Check Signet in App>', (tester) async {
      final stopwatch = Stopwatch()..start(); // Start timer

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

      stopwatch.stop();
      debugPrint(
        '⏱ Test took ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} s',
      );
    });
    testWidgets('<Node selection>', (tester) async {
      final stopwatch = Stopwatch()..start(); // Start timer

      final personalNode = "ssl://mainnet-0.foundation.xyz:50002";

      await goBackHome(tester);

      // Go to privacy
      await findAndPressTextButton(tester, 'Privacy');
      // Tap Foundation (default) to open dropdown
      await findAndPressTextButton(tester, 'Foundation (Default)');
      // Select Personal Node
      await findAndPressTextButton(tester, 'Personal Node');

      // Check that it gets selected and the field to enter the personal node shows up
      await findTextOnScreen(tester, "Personal Node");
      await findTextOnScreen(tester, "Enter your node address");

      // paste node
      await enterTextInField(tester, find.byType(TextFormField), personalNode);

      // check if it connects
      final textConnectFinder = find.text("Connected");
      await tester.pumpUntilFound(textConnectFinder,
          tries: 50, duration: Durations.long2);

      //Tap Personal Node to open dropdown
      await findAndPressTextButton(tester, 'Personal Node');
      await tester.pump(Durations.long2);

      // Select Blockstream
      await findAndPressTextButton(tester, 'Blockstream');
      await tester.pump(Durations.long2);

      // Check that it gets selected and a connection is attempted
      await findTextOnScreen(tester, "Blockstream");
      await tester.pump(Durations.long2);

      //Tap Block Stream to open dropdown
      await findAndPressTextButton(tester, 'Blockstream');
      await tester.pump(Durations.long2);

      // Change back to Personal Node, and check the pasted node was
      // NOT overwritten, and it connects to that one

      // Check if a connection is attempted over Personal node
      await findAndPressTextButton(tester, 'Personal Node');
      await tester.pumpUntilFound(
        find.byType(CircularProgressIndicator),
        tries: 20,
        duration: Durations.long1,
      );

      // check if it connects
      await tester.pumpUntilFound(textConnectFinder,
          tries: 50, duration: Durations.long2);

      // Grab the text currently inside the TextFormField
      final textField =
          tester.widget<TextFormField>(find.byType(TextFormField));
      final currentController = textField.controller;
      expect(currentController, isNotNull,
          reason: "TextFormField should have a controller");

      final currentNode = currentController!.text;

      // Compare with the originally entered node
      expect(currentNode, equals(personalNode),
          reason:
              "The Personal Node value should persist after switching back");

      // change back to Foundation default
      await findAndPressTextButton(tester, 'Personal Node');
      await tester.pump(Durations.long2);

      await findAndPressTextButton(tester, 'Foundation (Default)');
      await tester.pump(Durations.long2);

      await goBackHome(tester); // force test to home

      stopwatch.stop();
      debugPrint(
        '⏱ Test took ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} s',
      );
    });
    testWidgets('<Check prefix & suffixes for nodes>', (tester) async {
      final stopwatch = Stopwatch()..start(); // Start timer

      await goBackHome(tester);

      final personalNodeNoPrefix1 = "mainnet-0.foundation.xyz:50001";
      final personalNodeNoPrefix2 = "mainnet-0.foundation.xyz:50002";
      final localNode1 = "192.168.xxx.xxx:50001";
      final localNode2 = "192.168.xxx.xxx:50002";

      // Go to privacy
      await findAndPressTextButton(tester, 'Privacy');
      // Tap Foundation (default) to open dropdown
      await findAndPressTextButton(tester, 'Foundation (Default)');
      // Select Personal Node
      await findAndPressTextButton(tester, 'Personal Node');

      // Check that it gets selected and the field to enter the personal node shows up
      await findTextOnScreen(tester, "Personal Node");
      await findTextOnScreen(tester, "Enter your node address");

      /// check for 50002

      await testNodeEntry(tester,
          node: personalNodeNoPrefix2, expectedPrefix: 'ssl://');
      await testNodeEntry(tester,
          node: localNode2, expectedPrefix: 'ssl://', checkIfConnects: false);

      /// check for 50001
      await testNodeEntry(tester,
          node: personalNodeNoPrefix1, expectedPrefix: 'tcp://');
      await testNodeEntry(tester,
          node: localNode1, expectedPrefix: 'tcp://', checkIfConnects: false);

      /// Now do all the tests again if there is a :t / :s at the end ///////////////////

      final personalNodeNoPrefix1T = "mainnet-0.foundation.xyz:50001:t";
      final personalNodeNoPrefix2T = "mainnet-0.foundation.xyz:50002:s";
      final localNode1T = "192.168.xxx.xxx:50001:t";
      final localNode2T = "192.168.xxx.xxx:50002:s";

      /// check for 50002:t
      // paste node
      await testNodeEntry(tester,
          node: personalNodeNoPrefix2T, expectedPrefix: 'ssl://');

      await testNodeEntry(tester,
          node: localNode2T, expectedPrefix: 'ssl://', checkIfConnects: false);

      /// check for 50001:t

      await testNodeEntry(tester,
          node: personalNodeNoPrefix1T, expectedPrefix: 'tcp://');
      await testNodeEntry(tester,
          node: localNode1T, expectedPrefix: 'tcp://', checkIfConnects: false);

      /// Change back to Foundation deault
      // Press dropdown - Personal Node
      await findAndPressTextButton(tester, 'Personal Node');
      // Tap Foundation (default)
      await findAndPressTextButton(tester, 'Foundation (Default)');

      stopwatch.stop();
      debugPrint(
        '⏱ Test took ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} s',
      );
    });
    testWidgets('<Enable tor and check top shield>', (tester) async {
      final stopwatch = Stopwatch()..start(); // Start timer

      await goBackHome(tester);

      await findAndPressTextButton(tester, 'Privacy');

      // enable "better performance" if it is not enabled
      await enablePerformance(tester);

      // Perform the required actions to change to privacy
      await enablePrivacy(tester);
      // Check the shield icon after enabling privacy

      await checkTorShieldIcon(tester, expectPrivacy: true);

      // turn off Tor for next test
      await enablePerformance(tester);

      stopwatch.stop();
      debugPrint(
        '⏱ Test took ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} s',
      );
    });
    testWidgets('<Fee % test>', (tester) async {
      final stopwatch = Stopwatch()..start(); // Start timer

      await goBackHome(tester);

      await disableAllNetworks(tester);

      const hotSignetSendAddress =
          'tb1puds2rgwgyq79xxg9es0f7cvvcqp8es75494zvucxyxrv6cl3sc3sdc9vql'; // send coins to this address from base wallet

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
        final closeDialogButton = find.byIcon(Icons.close);
        await tester.tap(closeDialogButton.last, warnIfMissed: false);
        await tester.pump(Durations.long2);
      }

      // go back to accounts
      await pressHamburgerMenu(tester);
      await pressHamburgerMenu(tester);

      await checkSync(tester, waitAccSync: "Signet");
      await tester.pump(Durations.long2);

      final baseWalletFinder = find.text("Signet");
      expect(baseWalletFinder, findsWidgets);
      await tester.tap(baseWalletFinder.first);
      await tester.pump(Durations.long2);

      final sendButtonFinder = find.text("Send");
      expect(sendButtonFinder, findsWidgets);
      await tester.tap(sendButtonFinder.last);
      await tester.pump(Durations.long2);

      await enterTextInField(
          tester, find.byType(TextFormField), hotSignetSendAddress);

      await cycleToEnvoyIcon(tester, EnvoyIcons.sats);

      // enter amount
      await findAndPressTextButton(tester, '5');
      await findAndPressTextButton(tester, '6');
      await findAndPressTextButton(tester, '7');
      await findAndPressTextButton(tester, '8');

      // go to staging
      await waitForTealTextAndTap(tester, 'Confirm');
      await tester.pump(Durations.long2);

      // now wait for it to go to staging
      final textFeeFinder = find.text("Fee");
      await tester.pumpUntilFound(textFeeFinder,
          tries: 100, duration: Durations.long2);

      // scroll to see if /!\ alert icon is NOT present
      await scrollHome(tester, -300,
          scrollableWidgetType: SingleChildScrollView);

      await checkForEnvoyIconNotFound(tester, EnvoyIcons.alert);

      // change fee
      await findAndPressTextButton(tester, 'Custom');
      await tester.pump(Durations.long2);

      await scrollStagingFeeWheel(tester);

      await findAndPressTextButton(tester, 'Confirm Fee');
      await tester.pump(Durations.long2);
      await tester.pump(Durations.long2);
      await tester.pump(Durations.long2);

      // scroll to see if /!\ alert icon IS present
      await scrollHome(tester, -600,
          scrollableWidgetType: SingleChildScrollView);

      await checkForEnvoyIcon(tester, EnvoyIcons.alert);

      /// Check the amount
      // 1. Find the Text widget
      final textFinder =
          find.textContaining(RegExp(r'Fee is .*% of total amount'));

      expect(textFinder, findsOneWidget); // Ensure it's found

      // 2. Extract the text
      final Text textWidget = tester.widget(textFinder);
      final String fullText = textWidget.data ?? '';

      // 3. Extract the number using RegExp
      final match = RegExp(r'Fee is ([\d.]+)%').firstMatch(fullText);
      expect(match, isNotNull);

      final String percentageString = match!.group(1)!;
      final double feePercentage = double.parse(percentageString);

      // Find all EnvoyAmount widgets
      final envoyAmountFinder = find.byType(EnvoyAmount);
      // Get all EnvoyAmount widgets in order
      final envoyAmountWidgets =
          tester.widgetList<EnvoyAmount>(envoyAmountFinder).toList();

      // Extract amount, fee, and total
      final fee = envoyAmountWidgets[1].amountSats;
      final total = envoyAmountWidgets[2].amountSats;

      // 4. Assert on the extracted value
      final expectedFeePercentage =
          ((fee.toInt() / (total.toInt())) * 100).round();

      expect(feePercentage, equals(expectedFeePercentage));

      await goBackHome(tester); // force test to Home

      stopwatch.stop();
      debugPrint(
        '⏱ Test took ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} s',
      );
    });
    testWidgets('<Receiving txs - check Boost and Cancel>', (tester) async {
      final stopwatch = Stopwatch()..start(); // Start timer

      await goBackHome(tester);

      await disableAllNetworks(tester);

      //const testnetReceiveAddress =
      //    'tb1puds2rgwgyq79xxg9es0f7cvvcqp8es75494zvucxyxrv6cl3sc3sdc9vql';
      // TODO: fill this wallet if there is no money from here https://coinfaucet.eu/en/btc-testnet4/
      // TODO: when getting more coins you need to wait for the transaction confirmation before running the tests!!!

      const testnetSendAddress =
          'tb1puds2rgwgyq79xxg9es0f7cvvcqp8es75494zvucxyxrv6cl3sc3sdc9vql'; // send coins to this address from base wallet

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

      await goBackHome(tester); // force test to Home

      stopwatch.stop();
      debugPrint(
        '⏱ Test took ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} s',
      );
    });
    testWidgets('<Save note from popup>', (tester) async {
      await goBackHome(tester);
      await checkSync(tester);

      await disableAllNetworks(tester);

      const hotSignetSelfAddress =
          'tb1puds2rgwgyq79xxg9es0f7cvvcqp8es75494zvucxyxrv6cl3sc3sdc9vql';

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
        await findAndToggleSettingsSwitch(tester, 'Signet');
        final closeDialogButton = find.byIcon(Icons.close);
        await tester.tap(closeDialogButton.last);
        await tester.pump(Durations.long2);
      }

      if (!isSettingsTaprootSwitchOn) {
        // find And Toggle Taproot Switch
        await findAndToggleSettingsSwitch(tester, 'Receive to Taproot');
        final closeDialogButton = find.byIcon(Icons.close);
        await tester.tap(closeDialogButton.last, warnIfMissed: false);
        await tester.pump(Durations.long2);
      }

      // go back to accounts
      await pressHamburgerMenu(tester);
      await pressHamburgerMenu(tester);

      await checkSync(tester, waitAccSync: "Signet");
      await tester.pump(Durations.long2);

      final baseWalletFinder = find.text("Signet");
      expect(baseWalletFinder, findsWidgets);
      await tester.tap(baseWalletFinder.first);
      await tester.pump(Durations.long2);

      final sendButtonFinder = find.text("Send");
      expect(sendButtonFinder, findsWidgets);
      await tester.tap(sendButtonFinder.last);
      await tester.pump(Durations.long2);

      /// SEND some money to hot signet wallet
      await enterTextInField(
          tester, find.byType(TextFormField), hotSignetSelfAddress);

      await cycleToEnvoyIcon(tester, EnvoyIcons.sats);

      // enter amount
      await findAndPressTextButton(tester, '5');
      await findAndPressTextButton(tester, '6');
      await findAndPressTextButton(tester, '7');

      // go to staging
      await waitForTealTextAndTap(tester, 'Confirm');
      await tester.pump(Durations.long2);

      // now wait for it to go to staging
      final textFeeFinder = find.text("Fee");
      await tester.pumpUntilFound(textFeeFinder,
          tries: 100, duration: Durations.long2);

      await findAndPressTextButton(tester, 'Send Transaction');

      await enterTextInField(tester, find.byType(TextFormField), "This Note");

      await findAndPressTextButton(tester, 'Save');
      await tester.pump(Durations.long2);
      await pumpRepeatedly(tester);

      await slowSearchAndToggleText(tester, 'Continue');
      await tester.pump(Durations.long2);
      await tester.pump(Durations.long2);

      final textTxFinder = find.text("Awaiting confirmation");
      await tester.pumpUntilFound(textTxFinder,
          tries: 100, duration: Durations.long2);
      await tester.pump(Durations.long2);

      await findFirstTextButtonAndPress(tester, 'Sent');
      await tester.pump(Durations.long2);

      final textNoteFinder = find.text("This Note");
      await tester.pumpUntilFound(textNoteFinder,
          tries: 100, duration: Durations.long2);

      await goBackHome(tester); // force test to Home
    });
    testWidgets('<Switching Fiat in App>', (tester) async {
      final stopwatch = Stopwatch()..start(); // Start timer

      await goBackHome(tester);
      const String accountPassportName = "GH TEST ACC (#1)";

      /// Open Envoy settings, enable fiat
      await findAndPressTextButton(tester, 'Privacy');
      // enable "better performance" if it is not enabled
      await enablePerformance(tester);

      await findAndPressTextButton(tester, 'Accounts');

      // go to settings
      await pressHamburgerMenu(tester);
      await tapSettingsButton(tester);

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
      await tapSettingsButton(tester);

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
      await checkTorShieldIcon(tester, expectPrivacy: true);

      /// Open Envoy settings, enable fiat
      await pressHamburgerMenu(tester);
      await tapSettingsButton(tester);

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
      await tapSettingsButton(tester);

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

      /// turn off the tor for the next test
      await findAndPressTextButton(tester, 'Privacy');
      await enablePerformance(tester);

      stopwatch.stop();
      debugPrint(
        '⏱ Test took ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} s',
      );
    });
    testWidgets('<Boost screen>', (tester) async {
      final stopwatch = Stopwatch()..start(); // Start timer

      final coinLockKey = GlobalKey<CoinLockButtonState>();

      await goBackHome(tester);

      await disableAllNetworks(tester);

      //const hotSignetReceiveAddress =
      //    'tb1puds2rgwgyq79xxg9es0f7cvvcqp8es75494zvucxyxrv6cl3sc3sdc9vql';
      // TODO: fill this wallet if there is no money from here https://signet257.bublina.eu.org/
      // TODO: when getting more coins you need to wait for the transaction confirmation before running the tests!!!

      const hotSignetSendAddress =
          'tb1puds2rgwgyq79xxg9es0f7cvvcqp8es75494zvucxyxrv6cl3sc3sdc9vql'; // send coins to this address from base wallet

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

        // 🕒 Wait for the Rive animation/state to reflect locked status
        await tester.pumpUntilCondition(
          tries: 100,
          duration: const Duration(milliseconds: 200),
          condition: () {
            final isLocked = coinLockKey.currentState?.isLocked ?? false;
            return isLocked == true; // ✅ Stop when actually locked
          },
        );
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

        // 🕒 Wait for the Rive animation/state to reflect locked status
        await tester.pumpUntilCondition(
          tries: 100,
          duration: const Duration(milliseconds: 200),
          condition: () {
            final isLocked = coinLockKey.currentState?.isLocked ?? false;
            return isLocked == true; // ✅ Stop when actually locked
          },
        );
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

        // Wait for the lock animation/state to finish unlocking
        await tester.pumpUntilCondition(
          tries: 100,
          duration: const Duration(milliseconds: 200),
          condition: () {
            // Re-check the Rive widget state dynamically each try
            final isLocked = coinLockKey.currentState?.isLocked ?? true;
            return isLocked == false; // stop when unlocked
          },
        );
      }

      // go home, fix to refresh home page
      await tester.pump(Durations.long2);
      await findAndPressTextButton(tester, "Accounts");

      stopwatch.stop();
      debugPrint(
        '⏱ Test took ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} s',
      );
    });
    testWidgets('<Account delete icon>', (tester) async {
      final stopwatch = Stopwatch()..start(); // Start timer

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

      stopwatch.stop();
      debugPrint(
        '⏱ Test took ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} s',
      );
    });
    testWidgets('<Delete device>', (tester) async {
      final stopwatch = Stopwatch()..start(); // Start timer

      await goBackHome(tester);
      String deviceName = "Passport";

      final devicesButton = find.text('Devices');
      await tester.tap(devicesButton);
      await tester.pump(Durations.long2);
      await tester.pump(Durations.long2);
      await tester.pump(Durations.long2);

      // get the first device with matching name
      final deviceFinder = find.text(deviceName).last;
      expect(deviceFinder, findsOneWidget);
      await tester.tap(deviceFinder);
      await tester.pump(Durations.long2);

      await openMenuAndPressDeleteDevice(tester);

      final popUpText = find.text('Are you sure');
      // Check that a pop up comes up
      await findAndTapPopUpText(tester, "Cancel");
      await tester.pump(Durations.long2);
      await tester.pump(Durations.long2);

      // Check that a pop up close on 'Cancel'
      expect(popUpText, findsNothing);

      await openMenuAndPressDeleteDevice(tester);
      await tester.pumpUntilFound(popUpText, duration: Durations.long1);

      await findAndTapPopUpText(tester, 'Disconnect');
      await tester.pump(Durations.long2);
      await tester.pump(Durations.long2);

      // check that only one passport remains
      final remainingDevices = find.text(deviceName);
      expect(remainingDevices,
          findsNWidgets(1)); // second device have 2 "Passport" texts inside

      // Verify that deleting the device also removes its associated accounts
      await findAndPressTextButton(tester, 'Accounts');
      await tester.pump(Durations.long2);
      await scrollHome(tester, -600);
      final deletedAccount = find.text('Taproot modal test');
      expect(deletedAccount, findsNothing);
      await goBackHome(tester);

      stopwatch.stop();
      debugPrint(
        '⏱ Test took ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} s',
      );
    });
    testWidgets('<Logs freeze>', (tester) async {
      final stopwatch = Stopwatch()..start(); // Start timer

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

      stopwatch.stop();
      debugPrint(
        '⏱ Test took ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} s',
      );
    });
  });

  // Stop the timer and print the elapsed time
  stopwatch.stop();
  debugPrint(
    '⏱ Beefqa tests took ${(stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} s',
  );
}
