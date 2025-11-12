// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// ignore_for_file: constant_identifier_names///
import 'package:envoy/ble/bluetooth_manager.dart';
import 'package:envoy/ble/quantum_link_router.dart';
import 'package:envoy/business/devices.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/cupertino.dart';
import 'package:foundation_api/foundation_api.dart' as api;
import 'package:foundation_api/foundation_api.dart';

class BleOnboardHandler extends PassportMessageHandler with ChangeNotifier {
  BleOnboardHandler(super.writer);

  @override
  bool canHandle(api.QuantumLinkMessage message) {
    return message is api.QuantumLinkMessage_PairingResponse;
  }

  @override
  Future<void> handleMessage(api.QuantumLinkMessage message) async {
    if (message case api.QuantumLinkMessage_PairingResponse response) {
      _handlePairingResponse(response.field0);
    }
  }

  void _handlePairingResponse(api.PairingResponse response) async {
    try {
      final deviceColor = response.passportColor == PassportColor.dark
          ? DeviceColor.dark
          : DeviceColor.light;
      await BluetoothManager().addDevice(
        response.passportSerial.field0,
        response.passportFirmwareVersion.field0,
        BluetoothManager().bleId,
        deviceColor,
        onboardingComplete: response.onboardingComplete,
      );
    } catch (e, stack) {
      kPrint("Error handling pairing response: $e", stackTrace: stack);
    }
  }
}
