// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// ignore_for_file: constant_identifier_names
import 'dart:convert';
import 'dart:ui';

import 'package:envoy/account/accounts_manager.dart';
import 'package:envoy/business/bluetooth_manager.dart';
import 'package:envoy/business/local_storage.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/util/color_serializer.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/list_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'devices.g.dart';

enum DeviceType {
  passportGen1(0),
  passportGen12(1),
  passportPrime(2);

  final int id;

  const DeviceType(this.id);
}

enum DeviceColor { light, dark }

@JsonSerializable()
class Device {
  String name;
  final DeviceType type;
  final DeviceColor deviceColor;
  final String serial;
  @JsonKey(defaultValue: "")
  final String bleId;
  @JsonKey(defaultValue: null)
  final Uint8List? xid;
  final DateTime datePaired;
  String firmwareVersion;
  List<String>? pairedAccountIds;

  @JsonKey(toJson: colorToJson, fromJson: colorFromJson)
  final Color color;

  Device(this.name, this.type, this.serial, this.datePaired,
      this.firmwareVersion, this.color
  ,{this.deviceColor = DeviceColor.light, this.bleId = "", this.xid});

  // Serialisation
  factory Device.fromJson(Map<String, dynamic> json) => _$DeviceFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceToJson(this);
}

class Devices extends ChangeNotifier {
  @override
  // ignore: must_call_super
  void dispose({bool? force}) {
    // prevents riverpods StateNotifierProvider from disposing it
    if (force == true) {
      super.dispose();
    }
  }

  List<Device> devices = [];
  final LocalStorage _ls = LocalStorage();

  static const String DEVICES_PREFS = "devices";
  static final Devices _instance = Devices._internal();

  factory Devices() {
    return _instance;
  }

  //reconnect to all paired primes
  //TODO: fix simultaneous connections
  Future<void> connect() async {
    kPrint("Connecting to primes...");
    if (getPrimeDevices.isEmpty) {
      return;
    }
    await BluetoothManager().getPermissions();
    //wait for the bluetooth manager to initialize
    await Future.delayed(const Duration(seconds: 1));
    kPrint("Connecting to ${getPrimeDevices.length} primes");
    for (var device in getPrimeDevices) {
      if (device.bleId.isNotEmpty) {
        await BluetoothManager().restorePrimeDevice(device.bleId);
        final denied = await BluetoothManager.isBluetoothDenied();
        if (denied) {
          kPrint(
              "Bluetooth permissions denied, cannot connect to device ${device.name}");
          await BluetoothManager().getPermissions();
        }
        //OS will try to reconnect to bonded device automatically,
        //but we call connect to ensure our app connects to it
        await BluetoothManager().connect(id: device.bleId);
      }
    }
  }

  static Future<Devices> init() async {
    var singleton = Devices._instance;
    return singleton;
  }

  Devices._internal() {
    kPrint("Instance of Devices created!");
    //_clearDevices();
    restore();
  }

  void add(Device device) {
    for (var currentDevice in devices) {
      // Don't add if device with same serial already present
      if (currentDevice.serial == device.serial) {
        if (currentDevice.name != device.name) {
          renameDevice(currentDevice, device.name);
        }
        return;
      }
    }

    devices.add(device);
    storeDevices();
    notifyListeners();
  }

  //ignore:unused_element
  void _clearDevices() {
    _ls.prefs.remove(DEVICES_PREFS);
  }

  void storeDevices() {
    String json = jsonEncode(devices);
    _ls.prefs.setString(DEVICES_PREFS, json);
  }

  void restore() {
    devices.clear();

    if (_ls.prefs.containsKey(DEVICES_PREFS)) {
      var storedDevices = jsonDecode(_ls.prefs.getString(DEVICES_PREFS)!);
      for (var device in storedDevices) {
        devices.add(Device.fromJson(device));
      }
    }
  }

  void renameDevice(Device device, String newName) {
    device.name = newName;
    storeDevices();
    notifyListeners();
  }

  void markDeviceUpdated(int deviceId, String firmwareVersion) {
    for (var device in devices) {
      if (deviceId == device.type.index) {
        device.firmwareVersion = firmwareVersion;
      }
    }

    storeDevices();
    notifyListeners();
  }

  void deleteDevice(Device device) {
    // Delete connected accounts
    NgAccountManager().deleteDeviceAccounts(device);

    devices.remove(device);
    storeDevices();
    notifyListeners();

    if (device.type == DeviceType.passportPrime) {
      BluetoothManager().removeConnectedDevice();
    }
  }

  String getDeviceName(String serialNumber) {
    if (serialNumber == "envoy") {
      return S().accounts_screen_walletType_Envoy;
    }

    //TODO: for demo
    if (serialNumber == "prime" || serialNumber.isEmpty) {
      return "Passport Prime";
    }

    final device = devices.firstWhereOrNull((d) => d.serial == serialNumber);
    return device?.name ?? "";
  }

  String? getDeviceFirmwareVersion(String serialNumber) {
    return devices
            .firstWhereOrNull((d) => d.serial == serialNumber)
            ?.firmwareVersion ??
        "";
  }

  Device? getDeviceById(int deviceId) {
    return devices.firstWhereOrNull((device) => device.type.index == deviceId);
  }

  List<Device> get getPrimeDevices {
    return devices
        .where((device) => device.type == DeviceType.passportPrime)
        .toList();
  }

  Device? getDeviceBySerial(String serialNumber) {
    return devices.firstWhereOrNull((device) => device.serial == serialNumber);
  }
}
