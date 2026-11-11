// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/home/settings/qlv2_diagnostics_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows how to make a QLv2 session available', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Qlv2DiagnosticsPage()),
    );

    expect(find.text('QLv2 diagnostics'), findsOneWidget);
    expect(find.text('No QLv2 Passport session'), findsOneWidget);
    expect(
      find.text('Pair or reconnect a QLv2 Passport, then reopen this page.'),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox());
  });
}
