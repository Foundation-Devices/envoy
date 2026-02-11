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
  DeviceHandler(super.connection);

  @override
  bool canHandle(api.QuantumLinkMessage message) {
    return true;
  }

  @override
  Future<void> handleMessage(api.QuantumLinkMessage message) async {}

  @override
  void onDeviceStatus(api.DeviceStatus status) {
    super.onDeviceStatus(status);
    final device = qlConnection.getDevice();
    if (device == null) {
      kPrint("DeviceHandler: No connected device found");
      return;
    }
    if (device.firmwareVersion != status.version) {
      unawaited(Devices().markPrimeUpdated(device.serial, status.version));
      kPrint("Device version updated ${status.version}");
    }
  }
}
