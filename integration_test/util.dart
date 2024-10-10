// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';
import 'package:envoy/business/connectivity_manager.dart';
import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/main.dart';
import 'package:envoy/ui/components/amount_widget.dart';
import 'package:envoy/ui/components/big_tab.dart';
import 'package:envoy/ui/components/select_dropdown.dart';
import 'package:envoy/ui/home/cards/accounts/account_list_tile.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coin_balance_widget.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coins_switch.dart';
import 'package:envoy/ui/home/settings/setting_toggle.dart';
import 'package:envoy/ui/home/top_bar_home.dart';
import 'package:envoy/ui/loader_ghost.dart';
import 'package:envoy/ui/onboard/manual/widgets/mnemonic_grid_widget.dart';
import 'package:envoy/ui/routes/routes.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

Future<void> goBackHome(WidgetTester tester) async {
  mainRouter.go('/account');
  await tester.pumpWidget(const EnvoyApp());
}

Future<void> fromHomeToBuyOptions(WidgetTester tester) async {
  await tester.pump();
  final buyBitcoinButton = find.text('Buy');
  expect(buyBitcoinButton, findsOneWidget);

  await tester.tap(buyBitcoinButton);
  await tester.pump(Durations.long2);

  final selectRegionDropDown = find.text('Select State');
  await tester.pumpUntilFound(selectRegionDropDown,
      tries: 50, duration: Durations.long2);
  expect(selectRegionDropDown, findsOneWidget);
  await tester.tap(selectRegionDropDown);
  await tester.pump(Durations.long2);

  final dropdownItems = find.byType(DropdownMenuItem<EnvoyDropdownOption>);
  await tester.tap(dropdownItems.at(1)); // Tap at first state
  await tester.pump(Durations.long2);

  final continueButtonFinder = find.text('Continue');
  expect(continueButtonFinder, findsOneWidget);
  await tester.tap(continueButtonFinder);
  await tester.pump(Durations.long2);
  await tester.pump(Durations.long2);
}

Future<void> setUpAppFromStart(WidgetTester tester) async {
  await tester.pump();

  final setUpButtonFinder = find.text('Set Up Envoy Wallet');
  expect(setUpButtonFinder, findsOneWidget);
  await tester.tap(setUpButtonFinder);
  await tester.pump(const Duration(milliseconds: 500));

  final continueButtonFinder = find.text('Continue');
  expect(continueButtonFinder, findsOneWidget);
  await tester.tap(continueButtonFinder);
  await tester.pump(const Duration(milliseconds: 500));

  final enableMagicButtonFinder = find.text('Enable Magic Backups');
  expect(enableMagicButtonFinder, findsOneWidget);
  await tester.tap(enableMagicButtonFinder);
  await tester.pump(const Duration(milliseconds: 500));

  // video
  final createMagicButtonFinder = find.text('Create Magic Backup');
  expect(createMagicButtonFinder, findsOneWidget);
  await tester.tap(createMagicButtonFinder);
  await tester.pump(const Duration(milliseconds: 1500));

  await tester.pumpAndSettle();

  // animations
  expect(continueButtonFinder, findsOneWidget);
  await tester.tap(continueButtonFinder);
  await tester.pump(const Duration(milliseconds: 500));

  expect(continueButtonFinder, findsOneWidget);
  await tester.tap(continueButtonFinder);
  await tester.pump(const Duration(milliseconds: 500));
}

Future<void> resetEnvoyData() async {
  final appSupportDir = await getApplicationSupportDirectory();

  // Database
  const String dbName = 'envoy.db';
  final appDocumentDir = await getApplicationDocumentsDirectory();
  final dbFile = File(join(appDocumentDir.path, dbName));

  try {
    // Delete app data directory
    await appSupportDir.delete(recursive: true);
    // Delete the database file
    await dbFile.delete();
  } catch (e) {
    kPrint('Error deleting app data: $e');
  }
}

Future<void> goToAbout(WidgetTester tester) async {
  await tester.pump();
  final aboutButton = find.text('ABOUT');
  expect(aboutButton, findsOneWidget);

  await tester.tap(aboutButton);
  await tester.pump(Durations.long2);
}

FiatCurrency? getFiatCurrencyByCode(String code) {
  for (var fiatCurrency in ExchangeRate().supportedFiat) {
    if (fiatCurrency.code == code) {
      return fiatCurrency;
    }
  }
  return null;
}

Future<bool> checkFiatOnCurrentScreen(
    WidgetTester tester, String currentFiatCode) async {
  FiatCurrency? fiatCurrency = getFiatCurrencyByCode(currentFiatCode);
  if (fiatCurrency != null) {
    String? screenSymbol =
        await findSymbolOnScreen(tester, fiatCurrency.symbol);
    return screenSymbol == fiatCurrency.symbol;
  }
  return false;
}

Future<String?> findSymbolOnScreen(
    WidgetTester tester, String fiatSymbol) async {
  final finder = find.text(fiatSymbol);

  // Wait until the symbol appears on the screen or timeout after 30 seconds
  final end = DateTime.now().add(const Duration(seconds: 30));
  while (DateTime.now().isBefore(end)) {
    await tester.pump();
    if (tester.any(finder)) {
      return fiatSymbol;
    }
  }
  return null;
}

Future<void> pressHamburgerMenu(WidgetTester tester) async {
  // check if the toast pop-up is there before pressing on to the tob bar
  await checkForToast(tester);
  // go with top bar hamburger button
  final hamburgerIcon = find.byType(HamburgerMenu);
  expect(hamburgerIcon, findsOneWidget);

  await tester.tap(hamburgerIcon, warnIfMissed: false);
  await tester.pump(Durations.long2);
}

Future<void> goToSettings(WidgetTester tester) async {
  await tester.pump();
  final settingsButton = find.text('SETTINGS');
  expect(settingsButton, findsOneWidget);

  await tester.tap(settingsButton);
  await tester.pump(Durations.long2);
}

Future<String?> findCurrentFiatInSettings(WidgetTester tester) async {
  await tester.pump();
  String? currentSelection;
  for (var element in ExchangeRate().supportedFiat) {
    if (find.text(element.code).evaluate().isNotEmpty) {
      currentSelection = element.code;
    }
  }
  await tester.pump(Durations.long1);
  return currentSelection;
}

Future<bool> isSlideSwitchOn(WidgetTester tester, String listTileText) async {
  await tester.pump();

  // Find the ListTile widget containing the text "Display Fiat Values"
  final listTileFinder = find.ancestor(
      of: find.text(listTileText), matching: find.byType(ListTile));
  expect(listTileFinder, findsOneWidget);

  // Find the SettingToggle widget within the ListTile
  final settingToggleFinder =
      find.descendant(of: listTileFinder, matching: find.byType(SettingToggle));
  expect(settingToggleFinder, findsOneWidget);

  // Retrieve the SettingToggle widget
  final settingToggleWidget = tester.widget<SettingToggle>(settingToggleFinder);

  // Return the state of the switch using the getter function
  return settingToggleWidget.getter();
}

Future<void> findAndToggleSettingsSwitch(
    WidgetTester tester, String listTileText) async {
  await tester.pump();

  // Find the ListTile widget containing the text "Display Fiat Values"
  final listTileFinder = find.ancestor(
      of: find.text(listTileText), matching: find.byType(ListTile));
  expect(listTileFinder, findsOneWidget);

  // Find the SettingToggle widget within the ListTile
  final switchFinder =
      find.descendant(of: listTileFinder, matching: find.byType(SettingToggle));
  expect(switchFinder, findsOneWidget);

  // Tap the switch to toggle it
  await tester.tap(switchFinder);
  await tester.pump(Durations.long2);
}

Future<void> fromSettingsToFiatBottomSheet(WidgetTester tester,
    {String? currentSelection}) async {
  await tester.pump();
  final fiatOptionButton = find.text(currentSelection ?? 'USD');
  expect(fiatOptionButton, findsOneWidget);

  await tester.tap(fiatOptionButton);
  await tester.pump(Durations.long3);
}

Future<void> scrollActivityAndCheckFiat(
  WidgetTester tester,
  String currentSettingsFiatCode,
) async {
  bool fiatCheckResult;

  // Loop until the check passes or until you cannot scroll anymore
  while (true) {
    // Check the result on the current screen
    fiatCheckResult =
        await checkFiatOnCurrentScreen(tester, currentSettingsFiatCode);

    // If the check is successful, exit the loop
    if (fiatCheckResult) {
      break;
    }

    // Perform the drag operation on the CustomScrollView by the specified number of pixels
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -100));
    await tester.pump(Durations.long2);

    // If it reaches the bottom and cannot scroll further, it will return
    final Finder scrollable = find.byType(CustomScrollView);
    final ScrollableState scrollableState =
        tester.state<ScrollableState>(scrollable);
    if (scrollableState.position.pixels >=
        scrollableState.position.maxScrollExtent) {
      break;
    }
  }

  // Assert that the fiatCheckResult is true at the end of the scroll
  expect(fiatCheckResult, isTrue);
}

Future<void> goToSupport(WidgetTester tester) async {
  await tester.pump();
  final supportButton = find.text('SUPPORT');
  expect(supportButton, findsOneWidget);

  await tester.tap(supportButton);
  await tester.pump(Durations.long2);
}

Future<void> goToDocumentation(WidgetTester tester) async {
  await tester.pump();
  final documentationButton = find.text('DOCUMENTATION');
  expect(documentationButton, findsOneWidget);

  await tester.tap(documentationButton);
  await tester.pump(Durations.long2);
}

Future<void> goToTelegram(WidgetTester tester) async {
  await tester.pump();
  final telegramButton = find.text('TELEGRAM');
  expect(telegramButton, findsOneWidget);

  await tester.tap(telegramButton);
  await tester.pump(Durations.long2);
}

Future<void> goToEmail(WidgetTester tester) async {
  await tester.pump();
  final emailButton = find.text('EMAIL');
  expect(emailButton, findsOneWidget);

  await tester.tap(emailButton);
  await tester.pump(Durations.long2);
}

Future<void> fromHomeToHotWallet(WidgetTester tester) async {
  await tester.pump();
  final hotWalletButton = find.text('Envoy');
  expect(hotWalletButton, findsOneWidget);

  await tester.tap(hotWalletButton);
  await tester.pump(Durations.long2);
}

Future<void> openDotsMenu(WidgetTester tester) async {
  await checkForToast(tester);
  await tester.pump();
  final dotsButton = find.byIcon(Icons.more_horiz_outlined);
  expect(dotsButton, findsOneWidget);

  await tester.tap(dotsButton);
  await tester.pump(Durations.long2);
}

Future<void> fromDotsMenuToEditName(WidgetTester tester) async {
  await tester.pump();
  final editNameButton = find.text('EDIT ACCOUNT NAME');
  expect(editNameButton, findsOneWidget);

  await tester.tap(editNameButton);
  await tester.pump(Durations.long2);
}

Future<void> exitEditName(WidgetTester tester) async {
  await tester.pump();
  final exitButton = find.byIcon(Icons.close);
  // expect(exitButton, findsOneWidget);
  // Disabled because if the toast is visible, there will be two "Close" icons on the screen.

  await tester.tap(exitButton.first);
  await tester.pump(Durations.long2);
}

Future<void> enterTextInField(
  WidgetTester tester,
  Finder fieldFinder,
  String text,
) async {
  await tester.pump();

  final nameField = fieldFinder;
  // Ensure the widget is present on the screen
  expect(nameField, findsOneWidget);

  // Tap the field to focus it
  await tester.tap(nameField);
  await tester.pump(Durations.long2);

  // Enter text into the field
  await tester.enterText(nameField, text);
  await tester.pump(Durations.long2);
}

Future<void> saveName(WidgetTester tester) async {
  await tester.pump();
  final saveButton = find.text('Save');
  expect(saveButton, findsOneWidget);

  await tester.tap(saveButton);
  await tester.pump(Durations.long2);
}

Future<void> checkName(WidgetTester tester, String name) async {
  await tester.pump();
  final nameText = find.text(name).first;
  expect(nameText, findsOneWidget);
}

Future<void> setUpWalletFromSeedViaMagicRecover(
    WidgetTester tester, List<String> seed) async {
  await tester.pump();
  await onboardingAndEnterSeed(tester, seed);

  final restoreButtonFromDialog = find.text('Restore');
  await tester.pumpUntilFound(restoreButtonFromDialog,
      duration: Durations.long1, tries: 100);
  expect(restoreButtonFromDialog, findsOneWidget);
  await tester.tap(restoreButtonFromDialog);
  await tester.pump(Durations.long2);
  await tester.pumpAndSettle();

  final successMessage = find.text("Your Wallet Is Ready");
  final continueButtonFinder = find.text('Continue');
  expect(successMessage, findsOneWidget);
  expect(continueButtonFinder, findsOneWidget);
  await tester.tap(continueButtonFinder);
  await tester.pump(const Duration(milliseconds: 500));

  // Scroll down by 600 pixels
  await scrollHome(tester, -600);

  // search for passport account
  final passportAccount = find.text("Passport");

  // Ensure at least one instance of the text is found
  expect(passportAccount, findsWidgets);
  await tester.pumpAndSettle();
}

Future<void> setUpWalletFromSeedViaBackupFile(
    WidgetTester tester, List<String> seed) async {
  await tester.pump();
  await onboardingAndEnterSeed(tester, seed);

  final ignoreButtonFromDialog = find.text('Ignore');
  await tester.pumpUntilFound(ignoreButtonFromDialog,
      duration: Durations.long1, tries: 100);
  expect(ignoreButtonFromDialog, findsOneWidget);
  await tester.pump(Durations.long2);
  await tester.tap(ignoreButtonFromDialog);
  await tester.pump(Durations.long2);
  await tester.pumpAndSettle();

  final imageFinder = find.byType(Image);

  await tester.longPress(imageFinder);

  final successMessage = find.text("Your Wallet Is Ready");
  await tester.pumpUntilFound(successMessage,
      tries: 100, duration: Durations.long2);
  final continueButtonFinder = find.text('Continue');
  expect(successMessage, findsOneWidget);
  expect(continueButtonFinder, findsOneWidget);
  await tester.tap(continueButtonFinder);
  await tester.pump(const Duration(milliseconds: 500));

  // Scroll down by 600 pixels
  await scrollHome(tester, -600);

  // search for passport account
  final passportAccount = find.text("Passport");

  // Ensure at least one instance of the text is found
  expect(passportAccount, findsWidgets);
  await tester.pumpAndSettle();
}

Future<void> enterSeedWords(
    List<String> seed, WidgetTester tester, Finder finder) async {
  if (seed.length != 12) {
    throw ArgumentError('List must contain exactly 12 strings.');
  }
  for (int i = 0; i < seed.length; i++) {
    await tester.tap(finder.at(i), warnIfMissed: false);
    await tester.pump(Durations.long2);
    await tester.enterText(finder.at(i), seed[i]);
    await tester.pump(Durations.long2);
  }
}

Future<void> scrollHome(WidgetTester tester, double pixels) async {
  // Perform the drag operation on the ReorderableListView by the specified number of pixels
  await tester.drag(find.byType(ReorderableListView), Offset(0, pixels));
  await tester.pump(Durations.long2);
}

Future<void> scrollUntilVisible(WidgetTester tester, String text,
    {int maxScrolls = 50, double scrollIncrement = -100}) async {
  Finder finder = find.text(text);

  for (int i = 0; i < maxScrolls; i++) {
    // Try to find the widget
    if (finder.evaluate().isNotEmpty) {
      return; // Widget found, stop scrolling
    }

    await scrollHome(tester, scrollIncrement);
  }

  // Optionally, you could throw an exception if the widget isn't found after maxScrolls
  throw Exception(
      'Widget with text "$text" not found after scrolling $maxScrolls times.');
}

Future<void> scrollFindAndTapText(WidgetTester tester, String text,
    {int maxScrolls = 50, double scrollIncrement = -100}) async {
  Finder finder = find.text(text);

  for (int i = 0; i < maxScrolls; i++) {
    // Try to find the widget
    if (finder.evaluate().isNotEmpty) {
      // Widget found, tap on the first instance
      await tester.tap(finder);
      await tester.pumpAndSettle(); // Ensure the tap action is completed
      return;
    }

    // Scroll the view if the widget isn't found
    await scrollHome(tester, scrollIncrement);
  }

  // Optionally, throw an exception if the widget isn't found after maxScrolls
  throw Exception(
      'Widget with text "$text" not found after scrolling $maxScrolls times.');
}

Future<void> onboardingAndEnterSeed(
    WidgetTester tester, List<String> seed) async {
  final setUpButtonFinder = find.text('Set Up Envoy Wallet');
  expect(setUpButtonFinder, findsOneWidget);
  await tester.tap(setUpButtonFinder);
  await tester.pump(const Duration(milliseconds: 500));

  final continueButtonFinder = find.text('Continue');
  expect(continueButtonFinder, findsOneWidget);
  await tester.tap(continueButtonFinder);
  await tester.pump(const Duration(milliseconds: 500));

  final manuallyConfigureSeedWords = find.text('Manually Configure Seed Words');
  expect(manuallyConfigureSeedWords, findsOneWidget);
  await tester.tap(manuallyConfigureSeedWords);
  await tester.pump(const Duration(milliseconds: 1000));

  final importSeedButton = find.text('Import Seed');
  expect(importSeedButton, findsOneWidget);
  await tester.tap(importSeedButton);
  await tester.pump(const Duration(milliseconds: 1500));

  final import12SeedButton = find.text('12 Word Seed');
  expect(import12SeedButton, findsOneWidget);
  await tester.tap(import12SeedButton);
  await tester.pump(const Duration(milliseconds: 1500));

  final mnemonicInput = find.byType(MnemonicInput);
  expect(mnemonicInput, findsExactly(12));

  await enterSeedWords(seed, tester, mnemonicInput);

  // just tap somewhere on screen after entering seed
  final title = find.text('Enter Your Seed');
  expect(title, findsOneWidget);
  await tester.tap(title);
  await tester.pump(const Duration(milliseconds: 1500));

  final doneButton = find.text('Done');
  expect(doneButton, findsOneWidget);
  await tester.tap(doneButton);
  await tester.pump(const Duration(milliseconds: 500));
}

Future<void> findAndPressBuyOptions(WidgetTester tester) async {
  await tester.pump();

  // Find the GestureDetector containing the QrShield and Buy button text
  final buyButtonFinder = find.descendant(
    of: find.byType(GestureDetector),
    matching: find.text('Buy'),
  );
  expect(buyButtonFinder, findsOneWidget);

  // Get the parent GestureDetector widget
  final gestureDetectorFinder = find.ancestor(
    of: buyButtonFinder,
    matching: find.byType(GestureDetector),
  );
  expect(gestureDetectorFinder, findsOneWidget);

  // Tap the button
  await tester.tap(gestureDetectorFinder);
  await tester.pump(Durations.long2);
}

Future<void> checkBuyOptionAndTitle(WidgetTester tester) async {
  await tester.pump();

  // Find the GestureDetector containing the QrShield and Buy button text
  final buyButtonFinder = find.descendant(
    of: find.byType(GestureDetector),
    matching: find.text('Buy'),
  );

  // Check if the button is still there
  expect(buyButtonFinder, findsOneWidget);

  // Check if the "ACCOUNTS" title is still there
  // double check if we entered in BUY
  final accountsTitleFinder = find.text('ACCOUNTS');
  expect(accountsTitleFinder, findsOneWidget);
}

Future<void> setUpFromStartNoAccounts(WidgetTester tester) async {
  await tester.pump();

  final setUpButtonFinder = find.text('Set Up Envoy Wallet');
  expect(setUpButtonFinder, findsOneWidget);
  await tester.tap(setUpButtonFinder);
  await tester.pump(Durations.long2);

  final continueButtonFinder = find.text('Continue');
  expect(continueButtonFinder, findsOneWidget);
  await tester.tap(continueButtonFinder);
  await tester.pump(Durations.long2);

  // go to home w no accounts
  final skipButtonFinder = find.text('Skip');
  expect(skipButtonFinder, findsOneWidget);
  await tester.tap(skipButtonFinder);
  await tester.pump(Durations.long2);
}

Future<void> checkForToast(WidgetTester tester) async {
  final iconFinder = find.byWidgetPredicate(
    (widget) =>
        widget is EnvoyIcon &&
        (widget.icon == EnvoyIcons.info || widget.icon == EnvoyIcons.alert),
  );

  // Check if the icon is found initially
  bool iconInitiallyFound = iconFinder.evaluate().isNotEmpty;
  if (!iconInitiallyFound) {
    return; // Exit the test if the icon is not found initially
  } else {
    final closeToastButton = find.byIcon(Icons.close);
    if (tester.any(closeToastButton)) {
      final offset = tester.getTopLeft(closeToastButton.last);
      // Check if the widget is within the 400x800 screen bounds
      if (offset.dx >= 0 &&
          offset.dy >= 0 &&
          offset.dx <= 400 &&
          offset.dy <= 800) {
        await tester.tap(closeToastButton.last);
        await tester.pump(Durations.long2);
      } else {
        kPrint('The close button is off-screen and cannot be tapped.');
      }
    }
  }
}

Future<void> findAndTapActivitySlideButton(WidgetTester tester) async {
  // Find all GestureDetector widgets
  final gestureDetectors = find.byType(GestureDetector);

  // Iterate through each GestureDetector to find the one with the specific EnvoyIcon
  for (final gestureDetector in gestureDetectors.evaluate()) {
    final gestureDetectorWidget = gestureDetector.widget as GestureDetector;

    // Check if this GestureDetector contains the specific EnvoyIcon
    final iconFinder = find.descendant(
      of: find.byWidget(gestureDetectorWidget),
      matching: find.byWidgetPredicate(
        (widget) => widget is EnvoyIcon && widget.icon == EnvoyIcons.tag,
      ),
    );

    // If the specific EnvoyIcon is found inside this GestureDetector, tap it
    if (iconFinder.evaluate().isNotEmpty) {
      await tester.tap(find.byWidget(gestureDetectorWidget));
      await tester.pump();
      return; // Exit after tapping
    }
  }

  fail('No GestureDetector with the specified EnvoyIcon was found.');
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

Future<bool> findTextOnScreen(WidgetTester tester, String text) async {
  await tester.pump(Durations.long2);
  final textFinder = find.text(text);

  // Check if the text is found and return true or false accordingly
  return textFinder.evaluate().isNotEmpty;
}

Future<void> findAndPressEnvoyIcon(
    WidgetTester tester, EnvoyIcons expectedIcon) async {
  // Use the existing function to find the EnvoyIcon
  final iconFinder = await checkForEnvoyIcon(tester, expectedIcon);

  await tester.tap(iconFinder.first);
  await tester.pump(Durations.long2);
}

Future<void> findAndPressFirstEnvoyIcon(
    WidgetTester tester, EnvoyIcons expectedIcon) async {
  // Use the existing function to find the EnvoyIcon
  final iconFinder = await checkForEnvoyIcon(tester, expectedIcon);

  await tester.tap(iconFinder.first);
  await tester.pump(Durations.long2);
}

Future<Finder> checkForEnvoyIcon(
    WidgetTester tester, EnvoyIcons expectedIcon) async {
  final iconFinder = find.byWidgetPredicate(
    (widget) => widget is EnvoyIcon && widget.icon == expectedIcon,
  );
  await tester.pumpUntilFound(iconFinder, tries: 20, duration: Durations.long2);

  return iconFinder;
}

Future<void> findAndPressTextButton(
    WidgetTester tester, String buttonText) async {
  await tester.pump(Durations.long2);
  final textButton = find.text(buttonText);
  expect(textButton, findsOneWidget);

  await tester.tap(textButton);
  await tester.pump(Durations.long2);
}

Future<void> findFirstTextButtonAndPress(
    WidgetTester tester, String buttonText) async {
  await tester.pump(Durations.long2);

  // Find all widgets that match the text
  final textButtons = find.text(buttonText);

  // Ensure at least one widget is found
  expect(textButtons, findsWidgets);

  // Tap the first widget that matches
  await tester.tap(textButtons.first);
  await tester.pump(Durations.long2);
}

Future<void> findAndPressWidget<T extends Widget>(WidgetTester tester) async {
  await tester.pump(Durations.long2);

  // Find the widget of type T
  final widgetFinder = find.byType(T);
  expect(widgetFinder, findsOneWidget);
  await tester.tap(widgetFinder);

  await tester.pump(Durations.long2);
}

Future<void> findLastTextButtonAndPress(
    WidgetTester tester, String buttonText) async {
  await tester.pump(Durations.long2);

  // Find all widgets that match the text
  final textButtons = find.text(buttonText);

  // Ensure at least one widget is found
  expect(textButtons, findsWidgets);

  // Tap the first widget that matches
  await tester.tap(textButtons.last);
  await tester.pump(Durations.long2);
}

Future<void> findAndTapBigTab(WidgetTester tester, String label) async {
  await tester.pump();

  // Find all BigTab widgets
  final bigTabFinder = find.byType(BigTab);

  // Collect all BigTab widgets
  final bigTabWidgets = tester.widgetList<BigTab>(bigTabFinder).toList();

  // Check each BigTab widget for the correct label
  for (var tab in bigTabWidgets) {
    final textFinder = find.descendant(
      of: find.byWidget(tab),
      matching: find.byType(Text),
    );

    // Verify that the Text widget is found and contains the label
    if (textFinder.evaluate().isNotEmpty) {
      final textWidget = tester.widget<Text>(textFinder);
      if (textWidget.data != null && textWidget.data!.contains(label)) {
        // Tap the BigTab widget containing the label
        await tester.tap(find.byWidget(tab));
        await tester.pumpAndSettle();
        return; // Exit after tap
      }
    }
  }
}

Future<void> enablePrivacy(WidgetTester tester) async {
  await findAndTapBigTab(tester, 'Improved');
}

Future<void> enablePerformance(WidgetTester tester) async {
  await findAndTapBigTab(tester, 'Better');
}

Future<bool> checkTorShieldIcon(WidgetTester tester,
    {required bool expectPrivacy}) async {
  await tester.pumpAndSettle(); // Ensure the screen updates after interactions

  // Find all Image widgets on the screen
  final imageFinder = find.byType(Image);

  // Collect all Image widgets
  final imageWidgets = tester.widgetList<Image>(imageFinder).toList();

  if (expectPrivacy) {
    // Check the number of image widgets found
    expect(imageWidgets, hasLength(1),
        reason: 'Image should be visible when Privacy is enabled.');

    // Determine the path of the visible image
    final imageWidget = imageWidgets.first;
    final imageAssetPath = imageWidget.image is AssetImage
        ? (imageWidget.image as AssetImage).assetName
        : null;

    // Verify which image is displayed
    if (ConnectivityManager().torEnabled &&
        !ConnectivityManager().torTemporarilyDisabled) {
      // Expected image paths when tor is enabled
      if (ConnectivityManager().electrumConnected) {
        expect(imageAssetPath, 'assets/indicator_shield_teal.png');
        return true;
      } else {
        expect(imageAssetPath, 'assets/indicator_shield_red.png');
        return false;
      }
    } else {
      // Expect no image to be displayed
      expect(imageAssetPath, isNull);
      return false;
    }
  } else {
    // When Performance is enabled, expect no shield image to be visible
    expect(imageWidgets, isEmpty,
        reason: 'No image should be visible when Performance is enabled.');
    return false;
  }
}

Future<bool> isAccountTestnetTaproot(
    WidgetTester tester, Finder accountListTile,
    {bool isHotWallet = true}) async {
  await tester.pumpAndSettle();

  // Check for the presence of 'Testnet' and 'Taproot' texts within the Account List.
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

  // Check for 'Envoy' if isHotWallet is true, otherwise check for 'Passport'.
  bool containsEnvoyOrPassport = find
      .descendant(
        of: accountListTile,
        matching: find.text(isHotWallet ? 'Envoy' : 'Passport'),
      )
      .evaluate()
      .isNotEmpty;

  // Return true if meets criteria.
  bool meetsCriteria =
      containsTestnet && containsTaproot && containsEnvoyOrPassport;

  return meetsCriteria;
}

Future<bool> isAccountTestnet(WidgetTester tester, Finder accountListTile,
    {bool isHotWallet = true}) async {
  await tester.pumpAndSettle();

  // Check for the presence of 'Testnet' text within the Account List.
  bool containsTestnet = find
      .descendant(
        of: accountListTile,
        matching: find.text('Testnet'),
      )
      .evaluate()
      .isNotEmpty;

  // Check for 'Envoy' if isHotWallet is true, otherwise check for 'Passport'.
  bool containsEnvoyOrPassport = find
      .descendant(
        of: accountListTile,
        matching: find.text(isHotWallet ? 'Envoy' : 'Passport'),
      )
      .evaluate()
      .isNotEmpty;

  // Return true if the account meets the criteria.
  bool meetsCriteria = containsTestnet && containsEnvoyOrPassport;

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
  final Finder specificSwitchFinder = switchFinder.at(2);

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

Future<void> findAndTapFirstAccText(
    WidgetTester tester, String accountText) async {
  await tester.pump(Durations.long2);

  // Find the AccountListTile containing the specified accountText.
  final accountListTileFinder =
      find.widgetWithText(AccountListTile, accountText);

  // Check if the widget is found.
  if (accountListTileFinder.evaluate().isNotEmpty) {
    // Tap on the first found widget.
    await tester.tap(accountListTileFinder.first);
    await tester.pump(Durations.long2);
  } else {
    throw Exception(
        'No AccountListTile found with text containing $accountText');
  }
}

Future<void> fromHomeToAdvancedMenu(WidgetTester tester) async {
  await pressHamburgerMenu(tester);
  await goToSettings(tester);
  await openAdvanced(tester);
}

Future<void> findAndTapPopUpText(WidgetTester tester, String tapText) async {
  final tapButtonText = find.text(tapText);
  await tester.pumpUntilFound(tapButtonText,
      tries: 10, duration: Durations.long1);
  await tester.tap(tapButtonText.last);
  await tester.pump(Durations.long2);
}

Future<void> waitForTealTextAndTap(
    WidgetTester tester, String textToFind) async {
  // Define the Teal color you want to check for
  const Color expectedColor = EnvoyColors.accentPrimary;

  // Finder for the text widget
  final Finder textFinder = find.text(textToFind);

  // Wait until the text is found initially
  await tester.pumpUntilFound(textFinder,
      tries: 100, duration: Durations.long2);

  // Set the maximum number of retries to wait for the text to turn Teal
  const int maxRetries = 20;
  int retryCount = 0;

  // Wait the text button to settle
  await tester.pump(const Duration(milliseconds: 3500));
  // Loop until the text's color is Teal or the maximum retries are reached
  bool isTeal = false;
  while (!isTeal && retryCount < maxRetries) {
    // Find the text again
    await tester.pumpUntilFound(textFinder,
        tries: 100, duration: Durations.long2);
    // Get the Text widget
    final Text textWidget = tester.widget<Text>(textFinder);

    // Check the color of the Text widget
    if (textWidget.style?.color == expectedColor) {
      isTeal = true;
    } else {
      // If not Teal, wait a bit and try again
      await tester.pump(const Duration(milliseconds: 1000));
      retryCount++;
    }
  }

  // If the text is Teal, tap it
  if (isTeal) {
    await tester.tap(textFinder);
    await tester.pump(Durations.long2);
  } else {
    throw Exception("Text did not turn teal after $maxRetries attempts");
  }

  await tester.pump(Durations.long2);
}

Future<void> openPassportAccount(
    WidgetTester tester, String accountPassportName) async {
  await tester.pump(Durations.long2);

  // Find the first widget with the specified text
  final hotWalletButton = find.text(accountPassportName).first;

  expect(hotWalletButton, findsOneWidget);

  await tester.tap(hotWalletButton);
  await tester.pump(Durations.long2);
}

Future<void> openDeviceCard(WidgetTester tester, String deviceName) async {
  await tester.pump();
  final deviceCard = find.text(deviceName);
  expect(deviceCard, findsOneWidget);

  await tester.tap(deviceCard);
  await tester.pump(Durations.long2);
}

Future<void> openEditDevice(WidgetTester tester) async {
  await tester.pump();
  final editNameButton = find.text('EDIT DEVICE NAME');
  expect(editNameButton, findsOneWidget);

  await tester.tap(editNameButton);
  await tester.pump(Durations.long2);
}

extension PumpUntilFound on WidgetTester {
  /// Pumps the widget tree until the specified [finder] locates an element,
  /// or until the maximum number of tries is reached.
  ///
  /// This is particularly useful in scenarios involving animations or delayed
  /// widget appearances, where the desired widget might not be immediately
  /// present in the widget tree. It is especially handy when dealing with
  /// never-ending animations like a `CircularProgressIndicator`.
  Future<void> pumpUntilFound(
    Finder finder, {
    Duration duration = const Duration(milliseconds: 100),
    int tries = 10,
  }) async {
    for (var i = 0; i < tries; i++) {
      await pump(duration);

      final isNotEmpty = finder.tryEvaluate();

      if (isNotEmpty) {
        break;
      }
    }
  }
}

Future<bool> searchTaprootAccType(WidgetTester tester) async {
// Find all AccountListTile widgets
  var accountListTileFinder = find.byType(AccountListTile);

// Flag to track if a matching account is found
  bool foundTaprootAccount = false;

// Iterate through each AccountListTile and verify the contents
  for (var i = 0; i < accountListTileFinder.evaluate().length; i++) {
    final accountBadge = accountListTileFinder.at(i);
    bool isAccTaproot = await isAccountTaproot(tester, accountBadge);

//if any account is Taproot, break
    if (isAccTaproot) {
      foundTaprootAccount = true;
      break;
    }
  }

  return foundTaprootAccount;
}

Future<bool> searchTestTaprootAccType(WidgetTester tester) async {
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

  return foundTestnetTaprootAccount;
}

Future<bool> searchTestnetAccType(WidgetTester tester) async {
// Find all AccountListTile widgets
  var accountListTileFinder = find.byType(AccountListTile);

// Flag to track if a matching account is found
  bool foundTestnetAccount = false;

// Iterate through each AccountListTile and verify the contents
  for (var i = 0; i < accountListTileFinder.evaluate().length; i++) {
    final accountBadge = accountListTileFinder.at(i);
    bool isAccTestnet = await isAccountTestnet(tester, accountBadge);

//if any account is Testnet, break
    if (isAccTestnet) {
      foundTestnetAccount = true;
      break;
    }
  }

  return foundTestnetAccount;
}

Future<void> disableAllNetworks(WidgetTester tester) async {
  await fromHomeToAdvancedMenu(tester);
  // Check if "Testnet" is already enabled
  bool testnetAlreadyEnabled = await isSlideSwitchOn(tester, "Testnet");
  if (testnetAlreadyEnabled) {
    // Disable "Testnet"
    await findAndToggleSettingsSwitch(tester, "Testnet");
  }

  // Check if "Taproot" is already enabled
  bool taprootAlreadyEnabled = await isSlideSwitchOn(tester, "Taproot");
  if (taprootAlreadyEnabled) {
    // Disable "Taproot"
    await findAndToggleSettingsSwitch(tester, "Taproot");
  }

  // Check if "Signet" is already enabled
  bool signetAlreadyEnabled = await isSlideSwitchOn(tester, "Signet");
  if (signetAlreadyEnabled) {
    // Disable "Signet"
    await findAndToggleSettingsSwitch(tester, "Signet");
  }
  // back to home
  await pressHamburgerMenu(tester);
  await pressHamburgerMenu(tester);
}

Future<void> clearPromptStates(WidgetTester tester) async {
  await pressHamburgerMenu(tester);
  await goToSettings(tester);

  final devOptions = find.text('Dev options');
  expect(devOptions, findsOneWidget);
  await tester.tap(devOptions);
  await tester.pump(Durations.long2);

  final clearPrompts = find.text('Clear Prompt states');
  expect(clearPrompts, findsOneWidget);
  await tester.tap(clearPrompts);
  await tester.pump(Durations.long2);

  await pressHamburgerMenu(tester);
  await pressHamburgerMenu(tester);
}

Future<void> findAndPressIcon(WidgetTester tester, IconData iconData) async {
  final iconFinder = find.byIcon(iconData);

  // Check if the icon is found
  final iconWidgets = iconFinder.evaluate();
  if (iconWidgets.isEmpty) {
    throw Exception('Icon not found');
  }

  // Tap the first occurrence of the widget
  await tester.tap(iconFinder.first);
  await tester.pump(Durations.long2);
}
