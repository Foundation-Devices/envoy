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
import 'package:envoy/util/ntp.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_api/foundation_api.dart' as api;
import 'package:permission_handler/permission_handler.dart';

final bleChunkSize = BigInt.from(51200);

final bleDeviceStreamProvider = StreamProvider<List<QLConnection>>((ref) {
  return BluetoothChannel().deviceChannelsStream;
});

final deviceConnectionStatusStreamProvider =
    StreamProvider.family<DeviceStatus, String>((ref, deviceId) {
  //watching the device stream to trigger rebuilds when devices change
  ref.watch(bleDeviceStreamProvider);
  final bleDevice = BluetoothChannel().getDeviceChannel(deviceId);
  return bleDevice.deviceStatusStream;
});

final isPrimeConnectedProvider = Provider.family<bool, Device?>((ref, device) {
  if (device == null) return false;
  DeviceStatus? status =
      ref.watch(deviceConnectionStatusStreamProvider(device.bleId)).valueOrNull;
  status ??= BluetoothChannel().getDeviceChannel(device.bleId).lastDeviceStatus;
  return status.connected == true;
});

final connectedDeviceProvider =
    StreamProvider.family<DeviceStatus, String>((ref, deviceId) {
  final bleDevice = BluetoothChannel().getDeviceChannel(deviceId);
  return bleDevice.deviceStatusStream;
});

final fwTransferProgress = StreamProvider<FwTransferProgress>((ref) {
  final device = ref.watch(onboardingDeviceProvider);
  if (device == null) return const Stream.empty();
  return device.qlHandler.fwUpdateHandler.transferProgress;
});

class BluetoothManager extends WidgetsBindingObserver with EnvoyMessageWriter {
  StreamSubscription? _subscription;
  StreamSubscription? _writeProgressSubscription;
  final _bluetoothChannel = BluetoothChannel();

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

  Future<void> restoreAfterRecovery() async {
    final primes = Devices().getPrimeDevices;
    final newBleId = primes.isNotEmpty ? primes.first.bleId : "";

    if (newBleId.isEmpty) return;

    if (bleId != newBleId) {
      bleId = newBleId;
      _bluetoothChannel.getDeviceChannel(newBleId);
    }

    await restorePrimes();
  }

  // Restores XidDocuments for all Prime devices
  // TODO: support multiple devices
  Future<void> restorePrimes() async {
    // for (Device device in Devices().getPrimeDevices) {
    //   if (device.xid != null) {
    //     final api.XidDocument recipientXid = await api.deserializeXid(
    //       data: device.xid!,
    //     );
    //     _recipientXid = recipientXid;
    //     kPrint("Restored XID for device ${device.name}");
    //   } else {
    //     kPrint("No XID found for device ${device.name}");
    //   }
    // }
  }

  Future<void> initBluetooth() async {
    if (_qlIdentity == null) {}
    _listenToWriteProgress();
  }

  void _listenToWriteProgress() {
    BluetoothManager().writeProgressStream.listen((progress) {
      kPrint("Write progress: ${(progress * 100).toStringAsFixed(1)}%");
    });
  }

  Future getPermissions() async {
    if (Platform.isAndroid) {
      // return;
      kPrint(
          "Getting permissions... ${await BluetoothChannel().getAPILevel()}");
      // Envoy will be getting the BT addresses via QR
      // so we don't need location permission for scanning on Android 10 and below
      if (await BluetoothChannel().getAPILevel() <= 31) {
        await [
          Permission.bluetooth,
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
          Permission.locationWhenInUse
        ].request();
      } else {
        await [
          Permission.bluetooth,
          Permission.bluetoothScan,
          Permission.bluetoothConnect
        ].request();
      }
      kPrint("Scanning...");
      bool denied = await isBluetoothDenied();
      if (!denied) {
        await initBluetooth();
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

  //checks connected devices.
  // if a device is connected and its not in the list of prime devices, disconnect from it

  Future<List<Uint8List>> encodeMessage(
      {required api.QuantumLinkMessage message}) async {
    DateTime dateTime = DateTime.now();
    try {
      dateTime = await NTP.now(timeout: const Duration(seconds: 1));
    } catch (e) {
      kPrint("NTP error: $e");
    }
    final timestampSeconds = (dateTime.millisecondsSinceEpoch ~/ 1000);
    kPrint("Encoding Message timestamp: $timestampSeconds");

    api.EnvoyMessage envoyMessage =
        api.EnvoyMessage(message: message, timestamp: timestampSeconds);
    kPrint("Encoded Message $timestampSeconds");

    kPrint("Encoding message: $envoyMessage");
    return await api.encode(
      message: envoyMessage,
      sender: _qlIdentity!,
      recipient: _recipientXid!,
    );
  }

  Future<bool> encodeToFile(
      {required Uint8List message,
      required String filePath,
      required int chunkSize}) async {
    DateTime dateTime = DateTime.now();
    try {
      dateTime = await NTP.now(timeout: const Duration(seconds: 1));
    } catch (e) {
      kPrint("NTP error: $e");
    }
    final timestampSeconds = (dateTime.millisecondsSinceEpoch ~/ 1000);
    kPrint("Encoding Message timestamp: $timestampSeconds");
    //
    // List<api.EnvoyMessage> envoyMessages = messages.map((message) =>
    //     api.EnvoyMessage(message: message, timestamp: timestampSeconds)).toList();
    // kPrint("Encoded Message $timestampSeconds");
    kPrint("Encoding message: $message to file: $filePath");
    return await api.encodeToMagicBackupFile(
        payload: message,
        sender: _qlIdentity!,
        recipient: _recipientXid!,
        path: filePath,
        chunkSize: BigInt.from(chunkSize),
        timestamp: timestampSeconds);
  }

  @override
  Future<bool> writeMessage(api.QuantumLinkMessage message) async {
    kPrint("Sending message: ${message.runtimeType}");
    await _writeWithProgress(message);
    return true;
  }

  Future disconnect() async {
    //TODO: multi
    // await BluetoothChannel().disconnect();
  }

  Future<void> sendPsbt(String accountId, Uint8List psbt) async {
    await writeMessage(api.QuantumLinkMessage.signPsbt(
        api.SignPsbt(psbt: psbt, accountId: accountId)));
  }

  /*Future<api.PassportMessage?> decode(Uint8List bleData) async {
    // _decoder ??= await api.getDecoder();
    // _aridCache ??= await api.getAridCache();
    // api.DecoderStatus decoderStatus = await api.decode(
    //     data: bleData.toList(),
    //     decoder: _decoder!,
    //     quantumLinkIdentity: _qlIdentity!,
    //     aridCache: _aridCache!);
    // if (decoderStatus.payload != null) {
    //   return decoderStatus.payload;
    // } else {
    //   return null;
    // }
  }
*/
  Future<void> sendOnboardingState(api.OnboardingState state) async {
    writeMessage(api.QuantumLinkMessage.onboardingState(state));
  }

  Future<void> sendSecurityChallengeVerificationResult(
      api.VerificationResult result) async {
    final message = api.SecurityCheck.verificationResult(result);
    await writeMessage(api.QuantumLinkMessage.securityCheck(message));
  }

  Future<void> restorePrimeDevice(String serial) async {
    try {
      List<Device> primes = Devices().getPrimeDevices;

      if (primes.isEmpty) {
        return;
      }
      for (final prime in primes) {
        kPrint("Restoring Prime device XID for $prime");
        if (prime.xid != null) {
          _recipientXid = await api.deserializeXid(
            data: prime.xid!,
          );
        } else {
          kPrint("No XID found for device ${prime.name}");
        }
      }
    } catch (e) {
      kPrint('Error deserializing XidDocument: $e');
    }
  }

  Future<Stream<double>> _writeWithProgress(
      api.QuantumLinkMessage message) async {
    final data = await encodeMessage(message: message);
    kPrint("Encoded message! Size: ${data.length}");
    if (Platform.isIOS || Platform.isAndroid) {
      //TODO: multi
      // await _bluetoothChannel.writeAll(data);
    } else {
      throw UnimplementedError(
          "Bluetooth write not implemented for this platform");
    }
    return Stream.value(1.0);
  }

  void dispose() {
    _subscription?.cancel();
    _writeProgressSubscription?.cancel();
    _bluetoothChannel.dispose();
  }

  Future sendAccountUpdate(api.AccountUpdate update) async {
    kPrint("Sending account update to Prime");
    await writeMessage(api.QuantumLinkMessage.accountUpdate(update));
  }

  @override
  Future<Stream<double>> writeMessageWithProgress(
      api.QuantumLinkMessage message) async {
    return _writeWithProgress(message);
  }

  Future<void> reconnect(String id) async {
    await BluetoothChannel().reconnect(id);
  }
}
