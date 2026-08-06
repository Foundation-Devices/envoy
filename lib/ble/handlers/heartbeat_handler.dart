// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ble/quantum_link_router.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/ntp.dart';
import 'package:foundation_api/foundation_api.dart' as api;

/// Handler for heartbeat messages over Quantum Link.
/// Responds to incoming heartbeat messages by sending a heartbeat back.
class HeartbeatHandler extends PassportMessageHandler {
  DateTime? lastHeartbeat;
  HeartbeatHandler(super.connection);

  @override
  bool canHandle(api.QuantumLinkMessage message) {
    return message is api.QuantumLinkMessage_Heartbeat;
  }

  @override
  Future<void> handleMessage(api.QuantumLinkMessage message) async {
    if (message
        case api.QuantumLinkMessage_Heartbeat(field0: final heartbeat)) {
      kPrint("Received heartbeat, sending heartbeat response");
      lastHeartbeat = DateTime.now();
      qlConnection.onHeartbeatReceived();
      final success = await qlConnection.writeMessage(
        api.QuantumLinkMessage.heartbeat(
          api.Heartbeat(
            requestId: heartbeat.requestId,
            timestampMs: BigInt.from(
              NTPUtil().dateTime.millisecondsSinceEpoch,
            ),
          ),
        ),
      );
      kPrint("Heartbeat response write result: $success");
    }
  }
}
