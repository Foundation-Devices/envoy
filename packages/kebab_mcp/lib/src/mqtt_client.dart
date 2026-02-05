// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

/// MQTT client for communicating with the Kebab QA rig
class KebabMqttClient {
  final String brokerHost;
  final int brokerPort;
  final String topic;

  MqttServerClient? _client;

  KebabMqttClient({
    this.brokerHost = '127.0.0.1',
    this.brokerPort = 1235,
    this.topic = 'kebab/command',
  });

  Future<bool> connect() async {
    _client = MqttServerClient.withPort(
      brokerHost,
      'kebab-mcp-${DateTime.now().millisecondsSinceEpoch}',
      brokerPort,
    );

    _client!.keepAlivePeriod = 30;
    _client!.connectionMessage =
        MqttConnectMessage().startClean().withWillQos(MqttQos.atLeastOnce);

    try {
      await _client!.connect();
      return _client!.connectionStatus?.state == MqttConnectionState.connected;
    } catch (e) {
      return false;
    }
  }

  Future<bool> sendCommand(String command) async {
    if (_client == null ||
        _client!.connectionStatus?.state != MqttConnectionState.connected) {
      final connected = await connect();
      if (!connected) {
        return false;
      }
    }

    try {
      final payload = MqttClientPayloadBuilder()..addString(command);
      _client!.publishMessage(
        topic,
        MqttQos.atLeastOnce,
        payload.payload!,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  void disconnect() {
    _client?.disconnect();
    _client = null;
  }
}
