// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:envoy/ui/components/address_widget.dart';

void main() {
  testWidgets('AddressWidget', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              AddressWidget(
                address: '3J98t1WpEZ73CNmQviecrnyiWrnqRhWNLy',
                short: false,
              ),
              AddressWidget(
                address: '3J98t1WpEZ73CNmQviecrnyiWrnqRhWNLy',
                short: true,
              ),
            ],
          ),
        ),
      ),
    );

    await expectLater(
        find.byType(Column), matchesGoldenFile('address_widget.png'));
  });
}
