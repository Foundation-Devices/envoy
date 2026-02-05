// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';
import 'package:kebab_mcp/kebab_mcp.dart';

void main(List<String> args) async {
  // Parse optional arguments for broker configuration
  String brokerHost = '192.168.0.75';
  int brokerPort = 1235;

  for (var i = 0; i < args.length; i++) {
    if (args[i] == '--host' && i + 1 < args.length) {
      brokerHost = args[i + 1];
    } else if (args[i] == '--port' && i + 1 < args.length) {
      brokerPort = int.tryParse(args[i + 1]) ?? 1235;
    }
  }

  stderr.writeln('Starting Kebab MCP Server...');
  stderr.writeln('MQTT Broker: $brokerHost:$brokerPort');

  final server = KebabServer(
    brokerHost: brokerHost,
    brokerPort: brokerPort,
  );

  await server.start();
}
