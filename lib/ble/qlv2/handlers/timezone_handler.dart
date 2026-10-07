// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ble/qlv2/rpc_dispatcher.dart';
import 'package:envoy/channels/ql_connection.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/services.dart';
import 'package:qlv2/qlv2.dart' as qlv2;

class QLV2TimeZoneHandler
    implements QLV2RequestHandler<qlv2.InboundRpc_Timezone> {
  QLV2TimeZoneHandler({MethodChannel? platform})
      : _platform = platform ?? const MethodChannel('envoy');

  final MethodChannel _platform;

  @override
  Future<void> handleRequest(
    qlv2.InboundRpc_Timezone rpc,
    QLConnection device,
  ) async {
    final dateTime = DateTime.now();
    String zone;
    try {
      zone = await _platform.invokeMethod<String>('get_time_zone') ?? '';
    } catch (_) {
      zone = '';
    }

    await rpc.field0.respond(
      response: qlv2.TimezoneResponse(
        offsetMinutes: dateTime.timeZoneOffset.inMinutes,
        zone: zone,
      ),
    );
    kPrint(
      "Successfully sent QL v2 timezone response with offsetMinutes: "
      "${dateTime.timeZoneOffset.inMinutes}, zone: $zone",
    );
  }
}
