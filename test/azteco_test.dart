// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/azteco_voucher.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("Test create voucher from url", () async {
    String qrCode = "https://azte.co/?c1=8042&c2=3544&c3=4181&c4=5682";
    AztecoVoucher voucher = AztecoVoucher(qrCode);
    expect(voucher.code, ["8042", "3544", "4181", "5682"]);

    String redeemUrl =
        voucher.getRedeemUrl("3H7g6JtnR6LATgdpuYWrRov6tyedam2L7m");

    expect(redeemUrl,
        "https://azte.co/fd_despatch.php?CODE_1=8042&CODE_2=3544&CODE_3=4181&CODE_4=5682&ADDRESS=3H7g6JtnR6LATgdpuYWrRov6tyedam2L7m");
  });

  test("Test is QR voucher", () {
    String qrCode = "https://azte.co/?c1=1111&c2=2222&c3=3333&c4=4444";
    expect(AztecoVoucher.isVoucher(qrCode), true);
  });

  test("Test is not QR voucher", () {
    String qrCode = "https://konzum.hr/?c1=1111&c2=2222&c3=3333&c4=4444";
    expect(AztecoVoucher.isVoucher(qrCode), false);
  });

  test("Test Azteco dummy tx", () async {
    TestWidgetsFlutterBinding.ensureInitialized();

    const MethodChannel channel =
        MethodChannel('plugins.flutter.io/path_provider');
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return ".";
    });

    EnvoyStorage();

    await Future.delayed(Duration(seconds: 1));

    await EnvoyStorage().addAztecoTx("address", "account", DateTime.now());
    var txs = await EnvoyStorage().getAztecoTxs("account");

    expect(txs[0].received, 0);
  });
}
