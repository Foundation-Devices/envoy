// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ble/qlv2/protocol_handler.dart';
import 'package:envoy/business/devices.dart';
import 'package:envoy/channels/ql_connection.dart';
import 'package:envoy/ui/envoy_colors.dart' as legacy_colors;
import 'package:envoy/util/console.dart';
import 'package:qlv2/qlv2.dart' as qlv2;

Future<void> saveCompletedQlv2PassportDevice({
  required QLConnection device,
  required QLV2ProtocolHandler handler,
  qlv2.PassportDetailsResponse? passportDetails,
}) async {
  passportDetails ??= await handler.fetchPassportDetails();
  final identityBytes = await handler.ownIdentity();
  final peerBundleBytes = await handler.getPersistedPeer();
  if (identityBytes.isEmpty ||
      peerBundleBytes == null ||
      peerBundleBytes.isEmpty) {
    throw StateError('QL v2 pairing credentials are incomplete.');
  }
  final serial = passportDetails.serial.field0;
  device.primeSerial = serial;
  final existingDevice =
      Devices().getDeviceBySerial(serial) ?? device.getDevice();

  final deviceName = existingDevice?.name ??
      (passportDetails.deviceName.trim().isEmpty
          ? "Passport Prime"
          : passportDetails.deviceName.trim());
  final peripheralId = device.lastDeviceStatus.peripheralId;

  kPrint(
    "[PrimeOnboarding] qlv2_device_storage: saving device "
    "serial=$serial name=$deviceName bleId=${device.deviceId} "
    "peripheralId=${peripheralId == null || peripheralId.isEmpty ? device.deviceId : peripheralId} "
    "existing=${existingDevice != null} onboardingComplete=true",
  );

  await Devices().add(
    Device(
      deviceName,
      _mapQlv2PassportModel(passportDetails.model),
      serial,
      existingDevice?.datePaired ?? DateTime.now(),
      passportDetails.firmwareVersion.field0,
      existingDevice?.color ??
          legacy_colors.EnvoyColors.listAccountTileColors[0],
      bleId: device.deviceId,
      peripheralId: peripheralId == null || peripheralId.isEmpty
          ? device.deviceId
          : peripheralId,
      deviceColor: passportDetails.color == qlv2.PassportColor.dark
          ? DeviceColor.dark
          : DeviceColor.light,
      qlv2Identity: identityBytes,
      qlv2PeerBundle: peerBundleBytes,
      protocol: PrimeConnectionProtocol.qlV2,
      pairedAccountIds: existingDevice?.pairedAccountIds,
      primeBackupEnabled: existingDevice?.primeBackupEnabled,
      onboardingComplete: true,
    ),
  );

  kPrint(
    "[PrimeOnboarding] qlv2_device_storage: saved device serial=$serial",
  );
}

Future<bool> prepareQlv2PassportDeviceAfterPairing({
  required QLConnection device,
  required QLV2ProtocolHandler handler,
}) async {
  final passportDetails = await handler.fetchPassportDetails();
  device.primeSerial = passportDetails.serial.field0;
  if (!passportDetails.onboardingComplete) return false;

  await saveCompletedQlv2PassportDevice(
    device: device,
    handler: handler,
    passportDetails: passportDetails,
  );
  return true;
}

DeviceType _mapQlv2PassportModel(qlv2.PassportModel model) {
  return switch (model) {
    qlv2.PassportModel.gen1 => DeviceType.passportGen1,
    qlv2.PassportModel.gen2 => DeviceType.passportGen12,
    qlv2.PassportModel.prime => DeviceType.passportPrime,
  };
}
