// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:io';

import 'package:envoy/ble/handlers/fw_update_handler.dart';
import 'package:envoy/ble/handlers/onboard_handler.dart';
import 'package:envoy/business/devices.dart';
import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/business/prime_device.dart';
import 'package:envoy/business/scv_server.dart';
import 'package:envoy/business/server.dart';
import 'package:envoy/channels/ble_status.dart';
import 'package:envoy/channels/bluetooth_channel.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:envoy/util/ntp.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_api/foundation_api.dart' as api;
import 'package:permission_handler/permission_handler.dart';

import 'handlers/account_handler.dart';
import 'handlers/magic_backup_handler.dart';
import 'handlers/passphrase_handler.dart';
import 'handlers/shards_handler.dart';
import 'quantum_link_router.dart';

final connectedDevicesProvider = StreamProvider<DeviceStatus>((ref) {
  return BluetoothChannel().deviceStatusStream;
});

final isPrimeConnectedProvider = Provider.family<bool, String>((ref, bleId) {
  DeviceStatus? status = ref.watch(connectedDevicesProvider).valueOrNull;
  status ??= BluetoothChannel().lastDeviceStatus;
  return status.connected == true;
});

final sendProgressProvider =
    StateNotifierProvider<SendProgressNotifier, double>(
  (ref) => SendProgressNotifier(ref),
);
//TODO: refactor with new fw update progress tracking
final fwTransmitProgress = StateProvider<double>((ref) => 0.0);

final remainingTimeProvider = StateProvider<Duration>((ref) => Duration.zero);

final connectedDeviceProvider = StreamProvider<DeviceStatus>((ref) {
  return BluetoothChannel().deviceStatusStream;
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
  late final BleOnboardHandler _bleOnboardHandler = BleOnboardHandler(this);
  late final BlePassphraseHandler _blePassphraseHandler =
      BlePassphraseHandler(this, _passphraseEventStream);

  late final FwUpdateHandler _fwUpdateHandler = FwUpdateHandler(
    this,
  );

  //
  BleMagicBackupHandler get magicBackupHandler => _bleMagicBackupHandler;

  BleAccountHandler get bleAccountHandler => _bleAccountHandler;

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

  //TODO: firmware update progress tracking with new progress stream
  // int _totalFirmwareChunks = 0;
  // int _sentFirmwareChunks = 0;
  // bool _isUpdatingFirmware = false;

  void startFirmwareUpdate({required int totalChunks}) {
    // _totalFirmwareChunks = totalChunks;
    // _sentFirmwareChunks = 0;
    // _isUpdatingFirmware = true;
    _writeProgressController.add(0.0);
  }

  void endFirmwareUpdate() {
    // _isUpdatingFirmware = false;
    // _totalFirmwareChunks = 0;
    // _sentFirmwareChunks = 0;
  }

  String bleId = "";

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
    kPrint("Sending message: $message");
    await _writeWithProgress(message);
    return true;
  }

  Future<void> addDevice(String serialNumber, String firmwareVersion,
      String bleId, DeviceColor deviceColor,
      {bool onboardingComplete = false, String peripheralId = ""}) async {
    final recipientXid =
        await api.serializeXidDocument(xidDocument: _recipientXid!);
    final device = Device("Prime", DeviceType.passportPrime, serialNumber,
        DateTime.now(), firmwareVersion, EnvoyColors.listAccountTileColors[0],
        bleId: bleId,
        deviceColor: deviceColor,
        xid: recipientXid,
        peripheralId: peripheralId,
        onboardingComplete: onboardingComplete);
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
            unawaited(_messageRouter.dispatch(value.message, id));
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

      _bluetoothChannel.deviceStatusStream.listen((event) {
        if (event.type == BluetoothConnectionEventType.deviceConnected) {
          sendExchangeRateHistory();
        }
      });
      // _bluetoothChannel.listenToDeviceConnectionEvents().listen((event) {});
    } else {
      // _subscription = bluart.read(id: id).listen((bleData) {
      //   decode(bleData).then((value) {
      //     if (value != null) {
      //       _passportMessageStream.add(value);
      //       kPrint(
      //           "Got Passport message type: ${value.message.runtimeType} ${value.message}");
      //       if (value.message
      //           case api.QuantumLinkMessage_BroadcastTransaction transaction) {
      //         kPrint("Got the Broadcast Transaction");
      //         _transactionStream.add(transaction);
      //       }  if (value.message
      //           case api.QuantumLinkMessage_BroadcastTransaction transaction) {
      //         kPrint("Got the Broadcast Transaction");
      //         _transactionStream.add(transaction);
      //       }
      //     }
      //   }, onError: (e) {
      //     kPrint("Error decoding: $e");
      //   });
      // });
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
      _decoder = await api.getDecoder();
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
        timestamp: BigInt.from(timestamp),
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

  Future<void> sendFirmwareUpdateInfo(List<PrimePatch> patches) async {
    if (patches.isEmpty) {
      writeMessage(api.QuantumLinkMessage.firmwareUpdateCheckResponse(
          api.FirmwareUpdateCheckResponse_NotAvailable()));
      return;
    }

    final response = api.QuantumLinkMessage.firmwareUpdateCheckResponse(
        api.FirmwareUpdateCheckResponse.available(api.FirmwareUpdateAvailable(
            version: patches.last.version,
            timestamp: patches.last.releaseDate.millisecondsSinceEpoch,
            totalSize: 100,
            changelog: patches.last.changelog,
            patchCount: patches.length)));

    await writeMessage(response);
  }

  Future<void> sendFirmwareFetchEvent(api.FirmwareFetchEvent event) async {
    await writeMessage(api.QuantumLinkMessage.firmwareFetchEvent(event));
  }

  Future<void> sendFirmwarePayload(List<Uint8List> patches) async {
    final tempFile =
        await BluetoothChannel.getBleCacheFile(patches.hashCode.toString());

    DateTime dateTime = DateTime.now();
    try {
      dateTime = await NTP.now(timeout: const Duration(seconds: 1));
    } catch (e) {
      kPrint("NTP error: $e");
    }
    final timestampSeconds = (dateTime.millisecondsSinceEpoch ~/ 1000);

    final ready = await api.encodeToUpdateFile(
        payload: patches,
        sender: _qlIdentity!,
        recipient: _recipientXid!,
        path: tempFile.path,
        chunkSize: BigInt.from(200000),
        timestamp: timestampSeconds);

    if (ready) {
      kPrint("Firmware payload encoded to file: ${tempFile.path}");
      BluetoothChannel().getWriteProgress(tempFile.path).listen((progress) {
        // kPrint(
        //     "Firmware write progress: ${(progress.progress * 100).toStringAsFixed(1)}%");
      });
      final bool = await BluetoothChannel().transmitFromFile(tempFile.path);
      if (!bool) {
        await writeMessage(api.QuantumLinkMessage.firmwareFetchEvent(
          api.FirmwareFetchEvent.error("Firmware payload transmission failed!"),
        ));

        kPrint("Firmware payload transmission failed!");
        return;
      }
      kPrint("Firmware payload sent successfully! $bool");
    }
    // if (totalChunks == 0) {
    //   kPrint("No chunks to send. Aborting.");
    //   return;
    // }
    //
    // try {
    //
    //   for (final (chunkIndex, chunk) in allChunks.indexed) {
    //     kPrint("Sending overall chunk ${chunkIndex + 1} of $totalChunks");
    //     await writeMessage(chunk);
    //   }
    //
    //   await writeMessage(api.QuantumLinkMessage.firmwareFetchEvent(
    //     // api.FirmwareFetchEvent.complete(),
    //   ));
    //   kPrint("Firmware payload sent successfully!");
    // } finally {
    //   endFirmwareUpdate();
    // }
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
    // _writeProgressSubscription = writeStream.listen(
    //   (progress) {
    //     if (_isUpdatingFirmware && _totalFirmwareChunks > 0) {
    //       final overallProgress =
    //           (_sentFirmwareChunks + progress) / _totalFirmwareChunks;
    //       _writeProgressController.add(overallProgress.clamp(0.0, 1.0));
    //     } else {
    //       _writeProgressController.add(progress);
    //     }
    //   },
    //   onDone: () {
    //     kPrint("Progress stream done!");
    //     if (_isUpdatingFirmware) {
    //       _sentFirmwareChunks++;
    //     }
    //     _sendingData = false;
    //   },
    //   onError: (e) {
    //     kPrint("Progress stream errored out!");
    //     if (_isUpdatingFirmware) {
    //       endFirmwareUpdate();
    //     }
    //     _sendingData = false;
    //     _writeProgressController.addError(e);
    //   },
    // );
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

class SendProgressNotifier extends StateNotifier<double> {
  final Ref ref;
  StreamSubscription<WriteProgress>? _sub;
  DateTime? _startTime;
  Duration _elapsed = Duration.zero;

  SendProgressNotifier(this.ref) : super(0.0);

  void listen(String path) {
    _sub = BluetoothChannel().getWriteProgress(path).listen(
      (event) {
        final progress = event.progress;
        setProgress(progress);
      },
      onDone: () {
        state = 0.0;
        ref.read(remainingTimeProvider.notifier).state = Duration.zero;
      },
      onError: (_) {
        state = 0.0;
        ref.read(remainingTimeProvider.notifier).state = Duration.zero;
      },
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void setProgress(double progress) {
    state = progress;
    if (_startTime == null && progress > 0) {
      _startTime = DateTime.now();
      _elapsed = Duration.zero;
    }

    state = progress * 100;

    if (_startTime != null) {
      final now = DateTime.now();
      _elapsed = now.difference(_startTime!);
      final elapsedSeconds = _elapsed.inMilliseconds / 1000.0;

      if (progress > 0 && progress < 1 && elapsedSeconds > 0) {
        final speed = progress / elapsedSeconds;
        final remainingSeconds =
            ((1.0 - progress) / speed).clamp(0, double.infinity);
        ref.read(remainingTimeProvider.notifier).state =
            Duration(seconds: remainingSeconds.round());
      } else {
        ref.read(remainingTimeProvider.notifier).state = Duration.zero;
      }
    }
  }
}
