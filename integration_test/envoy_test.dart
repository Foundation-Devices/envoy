// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

//import 'dart:convert';
//import 'dart:io';
import 'package:envoy/main.dart';
import 'package:flutter_test/flutter_test.dart';
//import 'package:integration_test/integration_test.dart';

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
