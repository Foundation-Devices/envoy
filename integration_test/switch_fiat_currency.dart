// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/main.dart';
import 'package:envoy/ui/components/amount_widget.dart';
import 'package:envoy/ui/home/cards/accounts/account_list_tile.dart';
import 'package:envoy/ui/loader_ghost.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screenshot/screenshot.dart';
import 'btc_sats.dart';
import 'check_fiat_in_app.dart';
import 'connect_passport_via_recovery.dart';
import 'enable_tor.dart';

void main() {
  testWidgets('Switching Fiat in App', (tester) async {
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

      //await setUpWalletFromSeedViaMagicRecover(tester, seed);

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
    } finally {
      // Restore the original FlutterError.onError handler after the test.
      FlutterError.onError = originalOnError;
    }
  });
}

Future<String> extractFiatAmountFromAccount(
    WidgetTester tester, String accountText) async {
  await tester.pumpAndSettle(); // Ensure the widget tree is settled

  // Find the AccountListTile containing the specified accountText
  final accountListTileFinder =
      find.widgetWithText(AccountListTile, accountText);
  expect(accountListTileFinder.first, findsOneWidget);

  // Find the SecondaryAmountWidget within the AccountListTile
  final secondaryAmountWidgetFinder = find.descendant(
    of: accountListTileFinder.first,
    matching: find.byType(SecondaryAmountWidget),
  );
  expect(secondaryAmountWidgetFinder, findsOneWidget);

  // Extract the text from the RichText within the SecondaryAmountWidget
  final richTextFinder = find.descendant(
    of: secondaryAmountWidgetFinder,
    matching: find.byType(RichText),
  );

  // Ensure that there is a RichText present in the SecondaryAmountWidget
  expect(richTextFinder, findsWidgets);

  // Iterate through the found RichText widgets to locate the amount text
  final richTextWidgets = richTextFinder.evaluate();
  for (final widget in richTextWidgets) {
    final richTextWidget = widget.widget as RichText;
    final textSpan = richTextWidget.text as TextSpan;

    // Extract and return the text from the TextSpan
    String extractedText = extractTextFromTextSpan(textSpan);
    if (extractedText.isNotEmpty) {
      // Filter out non-numeric characters, keeping only digits, decimal points, and commas
      String filteredText = extractedText.replaceAll(RegExp(r'[^\d.,]'), '');
      if (filteredText.isNotEmpty) {
        return filteredText;
      }
    }
  }

  throw Exception('Amount text not found in the specified AccountListTile');
}

String extractTextFromTextSpan(TextSpan textSpan) {
  StringBuffer buffer = StringBuffer();

  void extractText(TextSpan span) {
    if (span.text != null) {
      buffer.write(span.text);
    }
    if (span.children != null) {
      for (InlineSpan child in span.children!) {
        if (child is TextSpan) {
          extractText(child);
        }
      }
    }
  }

  extractText(textSpan);
  return buffer.toString();
}

Future<void> checkAndWaitLoaderGhostInAccount(
    WidgetTester tester, String accountText) async {
  await tester.pumpAndSettle(); // Ensure the widget tree is settled

  // Find the AccountListTile containing the specified accountText
  final accountListTileFinder =
      find.widgetWithText(AccountListTile, accountText);
  expect(accountListTileFinder.first, findsOneWidget);

  while (true) {
    // Find the LoaderGhost within the AccountListTile
    final loaderGhostFinder = find.descendant(
      of: accountListTileFinder,
      matching: find.byType(LoaderGhost),
    );

    // If the LoaderGhost is not found, exit the function
    if (loaderGhostFinder.evaluate().isEmpty) {
      return; // No LoaderGhost found, exit the function
    }

    // Wait for the specified duration before checking again
    await tester.pump(const Duration(seconds: 2));
  }
}

Future<bool> findTextOnScreen(WidgetTester tester, String buttonText) async {
  await tester.pump(Durations.long2);
  final textButton = find.text(buttonText);

  // Check if the text is found and return true or false accordingly
  return textButton.evaluate().isNotEmpty;
}
