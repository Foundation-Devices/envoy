// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/devices.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/widgets/color_util.dart';
import 'package:envoy/util/xfp_endian.dart';
import 'package:flutter/material.dart';
import 'package:ngwallet/ngwallet.dart';
import 'package:uuid/uuid.dart';

Future<NgAccountConfig> getPassportAccountFromJson(dynamic json) async {
  bool oldJsonFormat = json['xpub'] != null;
  bool taprootEnabled = Settings().taprootEnabled();
  List<NgDescriptor> descriptors = [];

  if (!oldJsonFormat) {
    final bip84 = json["bip84"];
    if (bip84 != null) {
// TODO: try here
      descriptors.add(await getWalletFromJson(bip84));
    }

    final bip86 = json["bip86"];
    if (bip86 != null) {
      descriptors.add(await getWalletFromJson(bip86));
    }
  } else {
    descriptors.add(await getWalletFromJson(json));
  }

  Device device = getDeviceFromJson(json);
  Devices().add(device);

  int accountNumber = json["acct_num"];

  String externalDescriptor = descriptors.first.external_ ?? "";
  int publicKeyIndex = externalDescriptor.indexOf("]") + 1;

  String publicKeyType =
      externalDescriptor.substring(publicKeyIndex, publicKeyIndex + 4);

  Network network;
  if (publicKeyType == "tpub") {
    network = Network.testnet4;
  } else {
    network = Network.bitcoin;
  }

  AddressType addressType = AddressType.p2Wpkh;

  if (taprootEnabled) {
    //if any of the descriptors is taproot,
    //then use taproot as the preferred address type
    for (var descriptor in descriptors) {
      if (descriptor.addressType == AddressType.p2Tr) {
        addressType = AddressType.p2Tr;
        break;
      }
    }
  }

  int colorIndex = (accountNumber) % (EnvoyColors.listAccountTileColors.length);
  Color color = EnvoyColors.listAccountTileColors[colorIndex];
  if (accountNumber == 2147483646) {
    color = Colors.red;
  }
  NgAccountConfig accountConfig = NgAccountConfig(
      name: json["acct_name"] + " (#${accountNumber.toString()})",
      color: color.toHex(),
      seedHasPassphrase: false,
      deviceSerial: device.serial,
      dateAdded: DateTime.now().toString(),
      preferredAddressType: addressType,
      index: accountNumber,
      descriptors: descriptors,
      dateSynced: null,
      id: Uuid().v4(),
      network: network);
  return accountConfig;
}

Device getDeviceFromJson(json) {
  var fwVersion = json["fw_version"].toString();
  var serial = json["serial"].toString();
  String deviceName = json.containsKey("device_name") &&
          json["device_name"].toString().isNotEmpty
      ? json["device_name"].toString()
      : "Passport";

// Pick colours
  int colorIndex =
      Devices().devices.length % (EnvoyColors.listTileColorPairs.length);

  Device device = Device(
      deviceName,
      json["hw_version"] == 1
          ? DeviceType.passportGen1
          : DeviceType.passportGen12,
      serial,
      DateTime.now(),
      fwVersion,
      EnvoyColors.listAccountTileColors[colorIndex]);
  return device;
}

Future<NgDescriptor> getWalletFromJson(json) async {
  String scriptType = json["derivation"].contains("86") ? "tr" : "wpkh";
  String xfp = reverseXfpStringEndianness(json["xfp"].toRadixString(16));
  String derivation =
      json["derivation"].toString().replaceAll("'", "h").replaceAll("m", "");
  String xpub = json["xpub"];

  var partialDescriptor = "$scriptType([$xfp$derivation]$xpub";

  var externalDescriptor = "$partialDescriptor/0/*)";
  var internalDescriptor = "$partialDescriptor/1/*)";
  AddressType addressType = AddressType.p2Wpkh;
  if (scriptType == "tr") {
    addressType = AddressType.p2Tr;
  }
  return NgDescriptor(
      internal: internalDescriptor,
      external_: externalDescriptor,
      addressType: addressType);
}
