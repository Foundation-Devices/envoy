// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ble/quantum_link_router.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/ntp.dart';
import 'package:flutter/services.dart';
import 'package:foundation_api/foundation_api.dart' as api;

/// Handler for timezone messages over Quantum Link.
/// Responds to incoming timezone messages by sending a timezone back.
class TimeZoneHandler extends PassportMessageHandler {
  TimeZoneHandler(super.writer);
  static const _platform = MethodChannel('envoy');

  @override
  bool canHandle(api.QuantumLinkMessage message) {
    return message is api.QuantumLinkMessage_TimezoneRequest;
  }

  @override
  Future<void> handleMessage(
      api.QuantumLinkMessage message, String bleId) async {
    if (message case api.QuantumLinkMessage_TimezoneRequest _) {
      kPrint("Received timezone, sending timezone response");
      await _sendTimezoneResponse();
    }
  }

  Future<void> _sendTimezoneResponse() async {
    DateTime dateTime = DateTime.now();
    try {
      dateTime = await NTP.now(timeout: const Duration(milliseconds: 500));
    } catch (e) {
      kPrint("NTP error: $e");
    }
    final zone = await _platform.invokeMethod('get_time_zone');

    final timezoneResponse = api.TimezoneResponse(
        offsetMinutes: dateTime.timeZoneOffset.inMinutes, zone: zone);
    await writer.writeMessage(
        api.QuantumLinkMessage.timezoneResponse(timezoneResponse));
    kPrint(
        "Successfully sent timezone response with offsetMinutes: ${dateTime.timeZoneOffset.inMinutes}, zone: $zone");
  }
}
