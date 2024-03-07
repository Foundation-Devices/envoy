// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/btcpay_voucher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("get id from url", () async {
    String qrCode =
        "https://btcpay.foundationdevices.com/pull-payments/mZqpn42kWsHtKcSp9REAEvKq3RH";
    BtcPayVoucher btcpayVoucher = BtcPayVoucher(qrCode);

    expect(btcpayVoucher.id, "mZqpn42kWsHtKcSp9REAEvKq3RH");
  });

  test("Test is QR voucher", () {
    String qrCode =
        "https://btcpay.foundationdevices.com/pull-payments/mZqpn42kWsHtKcSp9REAEvKq3RH";
    expect(BtcPayVoucher.isVoucher(qrCode), true);
  });
  test("Test is not QR Btcpay voucher", () {
    String qrCode = "https://azte.co/?c1=1111&c2=2222&c3=3333&c4=4444";
    expect(BtcPayVoucher.isVoucher(qrCode), false);
  });
}
