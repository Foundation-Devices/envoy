// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:bluart/bluart.dart' as bluart;
import 'package:envoy/account/accounts_manager.dart';
import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/business/prime_device.dart';
import 'package:envoy/business/prime_shard.dart';
import 'package:envoy/business/scv_server.dart';
import 'package:envoy/business/server.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:envoy/util/ntp.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_api/foundation_api.dart' as api;
import 'package:ngwallet/ngwallet.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_value.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/business/devices.dart';
import 'package:envoy/util/bug_report_helper.dart';

final sendProgressProvider =
    StateNotifierProvider<SendProgressNotifier, double>(
  (ref) => SendProgressNotifier(ref),
);

final remainingTimeProvider = StateProvider<Duration>((ref) => Duration.zero);
final connectedDevicesProvider = StreamProvider<Set<bluart.BleDevice>>((ref) {
  return BluetoothManager().connectedDevicesStream;
});

final isPrimeConnectedProvider = Provider.family<bool, String>((ref, bleId) {
  final devices = ref.watch(connectedDevicesProvider).valueOrNull ?? {};
  kPrint("Connected devices: $devices");
  return devices.any((d) => d.id == bleId);
});

class BluetoothManager extends WidgetsBindingObserver {
  StreamSubscription? _subscription;
  StreamSubscription? _writeProgressSubscription;
  final Set<bluart.BleDevice> _connectedDevices = {};

  final StreamController<Set<bluart.BleDevice>> _connectedDevicesStream =
      StreamController<Set<bluart.BleDevice>>();

  Set<bluart.BleDevice> get connectedDevices => _connectedDevices;

  Stream<Set<bluart.BleDevice>> get connectedDevicesStream =>
      _connectedDevicesStream.stream.asBroadcastStream();

  static final BluetoothManager _instance = BluetoothManager._internal();
  UuidValue rxCharacteristic =
      UuidValue.fromString("6E400002B5A3F393E0A9E50E24DCCA9E");

  // Persist this across sessions
  api.QuantumLinkIdentity? _qlIdentity;
  final StreamController<api.PassportMessage> _passportMessageStream =
      StreamController<api.PassportMessage>();

  final StreamController<api.QuantumLinkMessage_BroadcastTransaction>
      _transactionStream =
      StreamController<api.QuantumLinkMessage_BroadcastTransaction>();

  api.EnvoyMasterDechunker? _decoder;
  api.XidDocument? _recipientXid;

  bool connected = false;

  bool _sendingData = false;

  factory BluetoothManager() {
    return _instance;
  }

  late final Stream<api.PassportMessage> _broadcastPassportStream =
      _passportMessageStream.stream.asBroadcastStream();

  Stream<api.PassportMessage> get passportMessageStream =>
      _broadcastPassportStream;

  Stream<api.QuantumLinkMessage_BroadcastTransaction> get transactionStream =>
      _transactionStream.stream.asBroadcastStream();

  final StreamController<double> _writeProgressController =
      StreamController<double>.broadcast();

  Stream<double> get writeProgressStream => _writeProgressController.stream;

  String bleId = "";

  Stream<bluart.Event>? events;

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
    await bluart.RustLib.init();

    kPrint("QL Identity: $_qlIdentity");

    await restorePrimeDevice();
    await restoreQuantumLinkIdentity();

    kPrint("QL Identity: $_qlIdentity");
  }

  Future<void> initBluetooth() async {
    if (events != null) {
      kPrint("Bluetooth already initialized");
      return;
    }

    events = bluart.init().asBroadcastStream();

    // Add a small delay to ensure Rust library is fully initialized
    await Future.delayed(const Duration(milliseconds: 300));

    events?.listen((bluart.Event event) async {
      if (event is bluart.Event_DeviceConnected) {
        _updateConnectionStatus(event.field0);
        connected = true;
      }

      if (event is bluart.Event_DeviceDisconnected) {
        _updateConnectionStatus(event.field0);
        connected = false;
      }

      if (event is bluart.Event_ScanResult) {
        if (event.field0.isEmpty) {
          kPrint("received empty scan result");
        }

        for (final device in event.field0) {
          _updateConnectionStatus(device);
          // TODO: don't autoconnect in onboarding
          // TODO: need some way to know if we're in OB
          // if (bleId.isNotEmpty && device.id == bleId && !connected) {
          //   kPrint("Autoconnecting to: ${device.id}");
          //   await connect(id: device.id);
          //   await listen(id: bleId);
          // }
        }
      }
    });

    if (_qlIdentity == null) {
      await _generateQlIdentity();
    }

    await scan();
    _listenForAccountUpdate();
    _listenForShardMessages();
    _listenToWriteProgress();
  }

  void _updateConnectionStatus(bluart.BleDevice device) {
    if (device.connected) {
      //kPrint("Event Device connected: ${device.id} ${device.name}");
      _connectedDevices.add(device);
    } else {
      if (_connectedDevices.any((d) => d.id == device.id)) {
        _connectedDevices.removeWhere((d) => d.id == device.id);
      }
    }
    _connectedDevicesStream.sink.add(_connectedDevices);
  }

  void _listenToWriteProgress() {
    BluetoothManager().writeProgressStream.listen((progress) {
      kPrint("Write progress: ${(progress * 100).toStringAsFixed(1)}%");
    });
  }

  void _listenForAccountUpdate() {
    passportMessageStream.listen((api.PassportMessage message) async {
      if (message.message
          case api.QuantumLinkMessage_AccountUpdate accountUpdate) {
        kPrint("Got account update!");
        final payload = accountUpdate.field0.update;
        kPrint("Got payload! ${payload.length}");
        final config = await EnvoyAccountHandler.getConfigFromRemote(
            remoteUpdate: payload);
        kPrint(
            "Got config ${config.id} ${config.descriptors.map((e) => e.external_)}");
        final fingerprint =
            NgAccountManager.getFingerprint(config.descriptors.first.internal);
        if (fingerprint == null) {
          throw Exception("Invalid fingerprint $fingerprint");
        }
        final dir = NgAccountManager.getAccountDirectory(
            deviceSerial: config.deviceSerial ?? "prime",
            network: config.network.toString(),
            fingerprint: fingerprint,
            number: config.index);
        kPrint("Account path! ${dir.path}");

        if (await dir.exists()) {
          EnvoyReport().log("AccountManager",
              "Failed to create account directory for ${config.name}:${config.deviceSerial}, already exists: ${dir.path}");
          throw Exception("Account already paired");
        } else {
          await dir.create(recursive: true);
        }

        final accountHandler = await EnvoyAccountHandler.addAccountFromConfig(
            dbPath: dir.path, config: config);
        await NgAccountManager()
            .addAccount(await accountHandler.state(), accountHandler);
        kPrint("Account added!");
      }
    });
  }

  void _listenForShardMessages() {
    passportMessageStream.listen((api.PassportMessage message) async {
      if (message.message is api.QuantumLinkMessage_MagicBackupEnabledRequest) {
        kPrint("Got magic backup enabled request!");
        writeMessage(api.QuantumLinkMessage.magicBackupEnabledResponse(
            api.MagicBackupEnabledResponse(enabled: true)));
      }

      if (message.message
          case api.QuantumLinkMessage_BackupShardRequest request) {
        kPrint("Got shard backup request!");
        final shard = request.field0.field0;

        // TODO: add shard ids to API
        try {
          await PrimeShard().addShard(shard: shard.payload);
          writeMessage(api.QuantumLinkMessage.backupShardResponse(
              api.BackupShardResponse_Success()));
          kPrint("Shard backed up!");
        } catch (e, _) {
          kPrint("Shard backup failure: $e");
          writeMessage(api.QuantumLinkMessage.backupShardResponse(
              api.BackupShardResponse_Success()));
        }
      }

      if (message.message
          case api.QuantumLinkMessage_RestoreShardRequest request) {
        kPrint("Got shard restore request!");
        final fingerprint = request.field0.seedFingerprint;

        try {
          final shard = await PrimeShard()
              .getShard(fingerprint: Uint8List.fromList(fingerprint));
          if (shard == null) {
            throw Exception("Shard not found!");
          }

          writeMessage(api.QuantumLinkMessage.restoreShardResponse(
              api.RestoreShardResponse_Success(
                  api.Shard(payload: shard.shard))));
          kPrint("Shard restored!");
        } catch (e, _) {
          kPrint("Shard restore failure: $e");
          writeMessage(api.QuantumLinkMessage.backupShardResponse(
              api.BackupShardResponse_Error(e.toString())));
        }
      }
    });
  }

  Future getPermissions() async {
    try {
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
    } catch (e, stack) {
      kPrint("Error getting permissions: $e", stackTrace: stack);
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
    if (Platform.isLinux) {
      return false;
    }

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
  Future<void> checkDeviceStates() async {
    kPrint("Checking device states...");
    try {
      kPrint(
          "Connected devices: ${connectedDevices.map((d) => "${d.id} :: ${d.name}").join(", name")}");
      if (connectedDevices.isNotEmpty) {
        bool foundDevice = false;
        for (var device in Devices().getPrimeDevices) {
          if (device.type == DeviceType.passportPrime &&
              connectedDevices.map((d) => d.id).contains(device.bleId)) {
            foundDevice = true;
            break;
          }
        }
        //found a device, devices is not completed onboarding
        if (!foundDevice) {
          kPrint("Disconnecting from Prime");
          await BluetoothManager().removeConnectedDevice();
        }
      }
    } catch (e, stack) {
      kPrint("Error checking device states: $e", stackTrace: stack);
    }
  }

  Future scan() async {
    bool isDenied = await isBluetoothDenied();
    if (Platform.isLinux || !isDenied) {
      kPrint("Scanning...");
      await bluart.scan(filter: ["6E400001-B5A3-F393-E0A9-E50E24DCCA9E"]);
    }
  }

  Future<List<Uint8List>> encodeMessage(
      {required api.QuantumLinkMessage message}) async {
    DateTime dateTime = await NTP.now();
    final timestampSeconds = (dateTime.millisecondsSinceEpoch ~/ 1000);

    api.EnvoyMessage envoyMessage =
        api.EnvoyMessage(message: message, timestamp: timestampSeconds);

    return await api.encode(
      message: envoyMessage,
      sender: _qlIdentity!,
      recipient: _recipientXid!,
    );
  }

  Future<void> pair(api.XidDocument recipient) async {
    _recipientXid = recipient;
    kPrint("pair: $hashCode");

    kPrint("Pairing...");
    final xid = await api.serializeXid(quantumLinkIdentity: _qlIdentity!);

    final recipientXid =
        await api.serializeXidDocument(xidDocument: _recipientXid!);

    await writeMessage(api.QuantumLinkMessage.pairingRequest(
        api.PairingRequest(xidDocument: xid)));

    // Listen for response
    listen(id: bleId);
    //Future.delayed(Duration(seconds: 2));

    // TODO: handle this in same place
    PrimeDevice prime = PrimeDevice(bleId, recipientXid);
    await EnvoyStorage().savePrime(prime);

    connected = true;
  }

  Future<void> writeMessage(api.QuantumLinkMessage message) async {
    kPrint("Sending message: $message");

    final encoded = await encodeMessage(message: message);
    kPrint("Encoded message!");

    await _writeWithProgress(encoded);
  }

  Future<void> addDevice(String serialNumber, String firmwareVersion,
      String bleId, DeviceColor deviceColor) async {
    Devices().add(Device("Prime", DeviceType.passportPrime, serialNumber,
        DateTime.now(), firmwareVersion, EnvoyColors.listAccountTileColors[0],
        bleId: bleId, deviceColor: deviceColor));
  }

  Future<void> removeConnectedDevice() async {
    if (connected) {
      disconnect();
    }

    EnvoyStorage().deletePrimeByBleId(bleId);

    bleId = "";
    _recipientXid = null;
  }

  Future disconnect() async {
    await bluart.disconnect(id: bleId);
    connected = false;
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

  Future<void> connect({required String id}) async {
    kPrint("Connecting to: $id");

    bleId = id;
    await bluart.connect(id: id);
    connected = true;

    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> listen({required String id}) async {
    _decoder = await api.getDecoder();
    _subscription = bluart.read(id: id).listen((bleData) {
      decode(bleData).then((value) {
        if (value != null) {
          _passportMessageStream.add(value);
          kPrint(
              "Got Passport message type: ${value.message.runtimeType} ${value.message}");
          if (value
              case api.QuantumLinkMessage_BroadcastTransaction transaction) {
            kPrint("Got the Broadcast Transaction");
            _transactionStream.add(transaction);
          }
        }
      }, onError: (e) {
        kPrint("Error decoding: $e");
      });
    });
  }

  Future<api.PassportMessage?> decode(Uint8List bleData) async {
    _decoder ??= await api.getDecoder();
    api.DecoderStatus decoderStatus = await api.decode(
        data: bleData.toList(),
        decoder: _decoder!,
        quantumLinkIdentity: _qlIdentity!);
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

  Future<void> restorePrimeDevice() async {
    try {
      List<PrimeDevice> primes = await EnvoyStorage().getAllPrimes();

      if (primes.isEmpty) {
        return;
      }

      PrimeDevice prime = primes.last;

      // Convert the xidDocument to a List<int>
      final List<int> xidBytes = prime.xidDocument.toList();

      final api.XidDocument recipientXid = await api.deserializeXid(
        data: xidBytes,
      );

      _recipientXid = recipientXid;
      bleId = prime.bleId;
    } catch (e) {
      kPrint('Error deserializing XidDocument: $e');
    }
  }

  Future<void> restoreQuantumLinkIdentity() async {
    try {
      _qlIdentity = await EnvoyStorage().getQuantumLinkIdentity();
    } catch (e) {
      kPrint('Error deserializing QL id: $e');
    }
  }

  Future<void> sendExchangeRate() async {
    if (_sendingData) {
      return;
    }
    try {
      final exchangeRate = ExchangeRate();

      // TODO: remove the randomness post-demo
      final exchangeRateMessage = api.ExchangeRate(
        currencyCode: "USD",
        rate: exchangeRate.usdRate! + Random().nextDouble() * 10,
      );

      writeMessage(api.QuantumLinkMessage.exchangeRate(exchangeRateMessage));
    } catch (e) {
      kPrint('Failed to send exchange rate: $e');
    }
  }

  void setupExchangeRateListener() {
    ExchangeRate().addListener(() async {
/*      if (connected) {
        kPrint("Sending exchange rate");
        await sendExchangeRate();
      }*/
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

    kPrint("TELLING PRIME THERE'S UPDATES");
    await writeMessage(response);
  }

  Future<void> sendFirmwareFetchEvent(api.FirmwareFetchEvent event) async {
    await writeMessage(api.QuantumLinkMessage.firmwareFetchEvent(event));
  }

  Future<void> sendFirmwarePayload(List<Uint8List> patches) async {
    for (final (patchIndex, patch) in patches.indexed) {
      kPrint("sending patch $patchIndex of size ${patch.length} bytes");
      final chunks = await api.splitFwUpdateIntoChunks(
          patchIndex: patchIndex,
          totalPatches: patches.length,
          patchBytes: patch,
          chunkSize: BigInt.from(10000));
      kPrint("split patch into ${chunks.length} chunks");

      for (final (chunkIndex, chunk) in chunks.indexed) {
        kPrint("sending chunk $chunkIndex of patch $patchIndex");
        await writeMessage(chunk);
      }
    }
    await writeMessage(api.QuantumLinkMessage.firmwareFetchEvent(
        api.FirmwareFetchEvent.complete()));
  }

  Future<void> _writeWithProgress(List<Uint8List> data) async {
    final completer = Completer<void>();
    _sendingData = true;

    final writeStream = bluart.writeAll(id: bleId, data: data);

    _writeProgressSubscription?.cancel();
    _writeProgressSubscription = writeStream.listen(
      (progress) {
        _writeProgressController.add(progress);
      },
      onDone: () {
        kPrint("Progress stream done!");
        _sendingData = false;
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
      onError: (e) {
        kPrint("Progress stream errored out!");
        _sendingData = false;
        _writeProgressController.addError(e);
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
    );

    return completer.future;
  }

  void dispose() {
    _subscription?.cancel();
    _writeProgressSubscription?.cancel();
  }
}

class SendProgressNotifier extends StateNotifier<double> {
  final Ref ref;
  StreamSubscription<double>? _sub;
  DateTime? _startTime;
  Duration _elapsed = Duration.zero;

  SendProgressNotifier(this.ref) : super(0.0) {
    _listen();
  }

  void _listen() {
    _sub = BluetoothManager().writeProgressStream.listen(
      (progress) {
        if (_startTime == null && progress > 0) {
          _startTime = DateTime.now();
          _elapsed = Duration.zero;
        }

        state = progress;

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
}
