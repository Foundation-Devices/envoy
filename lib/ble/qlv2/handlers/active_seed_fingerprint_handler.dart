// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ble/qlv2/rpc_handler.dart';
import 'package:envoy/channels/ql_connection.dart';
import 'package:qlv2/qlv2.dart' as qlv2;

class QLV2PassportActiveSeedFingerprintHandler
    implements QLV2SessionEventHandler<qlv2.ActiveSeedFingerprint> {
  @override
  Future<void> handleEvent(
    qlv2.ActiveSeedFingerprint event,
    QLConnection device,
  ) async {
    device.qlHandler.bleAccountHandler.handleActiveSeedFingerprint(
      fingerprint: event.fingerprint,
      hasPassphrase: event.hasPassphrase,
    );
  }
}
