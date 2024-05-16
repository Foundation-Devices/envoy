// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';
import 'package:envoy/main.dart';
import 'package:envoy/ui/components/select_dropdown.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path/path.dart';

void main() {
  testWidgets('flow to map and P2P', (tester) async {
    final FlutterExceptionHandler? originalOnError = FlutterError.onError;
    // Override FlutterError.onError to handle errors in the test.
    FlutterError.onError = (FlutterErrorDetails details) {
      print('FlutterError caught: ${details.exceptionAsString()}');
      // Forward the error to the original handler if necessary.
      if (originalOnError != null) {
        originalOnError(details);
      }
    };
    try {
      // Uncomment the line below if you want to reset Envoy data and go through the onboarding flow.
      // await resetEnvoyData();

      ScreenshotController envoyScreenshotController = ScreenshotController();
      await initSingletons();
      await tester.pumpWidget(Screenshot(
          controller: envoyScreenshotController, child: const EnvoyApp()));

      await setUpAppFromStart(tester);

      print("after onboarding");

      await fromHomeToBuyOptions(tester);

      print("buy options on the screen");

      // final atmTab = find.text('ATMs');
      // expect(atmTab, findsOneWidget);
      // await tester.tap(atmTab);
      // await tester.pump(Durations.long2);
      //
      // final continueButtonFinder = find.text('Continue');
      // expect(continueButtonFinder, findsOneWidget);
      // await tester.tap(continueButtonFinder);
      // await tester.pumpAndSettle();
      //
      // final iconFinder = find.byWidgetPredicate(
      //   (widget) => widget is EnvoyIcon && widget.icon == EnvoyIcons.location,
      // );
      // expect(iconFinder, findsAny);
      //
      // // close the map, back to buy option menu
      // final iconClose = find.byWidgetPredicate(
      //   (widget) => widget is EnvoyIcon && widget.icon == EnvoyIcons.close,
      // );
      // await tester.tap(iconClose);
      // await tester.pump(Durations.long2);
      //
      // // test "peer to peer" flow
      //
      // final peerTab = find.text('Peer to Peer');
      // expect(peerTab, findsOneWidget);
      // await tester.tap(peerTab);
      // await tester.pump(Durations.long2);
      //
      // expect(continueButtonFinder, findsOneWidget);
      // await tester.tap(continueButtonFinder);
      // await tester.pump(Durations.long2);
      //
      // final title = find.text("Select an option");
      // expect(title, findsOneWidget);
    } finally {
      // Restore the original FlutterError.onError handler after the test.
      FlutterError.onError = originalOnError;
    }
  });
}

Future<void> fromHomeToBuyOptions(WidgetTester tester) async {
  await tester.pump();
  final buyBitcoinButton = find.text('Buy');
  expect(buyBitcoinButton, findsOneWidget);

  await tester.tap(buyBitcoinButton);

  await Future.delayed(const Duration(
      seconds: 5)); // Ensure enough time for reading JSON data for countries.
  await tester.pump(Durations.long2);

  // final selectRegionDropDown = find.text('Select State');
  // expect(selectRegionDropDown, findsOneWidget);
  // await tester.tap(selectRegionDropDown);
  // await tester.pump(Durations.long2);
  //
  // final dropdownItems = find.byType(DropdownMenuItem<EnvoyDropdownOption>);
  // await tester.tap(dropdownItems.at(1)); // Tap at first state
  // await tester.pump(Durations.long2);
  //
  // final continueButtonFinder = find.text('Continue');
  // expect(continueButtonFinder, findsOneWidget);
  // await tester.tap(continueButtonFinder);
  // await tester.pump(Durations.long2);
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
