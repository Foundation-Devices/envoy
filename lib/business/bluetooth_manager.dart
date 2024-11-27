// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:typed_data';
import 'package:envoy/util/console.dart';
import 'package:bluart/bluart.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_value.dart';
import 'package:foundation_api/foundation_api.dart' as api;

class BluetoothManager {
  static final BluetoothManager _instance = BluetoothManager._internal();
  Adapter? adapter;
  List<BluartPeripheral> peripherals = [];
  BluartPeripheral? connected;

  UuidValue rxCharacteristic =
      UuidValue.fromString("6E400002B5A3F393E0A9E50E24DCCA9E");

  factory BluetoothManager() {
    return _instance;
  }

  static Future<BluetoothManager> init() async {
    var singleton = BluetoothManager._instance;
    await RustLib.init();
    await api.RustLib.init();
    return singleton;
  }

  BluetoothManager._internal() {
    kPrint("Instance of BluetoothManager created!");
  }

  Future<bool> connectToPrime() async {
    for (final peripheral in peripherals) {
      final name = await getNameFromPerihperal(peripheral: peripheral);
      kPrint("Found $name");
      if (name.contains("Prime")) {
        await connectPeripheral(peripheral: peripheral);
        connected = peripheral;
        return true;
      }
    }
    return false;
  }

  Future<bool> sayHello() async {
    if (connected == null) {
      return false;
    }

    String hello = "HELLO PRIME";
    await writeTo(
        peripheral: connected!,
        data: hello.codeUnits,
        rxCharacteristic: rxCharacteristic);

    return true;
  }

  scan() async {
    try {
      // Ensure adapter is initialized
      adapter ??= await firstAdapter();
      List<BluartPeripheral> result =
          await getPeripherals(adapter: adapter!, tcpPorts: ["127.0.0.1:9090"]);

      peripherals = result;
    } catch (e) {
      kPrint('Error searching for devices: $e');
    }
  }

  pair(String scannedQr) async {
    // get binary pairing envelope and send
    //ur:discovery/1-1/lpadadcfadcycyknksdpfehkadcytpsplftpsplrtpsotansfginieinjkiajlkoihjpkkoytpsotansfljoidjzkpihjyjljljyisguihjpkoiniaihtpsotpdagdnthsghbybecffwbalevtsffwdiwensesoytpsotansflktidjzkpihjyjljljyisfxishsjphsiajyihjpinjkjyiniatpsotpdagdfwrovebnrpchfwnllsbwrygahnjllpbtoytpsotansfliyjkihjtieihjptpsotansgylftanshfhdcxinayhnkkpmjnssfeaetesomyrksgtbwtwsaxkokspmynltrhzsbklebgyahsjonstansgrhdcxkedlaxgyetdifhzekogelfkbfhssnsotsnrphhsaiosetodtrfotfngyglclwzkpoyaxtpsotansghhdfzdpytswheemhphpdwbnisisjsondlkglaiyylplyahygdaowfaovoiogyztgrfhonwtaylgmnlgahdslaiohylffrdyfliyrsdwetcwbdjoaowpmuvdjymyoyqzvecsnlbgreyncp
    final data = await pair(scannedQr);
    writeData(data);
  }

  writeData(List<int> data) async {
    kPrint("data to transmit2: ${data.length}");
    List<int> dataToWrite = [...numberToByteList(data.length), ...data];

    // Can't do more than 256 at a time? Find out why
    // It seems writing is only reliable in 256 byte chunks (tops)
    // TODO: coordinate with Lucio on the link layer
    int lenWritten = 0;
    while (lenWritten < dataToWrite.length) {
      await writeTo(
          peripheral: connected!,
          data: dataToWrite.sublist(lenWritten, lenWritten + 256),
          rxCharacteristic: rxCharacteristic);

      lenWritten += 256;
      kPrint("written $lenWritten!");
    }
  }

  Future<List<int>> readData() async {
    return readFrom(peripheral: connected!, characteristic: rxCharacteristic);
  }
}

List<int> numberToByteList(int number) {
  final byteData = ByteData(4); // 32-bit
  byteData.setUint32(0, number, Endian.little);
  return byteData.buffer.asUint8List().toList();
}
