// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:io';

import 'package:envoy/ble/handlers/fw_update_handler.dart';
import 'package:envoy/ble/quantum_link_router.dart';
import 'package:envoy/ui/onboard/prime/state/ble_onboarding_state.dart';
import 'package:envoy/business/devices.dart';
import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/business/prime_device.dart';
import 'package:envoy/business/scv_server.dart';
import 'package:envoy/channels/ql_connection.dart';
import 'package:envoy/channels/ble_status.dart';
import 'package:envoy/channels/bluetooth_channel.dart';
import 'package:envoy/ui/widgets/envoy_step_item.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/envoy_storage.dart';
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
  if(device == null) return false;
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

  // map <device -> InProgressBackup>

  bool _sendingData = false;

  double? _lastSentBtcPrice;

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
      final deviceChannel = _bluetoothChannel.getDeviceChannel(newBleId);
      await listen(bleDevice: deviceChannel);
    }

    await restoreQuantumLinkIdentity();
    await restorePrimes();
  }

  Future<void> restoreQuantumLinkIdentity() async {
    final qlIdentity = await EnvoyStorage().getQuantumLinkIdentity();

    if (qlIdentity == null) {
      kPrint("No QL Identity found, generating new one.");
      await _generateQlIdentity();
    } else {
      kPrint("QL Identity found, restoring.");
      _qlIdentity = qlIdentity;
    }
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
    if (_qlIdentity == null) {
      await _generateQlIdentity();
    }
    _listenToWriteProgress();
  }

  void _listenToWriteProgress() {
    BluetoothManager().writeProgressStream.listen((progress) {
      kPrint("Write progress: ${(progress * 100).toStringAsFixed(1)}%");
    });
  }

  Future getPermissions() async {
    // return;
    kPrint("Getting permissions...");
    await Permission.bluetooth.request();
    await Permission.bluetoothConnect.request();
    // TODO: remove this
    // Envoy will be getting the BT addresses via QR
    await Permission.bluetoothScan.request();
    kPrint("Scanning...");
    bool denied = await isBluetoothDenied();
    if (!denied) {
      await initBluetooth();
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

  static Future<bool> isBluetoothDenied() async {
    bool isDenied = true;
    if (Platform.isAndroid) {
      isDenied = await Permission.bluetooth.isDenied ||
          await Permission.bluetoothConnect.isDenied ||
          await Permission.bluetoothScan.isDenied;
    } else {
      //Permission.bluetoothConnect and Permission.bluetoothScan are not available on iOS
      isDenied = await Permission.bluetooth.isDenied;
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

  Future<bool> pair(api.XidDocument recipient) async {
    _recipientXid = recipient;
    kPrint("pair: $hashCode");
    QLConnection? deviceChannel;
    if (bleId.isNotEmpty) {
      deviceChannel = _bluetoothChannel.getDeviceChannel(bleId);
      listen(bleDevice: deviceChannel);
    }

    //reset onboarding state
    deviceChannel?.qlHandler.bleOnboardHandler.reset();
    deviceChannel?.qlHandler.bleOnboardHandler
        .updateBlePairState("Connecting to Prime", EnvoyStepState.LOADING);

    if (_qlIdentity == null) {
      await _generateQlIdentity();
    }

    kPrint("Pairing...");
    final xid = await api.serializeXid(quantumLinkIdentity: _qlIdentity!);

    final recipientXid =
        await api.serializeXidDocument(xidDocument: _recipientXid!);

    final deviceName = await BluetoothChannel().getDeviceName();

    final success = await writeMessage(api.QuantumLinkMessage.pairingRequest(
        api.PairingRequest(xidDocument: xid, deviceName: deviceName)));
    kPrint("Pairing... success ?  $success");

    if (!success) {
      deviceChannel?.qlHandler.bleOnboardHandler
          .updateBlePairState("Unable to pair", EnvoyStepState.ERROR);
      throw Exception("Failed to send pairing request");
    }
    // Listen for response
    //Future.delayed(Duration(seconds: 2));

    // TODO: handle this in same place
    PrimeDevice prime = PrimeDevice(bleId, recipientXid);
    await EnvoyStorage().savePrime(prime);

    return true;
  }

  @override
  Future<bool> writeMessage(api.QuantumLinkMessage message) async {

    kPrint("Sending message: ${message.runtimeType}");
    await _writeWithProgress(message);
    return true;
  }

  Future<void> removeConnectedDevice() async {
    await EnvoyStorage().deletePrimeByBleId(bleId);

    await disconnect();
    bleId = "";
    _recipientXid = null;
  }

  Future disconnect() async {
    //TODO: multi
    // await BluetoothChannel().disconnect();
  }

  Future<void> sendPsbt(String accountId, Uint8List psbt) async {
    await writeMessage(api.QuantumLinkMessage.signPsbt(
        api.SignPsbt(psbt: psbt, accountId: accountId)));
  }

  Future<void> _generateQlIdentity() async {
    try {
      kPrint("Generating ql identity...");
      _qlIdentity = await api.generateQlIdentity();
      await EnvoyStorage().saveQuantumLinkIdentity(_qlIdentity!);
    } catch (e, stack) {
      kPrint("Couldn't generate ql identity: $e", stackTrace: stack);
    }
  }

  Future<QLConnection> setupBle(
      {required String id, int colorWay = 1}) async {
    if (_qlIdentity == null) {
      await _generateQlIdentity();
    }
    final connectionEvent = await BluetoothChannel().setupBle(id, colorWay);
    kPrint("Connection event: $connectionEvent");
    bleId = id;
    return connectionEvent;
  }

  Future<void> listen({required QLConnection bleDevice}) async {
    // _decoder = await api.getDecoder();
    if (Platform.isIOS || Platform.isAndroid) {
      // Listen to data from specific device channel
      // bleDevice.dataStream.listen((payload) {
      //   decode(payload).then((value) async {
      //     if (value != null) {
      //       unawaited(_messageRouter.dispatch(value, bleDevice));
      //       _passportMessageStream.add(value);
      //       kPrint(
      //           "Got Passport message type: ${value.message.runtimeType} ${value.message}");
      //       if (value.message
      //           case api.QuantumLinkMessage_BroadcastTransaction transaction) {
      //         kPrint("Got the Broadcast Transaction");
      //         _transactionStream.add(transaction);
      //       }
      //       if (value.message
      //           case api.QuantumLinkMessage_ApplyPassphrase applyPassphrase) {
      //         kPrint(
      //             "Got ApplyPassphrase event: ${applyPassphrase.field0.fingerprint}");
      //         _passphraseEventStream.add(applyPassphrase.field0);
      //       }
      //     }
      //   }, onError: (e) {
      //     kPrint("Error decoding: $e");
      //   });
      // });

      // Listen to device connection status from specific device
      // bleDevice.deviceStatusStream.listen((event) async {
      //   if (event.type == BluetoothConnectionEventType.deviceConnected) {
      //     await Future.delayed(Duration(seconds: 2));
      //     sendExchangeRateHistory();
      //   }
      // });
    }
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

  Future<void> sendSecurityChallengeRequest() async {
    kPrint("sending security challenge");
    api.ChallengeRequest? challenge = await ScvServer().getPrimeChallenge();

    if (challenge == null) {
      // TODO: SCV what now?
      kPrint("No challenge available");
      return;
    }

    final request = api.SecurityCheck.challengeRequest(challenge);
    kPrint("writing security challenge");
    await writeMessage(api.QuantumLinkMessage.securityCheck(request));
    kPrint("successfully wrote security challenge");
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

  Future<void> sendExchangeRate() async {
    if (_sendingData) return;

    if (Devices().getPrimeDevices.isEmpty || _recipientXid == null) {
      return;
    }
    //TODO: support multi device
    if (Devices().getPrimeDevices.first.onboardingComplete) {
      return;
    }
    kPrint(
        "Preparing to send exchange rate to Prime... $_sendingData devices ${Devices().getPrimeDevices.length}");
    try {
      _sendingData = true;
      final exchangeRate = ExchangeRate();
      final currentExchange = exchangeRate.usdRate!;

      // Only send if price actually changed
      if (_lastSentBtcPrice != null && _lastSentBtcPrice == currentExchange) {
        return;
      }

      final timestamp = exchangeRate.usdRateTimestamp?.millisecondsSinceEpoch ??
          DateTime.now().millisecondsSinceEpoch;

      final exchangeRateMessage = api.ExchangeRate(
        currencyCode: "USD",
        rate: currentExchange,
        timestamp: BigInt.from(timestamp / 1000),
      );

      writeMessage(api.QuantumLinkMessage.exchangeRate(exchangeRateMessage));

      _lastSentBtcPrice = currentExchange;
    } catch (e) {
      kPrint('Failed to send exchange rate to Prime: $e');
    } finally {
      _sendingData = false;
    }
  }

  Future<void> sendExchangeRateHistory() async {
    if (_sendingData) return;

    if (Devices().getPrimeDevices.isEmpty || _recipientXid == null) {
      return;
    }
    //TODO: support multi device

    if (Devices().getPrimeDevices.first.onboardingComplete) {
      return;
    }
    try {
      _sendingData = true;

      final historyPoints = ExchangeRate().history.points;
      final currency = ExchangeRate().history.currency;

      if (historyPoints.isEmpty) {
        kPrint("No exchange rate history to send.");
        return;
      }

      // Convert Dart RatePoint -> API PricePoint
      final apiPoints = historyPoints.map((p) {
        return api.PricePoint(
          rate: p.price,
          timestamp: BigInt.from(p.timestamp),
        );
      }).toList();

      final historyMessage = api.ExchangeRateHistory(
        history: apiPoints,
        currencyCode: currency,
      );

      await writeMessage(
          api.QuantumLinkMessage.exchangeRateHistory(historyMessage));

      kPrint(
          "Sent ${apiPoints.length} exchange rate points for currency $currency");
    } catch (e) {
      kPrint('Failed to send exchange rate history: $e');
    } finally {
      _sendingData = false;
    }
  }

  void setupExchangeRateListener() {
    ExchangeRate().addListener(() async {
      await sendExchangeRate();
    });
  }

  Future<Stream<double>> _writeWithProgress(
      api.QuantumLinkMessage message) async {
    _sendingData = true;
    final data = await encodeMessage(message: message);
    kPrint("Encoded message! Size: ${data.length}");
    if (Platform.isIOS || Platform.isAndroid) {
      //TODO: multi
      // await _bluetoothChannel.writeAll(data);
    } else {
      _sendingData = false;
      throw UnimplementedError(
          "Bluetooth write not implemented for this platform");
    }
    _sendingData = false;
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
