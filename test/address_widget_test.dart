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
          body: Container(
            height: 600,
            width: 400,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: AddressWidget(
                    address: '3J98t1WpEZ73CNmQviecrnyiWrnqRhWNLy',
                    short: false,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: AddressWidget(
                    address: '3J98t1WpEZ73CNmQviecrnyiWrnqRhWNLy',
                    short: true,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: AddressWidget(
                    address:
                        '3J98t1WpEZ73CNmQviecrnyiWrnqRhWNLy3J98t1WpEZ73CNmQviecrnyiWrnqRhWNLy',
                    short: false,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await expectLater(
        find.byType(Container), matchesGoldenFile('address_widget.png'));
  });
}
