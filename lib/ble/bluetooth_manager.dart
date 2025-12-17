// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:io';

import 'package:envoy/ble/handlers/device_handler.dart';
import 'package:envoy/ble/handlers/fw_update_handler.dart';
import 'package:envoy/ble/handlers/onboard_handler.dart';
import 'package:envoy/ble/handlers/scv_handler.dart';
import 'package:envoy/ble/handlers/timezone_handler.dart' show TimeZoneHandler;
import 'package:envoy/business/devices.dart';
import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/business/prime_device.dart';
import 'package:envoy/business/scv_server.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/channels/ble_status.dart';
import 'package:envoy/channels/bluetooth_channel.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/widgets/envoy_step_item.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:envoy/util/ntp.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_api/foundation_api.dart' as api;
import 'package:permission_handler/permission_handler.dart';

import 'handlers/account_handler.dart';
import 'handlers/heartbeat_handler.dart';
import 'handlers/magic_backup_handler.dart';
import 'handlers/passphrase_handler.dart';
import 'handlers/shards_handler.dart';
import 'quantum_link_router.dart';

final bleChunkSize = BigInt.from(51200);

final deviceConnectionStatusStreamProvider =
    StreamProvider<DeviceStatus>((ref) {
  return BluetoothChannel().deviceStatusStream;
});

//TODO: support multiple devices
final isPrimeConnectedProvider = Provider.family<bool, String>((ref, bleId) {
  DeviceStatus? status =
      ref.watch(deviceConnectionStatusStreamProvider).valueOrNull;
  status ??= BluetoothChannel().lastDeviceStatus;
  return status.connected == true;
});

//TODO: refactor with new fw update progress tracking
final remainingTimeProvider = StateProvider<Duration>((ref) => Duration.zero);

final connectedDeviceProvider = StreamProvider<DeviceStatus>((ref) {
  return BluetoothChannel().deviceStatusStream;
});

final fwTransferProgress = StreamProvider<FwTransferProgress>((ref) {
  return BluetoothManager().fwUpdateHandler.transferProgress;
});

class BluetoothManager extends WidgetsBindingObserver with EnvoyMessageWriter {
  StreamSubscription? _subscription;
  StreamSubscription? _writeProgressSubscription;
  final _bluetoothChannel = BluetoothChannel();

  //holds registered handlers.
  final PassportMessageRouter _messageRouter = PassportMessageRouter();

  //Handlers.
  //Handles various types of messages received from the Passport device.
  //can be exposed to UI through BluetoothManager instance.
  late final BleMagicBackupHandler _bleMagicBackupHandler =
      BleMagicBackupHandler(this);
  late final BleAccountHandler _bleAccountHandler = BleAccountHandler(this);
  late final ShardsHandler _bleShardsHandler = ShardsHandler(this);
  late final ScvHandler _scvAccountHandler = ScvHandler(this);
  late final BleOnboardHandler _bleOnboardHandler = BleOnboardHandler(this);
  late final BlePassphraseHandler _blePassphraseHandler =
      BlePassphraseHandler(this, _passphraseEventStream);

  late final FwUpdateHandler _fwUpdateHandler = FwUpdateHandler(
    this,
  );

  late final HeartbeatHandler _heartbeatHandler = HeartbeatHandler(this);

  //
  BleMagicBackupHandler get magicBackupHandler => _bleMagicBackupHandler;

  BleAccountHandler get bleAccountHandler => _bleAccountHandler;

  ScvHandler get scvAccountHandler => _scvAccountHandler;

  BleOnboardHandler get bleOnboardHandler => _bleOnboardHandler;

  FwUpdateHandler get fwUpdateHandler => _fwUpdateHandler;

  static final BluetoothManager _instance = BluetoothManager._internal();

  api.EnvoyAridCache? _aridCache;

  // Persist this across sessions
  api.QuantumLinkIdentity? _qlIdentity;
  final StreamController<api.PassportMessage> _passportMessageStream =
      StreamController<api.PassportMessage>.broadcast();

  final StreamController<api.QuantumLinkMessage_BroadcastTransaction>
      _transactionStream =
      StreamController<api.QuantumLinkMessage_BroadcastTransaction>.broadcast();

  final StreamController<api.ApplyPassphrase> _passphraseEventStream =
      StreamController<api.ApplyPassphrase>.broadcast();

  api.EnvoyMasterDechunker? _decoder;

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

    _messageRouter.registerHandler(_bleMagicBackupHandler);
    _messageRouter.registerHandler(_bleShardsHandler);
    _messageRouter.registerHandler(_bleAccountHandler);
    _messageRouter.registerHandler(_bleOnboardHandler);
    _messageRouter.registerHandler(_blePassphraseHandler);
    _messageRouter.registerHandler(_fwUpdateHandler);
    _messageRouter.registerHandler(_scvAccountHandler);
    _messageRouter.registerHandler(_heartbeatHandler);
    _messageRouter.registerHandler(DeviceHandler(this));
    _messageRouter.registerHandler(TimeZoneHandler(this));

    await listen(id: bleId);
    kPrint("QL Identity: $_qlIdentity");
    await restoreQuantumLinkIdentity();
    await restorePrimes();
    _aridCache = await api.getAridCache();
    kPrint("QL Identity: $_qlIdentity");
    initBluetooth();
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
    for (Device device in Devices().getPrimeDevices) {
      if (device.xid != null) {
        final api.XidDocument recipientXid = await api.deserializeXid(
          data: device.xid!,
        );
        _recipientXid = recipientXid;
        kPrint("Restored XID for device ${device.name}");
      } else {
        kPrint("No XID found for device ${device.name}");
      }
    }
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
    listen(id: bleId);

    //reset onboarding state
    bleOnboardHandler.reset();
    bleOnboardHandler.updateBlePairState(
        "Connecting to Prime", EnvoyStepState.LOADING);

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
      bleOnboardHandler.updateBlePairState(
          "Unable to pair", EnvoyStepState.ERROR);
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
    if (!BluetoothChannel().lastDeviceStatus.connected) {
      await BluetoothChannel().deviceStatusStream.firstWhere((status) {
        return status.connected == true;
      }).timeout(Duration(seconds: 10), onTimeout: () {
        throw Exception("Failed to send message, device not connected");
      });
    }
    kPrint("Sending message: ${message.runtimeType}");
    await _writeWithProgress(message);
    return true;
  }

  Future<void> addDevice(String serialNumber, String firmwareVersion,
      String bleId, DeviceColor deviceColor,
      {bool onboardingComplete = false, String peripheralId = ""}) async {
    final recipientXid =
        await api.serializeXidDocument(xidDocument: _recipientXid!);
    final device = Device(
      "Prime",
      DeviceType.passportPrime,
      serialNumber,
      DateTime.now(),
      firmwareVersion,
      EnvoyColors.listAccountTileColors[0],
      bleId: bleId,
      deviceColor: deviceColor,
      xid: recipientXid,
      peripheralId: peripheralId,
      onboardingComplete: onboardingComplete,
      primeBackupEnabled: Settings().syncToCloud,
    );
    Devices().add(device);
  }

  Future<void> removeConnectedDevice() async {
    await EnvoyStorage().deletePrimeByBleId(bleId);

    await disconnect();
    bleId = "";
    _recipientXid = null;
  }

  Future disconnect() async {
    await BluetoothChannel().disconnect();
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

  Future<bool> setupBle({required String id, int colorWay = 1}) async {
    if (_qlIdentity == null) {
      await _generateQlIdentity();
    }
    final connectionEvent = await BluetoothChannel().setupBle(id, colorWay);
    kPrint("Connection event: $connectionEvent");
    bleId = id;
    return connectionEvent.connected;
  }

  Future<void> listen({required String id}) async {
    _decoder = await api.getDecoder();
    if (Platform.isIOS || Platform.isAndroid) {
      _bluetoothChannel.listenToDataEvents().listen((payload) {
        decode(payload).then((value) async {
          if (value != null) {
            unawaited(_messageRouter.dispatch(value, id));
            _passportMessageStream.add(value);
            kPrint(
                "Got Passport message type: ${value.message.runtimeType} ${value.message}");
            if (value.message
                case api.QuantumLinkMessage_BroadcastTransaction transaction) {
              kPrint("Got the Broadcast Transaction");
              _transactionStream.add(transaction);
            }
          }
        }, onError: (e) {
          kPrint("Error decoding: $e");
        });
      });

      _bluetoothChannel.deviceStatusStream.listen((event) async {
        if (event.type == BluetoothConnectionEventType.deviceConnected) {
          await Future.delayed(Duration(seconds: 2));
          sendExchangeRateHistory();
        }
      });
    }
  }

  Future<api.PassportMessage?> decode(Uint8List bleData) async {
    _decoder ??= await api.getDecoder();
    _aridCache ??= await api.getAridCache();
    api.DecoderStatus decoderStatus = await api.decode(
        data: bleData.toList(),
        decoder: _decoder!,
        quantumLinkIdentity: _qlIdentity!,
        aridCache: _aridCache!);
    if (decoderStatus.payload != null) {
      return decoderStatus.payload;
    } else {
      return null;
    }
  }

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
      await _bluetoothChannel.writeAll(data);
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

  Future<void> reconnect(Device device) async {
    await BluetoothChannel().reconnect(device);
  }
}
