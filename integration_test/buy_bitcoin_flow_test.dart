// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';
import 'package:envoy/main.dart';
import 'package:envoy/ui/components/select_dropdown.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path/path.dart';

// Note: Do not run main; run each test separately.
void main() {
  testWidgets('flow to map', (tester) async {
    // Uncomment the line below if you want to reset Envoy data and go through the onboarding flow.
    //await resetEnvoyData();

    ScreenshotController envoyScreenshotController = ScreenshotController();
    await initSingletons();
    await tester.pumpWidget(Screenshot(
        controller: envoyScreenshotController, child: const EnvoyApp()));

    // Uncomment the line below if you want to reset Envoy data and go through the onboarding flow.
    //await setUpAppFromStart(tester);

    await fromHomeToBuyOptions(tester);

    final atmTab = find.text('ATMs');
    expect(atmTab, findsOneWidget);
    await tester.tap(atmTab);
    await tester.pump(Durations.long2);

    final continueButtonFinder = find.text('Continue');
    expect(continueButtonFinder, findsOneWidget);
    await tester.tap(continueButtonFinder);
    await tester.pumpAndSettle();

    final iconFinder = find.byWidgetPredicate(
      (widget) => widget is EnvoyIcon && widget.icon == EnvoyIcons.location,
    );
    expect(iconFinder, findsAny);
  });

  testWidgets('flow to peer to peer', (tester) async {
    // Uncomment the line below if you want to reset Envoy data and go through the onboarding flow.
    //await resetEnvoyData();

    await initSingletons();
    ScreenshotController envoyScreenshotController = ScreenshotController();
    await tester.pumpWidget(Screenshot(
        controller: envoyScreenshotController, child: const EnvoyApp()));

    // Uncomment the line below if you want to reset Envoy data and go through the onboarding flow.
    //await setUpAppFromStart(tester);

    await fromHomeToBuyOptions(tester);

    final peerTab = find.text('Peer to Peer');
    expect(peerTab, findsOneWidget);
    await tester.tap(peerTab);
    await tester.pump(Durations.long2);

    final continueButtonFinder = find.text('Continue');
    expect(continueButtonFinder, findsOneWidget);
    await tester.tap(continueButtonFinder);
    await tester.pump(Durations.long2);

    final title = find.text("Select an option");
    expect(title, findsOneWidget);
  });

  testWidgets('flow to ramp', (tester) async {
    // Uncomment the line below if you want to reset Envoy data and go through the onboarding flow.
    //await resetEnvoyData();

    await initSingletons();
    ScreenshotController envoyScreenshotController = ScreenshotController();
    await tester.pumpWidget(Screenshot(
        controller: envoyScreenshotController, child: const EnvoyApp()));

    // Uncomment the line below if you want to reset Envoy data and go through the onboarding flow.
    //await setUpAppFromStart(tester);

    await fromHomeToBuyOptions(tester);
    final rampTab = find.text('Buy in Envoy');
    expect(rampTab, findsOneWidget);
    await tester.tap(rampTab);
    await tester.pump(Durations.long2);

    final continueButtonFinder = find.text('Continue');
    expect(continueButtonFinder, findsOneWidget);
    await tester.tap(continueButtonFinder);
    await tester.pump(Durations.long2);

    final title = find.text("Where should the Bitcoin be sent?");
    expect(title, findsOneWidget);
    await tester.tap(continueButtonFinder);
    await tester.pump(Durations.long2);

    final titleModalDialog = find.text("Leaving Envoy");
    expect(titleModalDialog, findsOneWidget);

    // Note: The "ramp" widget is only supported on Android and iOS platforms,
    // so there is no reliable way to verify its functionality in this test.
  });
}

Future<void> fromHomeToBuyOptions(WidgetTester tester) async {
  await tester.pump();
  final buyBitcoinButton = find.text('Buy');
  expect(buyBitcoinButton, findsOneWidget);
  await tester.tap(buyBitcoinButton);

  await tester.pump(Durations.long2);
  await Future.delayed(const Duration(
      seconds: 5)); // Ensure enough time for reading JSON data for countries.
  await tester.pump(Durations.long2);

  final selectRegionDropDown = find.text('Select State');
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
