// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ble/qlv2/rpc_handler.dart';
import 'package:envoy/business/devices.dart';
import 'package:envoy/channels/ql_connection.dart';
import 'package:qlv2/qlv2.dart' as qlv2;

class QLV2PassportDetailsUpdatedHandler
    implements QLV2SessionEventHandler<qlv2.PassportDetailsResponse> {
  @override
  Future<void> handleEvent(
    qlv2.PassportDetailsResponse event,
    QLConnection device,
  ) async {
    await Devices().updatePrimeDetails(
      serial: event.serial.field0,
      name: event.deviceName,
      firmwareVersion: event.firmwareVersion.field0,
      onboardingComplete: event.onboardingComplete,
    );
  }
}
