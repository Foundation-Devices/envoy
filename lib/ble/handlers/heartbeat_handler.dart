// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ble/quantum_link_router.dart';
import 'package:envoy/util/console.dart';
import 'package:foundation_api/foundation_api.dart' as api;

/// Handler for heartbeat messages over Quantum Link.
/// Responds to incoming heartbeat messages by sending a heartbeat back.
class HeartbeatHandler extends PassportMessageHandler {
  HeartbeatHandler(super.writer);

  @override
  bool canHandle(api.QuantumLinkMessage message) {
    return message is api.QuantumLinkMessage_Heartbeat;
  }

  @override
  Future<void> handleMessage(
      api.QuantumLinkMessage message, String bleId) async {
    if (message case api.QuantumLinkMessage_Heartbeat _) {
      kPrint("Received heartbeat, sending heartbeat response");
      await _sendHeartbeatResponse();
    }
  }

  Future<void> _sendHeartbeatResponse() async {
    final heartbeat = api.Heartbeat();
    await writer.writeMessage(api.QuantumLinkMessage.heartbeat(heartbeat));
    kPrint("Heartbeat response sent");
  }
}
