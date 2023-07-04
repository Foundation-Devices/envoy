// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

//import 'dart:convert';
//import 'dart:io';
import 'dart:io';
import 'package:path/path.dart';
import 'package:envoy/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:integration_test/integration_test.dart';

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
  testWidgets("Passport simulator integration test",
      (WidgetTester tester) async {
    // Initialize singletons
    await initSingletons();
    await tester.pumpWidget(EnvoyApp());

    // var process = await Process.start('just', ['/home/igor/Code/passport-air/simulator/sim', 'color']);
    // process.stdout
    //     .transform(utf8.decoder)
    //     .forEach(print);

    //await Process.run('xdotool', ['mousemove', '-w', '0x8a0000e', '210', '550']);
    //await Process.run('xdotool', ['key', '-w', '0x8a0000e', 'x']);

    //print(result.stdout);

    //sleep(new Duration(seconds: 30));

    // TODO: enable this
    // Every time we start the app we should land on Devices
    //final titleFinder = find.text('DEVICES');
    //expect(titleFinder, findsOneWidget);
  });
}
