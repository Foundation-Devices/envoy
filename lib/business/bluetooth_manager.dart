// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'package:envoy/util/console.dart';
import 'package:bluart/src/rust/frb_generated.dart';
import 'package:bluart/src/rust/api/bluart.dart';
import 'package:envoy/util/list_utils.dart';
import 'package:uuid/uuid_value.dart';


class BluetoothManager {
  static final BluetoothManager _instance = BluetoothManager._internal();
  BtleplugPlatformAdapter? adapter;
  List<BluartPeripheral> peripherals = [];

  factory BluetoothManager() {
    return _instance;
  }

  static Future<BluetoothManager> init() async {
    var singleton = BluetoothManager._instance;
    await RustLib.init();
    return singleton;
  }

  BluetoothManager._internal() {
    kPrint("Instance of BluetoothManager created!");
  }

  Future<bool> sayHello() async {
    for (final peripheral in peripherals) {
      final name = await getNameFromPerihperal(peripheral: peripheral);
      if (name.contains("Prime")) {
        await connectPeripheral(peripheral: peripheral);
        String hello = "HELLO PRIME";
        var rxCharacteristic =
        UuidValue.fromString("6E400002B5A3F393E0A9E50E24DCCA9E");
        await writeTo(
            peripheral: peripheral,
            data: hello.codeUnits,
            rxCharacteristic: rxCharacteristic);

        return true;
      }
    }
    return false;
}

  scan() async {
    try {
      // Ensure adapter is initialized
      adapter ??= await firstAdapter();
      List<BluartPeripheral> result = await getPeripherals(
          adapter: adapter!,
          tcpPorts: [
            "127.0.0.1:9090"
          ]);

      peripherals = result;
    } catch (e) {
      print('Error searching for devices: $e');
    }
  }
}