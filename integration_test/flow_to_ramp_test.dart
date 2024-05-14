// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screenshot/screenshot.dart';
import 'flow_to_map_and_p2p_test.dart';

void main() {
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
