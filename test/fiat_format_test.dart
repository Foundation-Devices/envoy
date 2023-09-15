// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

void main() {
  test("Test formatting when USD selected on en_US locale", () async {
    // e.g.
    // USD -- hr_HR --> 9.5 --> "9,50$"
    // EUR -- hr_HR --> 9.5 --> "9,50€"
    // EUR -- en_IE --> 9.5 --> "€9.50"

    var formater = NumberFormat.currency(
      locale: "en_US",
      symbol: '\$',
      decimalDigits: 2,
    );

    var formatedFiat = formater.format(9.5);

    String expectedString = "\$9.50";

    expect(formatedFiat, expectedString);
  });
  test("Test formatting locale hr_HR with removing non breaking space",
      () async {
    var formater =
        NumberFormat.currency(locale: "hr_HR", decimalDigits: 2, symbol: "");

    const int $nbsp = 0x00A0;

    var formatedFiat =
        formater.format(9.5).replaceAll(String.fromCharCode($nbsp), "");
    expect(formatedFiat, "9,50");
  });
}
