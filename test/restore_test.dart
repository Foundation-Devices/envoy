// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';

import 'package:envoy/business/envoy_seed.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast/utils/sembast_import_export.dart';
import 'package:test/test.dart';

void main() {
  test('Migrate old SharedPreferences backups to sembast format', () async {
    Map<String, String> backupData = {
      "settings":
          r'{"displayUnit":"btc","selectedFiat":null,"environment":"production","selectedElectrumAddress":"ssl://mainnet.foundation.xyz:50002","usingDefaultElectrumServer":true,"usingTor":true,"nguServerAddress":"https://ngu.foundation.xyz","syncToCloudSetting":true,"allowScreenshotsSetting":false,"showTestnetAccountsSetting":false}',
      "accounts":
          r'[{"wallet":{"name":"1ff2deeb-mainnet","externalDescriptor":null,"internalDescriptor":null,"publicExternalDescriptor":null,"publicInternalDescriptor":null,"network":"Mainnet","hot":true,"hasPassphrase":false,"transactions":[],"balance":0,"feeRateFast":0.0002324,"feeRateSlow":0.00006462},"name":"Mobile Wallet","deviceSerial":"envoy","dateAdded":"2023-08-10T15:31:53.873958","number":0,"id":"22f0858f-dac0-4866-a8df-c13c7a40e3f2","dateSynced":"2023-08-10T15:42:11.114186"},{"wallet":{"name":"1ff2deeb-testnet","externalDescriptor":null,"internalDescriptor":null,"publicExternalDescriptor":null,"publicInternalDescriptor":null,"network":"Testnet","hot":true,"hasPassphrase":false,"transactions":[],"balance":0,"feeRateFast":0.00001,"feeRateSlow":0.00001},"name":"Mobile Wallet","deviceSerial":"envoy","dateAdded":"2023-08-10T15:31:53.874254","number":0,"id":"0dc4df2b-6134-4b70-823f-367b627d5b26","dateSynced":"2023-08-10T15:42:00.788479"}]',
      "envoy.db":
          r'{"sembast_export":1,"version":2,"stores":[{"name":"firmware","keys":[0,1],"values":[{"version":"v2.1.2","path":"v2.1.2-founders-passport.bin"},{"version":"v2.1.2","path":"v2.1.2-passport.bin"}]}]}'
    };

    EnvoySeed.migrateFromSharedPreferences(backupData);
    expect(backupData["envoy.db"]?.contains("1ff2deeb-mainnet"), true);

    await importDatabase(
        jsonDecode(backupData["envoy.db"]!), databaseFactoryIo, "./test.db");
  });
}
