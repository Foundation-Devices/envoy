// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:test/test.dart';
import 'package:wallet/wallet.dart';
import 'dart:math';
import 'package:path_provider/path_provider.dart';

void main() async {
  test('Get new address', () async {
    var dir = await getApplicationDocumentsDirectory();
    var wallet = Wallet(
        Random().nextInt(9999).toString(),
        true,
        "wpkh([5d14cd2a/84h/1h/0h]tpubDCWhawC5a8Rgx6y7rk5qHtueax2MVWfdfobzEcmcSvQUDYq94dnqyx6KAFbxCocxQnnLuFcRYFWmvXS9DtWRYqJeU33pcvsam9AaozJXS1P/0/*)",
        "wpkh([5d14cd2a/84h/1h/0h]tpubDCWhawC5a8Rgx6y7rk5qHtueax2MVWfdfobzEcmcSvQUDYq94dnqyx6KAFbxCocxQnnLuFcRYFWmvXS9DtWRYqJeU33pcvsam9AaozJXS1P/1/*)")
      ..init(dir.path);

    var address = await wallet.getAddress();
    expect(address, "tb1qghhpvphu6rd6ygwuurw3p9cg7se84taj2vssdu");

    var address2 = await wallet.getAddress();
    expect(address2, "tb1q79crajpg7y838vmqngerx6eqv5tuytzlk7cx3n");
  });

  test('Decode PSBT', () async {
    var dir = await getApplicationDocumentsDirectory();
    var wallet = Wallet(
        Random().nextInt(9999).toString(),
        true,
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

  test('Validate address', () {
    expect(Wallet.validateAddress("tb1qghhpvphu6rd6ygwuurw3p9cg7se84taj2vssdu"),
        true);
    expect(Wallet.validateAddress("tb1q79crajpg7y838vmqngerx6eqv5tuytzlk7cx3n"),
        true);
    expect(Wallet.validateAddress("3FZbgi29cpjq2GjdwV8eyHuJJnkLtktZc5"), true);
    expect(Wallet.validateAddress("3FZbgi29cpjq2GjdwV8eyHuJJnkLtktZc4"), false);
  });
}
