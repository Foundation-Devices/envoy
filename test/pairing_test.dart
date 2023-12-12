// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';

import 'package:envoy/business/account.dart';
import 'package:envoy/business/account_manager.dart';
import 'package:envoy/business/local_storage.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/wallet.dart';

void main() async {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    const MethodChannel channel =
        MethodChannel('plugins.flutter.io/path_provider');

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return ".";
    });

    LocalStorage.init();
    EnvoyStorage();
    EnvoyStorage().init();

    await Future.delayed(Duration(seconds: 1));
  });

  test('Taproot pairing test', () async {
    String payload =
        '{"acct_name": "Primary", "acct_num": 0, "fw_version": "v2.3.0b2", "bip84": {"derivation": "m/84\'/0\'/0\'", "xpub": "xpub6DSVbgAYYafWnxj7S58sdcuqLDiDtD3sWTN1eWgH8J3V11BajGSDWr1mHY7Cw1LNLCz8WAW16L1SZ3hJs45CvB31RjkNa7XrK8SpeEYSNKZ", "xfp": 808196535}, "bip86": {"derivation": "m/86\'/0\'/0\'", "xpub": "xpub6Bn4NJb2qKkQUfHhWkRkvfVxDLxfcBcBBqBM4inCyt6tjH7iFmWcAcyDi4GC9ppYPvWPfppYTwQ9pJieVrd6NL27tHXprXeNSuWDdS7XovD", "xfp": 808196535}, "serial": "3BAB-1BE4-5780-FC98", "device_name": "", "hw_version": 1.2}';
    var json = jsonDecode(payload);

    List<Account> accounts =
        await AccountManager.getPassportAccountsFromJson(json);

    // Try are supposed to have same name initially
    expect(accounts[0].name, accounts[1].name);

    // Paired from same device
    expect(accounts[0].deviceSerial, accounts[1].deviceSerial);

    // First one always PKWH
    expect(accounts[0].wallet.type, WalletType.witnessPublicKeyHash);

    // And Taproot
    expect(accounts[1].wallet.type, WalletType.taproot);
  });
}
