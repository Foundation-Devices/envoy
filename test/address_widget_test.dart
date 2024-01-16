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
          body: Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      height: 600,
                      width: 400,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: AddressWidget(
                              address:
                                  'bc1p5d7rjq7g6rdk2yhzks9smlaqtedr4dekq08ge8ztwac72sfr9rusxg3297',
                              short: false,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: AddressWidget(
                              address:
                                  'bc1p5d7rjq7g6rdk2yhzks9smlaqtedr4dekq08ge8ztwac72sfr9rusxg3297',
                              short: true,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: AddressWidget(
                              address:
                                  'bc1p5d7rjq7g6rdk2yhzks9smlaqtedr4dekq08ge8ztwac72sfr9rusxg3297bc1p5d7rjq7g6rdk2yhzks9smlaqtedr4dekq08ge8ztwac72sfr9rusxg3297',
                              short: false,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 600,
                      width: 400,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: AddressWidget(
                              address:
                                  'bc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq',
                              short: false,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: AddressWidget(
                              address:
                                  'bc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq',
                              short: true,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: AddressWidget(
                              address:
                                  'bc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdqbc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq',
                              short: false,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
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
                  Expanded(
                    child: Container(
                      height: 600,
                      width: 400,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: AddressWidget(
                              address: '1BvBMSEYstWetqTFn5Au4m4GFg7xJaNVN2',
                              short: false,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: AddressWidget(
                              address: '1BvBMSEYstWetqTFn5Au4m4GFg7xJaNVN2',
                              short: true,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: AddressWidget(
                              address:
                                  '1BvBMSEYstWetqTFn5Au4m4GFg7xJaNVN21BvBMSEYstWetqTFn5Au4m4GFg7xJaNVN2',
                              short: false,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    await expectLater(
        find.byType(MaterialApp), matchesGoldenFile('address_widget.png'));
  });
}
