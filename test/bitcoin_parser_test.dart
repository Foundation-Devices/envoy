// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

// ignore_for_file: depend_on_referenced_packages
import 'dart:io';

import 'package:envoy/business/bitcoin_parser.dart';
import 'package:envoy/ui/amount_entry.dart';
import 'package:ngwallet/ngwallet.dart';
import 'package:test/test.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

void main() async {
  setUpAll(() async => await RustLib.init(
      externalLibrary: ExternalLibrary.open(
          'target/debug/librust_lib_ngwallet.${Platform.isMacOS ? "dylib" : "so"}')));

  test("Test valid address and amount", () async {
    var pasted =
        "bitcoin:bc1qj9cjncwvsg02fqkjrh7p3umujyvn2a80ty3mwn?amount=5&label=Fund%20Bisq%20wallet";

    var parsed = await BitcoinParser.parse(pasted);
    Future.delayed(const Duration(seconds: 2));

    expect(parsed.address, "bc1qj9cjncwvsg02fqkjrh7p3umujyvn2a80ty3mwn");
    expect(parsed.amountSats, 500000000);
    expect(parsed.unit, AmountDisplayUnit.btc);
  });

  test("Test without key word", () async {
    var pasted =
        "bc1qj9cjncwvsg02fqkjrh7p3umujyvn2a80ty3mwn?amount=0&label=Fund%20Bisq%20wallet";

    var parsed = await BitcoinParser.parse(pasted);

    expect(parsed.address, null);
    expect(parsed.amountSats, null);
  });

  test("Test string with \$", () async {
    var pasted = "23\$";

    var parsed = await BitcoinParser.parse(pasted,
        fiatExchangeRate: 1,
        selectedFiat: "USD",
        currentUnit: AmountDisplayUnit.fiat);

    expect(parsed.address, null);
    expect(parsed.unit, AmountDisplayUnit.fiat);
  });

  test("Test amount with , ", () async {
    var pasted = "23,5";

    var parsed = await BitcoinParser.parse(pasted,
        fiatExchangeRate: 1,
        selectedFiat: "USD",
        currentUnit: AmountDisplayUnit.btc);

    expect(parsed.address, null);
    expect(parsed.unit, AmountDisplayUnit.fiat);
  });

  test("Test small amount", () async {
    var pasted = "0.0008";

    var parsed =
        await BitcoinParser.parse(pasted, currentUnit: AmountDisplayUnit.btc);

    expect(parsed.address, null);
    expect(parsed.amountSats, 80000);
    expect(parsed.unit, AmountDisplayUnit.btc);
  });

  test("Test with dot and not enough in wallet", () async {
    var pasted = "1.28";
    var parsed = await BitcoinParser.parse(pasted,
        fiatExchangeRate: 1,
        account: getAccount(balance: 10),
        selectedFiat: "USD",
        currentUnit: AmountDisplayUnit.btc);

    expect(parsed.address, null);
    expect(parsed.unit, AmountDisplayUnit.fiat);
  });

  test("Test negative amount", () async {
    var copied = "-7";
    var decoded =
        await BitcoinParser.parse(copied, currentUnit: AmountDisplayUnit.btc);

    expect(decoded.address, null);
    expect(decoded.amountSats, null);
    expect(decoded.unit, null);
  });

  test("Test rounded amount", () async {
    var copied = "7";

    var decoded =
        await BitcoinParser.parse(copied, currentUnit: AmountDisplayUnit.sat);

    expect(decoded.address, null);
    expect(decoded.amountSats, 7);
    expect(decoded.unit, AmountDisplayUnit.sat);
  });

  test("Test amount with dot and enough in wallet ", () async {
    var pasted = "0.05";
    var parsed = await BitcoinParser.parse(pasted,
        fiatExchangeRate: 1,
        account: getAccount(balance: 10000000),
        currentUnit: AmountDisplayUnit.btc);

    expect(parsed.address, null);
    expect(parsed.amountSats, 5000000);
    expect(parsed.unit, AmountDisplayUnit.btc);
  });

  test("Test amount with dot and not enough in wallet", () async {
    var pasted = "0.05";
    var parsed = await BitcoinParser.parse(pasted,
        fiatExchangeRate: 1,
        account: getAccount(balance: 10),
        selectedFiat: "USD",
        currentUnit: AmountDisplayUnit.fiat);

    expect(parsed.address, null);
    expect(parsed.unit, AmountDisplayUnit.fiat);
  });
  test("Test amount with comma and not enough in wallet", () async {
    var pasted = "0,05";

    var parsed = await BitcoinParser.parse(pasted,
        fiatExchangeRate: 1,
        selectedFiat: "USD",
        currentUnit: AmountDisplayUnit.fiat);

    expect(parsed.address, null);
    expect(parsed.unit, AmountDisplayUnit.fiat);
  });

  test("Test string with \$ and comma", () async {
    var pasted = "23,2\$";

    var parsed = await BitcoinParser.parse(pasted,
        fiatExchangeRate: 1,
        selectedFiat: "USD",
        currentUnit: AmountDisplayUnit.fiat);

    expect(parsed.address, null);
    expect(parsed.amountSats, 2320000000);
    expect(parsed.unit, AmountDisplayUnit.fiat);
  });
  test("Test string with \$ and dot", () async {
    var pasted = "1.22\$";

    var parsed = await BitcoinParser.parse(pasted,
        fiatExchangeRate: 1,
        selectedFiat: "USD",
        currentUnit: AmountDisplayUnit.fiat);

    expect(parsed.address, null);
    expect(parsed.unit, AmountDisplayUnit.fiat);
  });

  test("Test string with \$ and fiat is not selected", () async {
    var pasted = "1.22\$";

    var parsed = await BitcoinParser.parse(pasted,
        fiatExchangeRate: 1,
        selectedFiat: null,
        currentUnit: AmountDisplayUnit.btc);

    expect(parsed.address, null);
    expect(parsed.unit, null);
  });

  test("Test string with dot and fiat is not selected", () async {
    var pasted = "1.22";

    var parsed = await BitcoinParser.parse(pasted,
        fiatExchangeRate: 1,
        selectedFiat: null,
        currentUnit: AmountDisplayUnit.btc);

    expect(parsed.address, null);
    expect(parsed.amountSats, 122000000);
    expect(parsed.unit, AmountDisplayUnit.btc);
  });

  test("test whole number", () async {
    var pasted = "1";

    var parsed = await BitcoinParser.parse(pasted,
        fiatExchangeRate: 1,
        selectedFiat: null,
        currentUnit: AmountDisplayUnit.btc);

    expect(parsed.address, null);
    expect(parsed.amountSats, 100000000);
    expect(parsed.unit, AmountDisplayUnit.btc);
  });

  test("test (pasted > 0.001 && pasted < 1)", () async {
    var pasted = "0.02";

    var parsed = await BitcoinParser.parse(pasted,
        fiatExchangeRate: 1,
        selectedFiat: null,
        currentUnit: AmountDisplayUnit.sat);

    expect(parsed.address, null);
    expect(parsed.amountSats, 2000000);
    expect(parsed.unit, AmountDisplayUnit.btc);
  });

  test("test (num < 21000000)", () async {
    var pasted = "19000000.005";

    var parsed = await BitcoinParser.parse(pasted,
        fiatExchangeRate: 1,
        selectedFiat: null,
        currentUnit: AmountDisplayUnit.sat);

    expect(parsed.address, null);
    expect(parsed.amountSats, 1900000000500000);
    expect(parsed.unit, AmountDisplayUnit.btc);
  });

  test("test (num >= 21000000)", () async {
    var pasted = "21000100";

    var parsed = await BitcoinParser.parse(pasted,
        fiatExchangeRate: 1,
        selectedFiat: null,
        currentUnit: AmountDisplayUnit.sat);

    expect(parsed.address, null);
    expect(parsed.amountSats, 21000100);
    expect(parsed.unit, AmountDisplayUnit.sat);
  });

  test("test (num >= 21000000) - with decimal places", () async {
    var pasted = "21000100.02";

    var parsed = await BitcoinParser.parse(pasted,
        fiatExchangeRate: 1,
        selectedFiat: null,
        currentUnit: AmountDisplayUnit.sat);

    expect(parsed.address, null);
    expect(parsed.amountSats, null);
    expect(parsed.unit, null);
  });
}

EnvoyAccount getAccount({required int balance}) {
  final account = EnvoyAccount(
      name: "name",
      color: "color",
      preferredAddressType: AddressType.p2Sh,
      seedHasPassphrase: true,
      index: 0,
      descriptors: [
        NgDescriptor(internal: "internal", addressType: AddressType.p2Sh)
      ],
      network: Network.bitcoin,
      id: "id",
      nextAddress: [("p2sh", AddressType.p2Sh)],
      balance: BigInt.from(balance),
      unlockedBalance: BigInt.from(0),
      isHot: true,
      transactions: [],
      utxo: [],
      tags: [],
      xfp: "xfp",
      externalPublicDescriptors: [(AddressType.p2Sh, "p2sh")], archived: false);
  return account;
}
