// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ble/qlv2/rpc_dispatcher.dart';
import 'package:envoy/channels/ql_connection.dart';
import 'package:envoy/util/console.dart';
import 'package:qlv2/qlv2.dart' as qlv2;

class QLV2CurrentTimeHandler
    implements QLV2RequestHandler<qlv2.InboundRpc_CurrentTime> {
  @override
  Future<void> handleRequest(
    qlv2.InboundRpc_CurrentTime rpc,
    QLConnection device,
  ) async {
    kPrint(
      "Received Time Request",
    );
    final dateTime = DateTime.now();
    final serverTimeMillis = BigInt.from(dateTime.millisecondsSinceEpoch);

    await rpc.field0.respond(
      response: qlv2.CurrentTimeResponse(
        serverTimeMillis: serverTimeMillis,
      ),
    );
    kPrint(
      "Successfully sent QL v2 current time response with "
      "serverTimeMillis: $serverTimeMillis",
    );
  }
}
