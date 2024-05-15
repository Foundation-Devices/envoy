// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screenshot/screenshot.dart';

void main() {
  testWidgets('onboarding flow just for test', (tester) async {
    print("before initSingletons");
    await initSingletons();
    print("before envoyScreenshotController");
    ScreenshotController envoyScreenshotController = ScreenshotController();
    print("before run app");
    await tester.pumpWidget(Screenshot(
        controller: envoyScreenshotController, child: const EnvoyApp()));

    await tester.pump();
    print("after pump");
    final setUpButtonFinder = find.text('Set Up Envoy Wallet');
    expect(setUpButtonFinder, findsOneWidget);
    await tester.tap(setUpButtonFinder);
    await tester.pump(const Duration(milliseconds: 500));

    final continueButtonFinder = find.text('Continue');
    expect(continueButtonFinder, findsOneWidget);
    await tester.tap(continueButtonFinder);
    await tester.pump(const Duration(milliseconds: 500));

    print("open magic backup");
    final enableMagicButtonFinder = find.text('Enable Magic Backups');
    expect(enableMagicButtonFinder, findsOneWidget);
    await tester.tap(enableMagicButtonFinder);
    await tester.pump(const Duration(milliseconds: 500));

    print("open screen with video");
    // video
    final createMagicButtonFinder = find.text('Create Magic Backup');
    expect(createMagicButtonFinder, findsOneWidget);
    await tester.tap(createMagicButtonFinder);
    await tester.pump(const Duration(milliseconds: 1500));
    print("after screen with video");
  });
}
