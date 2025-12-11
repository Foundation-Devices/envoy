// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// ignore_for_file: constant_identifier_names
import 'dart:async';

import 'package:envoy/ble/quantum_link_router.dart';
import 'package:envoy/business/devices.dart';
import 'package:envoy/util/console.dart';
import 'package:foundation_api/foundation_api.dart' as api;

// Listens to all passport messages. Device-specific events should be handled here,
// such as updating the KeyOS version, battery percentage,
class DeviceHandler extends PassportMessageHandler {
  DeviceHandler(super.writer);

  @override
  bool canHandle(api.QuantumLinkMessage message) {
    return true;
  }

  @override
  Future<void> handleMessage(
      api.QuantumLinkMessage message, String bleId) async {}

  @override
  void onDeviceStatus(api.DeviceStatus stauts, Device device) {
    super.onDeviceStatus(stauts, device);
    if (device.firmwareVersion != stauts.version) {
      unawaited(Devices().markPrimeUpdated(device.serial, stauts.version));
      kPrint("Device version updated ${stauts.version}");
    }
  }
}
