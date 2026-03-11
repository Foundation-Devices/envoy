// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:io';

import 'package:envoy/ble/handlers/fw_update_handler.dart';
import 'package:envoy/ble/quantum_link_router.dart';
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
  // Rebuild the stream provider when the underlying QLConnection instance
  ref.watch(qlConnectionStreamProvider);
  return device.qlConnection().qlActiveStream;
});

final primeQLActivityProvider = Provider.family<bool, Device?>((ref, device) {
  if (device == null) return false;
  final qlActive = ref.watch(_qlActiveStreamProvider(device)).valueOrNull;
  return qlActive ?? false;
});

final connectedDeviceProvider = StreamProvider.family<DeviceStatus, String>((
  ref,
  deviceId,
) {
  final qlConnection = BluetoothChannel().getDeviceChannel(deviceId);
  return qlConnection.deviceStatusStream;
});

final fwTransferProgress = StreamProvider<FwTransferProgress>((ref) {
  final device = ref.watch(onboardingDeviceProvider);
  if (device == null) return const Stream.empty();
  return device.qlHandler.fwUpdateHandler.transferProgress;
});

class BluetoothManager extends WidgetsBindingObserver {
  //holds registered handlers.
  final PassportMessageRouter _messageRouter = PassportMessageRouter();

  static final BluetoothManager _instance = BluetoothManager._internal();

  // Persist this across sessions
  api.QuantumLinkIdentity? _qlIdentity;
  final StreamController<api.PassportMessage> _passportMessageStream =
      StreamController<api.PassportMessage>.broadcast();

  final StreamController<api.QuantumLinkMessage_BroadcastTransaction>
      _transactionStream =
      StreamController<api.QuantumLinkMessage_BroadcastTransaction>.broadcast();

  final StreamController<api.ApplyPassphrase> _passphraseEventStream =
      StreamController<api.ApplyPassphrase>.broadcast();

  //TODO: support multiple devices
  api.XidDocument? _recipientXid;

  factory BluetoothManager() {
    return _instance;
  }

  late final Stream<api.PassportMessage> _broadcastPassportStream =
      _passportMessageStream.stream.asBroadcastStream();

  Stream<api.PassportMessage> get passportMessageStream =>
      _broadcastPassportStream;

  Stream<api.QuantumLinkMessage_BroadcastTransaction> get transactionStream =>
      _transactionStream.stream.asBroadcastStream();

  Stream<api.ApplyPassphrase> get passphraseEventStream =>
      _passphraseEventStream.stream.asBroadcastStream();

  final StreamController<double> _writeProgressController =
      StreamController<double>.broadcast();

  Stream<double> get writeProgressStream => _writeProgressController.stream;

  String bleId = "";

  api.QuantumLinkIdentity? get qlIdentity => _qlIdentity;

  api.XidDocument? get recipientXid => _recipientXid;

  static Future<BluetoothManager> init() async {
    var singleton = BluetoothManager._instance;
    return singleton;
  }

  BluetoothManager._internal() {
    _init();
    kPrint("Instance of BluetoothManager created!");
  }

  Future _init() async {
    await api.RustLib.init();
  }

  PassportMessageRouter getMessageRouter() {
    return _messageRouter;
  }

  Future getPermissions() async {
    if (Platform.isAndroid) {
      // return;
      kPrint(
        "Getting permissions... ${await BluetoothChannel().getAPILevel()}",
      );
      // Envoy will be getting the BT addresses via QR
      // so we don't need location permission for scanning on Android 10 and below
      if (await BluetoothChannel().getAPILevel() <= 31) {
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
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
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

  // Check if Bluetooth permissions are denied
  // IOS uses AccessoryKit so no need to check for permissions
  static Future<bool> isBluetoothDenied() async {
    bool isDenied = false;
    if (Platform.isAndroid) {
      final apiLevel = await BluetoothChannel().getAPILevel();
      if (apiLevel <= 31) {
        isDenied = await Permission.bluetooth.isDenied ||
            await Permission.bluetoothConnect.isDenied ||
            await Permission.bluetoothScan.isDenied;
        await Permission.locationWhenInUse.isDenied;
      } else {
        isDenied = await Permission.bluetooth.isDenied ||
            await Permission.bluetoothConnect.isDenied ||
            await Permission.bluetoothScan.isDenied;
      }
    }
    return isDenied;
  }
}
