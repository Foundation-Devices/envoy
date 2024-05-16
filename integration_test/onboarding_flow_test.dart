// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screenshot/screenshot.dart';

void main() {
  testWidgets('onboarding flow', (tester) async {
    await initSingletons();

    ScreenshotController envoyScreenshotController = ScreenshotController();

    await tester.pumpWidget(Screenshot(
        controller: envoyScreenshotController, child: const EnvoyApp()));

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
  });
}
