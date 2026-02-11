// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:mcp_dart/mcp_dart.dart';
import 'mqtt_client.dart';

/// MCP Server for controlling the Kebab QA rig
class KebabServer {
  final KebabMqttClient _mqttClient;
  late final McpServer _server;

  KebabServer({
    String brokerHost = '192.168.0.75',
    int brokerPort = 1235,
  }) : _mqttClient = KebabMqttClient(
          brokerHost: brokerHost,
          brokerPort: brokerPort,
        );

  Future<void> start() async {
    _server = McpServer(
      Implementation(
        name: 'kebab-mcp',
        version: '0.1.0',
      ),
      options: McpServerOptions(
        capabilities: ServerCapabilities(
          tools: ServerCapabilitiesTools(),
        ),
      ),
    );

    _registerTools();

    final transport = StdioServerTransport();
    await _server.connect(transport);
  }

  void _registerTools() {
    // Home - Home the stepper motors
    _server.registerTool(
      'home',
      description: 'Home the stepper motors to their initial position',
      inputSchema: ToolInputSchema(properties: {}),
      callback: (args, extra) async {
        return await _sendCommand('home', 'Homing stepper motors');
      },
    );

    // iphone_scan_prime - Scan Prime using iPhone
    _server.registerTool(
      'iphone_scan_prime',
      description: 'Position devices so the iPhone can scan the Prime QR code',
      inputSchema: ToolInputSchema(properties: {}),
      callback: (args, extra) async {
        return await _sendCommand(
            'iphone_scan_prime', 'Positioning for iPhone to scan Prime');
      },
    );

    // prime_scan_iphone - Scan iPhone using Prime
    _server.registerTool(
      'prime_scan_iphone',
      description: 'Position devices so the Prime can scan the iPhone QR code',
      inputSchema: ToolInputSchema(properties: {}),
      callback: (args, extra) async {
        return await _sendCommand(
            'prime_scan_iphone', 'Positioning for Prime to scan iPhone');
      },
    );

    // face_tester_1 - Face devices toward tester (left)
    _server.registerTool(
      'face_tester_1',
      description: 'Face devices toward tester position 1 (left side)',
      inputSchema: ToolInputSchema(properties: {}),
      callback: (args, extra) async {
        return await _sendCommand(
            'face_tester_1', 'Rotating to face tester (left)');
      },
    );

    // face_tester_2 - Face devices toward tester (right)
    _server.registerTool(
      'face_tester_2',
      description: 'Face devices toward tester position 2 (right side)',
      inputSchema: ToolInputSchema(properties: {}),
      callback: (args, extra) async {
        return await _sendCommand(
            'face_tester_2', 'Rotating to face tester (right)');
      },
    );

    // disable_motors - Disable all motors
    _server.registerTool(
      'disable_motors',
      description: 'Disable all stepper motors (allows manual movement)',
      inputSchema: ToolInputSchema(properties: {}),
      callback: (args, extra) async {
        return await _sendCommand('disable_motors', 'Disabling all motors');
      },
    );

    // Generic send_command for custom commands
    _server.registerTool(
      'send_command',
      description: 'Send a custom command to the Kebab rig',
      inputSchema: ToolInputSchema(
        properties: {
          'command': JsonSchema.string(
            description: 'The command string to send to the Kebab',
          ),
        },
        required: ['command'],
      ),
      callback: (args, extra) async {
        final command = args['command'] as String;
        return await _sendCommand(command, 'Sending custom command: $command');
      },
    );
  }

  Future<CallToolResult> _sendCommand(
      String command, String description) async {
    final success = await _mqttClient.sendCommand(command);

    if (success) {
      return CallToolResult.fromContent(
        [TextContent(text: '$description - OK')],
      );
    } else {
      return CallToolResult(
        content: [
          TextContent(
              text: 'Failed to send command "$command". Check MQTT connection.')
        ],
        isError: true,
      );
    }
  }

  void stop() {
    _mqttClient.disconnect();
  }
}
