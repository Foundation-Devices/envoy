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

  testWidgets('Expired or disposed toasts can be shown again', (tester) async {
    late BuildContext context;
    Widget app() => MaterialApp(
          home: Builder(
            builder: (value) {
              context = value;
              return const Scaffold();
            },
          ),
        );
    void showToast(String message, {Duration? duration}) {
      unawaited(EnvoyToast<void>(
        replaceExisting: true,
        message: message,
        duration: duration,
        builder: (_) => Text(message),
      ).show(context));
    }

    await tester.pumpWidget(app());
    showToast('Address copied', duration: const Duration(seconds: 2));
    await tester.pumpAndSettle();
    showToast('Tor not reachable');
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Address copied'), findsNothing);
    expect(find.text('Tor not reachable'), findsOneWidget);
    showToast('Address copied');
    await tester.pumpAndSettle();
    expect(find.text('Address copied'), findsOneWidget);

    // Removing the navigator disposes routes without popping their futures.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await tester.pumpWidget(app());
    showToast('Address copied');
    showToast('Tor not reachable');
    await tester.pumpAndSettle();
    expect(find.text('Address copied'), findsOneWidget);
    expect(find.text('Tor not reachable'), findsOneWidget);
    EnvoyToast.dismissPreviousToasts(context);
    await tester.pumpAndSettle();
  });
}
