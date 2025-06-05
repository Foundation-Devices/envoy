// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:bluart/bluart.dart' as bluart;
import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/business/prime_device.dart';
import 'package:envoy/business/scv_server.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/ntp.dart';
import 'package:foundation_api/foundation_api.dart' as api;
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_value.dart';
import 'package:envoy/util/envoy_storage.dart';

class BluetoothManager {
  StreamSubscription? _subscription;
  static final BluetoothManager _instance = BluetoothManager._internal();
  UuidValue rxCharacteristic =
      UuidValue.fromString("6E400002B5A3F393E0A9E50E24DCCA9E");

  // Persist this across sessions
  api.QuantumLinkIdentity? _qlIdentity;
  final StreamController<api.PassportMessage> _passportMessageStream =
      StreamController<api.PassportMessage>();

  final StreamController<api.PassportMessage> _transactionStream =
      StreamController<api.PassportMessage>();

  api.Dechunker? _decoder;
  api.XidDocument? _recipientXid;

  bool connected = false;

  bool _sendingData = false;

  factory BluetoothManager() {
    return _instance;
  }

  Stream<api.PassportMessage> get passportMessageStream =>
      _passportMessageStream.stream.asBroadcastStream();

  Stream<api.PassportMessage> get transactionStream =>
      _transactionStream.stream.asBroadcastStream();

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

  _init() async {
    await getPermissions();

    await api.RustLib.init();
    await bluart.RustLib.init();

    events = bluart.init().asBroadcastStream();

    kPrint("QL Identity: $_qlIdentity");

    await restorePrimeDevice();
    await restoreQuantumLinkIdentity();

    kPrint("QL Identity: $_qlIdentity");

    events?.listen((bluart.Event event) async {
      if (event is bluart.Event_DeviceConnected) {
        connected = true;
      }

      if (event is bluart.Event_DeviceDisconnected) {
        connected = false;
      }

      if (event is bluart.Event_ScanResult) {
        kPrint("Scan result received, bleId = $bleId");
        if (bleId == "") {
          return;
        }

        for (final device in event.field0) {
          kPrint("Paired device found: ${device.id}");
          if (device.id == bleId && !connected) {
            await connect(id: device.id);
            await listen(id: bleId);
          }
        }
      }
    });

    if (_qlIdentity == null) {
      await _generateQlIdentity();
    }

    await scan();
  }

  getPermissions() async {
    await Permission.bluetooth.request();
    await Permission.bluetoothConnect.request();
    // TODO: remove this
    // Envoy will be getting the BT addresses via QR
    await Permission.bluetoothScan.request();
  }

  scan() async {
    await bluart.scan(filter: [""]);
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
    _sendingData = true;
    _recipientXid = recipient;
    kPrint("pair: $hashCode");

    kPrint("Pairing...");
    final xid = await api.serializeXid(quantumLinkIdentity: _qlIdentity!);

    final recipientXid =
        await api.serializeXidDocument(xidDocument: _recipientXid!);

    api.PairingRequest request = api.PairingRequest(xidDocument: xid);
    kPrint("Encoding...");

    final encoded = await encodeMessage(
        message: api.QuantumLinkMessage.pairingRequest(request));

/*    kPrint("Encoded...");
    kPrint("post-decode quantum isDisposed = ${qlIdentity!.isDisposed}");
    kPrint("Number of chunks: ${encoded.length}");*/

    await bluart.writeAll(id: bleId, data: encoded);

    // Listen for response
    listen(id: bleId);
    Future.delayed(Duration(seconds: 1));

    connected = true;
    _sendingData = false;

    PrimeDevice prime = PrimeDevice(bleId, recipientXid);
    await EnvoyStorage().savePrime(prime);
  }

  Future<void> sendPsbt(String accountId, String psbt) async {
    _sendingData = true;
    final encoded = await encodeMessage(
        message: api.QuantumLinkMessage.signPsbt(
            api.SignPsbt(psbt: psbt, accountId: accountId)));

    kPrint("before sending psbt");
    await bluart.writeAll(id: bleId, data: encoded);
    _sendingData = false;
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
  }

  Future<void> listen({required String id}) async {
    _decoder = await api.getDecoder();
    _subscription = bluart.read(id: id).listen((bleData) {
      decode(bleData).then((value) {
        //kPrint("Dechunked: {$value}");
        if (value != null) {
          _passportMessageStream.add(value);
          kPrint(
              "get passport message type:: ${value.message.runtimeType} ${value.message}");
          _transactionStream.add(value);
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
    _sendingData = true;
    final encoded = await encodeMessage(
      message: api.QuantumLinkMessage.onboardingState(state),
    );

    await bluart.writeAll(id: bleId, data: encoded);
    _sendingData = false;
  }

  Future<void> send(api.QuantumLinkMessage message) async {
    _sendingData = true;
    final encoded = await encodeMessage(
      message: message,
    );
    await bluart.writeAll(id: bleId, data: encoded);
    _sendingData = false;
  }

  Future<void> sendFirmwarePayload() async {
    _sendingData = true;
    // Create 100 KB of random data
    final random = Random();
    final payloadSize = 100 * 1024; // 100 KB
    final randomBytes = Uint8List.fromList(
      List.generate(payloadSize, (_) => random.nextInt(256)),
    );

    final payload = api.FirmwarePayload(payload: randomBytes);

    final encoded = await encodeMessage(
      message: api.QuantumLinkMessage.firmwarePayload(payload),
    );

    await bluart.writeAll(id: bleId, data: encoded);
    _sendingData = false;
  }

  Future<void> sendChallengeMessage() async {
    api.SecurityChallengeMessage? challenge =
        await ScvServer().getPrimeChallenge();

    if (challenge == null) {
      // TODO: SCV what now?
      kPrint("No challenge available");
      return;
    }
    _sendingData = true;

    final encoded = await encodeMessage(
      message: api.QuantumLinkMessage.securityChallengeMessage(challenge),
    );

    await bluart.writeAll(id: bleId, data: encoded);
    _sendingData = false;
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

      final encoded = await encodeMessage(
        message: api.QuantumLinkMessage.exchangeRate(exchangeRateMessage),
      );

      await bluart.writeAll(id: bleId, data: encoded);
    } catch (e) {
      kPrint('Failed to send exchange rate: $e');
    }
  }

  void setupExchangeRateListener() {
    ExchangeRate().addListener(() async {
      if (connected) {
        kPrint("Sending exchange rate");
        await sendExchangeRate();
      }
    });
  }

  dispose() {
    _subscription?.cancel();
  }
}
