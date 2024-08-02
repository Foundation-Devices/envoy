// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'package:envoy/util/console.dart';
import 'package:bluart/src/rust/frb_generated.dart';
import 'package:bluart/src/rust/api/bluart.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_value.dart';
import 'package:foundation_api/src/rust/api/api.dart' as api;

class BluetoothManager {
  static final BluetoothManager _instance = BluetoothManager._internal();
  Adapter? adapter;
  List<BluartPeripheral> peripherals = [];
  BluartPeripheral? connected;

  UuidValue rxCharacteristic =
      UuidValue.fromString("6E400002B5A3F393E0A9E50E24DCCA9E");

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

  Future<bool> connectToPrime() async {
    for (final peripheral in peripherals) {
      final name = await getNameFromPerihperal(peripheral: peripheral);
      print("Found $name");
      if (name.contains("Prime")) {
        await connectPeripheral(peripheral: peripheral);
        connected = peripheral;
        return true;
      }
    }
    return false;
  }

  Future<bool> sayHello() async {
    if (connected == null) {
      return false;
    }

    String hello = "HELLO PRIME";
    await writeTo(
        peripheral: connected!,
        data: hello.codeUnits,
        rxCharacteristic: rxCharacteristic);

    return true;
  }

  scan() async {
    try {
      // Ensure adapter is initialized
      adapter ??= await firstAdapter();
      List<BluartPeripheral> result =
          await getPeripherals(adapter: adapter!, tcpPorts: ["127.0.0.1:9090"]);

      peripherals = result;
    } catch (e) {
      print('Error searching for devices: $e');
    }
  }

  pair(String scannedQr) async {
    // get binary pairing envelope and send
    final data = await api.pair(discoveryQr: scannedQr);

    print("data to transmit: ${data.length}");
    await writeTo(
        peripheral: connected!,
        data: data,
        rxCharacteristic: rxCharacteristic);
  }


}
