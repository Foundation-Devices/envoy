// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/bip21.dart';
import 'package:test/test.dart';

void main() {
  test("Test Bisq QR", () {
    var bisqQrCode =
        "bitcoin:bc1qj9cjncwvsg02fqkjrh7p3umujyvn2a80ty3mwn?amount=0&label=Fund%20Bisq%20wallet&message=test";
    var decoded = Bip21.decode(bisqQrCode);
    expect(decoded.address, "bc1qj9cjncwvsg02fqkjrh7p3umujyvn2a80ty3mwn");
    expect(decoded.label, "Fund Bisq wallet");
    expect(decoded.amount, 0);
    expect(decoded.message, "test");
  });
}
