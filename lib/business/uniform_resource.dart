// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:convert';
import 'dart:typed_data';

import 'package:cbor/cbor.dart' as cbor;
import 'package:envoy/business/scv_server.dart';
import 'package:typed_data/typed_data.dart';
import 'package:ur/ur.dart';
import 'package:uuid/uuid.dart';

abstract class CborObject {
  void appendToCryptoRequest(cbor.MapBuilder tlMap);
}

class UniformResourceWriter {
  final inst = cbor.Cbor();
  late cbor.Encoder cborEncoder;
  cbor.MapBuilder tlMap = cbor.MapBuilder.builder();
  int tlMapIndex = 1;
  UrEncoder? _urEncoder;

  int fragmentLength = 50;
}

class FirmwareVersionRequest extends CborObject {
  @override
  void appendToCryptoRequest(cbor.MapBuilder tlMap) {
    tlMap.writeTag(770);
    tlMap.writeInt(0);
  }
}

class PassportFirmwareVersion extends CborObject {
  String version;

  PassportFirmwareVersion(this.version);

  @override
  void appendToCryptoRequest(cbor.MapBuilder tlMap) {
    tlMap.writeTag(771);
    tlMap.writeString(version);
  }
}

class PassportModel extends CborObject {
  int model;

  PassportModel(this.model);

  @override
  void appendToCryptoRequest(cbor.MapBuilder tlMap) {
    tlMap.writeTag(721);
    tlMap.writeInt(model);
  }
}

class PassportSerial extends CborObject {
  String serial;

  PassportSerial(this.serial);

  @override
  void appendToCryptoRequest(cbor.MapBuilder tlMap) {
    tlMap.writeTag(761);
    tlMap.writeString(serial);
  }
}

class ScvChallengeRequest extends CborObject {
  String id;
  String signature;
  String derSignature;

  ScvChallengeRequest(this.id, this.signature, this.derSignature);

  ScvChallengeRequest.fromServer(Challenge challenge)
      : id = challenge.id,
        signature = challenge.signature,
        derSignature = challenge.derSignature;

  @override
  void appendToCryptoRequest(cbor.MapBuilder tlMap) {
    tlMap.writeTag(710);
    tlMap.writeMap(<int, String>{1: id, 2: signature, 3: derSignature});
  }
}

class ScvChallengeResponse extends CborObject {
  String id;
  List<String> responseWords;

  ScvChallengeResponse(this.id, this.responseWords);

  @override
  void appendToCryptoRequest(cbor.MapBuilder tlMap) {
    tlMap.writeTag(711);
    tlMap.writeMap({2: responseWords, 3: id});
  }
}

class SeedRequest extends CborObject {
  final List<int> seedDigest;

  SeedRequest(this.seedDigest);

  @override
  void appendToCryptoRequest(cbor.MapBuilder tlMap) {
    tlMap.writeTag(500);
    tlMap.writeMap(<int, List<int>>{1: seedDigest});
  }
}

class PsbtSignatureRequest extends CborObject {
  final List<int> psbt;

  PsbtSignatureRequest(this.psbt);

  @override
  void appendToCryptoRequest(cbor.MapBuilder tlMap) {
    tlMap.writeTag(502);
    tlMap.writeMap(<int, List<int>>{1: psbt});
  }
}

class CryptoRequest extends UniformResourceWriter {
  late List<int> uuid;

  // Can embed multiple requests in form of CBOR objects
  List<CborObject> objects = [];

  CryptoRequest({int fragmentLen: 50}) {
    fragmentLength = fragmentLen;
    cborEncoder = inst.encoder;
    generateUuid();
  }

  CryptoRequest.specificUuid(List<int> uuid) : uuid = uuid {
    cborEncoder = inst.encoder;
    _writeTlMapKey();
    tlMap.writeTag(37);

    Uint8Buffer uuidBuffer = Uint8Buffer(16);
    uuidBuffer.addAll(uuid);

    tlMap.writeBytes(uuidBuffer);
  }

  CryptoRequest.fromCbor(Uint8List payload) {
    String keyData = "";

    for (int number in payload) {
      keyData = keyData + number.toRadixString(16).padLeft(2, "0");
    }

    final payloadBuffer = Uint8Buffer();
    payloadBuffer.addAll(payload);

    inst.decodeFromBuffer(payloadBuffer);

    var map = inst.getDecodedData()![0];

    uuid = map[1].toList();

    // TODO: fix this when you upgrade cbor to latest
    if (map.length == 2) {
      objects.add(ScvChallengeRequest(map[2][1], map[2][2], map[2][3]));
    } else if (map.length == 5) {
      objects.add(CryptoHdKey.fromCborMap(map[2]));
      objects.add(PassportModel(map[3]));
      objects.add(PassportFirmwareVersion(map[4]));
      objects.add(PassportSerial(map[5]));
    }
  }

  void _writeTlMapKey() {
    // Key then value (not nice!)
    tlMap.writeInt(tlMapIndex);
    tlMapIndex++;
  }

  String nextPart() {
    encode();

    var buffer = inst.output.getData().cast<int>();

    if (_urEncoder == null) {
      _urEncoder =
          Ur().encoder('crypto-request', Uint8List.fromList(buffer), 50);
    }

    return _urEncoder!.nextPart();
  }

  void encode() {
    for (var request in objects) {
      _writeTlMapKey();
      request.appendToCryptoRequest(tlMap);
    }

    cborEncoder.addBuilderOutput(tlMap.getData());
  }

  void generateUuid() {
    // https://github.com/BlockchainCommons/crypto-commons/blob/master/Docs/ur-99-request-response.md#request--response
    // "A matching UUID, tagged 37"
    _writeTlMapKey();
    tlMap.writeTag(37);

    // UUIDs are 128 bit
    Uint8Buffer uuidBuffer = Uint8Buffer(16);
    uuid = Uuid().v4buffer(uuidBuffer);

    tlMap.writeBytes(uuidBuffer);
  }
}

class CryptoResponse extends UniformResourceWriter {
  List<int>? uuid;
  List<CborObject> objects = [];

  CryptoResponse.fromCbor(Uint8List payload) {
    String keyData = "";

    for (int number in payload) {
      keyData = keyData + number.toRadixString(16).padLeft(2, "0");
    }

    final payloadBuffer = Uint8Buffer();
    payloadBuffer.addAll(payload);

    inst.decodeFromBuffer(payloadBuffer);

    var map = inst.getDecodedData()![0];

    uuid = map[1].toList();

    if (map.length == 3) {
      List<String> responseWords = map[2].values.toList().cast<String>();
      String id = map[3].toString();
      objects.add(ScvChallengeResponse(id, responseWords));
    }
  }
}

class UniformResourceReader {
  UrDecoder urDecoder = Ur().decoder();
  Object? decoded;

  void receive(String data) {
    String type = data.substring(data.indexOf(":") + 1, data.indexOf("/"));

    // More than one forward slash means is multipart
    bool multipart = "/".allMatches(data).length > 1;

    Uint8List payload;
    if (!multipart) {
      payload = Ur.decodeSinglePart(data);
    } else {
      payload = urDecoder.receive(data);
    }

    if (payload.isNotEmpty) {
      if (type == "crypto-hdkey") {
        decoded = CryptoHdKey.fromCbor(payload);
      } else if (type == "crypto-request") {
        decoded = CryptoRequest.fromCbor(payload);
      } else if (type == "crypto-response") {
        decoded = CryptoResponse.fromCbor(payload);
      } else if (type == "bytes") {
        decoded = Binary.fromPayload(payload);
      } else if (type == "crypto-psbt") {
        decoded = CryptoPsbt.fromCbor(payload);
      }
    }
  }
}

enum HdKeyNetwork { mainnet, testnet }

class CryptoHdKey extends CborObject {
  List<int>? keyData;
  List<int>? chainCode;
  HdKeyNetwork? network;
  int? parentFingerprint;

  // TODO: consider having this as a separate object
  List<Index>? keypath;

  String get path {
    String keypathString = "";
    for (var index in keypath!) {
      keypathString = keypathString + "/" + index.key.toString();
      if (index.hardened) {
        keypathString = keypathString + "h";
      }
    }
    return keypathString;
  }

  CryptoHdKey(
      {this.keyData,
      this.chainCode,
      this.network,
      this.parentFingerprint,
      this.keypath});

  CryptoHdKey.fromCbor(Uint8List payload) {
    final inst = cbor.Cbor();
    final payloadBuffer = Uint8Buffer();
    payloadBuffer.addAll(payload);

    inst.decodeFromBuffer(payloadBuffer);

    var map = inst.getDecodedData()![0];

    keyData = map[3].toList();
    chainCode = map[4].toList();

    network = map[5][2] == 0 ? HdKeyNetwork.mainnet : HdKeyNetwork.testnet;
    parentFingerprint = map[8];

    var path = map[6][1];
    if (path != null) {
      keypath = [];
      for (int i = 0; i < path.length; i += 2) {
        keypath!.add(Index(path[i], path[i + 1]));
      }
    }
  }

  CryptoHdKey.fromCborMap(Map map) {
    keyData = map[3].toList();
    chainCode = map[4].toList();

    network = map[5][2] == 0 ? HdKeyNetwork.mainnet : HdKeyNetwork.testnet;
    parentFingerprint = map[8];

    var path = map[6][1];
    if (path != null) {
      keypath = [];
      for (int i = 0; i < path.length; i += 2) {
        keypath!.add(Index(path[i], path[i + 1]));
      }
    }
  }

  @override
  void appendToCryptoRequest(cbor.MapBuilder tlMap) {
    tlMap.writeTag(303);
    List keypathList = [];
    for (var index in keypath!) {
      keypathList.add(index.key);
      keypathList.add(index.hardened);
    }
    tlMap.writeMap({
      3: keyData,
      4: chainCode,
      5: {2: network == HdKeyNetwork.mainnet ? 0 : 1},
      6: {1: keypathList},
      8: parentFingerprint
    });
  }
}

class Index {
  int key;
  bool hardened;

  Index(this.key, this.hardened);
}

class Binary {
  String decoded = "";
  Uint8List payload;

  Binary.fromPayload(this.payload) {
    decoded = String.fromCharCodes(payload);
  }
}

class CryptoPsbt {
  String decoded = "";
  Uint8List payload;

  CryptoPsbt.fromPayload(this.payload) {
    decoded = String.fromCharCodes(payload);
  }

  CryptoPsbt.fromCbor(this.payload) {
    final inst = cbor.Cbor();
    final payloadBuffer = Uint8Buffer();
    payloadBuffer.addAll(payload);

    inst.decodeFromBuffer(payloadBuffer);

    var psbt = inst.getDecodedData()![0];
    decoded = base64Encode(psbt);
  }
}
