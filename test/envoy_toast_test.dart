// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:envoy/ui/widgets/toast/envoy_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Tor warnings stay unique while other toasts appear and expire', (
    tester,
  ) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (value) {
            context = value;
            return const Scaffold();
          },
        ),
      ),
    );

    void showWarning() {
      unawaited(EnvoyToast<void>(
        replaceExisting: true,
        message: 'Tor not reachable',
        builder: (_) => const Text('Tor not reachable'),
      ).show(context));
    }

    showWarning();
    showWarning();
    await tester.pumpAndSettle();
    expect(find.text('Tor not reachable'), findsOneWidget);

    unawaited(EnvoyToast<void>(
      replaceExisting: true,
      message: 'Address copied',
      duration: const Duration(seconds: 2),
      builder: (_) => const Text('Address copied'),
    ).show(context));
    await tester.pumpAndSettle();
    showWarning();
    await tester.pumpAndSettle();
    expect(find.text('Tor not reachable'), findsOneWidget);
    expect(find.text('Address copied'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    showWarning();
    await tester.pumpAndSettle();
    expect(find.text('Tor not reachable'), findsOneWidget);
    expect(find.text('Address copied'), findsNothing);

    EnvoyToast.dismissPreviousToasts(context);
    await tester.pumpAndSettle();
    expect(find.text('Tor not reachable'), findsNothing);
    showWarning();
    await tester.pumpAndSettle();
    expect(find.text('Tor not reachable'), findsOneWidget);
    EnvoyToast.dismissPreviousToasts(context);
    await tester.pumpAndSettle();
  });
}
