// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/util/amount.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("Test converting large amount BTC string to Sats", () async {
    expect(convertBtcStringToSats("9"), 900000000);
  });

  test("Test converting small amount BTC string to Sats", () async {
    expect(convertBtcStringToSats("0.00000009"), 9);
  });

  test("Test converting BTC string with too many digits to Sats", () async {
    expect(convertBtcStringToSats("0.00000003999999999"), 3);
  });
}
