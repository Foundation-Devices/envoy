import 'package:envoy/business/devices.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/util/xfp_endian.dart';
import 'package:ngwallet/ngwallet.dart';
import 'package:uuid/uuid.dart';

Future<NgAccountConfig> getPassportAccountFromJson(dynamic json) async {
  List<NgDescriptor> descriptors = [];

  final bip84 = json["bip84"];
  if (bip84 != null) {
// TODO: try here
    descriptors.add(await getWalletFromJson(bip84));
  }

  final bip86 = json["bip86"];
  if (bip86 != null) {
    descriptors.add(await getWalletFromJson(bip86));
  }

  Device device = getDeviceFromJson(json);
  Devices().add(device);

  int accountNumber = json["acct_num"];

  NgAccountConfig accountConfig = NgAccountConfig(
      name: json["acct_name"] + " (#${accountNumber.toString()})",
      color: "blue",
      seedHasPassphrase: false,
      deviceSerial: device.serial,
      dateAdded: DateTime.now().toString(),
      preferredAddressType: AddressType.p2Wpkh,
      index: accountNumber,
      descriptors: descriptors,
      dateSynced: null,
      id: Uuid().v4(),
      network: Network.bitcoin);

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
