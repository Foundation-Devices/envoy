// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// ignore_for_file: constant_identifier_names
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:envoy/account/accounts_manager.dart';
import 'package:envoy/ble/bluetooth_manager.dart';
import 'package:envoy/business/local_storage.dart';
import 'package:envoy/channels/bluetooth_channel.dart';
import 'package:envoy/channels/ql_connection.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/util/color_serializer.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:envoy/util/list_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_api/foundation_api.dart' as api;
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
  @JsonKey(defaultValue: "")
  final String peripheralId;
  @JsonKey(defaultValue: false)
  bool onboardingComplete;
  @Uint8ListConverter()
  final Uint8List? xid;

  //type QuantumLinkIdentity
  @Uint8ListConverter()
  final Uint8List? senderXid;
  final DateTime datePaired;
  String firmwareVersion;
  List<String>? pairedAccountIds;
  bool? primeBackupEnabled;

  @JsonKey(toJson: colorToJson, fromJson: colorFromJson)
  final Color color;

  Device(
    this.name,
    this.type,
    this.serial,
    this.datePaired,
    this.firmwareVersion,
    this.color, {
    this.deviceColor = DeviceColor.light,
    this.bleId = "",
    this.peripheralId = "",
    this.xid,
    this.senderXid,
    this.pairedAccountIds,
    this.primeBackupEnabled,
    this.onboardingComplete = false,
  });

  // Serialisation
  factory Device.fromJson(Map<String, dynamic> json) => _$DeviceFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceToJson(this);

  /// Deserialize the stored QuantumLinkIdentity (sender XID)
  Future<api.QuantumLinkIdentity?> getQlIdentity() async {
    if (type != DeviceType.passportPrime) {
      throw UnimplementedError(
        "This method is only supported for Passport Prime devices",
      );
    }
    List<int>? senderXid = this.senderXid?.toList();
    if (senderXid == null) {
      /// Fallback to old storage method for backwards compatibility
      final qlIdentity = await EnvoyStorage().getQuantumLinkIdentity();
      if (qlIdentity == null) return null;
      return qlIdentity;
    }
    final sender = await api.deserializeQlIdentity(data: senderXid.toList());
    QLConnection.debugIdentitiesQuantumLinkIdentity(
      message: "Deserializing QL Identity ",
      identity: sender,
    );
    return sender;
  }

  /// Deserialize the stored XidDocument (recipient XID)
  Future<api.XidDocument?> getXidDocument() async {
    if (type != DeviceType.passportPrime) {
      throw UnimplementedError(
        "This method is only supported for Passport Prime devices",
      );
    }
    if (xid == null) return null;
    final x = await api.deserializeXid(data: xid!.toList());
    QLConnection.debugIdentitiesXidDocument(
      message: "Deserializing  XID ",
      recipient: x,
    );
    return x;
  }

  // //getter for connection associated with this device
  QLConnection qlConnection() {
    if (type != DeviceType.passportPrime) {
      throw UnimplementedError(
        "This method is only supported for Passport Prime devices",
      );
    }
    final id = Platform.isAndroid ? bleId : peripheralId;
    return BluetoothChannel().getDeviceChannel(id);
  }
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
    if (getPrimeDevices.isEmpty) {
      return;
    }
    kPrint("Connecting to primes...");
    final denied = await BluetoothManager.isBluetoothDenied();
    if (denied) {
      kPrint("Bluetooth permissions denied, cannot connect to device ");
      await BluetoothManager().getPermissions();
    }
    if (await BluetoothManager.isBluetoothDenied()) {
      kPrint("Bluetooth permissions still denied, cannot connect to device ");
      return;
    }
    //wait for the bluetooth manager to initialize
    await Future.delayed(const Duration(seconds: 1));
    kPrint("Connecting to ${getPrimeDevices.length} primes");
    BluetoothChannel().resetDeviceChannels();
    for (var device in getPrimeDevices) {
      if (device.bleId.isNotEmpty) {
        final deviceId =
            Platform.isAndroid ? device.bleId : device.peripheralId;

        // 1. Create native BleDevice on platform level and sets-up
        //event-channels and method channels
        await BluetoothChannel().prepareDevice(deviceId);

        await Future.delayed(const Duration(milliseconds: 1500));

        // 2. Create Dart QLConnection - connects to platform BleDevice eventChannel/methodChannel
        final qlConnection = BluetoothChannel().getDeviceChannel(deviceId);

        // 3. Set up XIDs before connection so messages can be decoded
        await qlConnection.reconnect(device);

        // 4. Now initiate BLE connection - events will be received by Dart
        await BluetoothChannel().reconnect(deviceId);
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

  Future add(Device device) async {
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
    await storeDevices();
    notifyListeners();
  }

  //ignore:unused_element
  void _clearDevices() {
    _ls.prefs.remove(DEVICES_PREFS);
  }

  Future storeDevices() async {
    String json = jsonEncode(devices);
    await _ls.prefs.setString(DEVICES_PREFS, json);
  }

  Future restore({bool hasExitingSetup = false}) async {
    if (!hasExitingSetup) {
      devices.clear();
    }

    if (_ls.prefs.containsKey(DEVICES_PREFS)) {
      var storedDevices = jsonDecode(_ls.prefs.getString(DEVICES_PREFS)!);
      for (var deviceData in storedDevices) {
        var newDevice = Device.fromJson(deviceData);

        bool alreadyExists = devices.any((d) => d.serial == newDevice.serial);
        if (!alreadyExists) {
          devices.add(newDevice);
        }
      }
    }
    await storeDevices();
    notifyListeners();
  }

  Future renameDevice(Device device, String newName) async {
    device.name = newName;
    await storeDevices();
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

  Future markPrimeUpdated(String serial, String firmwareVersion) async {
    for (var device in getPrimeDevices) {
      if (serial == device.serial) {
        device.firmwareVersion = firmwareVersion;
      }
    }

    await storeDevices();
    notifyListeners();
  }

  void deleteDevice(Device device) async {
    if (device.type == DeviceType.passportPrime) {
      final qlConnection = device.qlConnection();
      await qlConnection.disconnect();
      qlConnection.dispose();
    }
    // Delete connected accounts
    await NgAccountManager().deleteDeviceAccounts(device);

    devices.remove(device);
    await storeDevices();
    notifyListeners();
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

  Device? getDeviceByBleId(String bleId) {
    return devices.firstWhereOrNull((device) => device.bleId == bleId);
  }

  List<Device> get getPrimeDevices {
    return devices
        .where((device) => device.type == DeviceType.passportPrime)
        .toList();
  }

  Device? getDeviceBySerial(String serialNumber) {
    return devices.firstWhereOrNull((device) => device.serial == serialNumber);
  }

  Future updatePrimeBackupStatus(bool isEnabled, Device targetDevice) async {
    for (var device in devices) {
      if (device.serial == targetDevice.serial &&
          device.type == DeviceType.passportPrime) {
        device.primeBackupEnabled = isEnabled;
        await storeDevices();
        notifyListeners();
        return;
      }
    }
  }

  bool hasNonPrimeDevices() {
    return devices.any((device) => device.type != DeviceType.passportPrime);
  }

  Future<void> markPrimeOnboarded(bool onboarded, Device targetDevice) async {
    for (var device in devices) {
      if (device.type == DeviceType.passportPrime &&
          device.serial == targetDevice.serial) {
        device.onboardingComplete = onboarded;
        await storeDevices();
        notifyListeners();
        return;
      }
    }
  }
}

class Uint8ListConverter implements JsonConverter<Uint8List?, List<dynamic>?> {
  /// Create a new instance of [Uint8ListConverter].
  const Uint8ListConverter();

  @override
  Uint8List? fromJson(List<dynamic>? json) {
    if (json == null) return null;

    try {
      final list = json.map((e) => e as int).toList();
      return Uint8List.fromList(list);
    } catch (e) {
      return null;
    }
  }

  @override
  List<int>? toJson(Uint8List? object) {
    if (object == null) return null;

    return object.toList();
  }
}

final devicesProvider = ChangeNotifierProvider<Devices>((ref) {
  return Devices();
});

// Provider that checks if any Prime device has backup enabled
final primeBackupEnabledProvider = Provider<bool>((ref) {
  final devices = ref.watch(devicesProvider).devices;

  return devices.any(
    (device) =>
        device.type == DeviceType.passportPrime &&
        device.primeBackupEnabled == true,
  );
});
