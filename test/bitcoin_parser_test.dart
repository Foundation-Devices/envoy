// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';
import 'dart:math';
import 'package:envoy/business/bitcoin_parser.dart';
import 'package:envoy/ui/amount_entry.dart';
import 'package:test/test.dart';
import 'package:wallet/wallet.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'bitcoin_parser_test.mocks.dart';

@GenerateMocks([Wallet])
void main() async {
  Directory dir = Directory.current;

  test("Test valid address and amount", () async {
    var pasted =
        "bitcoin:bc1qj9cjncwvsg02fqkjrh7p3umujyvn2a80ty3mwn?amount=5&label=Fund%20Bisq%20wallet";

    var parsed = await BitcoinParser.parse(pasted);
    Future.delayed(Duration(seconds: 2));

    expect(parsed.address, "bc1qj9cjncwvsg02fqkjrh7p3umujyvn2a80ty3mwn");
    expect(parsed.amountSats, 500000000);
    expect(parsed.unit, AmountDisplayUnit.btc);
  });

  test("Test without key word", () async {
    var pasted =
        "bc1qj9cjncwvsg02fqkjrh7p3umujyvn2a80ty3mwn?amount=0&label=Fund%20Bisq%20wallet";

    var parsed = await BitcoinParser.parse(pasted);

    expect(await parsed.address, null);
    expect(await parsed.amountSats, null);
  });

  test("Test string with \$", () async {
    var pasted = "23\$";

    var parsed = await BitcoinParser.parse(pasted,
        fiatExchangeRate: 1, selectedFiat: "USD");

    expect(parsed.address, null);
    expect(parsed.unit, AmountDisplayUnit.fiat);
  });

  test("Test amount with , ", () async {
    var pasted = "23,5";

    var parsed = await BitcoinParser.parse(pasted,
        fiatExchangeRate: 1, selectedFiat: "USD");

    expect(parsed.address, null);
    expect(parsed.unit, AmountDisplayUnit.fiat);
  });

  test("Test small amount", () async {
    var pasted = "0.0008";

    var parsed = await BitcoinParser.parse(pasted);

    expect(parsed.address, null);
    expect(parsed.amountSats, 80000);
    expect(parsed.unit, AmountDisplayUnit.btc);
  });

  test("Test with dot and not enough in wallet", () async {
    var pasted = "1.28";
    final wallet = MockWallet();

    when(wallet.balance).thenReturn(10);
    when(wallet.validateAddress(pasted)).thenAnswer((_) async => false);

    var parsed = await BitcoinParser.parse(pasted,
        fiatExchangeRate: 1, wallet: wallet, selectedFiat: "USD");

    expect(parsed.address, null);
    expect(parsed.unit, AmountDisplayUnit.fiat);
  });

  test("Test negative amount", () async {
    var copied = "-7";
    var decoded = await BitcoinParser.parse(copied);

    expect(decoded.address, null);
    expect(decoded.amountSats, null);
    expect(decoded.unit, null);
  });

  test("Test rounded amount", () async {
    var copied = "7";

    var decoded = await BitcoinParser.parse(copied);

    expect(decoded.address, null);
    expect(decoded.amountSats, 7);
    expect(decoded.unit, AmountDisplayUnit.sat);
  });

  test("Test amount with dot and enough in wallet ", () async {
    var pasted = "0.05";

    final wallet = MockWallet();

    when(wallet.balance).thenReturn(10000000);
    when(wallet.validateAddress(pasted)).thenAnswer((_) async => false);

    var parsed =
        await BitcoinParser.parse(pasted, fiatExchangeRate: 1, wallet: wallet);

    expect(parsed.address, null);
    expect(parsed.amountSats, 5000000);
    expect(parsed.unit, AmountDisplayUnit.btc);
  });

  test("Test amount with dot and not enough in wallet", () async {
    var pasted = "0.05";

    final wallet = MockWallet();

    when(wallet.balance).thenReturn(10);
    when(wallet.validateAddress(pasted)).thenAnswer((_) async => false);

    var parsed = await BitcoinParser.parse(pasted,
        fiatExchangeRate: 1, wallet: wallet, selectedFiat: "USD");

    expect(parsed.address, null);
    expect(parsed.unit, AmountDisplayUnit.fiat);
  });
  test("Test amount with comma and not enough in wallet", () async {
    var pasted = "0,05";

    var parsed = await BitcoinParser.parse(pasted,
        fiatExchangeRate: 1, selectedFiat: "USD");

    expect(parsed.address, null);
    expect(parsed.unit, AmountDisplayUnit.fiat);
  });

  test("Test string with \$ and comma", () async {
    var pasted = "23,2\$";

    var parsed = await BitcoinParser.parse(pasted,
        fiatExchangeRate: 1, selectedFiat: "USD");

    expect(parsed.address, null);
    expect(parsed.amountSats, 2320000000);
    expect(parsed.unit, AmountDisplayUnit.fiat);
  });
  test("Test string with \$ and dot", () async {
    var pasted = "1.22\$";

    var parsed = await BitcoinParser.parse(pasted,
        fiatExchangeRate: 1, selectedFiat: "USD");

    expect(parsed.address, null);
    expect(parsed.unit, AmountDisplayUnit.fiat);
  });

  test("Test only address", () async {
    var pasted = "bc1qj9cjncwvsg02fqkjrh7p3umujyvn2a80ty3mwn";
    Wallet wallet = getWallet(dir);

    var parsed =
        await BitcoinParser.parse(pasted, fiatExchangeRate: 1, wallet: wallet);

    expect(parsed.address, "bc1qj9cjncwvsg02fqkjrh7p3umujyvn2a80ty3mwn");
    expect(parsed.unit, null);
  });

  test("Test string with \$ and fiat is not selected", () async {
    var pasted = "1.22\$";

    var parsed = await BitcoinParser.parse(pasted,
        fiatExchangeRate: 1, selectedFiat: null);

    expect(parsed.address, null);
    expect(parsed.unit, null);
  });

  test("Test string with dot and fiat is not selected", () async {
    var pasted = "1.22";

    var parsed = await BitcoinParser.parse(pasted,
        fiatExchangeRate: 1, selectedFiat: null);

    expect(parsed.address, null);
    expect(parsed.amountSats, 122000000);
    expect(parsed.unit, AmountDisplayUnit.btc);
  });
}

Wallet getWallet(Directory dir) {
  final seed =
      "copper december enlist body dove discover cross help evidence fall rich clean";
  final path = "m/84'/0'/0'";

  var walletsDir =
      dir.path + "/test_wallets_" + Random().nextInt(9999).toString() + "/";

  var wallet = Wallet.deriveWallet(seed, path, walletsDir, Network.Mainnet,
      privateKey: false, initWallet: true);
  return wallet;
}
