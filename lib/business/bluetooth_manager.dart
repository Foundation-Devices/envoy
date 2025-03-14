// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:typed_data';

import 'package:bluart/bluart.dart' as bluart;
import 'package:envoy/util/console.dart';
import 'package:foundation_api/foundation_api.dart' as api;
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_value.dart';

class BluetoothManager {
  StreamSubscription? _subscription;
  static final BluetoothManager _instance = BluetoothManager._internal();
  UuidValue rxCharacteristic =
      UuidValue.fromString("6E400002B5A3F393E0A9E50E24DCCA9E");
  api.QuantumLinkIdentity? qlIdentity;
  final StreamController<api.PassportMessage> _passPortMessageStream =
      StreamController<api.PassportMessage>();

  api.Dechunker? _deChunker;


  factory BluetoothManager() {
    return _instance;
  }

  get passPortMessageStream => _passPortMessageStream.stream;

  String bleId = "";

  static Future<BluetoothManager> init() async {
    print("INIT CALLED ");
    var singleton = BluetoothManager._instance;
    return singleton;
  }

  BluetoothManager._internal() {
    _init();
    kPrint("Instance of BluetoothManager created!");
  }
  _init() async {
    await api.RustLib.init();
    await bluart.RustLib.init();
    await bluart.init();
    _generateQlIdentity();
  }

  getPermissions() async {
    await Permission.bluetooth.request();
    await Permission.bluetoothConnect.request();
    // TODO: remove this
    // Envoy will be getting the BT addresses via QR
    await Permission.bluetoothScan.request();
  }

  void scan() {
    bluart.scan(filter: [""]);
  }

  Future<List<Uint8List>> encodeMessage(
      {required api.QuantumLinkMessage message,
      required api.XidDocument recipient}) async {
    api.EnvoyMessage envoyMessage =
        api.EnvoyMessage(message: message, timestamp: 0);
    return await api.encode(
      message: envoyMessage,
      sender: qlIdentity!,
      recipient: recipient,
    );
  }

  Future<void> pair(api.XidDocument recipient) async {
    kPrint("pair: $hashCode");

    kPrint("Pairing...");
    api.PairingRequest request = api.PairingRequest();
    kPrint("Encoding...");

    final encoded = await encodeMessage(
        message: api.QuantumLinkMessage.pairingRequest(request),
        recipient: recipient);
    kPrint("Encoded...");

    for (var element in encoded) {
      kPrint("Writing to {$bleId}: {$element}");
      bluart.write(id: bleId, data: element);
    }
  }

  void _generateQlIdentity() async {
    try {
      kPrint("Generating ql identity...");
      qlIdentity = await api.generateQlIdentity();
      // kPrint("Generated ql identity: $qlIdentity");
    } catch (e, stack) {
      kPrint("Couldn't generate ql identity: $e", stackTrace: stack);
    }
  }

  Future<void> connect({required String id}) async {
    kPrint("before connect: $hashCode");

    bleId = id;
    await bluart.connect(id: id);
    kPrint("after connect: $hashCode");
    listen(id: id);
  }

  void listen({required String id}) async {
    _deChunker = await api.getDecoder();
    _subscription = bluart.read(id: id).listen((bleData) {
      dechunkThis(bleData).then((value) {
        _passPortMessageStream.add(value!);
      }, onError: (e) {
        kPrint("Error decoding: $e");
      });
    });
  }

  Future<api.PassportMessage?> dechunkThis(Uint8List bleData) async {
    _deChunker ??= await api.getDecoder();
    api.DecoderStatus decoderStatus = await api.decode(
        data: bleData.toList(),
        decoder: _deChunker!,
        quantumLinkIdentity: qlIdentity!);
    if (decoderStatus.payload != null) {
      _deChunker = await api.getDecoder();
      return decoderStatus.payload;
    } else {
      return null;
    }
  }

  dispose() {
    _subscription?.cancel();
  }
}
