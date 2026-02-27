// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:envoy/ble/handlers/fw_update_handler.dart';
import 'package:envoy/business/devices.dart';
import 'package:envoy/channels/ble_status.dart';
import 'package:envoy/channels/bluetooth_channel.dart';
import 'package:envoy/channels/ql_connection.dart';
import 'package:envoy/ui/onboard/prime/state/ble_onboarding_state.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_api/foundation_api.dart' as api;
import 'package:permission_handler/permission_handler.dart';

final bleChunkSize = BigInt.from(51200);

final qlConnectionStreamProvider = StreamProvider<List<QLConnection>>((ref) {
  return BluetoothChannel().deviceChannelsStream;
});

final deviceConnectionStatusStreamProvider =
    StreamProvider.family<DeviceStatus, Device>((ref, device) {
  //watching the device stream to trigger rebuilds when devices change
  ref.watch(qlConnectionStreamProvider);
  return device.qlConnection().deviceStatusStream;
});

final onboardingDeviceConnectionStatusStream =
    StreamProvider<DeviceStatus>((ref) {
  final device = ref.watch(onboardingDeviceProvider);
  //watching the device stream to trigger rebuilds when devices change
  ref.watch(qlConnectionStreamProvider);
  return device?.deviceStatusStream ?? const Stream.empty();
});

final isPrimeConnectedProvider = Provider.family<bool, Device?>((ref, device) {
  if (device?.type != DeviceType.passportPrime) return false;
  if (device == null) return false;
  DeviceStatus? status =
      ref.watch(deviceConnectionStatusStreamProvider(device)).valueOrNull;
  status ??= device.qlConnection().lastDeviceStatus;
  return status.connected;
});

final _qlActiveStreamProvider =
    StreamProvider.family<bool, Device>((ref, device) {
  // Rebuild the stream provider when the underlying QLConnection instance changes
  ref.watch(qlConnectionStreamProvider);
  return device.qlConnection().qlActiveStream;
});

final primeQLActivityProvider = Provider.family<bool, Device?>((ref, device) {
  if (device == null) return false;
  final qlActive = ref.watch(_qlActiveStreamProvider(device)).valueOrNull;
  return qlActive ?? false;
});

final fwTransferProgress = StreamProvider<FwTransferProgress>((ref) {
  final device = ref.watch(onboardingDeviceProvider);
  if (device == null) return const Stream.empty();
  return device.qlHandler.fwUpdateHandler.transferProgress;
});

class BluetoothManager extends WidgetsBindingObserver {
  final _bluetoothChannel = BluetoothChannel();

  static final BluetoothManager _instance = BluetoothManager._internal();

  static int? _cachedApiLevel;

  //only for android Android, IOS uses AccessoryKit so no need to check for permissions.
  static Future<int> _getApiLevel() async {
    _cachedApiLevel ??= await BluetoothChannel().getAPILevel();
    return _cachedApiLevel!;
  }

  factory BluetoothManager() {
    return _instance;
  }

  BluetoothManager._internal() {
    _init();
    kPrint("Instance of BluetoothManager created!");
  }

  Future _init() async {
    await api.RustLib.init();
  }

  static Future<BluetoothManager> init() async {
    return BluetoothManager._instance;
  }

  Future getPermissions() async {
    if (Platform.isAndroid) {
      final apiLevel = await _getApiLevel();
      kPrint("Getting permissions... $apiLevel");
      // On API <= 30, ACCESS_FINE_LOCATION is required for BLE scanning.
      // On API 31+, BLUETOOTH_SCAN is declared with neverForLocation in the
      // manifest, so no location permission is needed.
      if (apiLevel <= 30) {
        await [
          Permission.bluetooth,
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
          Permission.locationWhenInUse,
        ].request();
      } else {
        await [
          Permission.bluetooth,
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
        ].request();
      }
      kPrint("Scanning...");
      bool denied = await isBluetoothDenied();
      if (!denied) {
        kPrint("Bluetooth permissions granted.");
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        Devices().connect();
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.hidden:
    }
  }

  // Check if Bluetooth permissions are denied.
  // iOS uses AccessoryKit so no need to check for permissions.
  static Future<bool> isBluetoothDenied() async {
    if (!Platform.isAndroid) return false;
    final apiLevel = await _getApiLevel();
    final btDenied = await Permission.bluetooth.isDenied ||
        await Permission.bluetoothConnect.isDenied ||
        await Permission.bluetoothScan.isDenied;
    if (btDenied) return true;
    if (apiLevel <= 30) {
      return await Permission.locationWhenInUse.isDenied;
    }
    return false;
  }

  Future<void> reconnect(String id) async {
    await BluetoothChannel().reconnect(id);
  }

  void dispose() {
    _bluetoothChannel.dispose();
  }
}
