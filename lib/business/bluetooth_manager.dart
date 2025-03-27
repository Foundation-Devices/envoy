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
  final StreamController<api.PassportMessage> _passportMessageStream =
      StreamController<api.PassportMessage>();

  api.Dechunker? _decoder;
  api.XidDocument? _recipientXid;

  factory BluetoothManager() {
    return _instance;
  }

  get passportMessageStream => _passportMessageStream.stream;

  String bleId = "";

  Stream<List<bluart.BleDevice>>? devices;

  static Future<BluetoothManager> init() async {
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
    devices = await bluart.init().asBroadcastStream();
    _generateQlIdentity();
  }

  getPermissions() async {
    await Permission.bluetooth.request();
    await Permission.bluetoothConnect.request();
    // TODO: remove this
    // Envoy will be getting the BT addresses via QR
    await Permission.bluetoothScan.request();
  }

  scan() {
    bluart.scan(filter: [""]);
  }

  Future<List<Uint8List>> encodeMessage(
      {required api.QuantumLinkMessage message}) async {
    api.EnvoyMessage envoyMessage =
        api.EnvoyMessage(message: message, timestamp: 0);

    return await api.encode(
      message: envoyMessage,
      sender: qlIdentity!,
      recipient: _recipientXid!,
    );
  }

  Future<void> pair(api.XidDocument recipient) async {
    _recipientXid = recipient;
    kPrint("pair: $hashCode");

    kPrint("Pairing...");
    final xid = await api.serializeXid(quantumLinkIdentity: qlIdentity!);
    api.PairingRequest request = api.PairingRequest(xidDocument: xid);
    kPrint("Encoding...");

    final encoded = await encodeMessage(
        message: api.QuantumLinkMessage.pairingRequest(request));

    kPrint("Encoded...");

    kPrint("post-decode quantum isDisposed = ${qlIdentity!.isDisposed}");

    kPrint("Number of chunks: ${encoded.length}");

    await bluart.writeAll(id: bleId, data: encoded);

    // Listen for response
    listen(id: bleId);
    Future.delayed(Duration(seconds: 1));
    //kPrint("writing after listen...");
    //await bluart.write(id: bleId, data: "123".codeUnits);
  }

  Future<void> sendPsbt(String descriptor, String psbt) async {
    final encoded = await encodeMessage(
        message: api.QuantumLinkMessage.signPsbt(api.SignPsbt(descriptor: descriptor, psbt: psbt)));

    kPrint("before sending psbt");
    await bluart.writeAll(id: bleId, data: encoded);
  }

  void _generateQlIdentity() async {
    try {
      kPrint("Generating ql identity...");
      qlIdentity = await api.generateQlIdentity();
      kPrint("boot quantum isDisposed = ${qlIdentity!.isDisposed}");
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
  }

  void listen({required String id}) async {
    _decoder = await api.getDecoder();
    _subscription = bluart.read(id: id).listen((bleData) {
      decode(bleData).then((value) {
        //kPrint("Dechunked: {$value}");
        if (value != null) {
          _passportMessageStream.add(value);
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
        quantumLinkIdentity: qlIdentity!);
    if (decoderStatus.payload != null) {
      _decoder = await api.getDecoder();
      return decoderStatus.payload;
    } else {
      return null;
    }
  }

  Future<void> sendOnboardingState(api.OnboardingState state) async {
    final encoded = await encodeMessage(
      message: api.QuantumLinkMessage.onboardingState(state),
    );



    await bluart.writeAll(id: bleId, data: encoded);


  }

  dispose() {
    _subscription?.cancel();
  }
}
