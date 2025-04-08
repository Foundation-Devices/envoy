// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:ngwallet/src/rust/frb_generated.dart';
import 'package:ngwallet/src/rust/api/simple.dart';

void main() {
  test("Test converting large amount BTC string to Sats", () async {
    await RustLib.init();
    // var wallet = await Wallet.newInstance();
    // final address = await wallet.nextAddress();

    print(address);
  });
}
