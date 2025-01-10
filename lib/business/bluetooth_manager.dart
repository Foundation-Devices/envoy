// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'package:envoy/util/console.dart';
import 'package:bluart/bluart.dart' as bluart;

import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_value.dart';
import 'package:foundation_api/foundation_api.dart' as api;

class BluetoothManager {
  static final BluetoothManager _instance = BluetoothManager._internal();
  UuidValue rxCharacteristic =
      UuidValue.fromString("6E400002B5A3F393E0A9E50E24DCCA9E");

  factory BluetoothManager() {
    return _instance;
  }

  static Future<BluetoothManager> init() async {
    var singleton = BluetoothManager._instance;
    await bluart.RustLib.init();
    await bluart.init();

    await api.RustLib.init();
    return singleton;
  }

  BluetoothManager._internal() {
    kPrint("Instance of BluetoothManager created!");
  }

  void getPermissions() {
    Permission.bluetooth.request();
    Permission.bluetoothConnect.request();

    // TODO: remove this
    // Envoy will be getting the BT addresses via QR
    Permission.bluetoothScan.request();
  }

  void scan() {
    bluart.scan(filter: [""]);
  }
}
