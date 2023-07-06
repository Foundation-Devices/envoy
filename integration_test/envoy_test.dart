// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:envoy/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> resetData() async {
  // Preferences
  final prefs = await SharedPreferences.getInstance();
  final appSupportDir = await getApplicationSupportDirectory();

  // Database
  final String dbName = 'envoy.db';
  final appDocumentDir = await getApplicationDocumentsDirectory();
  final dbFile = File(join(appDocumentDir.path, dbName));

  try {
    // Clear shared preferences
    await prefs.clear();
    // Delete app data directory
    await appSupportDir.delete(recursive: true);
    // Delete the database file
    await dbFile.delete();
  } catch (e) {
    print('Error deleting app data: $e');
  }
}

void main() {
  group('end-to-end test', () {
    testWidgets('Connect an existing passport flow', (tester) async {
      await resetData();
      await initSingletons();
      await tester.pumpWidget(EnvoyApp());

      final originalOnError = FlutterError.onError!;
      FlutterError.onError = (FlutterErrorDetails details) {
        originalOnError(details);
      };

      await tester.pump();

      final setUpButtonFinder = find.text('Set Up Envoy Wallet');
      final continueButtonFinder = find.text('Continue');
      final enableMagicButtonFinder = find.text('Enable Magic Backups');
      final createMagicButtonFinder = find.text('Create Magic Backup');

      expect(setUpButtonFinder, findsOneWidget);
      await tester.tap(setUpButtonFinder);
      await tester.pump(Duration(milliseconds: 500));

      expect(continueButtonFinder, findsOneWidget);
      await tester.tap(continueButtonFinder);
      await tester.pump(Duration(milliseconds: 500));

      expect(enableMagicButtonFinder, findsOneWidget);
      await tester.tap(enableMagicButtonFinder);
      await tester.pump(Duration(milliseconds: 500));

      //video
      expect(createMagicButtonFinder, findsOneWidget);
      await tester.tap(createMagicButtonFinder);
      await tester.pump(Duration(milliseconds: 1500));

      await tester.pumpAndSettle();

// animations

      expect(continueButtonFinder, findsOneWidget);
      await tester.tap(continueButtonFinder);
      await tester.pump(Duration(milliseconds: 500));

      expect(continueButtonFinder, findsOneWidget);
      await tester.tap(continueButtonFinder);
      await tester.pump(Duration(milliseconds: 500));

// main ˇˇ

      final devicesButton = find.text('Devices');
      final iconPlus = find.byIcon(Icons.add);
      final connectExistingPassport = find.text("CONNECT AN EXISTING PASSPORT");
      final getStarted = find.text("Get Started");

      await tester.tap(devicesButton);
      await tester.pumpAndSettle();

      await tester.tap(iconPlus);
      await tester.pumpAndSettle();

      await tester.tap(connectExistingPassport);
      await tester.pump(Duration(milliseconds: 500));

      expect(getStarted, findsOneWidget);
      await tester.tap(getStarted);
      await tester.pumpAndSettle();

      expect(continueButtonFinder, findsOneWidget);
      await tester.tap(continueButtonFinder);
      await tester.pumpAndSettle();
    });
  });
}
