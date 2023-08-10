// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:test/test.dart';
import 'package:wallet/wallet.dart';
import 'dart:math';
import 'dart:io';

void main() async {
  Directory dir = Directory.current;

  test('Get new address', () async {
    var wallet = Wallet(
        Random().nextInt(9999).toString(),
        Network.Testnet,
        "wpkh([5d14cd2a/84h/1h/0h]tpubDCWhawC5a8Rgx6y7rk5qHtueax2MVWfdfobzEcmcSvQUDYq94dnqyx6KAFbxCocxQnnLuFcRYFWmvXS9DtWRYqJeU33pcvsam9AaozJXS1P/0/*)",
        "wpkh([5d14cd2a/84h/1h/0h]tpubDCWhawC5a8Rgx6y7rk5qHtueax2MVWfdfobzEcmcSvQUDYq94dnqyx6KAFbxCocxQnnLuFcRYFWmvXS9DtWRYqJeU33pcvsam9AaozJXS1P/1/*)")
      ..init(dir.path);

    var address = await wallet.getAddress();
    expect(address, "tb1qghhpvphu6rd6ygwuurw3p9cg7se84taj2vssdu");

    var address2 = await wallet.getAddress();
    expect(address2, "tb1q79crajpg7y838vmqngerx6eqv5tuytzlk7cx3n");
  });

  test('Get new change address', () async {
    var wallet = Wallet(
        Random().nextInt(9999).toString(),
        Network.Testnet,
        "wpkh([5d14cd2a/84h/1h/0h]tpubDCWhawC5a8Rgx6y7rk5qHtueax2MVWfdfobzEcmcSvQUDYq94dnqyx6KAFbxCocxQnnLuFcRYFWmvXS9DtWRYqJeU33pcvsam9AaozJXS1P/0/*)",
        "wpkh([5d14cd2a/84h/1h/0h]tpubDCWhawC5a8Rgx6y7rk5qHtueax2MVWfdfobzEcmcSvQUDYq94dnqyx6KAFbxCocxQnnLuFcRYFWmvXS9DtWRYqJeU33pcvsam9AaozJXS1P/1/*)")
      ..init(dir.path);

    var address = await wallet.getChangeAddress();
    expect(address, "tb1qha9pfdu5cpdr6xhdceavwegdwar4py46qqspz3");

    var address2 = await wallet.getChangeAddress();
    expect(address2, "tb1qhmlys6r70dc52capnhuke0rznnk5rsjvzvupec");
  });

  test('Decode PSBT', () async {
    var wallet = Wallet(
        Random().nextInt(9999).toString(),
        Network.Testnet,
        "wpkh([5d14cd2a/84h/1h/0h]tpubDCWhawC5a8Rgx6y7rk5qHtueax2MVWfdfobzEcmcSvQUDYq94dnqyx6KAFbxCocxQnnLuFcRYFWmvXS9DtWRYqJeU33pcvsam9AaozJXS1P/0/*)",
        "wpkh([5d14cd2a/84h/1h/0h]tpubDCWhawC5a8Rgx6y7rk5qHtueax2MVWfdfobzEcmcSvQUDYq94dnqyx6KAFbxCocxQnnLuFcRYFWmvXS9DtWRYqJeU33pcvsam9AaozJXS1P/1/*)")
      ..init(dir.path);

    var psbt =
        "cHNidP8BAHEBAAAAAQU2MK4mbnsx/zjbmKwHGUAMVT1zXRFTPBArkMACRZjxAQAAAAD9////AhAnAAAAAAAAFgAU/52lZ+YvMOqGVPodX71HvvjjvhP7FQEAAAAAABYAFKqBwKFeT43famR0JJGaAhoMZKrXAAAAAAABAN4BAAAAAAEBArVvNyXe4TvWObt2vPpIv4IJPeFG1hRK8RtTgzVx3MEAAAAAAP3///8CECcAAAAAAAAWABT/naVn5i8w6oZU+h1fvUe++OO+E+ZAAQAAAAAAFgAUvv5IaH57cUVjoZ35bLxinO1BwkwCRzBEAiABTG7xfKRyZF2ezFCByBLSMGTA2FXYpMN881YXQZB/TgIgbU/OqbuWbe4KhWnjKeglVbnkko70H6glFe/zoo069fUBIQIeb6icGFSB9miQOCV9IMVmJdbEkXG8Hi86LaEyJRa5swAAAAABAR/mQAEAAAAAABYAFL7+SGh+e3FFY6Gd+Wy8YpztQcJMIgICZNLhaTjDm6k30vM/U2+d1TKQ02pk3MFxixFp4EQN1G5IMEUCIQCYRpRlO8YiUXZHLRYmS7fxhgCCDtYRVJ7Tb1rVOKqsHAIgcAeg6Dh8l2N9cixRUyCKwe0jWC9Xc7lNMrxJnDnlmN8BAQMEAQAAACIGAmTS4Wk4w5upN9LzP1NvndUykNNqZNzBcYsRaeBEDdRuGCrNFF1UAACAAQAAgAAAAIABAAAAAQAAAAAAIgIDRcB4bLvY45WvIPqto3nRP4nAQm1FHeIBWcqo2UiIHYoYKs0UXVQAAIABAACAAAAAgAEAAAACAAAAAA==";

    var decoded = await wallet.decodePsbt(psbt);

    expect(decoded.rawTx,
        "01000000000101053630ae266e7b31ff38db98ac0719400c553d735d11533c102b90c0024598f10100000000fdffffff021027000000000000160014ff9da567e62f30ea8654fa1d5fbd47bef8e3be13fb15010000000000160014aa81c0a15e4f8ddf6a647424919a021a0c64aad702483045022100984694653bc6225176472d16264bb7f18600820ed611549ed36f5ad538aaac1c02207007a0e8387c97637d722c5153208ac1ed23582f5773b94d32bc499c39e598df01210264d2e16938c39ba937d2f33f536f9dd53290d36a64dcc1718b1169e0440dd46e00000000");
  });

  test('Broadcast TX', () async {
    // var tx =
    //     "010000000102b56f3725dee13bd639bb76bcfa48bf82093de146d6144af11b53833571dcc10000000000fdffffff02ff43010000000000160014befe48687e7b714563a19df96cbc629ced41c24c1027000000000000160014ff9da567e62f30ea8654fa1d5fbd47bef8e3be1300000000";
    // var electrum = "tcp://137.184.134.236:50001";
    // var torPort = -1;
    //
    // var txid = await wallet.broadcastTx(electrum, torPort, tx);
    // expect(txid,
    //     "010000000102b56f3725dee13bd639bb76bcfa48bf82093de146d6144af11b53833571dcc10000000000fdffffff0288130000000000001976a914344a0f48ca150ec2b903817660b9b68b13a6702688ac705e010000000000160014befe48687e7b714563a19df96cbc629ced41c24c00000000");
  });

  test('Validate address', () async {
    var wallet = Wallet(
        Random().nextInt(9999).toString(),
        Network.Testnet,
        "wpkh([5d14cd2a/84h/1h/0h]tpubDCWhawC5a8Rgx6y7rk5qHtueax2MVWfdfobzEcmcSvQUDYq94dnqyx6KAFbxCocxQnnLuFcRYFWmvXS9DtWRYqJeU33pcvsam9AaozJXS1P/0/*)",
        "wpkh([5d14cd2a/84h/1h/0h]tpubDCWhawC5a8Rgx6y7rk5qHtueax2MVWfdfobzEcmcSvQUDYq94dnqyx6KAFbxCocxQnnLuFcRYFWmvXS9DtWRYqJeU33pcvsam9AaozJXS1P/1/*)")
      ..init(dir.path);

    expect(
        await wallet
            .validateAddress("tb1qghhpvphu6rd6ygwuurw3p9cg7se84taj2vssdu"),
        true);
    expect(
        await wallet
            .validateAddress("tb1q79crajpg7y838vmqngerx6eqv5tuytzlk7cx3n"),
        true);

    wallet = Wallet(
        Random().nextInt(9999).toString(),
        Network.Mainnet,
        "wpkh([5d14cd2a/84h/1h/0h]xpub6DQrFKWSTE7e13Juxx8La4iAmAvdUjVGhaqNLSNqgVGkCWmtjt76YFmWsT4XYFaZAYCLWebNXHPCNkbC6Z4y3n3rPHra7CF35bLN8M4FzbQ/0/*)",
        "wpkh([5d14cd2a/84h/1h/0h]xpub6DQrFKWSTE7e13Juxx8La4iAmAvdUjVGhaqNLSNqgVGkCWmtjt76YFmWsT4XYFaZAYCLWebNXHPCNkbC6Z4y3n3rPHra7CF35bLN8M4FzbQ/1/*)")
      ..init(dir.path);

    expect(await wallet.validateAddress("3FZbgi29cpjq2GjdwV8eyHuJJnkLtktZc5"),
        true);
    expect(await wallet.validateAddress("3FZbgi29cpjq2GjdwV8eyHuJJnkLtktZc4"),
        false);
  });

  test('Sign PSBT', () {
    var psbt =
        "cHNidP8BAHEBAAAAAQK1bzcl3uE71jm7drz6SL+CCT3hRtYUSvEbU4M1cdzBAAAAAAD9////AhAnAAAAAAAAFgAU/52lZ+YvMOqGVPodX71HvvjjvhPmQAEAAAAAABYAFL7+SGh+e3FFY6Gd+Wy8YpztQcJMAAAAAAABAOEBAAAAAAEB9zfXG8unF1K1XTWR6B/T8F/foZlQQbanqokdrjpikBYBAAAAAP3///8CiHIBAAAAAAAWABS/ShS3lMBaPRrtxnrHZQ13R1CSuogTAAAAAAAAGXapFDRKD0jKFQ7CuQOBdmC5tosTpnAmiKwCRzBEAiB2srsoiwSe74VankPLjqBml4asVBJqlE8E7fWbGTjcygIga1hT2F4OFdhI+GzI4st1zoWktKekffu8P7DaPlsTWrgBIQIxvgkaqjPEtQ11V4ioUhBxlIn7YpbaW+sgIi4Z/npkDgAAAAABAR+IcgEAAAAAABYAFL9KFLeUwFo9Gu3GesdlDXdHUJK6IgICHm+onBhUgfZokDglfSDFZiXWxJFxvB4vOi2hMiUWubNHMEQCIAFMbvF8pHJkXZ7MUIHIEtIwZMDYVdikw3zzVhdBkH9OAiBtT86pu5Zt7gqFaeMp6CVVueSSjvQfqCUV7/OijTr19QEBAwQBAAAAIgYCHm+onBhUgfZokDglfSDFZiXWxJFxvB4vOi2hMiUWubMYKs0UXVQAAIABAACAAAAAgAEAAAAAAAAAAAAiAgJk0uFpOMObqTfS8z9Tb53VMpDTamTcwXGLEWngRA3UbhgqzRRdVAAAgAEAAIAAAACAAQAAAAEAAAAA";

    var tx = Wallet.signOffline(
        psbt,
        "wpkh([5d14cd2a/84h/1h/0h]tpubDCWhawC5a8Rgx6y7rk5qHtueax2MVWfdfobzEcmcSvQUDYq94dnqyx6KAFbxCocxQnnLuFcRYFWmvXS9DtWRYqJeU33pcvsam9AaozJXS1P/0/*)",
        "wpkh([5d14cd2a/84h/1h/0h]tpubDCWhawC5a8Rgx6y7rk5qHtueax2MVWfdfobzEcmcSvQUDYq94dnqyx6KAFbxCocxQnnLuFcRYFWmvXS9DtWRYqJeU33pcvsam9AaozJXS1P/1/*)",
        true);

    expect(tx,
        "010000000102b56f3725dee13bd639bb76bcfa48bf82093de146d6144af11b53833571dcc10000000000fdffffff021027000000000000160014ff9da567e62f30ea8654fa1d5fbd47bef8e3be13e640010000000000160014befe48687e7b714563a19df96cbc629ced41c24c00000000");
  });

  test('Generate seed', () {
    String seed = Wallet.generateSeed();

    final List words = seed.split(" ");

    expect(words.length, 12);
  });

  test('Validate seed', () {
    expect(
        Wallet.validateSeed(
            "copper december enlist body dove discover cross help evidence fall rich clean"),
        true);

    // 24 words is a-ok
    expect(
        Wallet.validateSeed(
            "elite awkward put dust evidence follow sting decade barrel distance august verify intact hope away drastic vendor question clarify online absent world news crucial"),
        true);

    // We don't support any other language than English for now
    expect(
        Wallet.validateSeed(
            "のこる　しもん　よそう　ひつよう　てまえ　げきか　くさき　ぬらす　おきる　けたば　きこく　いがい"),
        false);
  });

  test('Get derived private wallet address', () async {
    final seed =
        "copper december enlist body dove discover cross help evidence fall rich clean";
    final path = "m/84'/0'/0'";

    var walletsDir =
        dir.path + "/test_wallets_" + Random().nextInt(9999).toString() + "/";

    var wallet1 = Wallet.deriveWallet(seed, path, walletsDir, Network.Mainnet,
        privateKey: true);

    var address1 = await wallet1.getAddress();
    expect(address1.contains("bc1"), true);

    var wallet2 = Wallet.deriveWallet(seed, path, walletsDir, Network.Mainnet,
        privateKey: true, passphrase: "yolo");

    var address2 = await wallet2.getAddress();
    expect(address2.contains("bc1"), true);
    expect(address1 == address2, false);
  });

  test('Get derived testnet wallet address', () async {
    final seed =
        "copper december enlist body dove discover cross help evidence fall rich clean";
    final path = "m/84'/0'/0'";

    var walletsDir =
        dir.path + "/test_wallets_" + Random().nextInt(9999).toString() + "/";

    var wallet = Wallet.deriveWallet(seed, path, walletsDir, Network.Testnet,
        privateKey: true);

    var address = await wallet.getAddress();

    expect(address.contains("tb1"), true);
  });

  test('Derive public wallet from seed and path', () async {
    final seed =
        "copper december enlist body dove discover cross help evidence fall rich clean";
    final path = "m/84'/0'/0'";

    var walletsDir =
        dir.path + "/test_wallets_" + Random().nextInt(9999).toString() + "/";

    var wallet = Wallet.deriveWallet(seed, path, walletsDir, Network.Mainnet,
        privateKey: false);
    expect(wallet.internalDescriptor!.contains("xpub"), true);
  });

  test('Derive private wallet from seed and path', () async {
    final seed =
        "copper december enlist body dove discover cross help evidence fall rich clean";
    final path = "m/84'/0'/0'";

    var walletsDir =
        dir.path + "/test_wallets_" + Random().nextInt(9999).toString() + "/";

    var wallet = Wallet.deriveWallet(seed, path, walletsDir, Network.Mainnet,
        privateKey: true);
    expect(wallet.internalDescriptor!.contains("xprv"), true);
  });
}
