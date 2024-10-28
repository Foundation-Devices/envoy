// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// ignore_for_file: constant_identifier_names
import 'dart:ui';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/list_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:envoy/business/local_storage.dart';
import 'dart:convert';
import 'package:envoy/util/color_serializer.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/business/account_manager.dart';

part 'devices.g.dart';

enum DeviceType { passportGen1, passportGen12, passportGen2 }

@JsonSerializable()
class Device {
  String name;
  final DeviceType type;
  final String serial;
  final DateTime datePaired;
  String firmwareVersion;
  List<String>? pairedAccountIds;

  @JsonKey(toJson: colorToJson, fromJson: colorFromJson)
  final Color color;

  Device(this.name, this.type, this.serial, this.datePaired,
      this.firmwareVersion, this.color);

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

  static Future<Devices> init() async {
    var singleton = Devices._instance;
    return singleton;
  }

  Devices._internal() {
    kPrint("Instance of Devices created!");
    //_clearDevices();
    restore();
  }

  add(Device device) {
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
  _clearDevices() {
    _ls.prefs.remove(DEVICES_PREFS);
  }

  storeDevices() {
    String json = jsonEncode(devices);
    _ls.prefs.setString(DEVICES_PREFS, json);
  }

  restore() {
    devices.clear();

    if (_ls.prefs.containsKey(DEVICES_PREFS)) {
      var storedDevices = jsonDecode(_ls.prefs.getString(DEVICES_PREFS)!);
      for (var device in storedDevices) {
        devices.add(Device.fromJson(device));
      }
    }
  }

  renameDevice(Device device, String newName) {
    device.name = newName;
    storeDevices();
    notifyListeners();
  }

  markDeviceUpdated(int deviceId, String firmwareVersion) {
    for (var device in devices) {
      if (deviceId == device.type.index) {
        device.firmwareVersion = firmwareVersion;
      }
    }

    storeDevices();
    notifyListeners();
  }

  deleteDevice(Device device) {
    // Delete connected accounts
    AccountManager().deleteDeviceAccounts(device);

    devices.remove(device);
    storeDevices();
    notifyListeners();
  }

  getDeviceName(String serialNumber) {
    if (serialNumber == "envoy") {
      return S().accounts_screen_walletType_Envoy;
    }
    //TODO: for demo
    if (serialNumber == "prime") {
      return "Passport Prime";
    }

    return devices.firstWhere((d) => d.serial == serialNumber).name;
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
}
