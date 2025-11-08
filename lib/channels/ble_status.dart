// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

enum BluetoothConnectionEventType {
  deviceConnected,
  deviceDisconnected,
  deviceFound,
  scanStarted,
  scanStopped,
  scanError,
  connectionAttempt,
  connectionError,
}

class DeviceStatus {
  final BluetoothConnectionEventType? type;
  final bool connected;
  final bool bonded;
  final String? peripheralId;
  final String? peripheralName;
  final String? error;
  final int? rssi;

  const DeviceStatus({
    this.type,
    required this.connected,
    this.peripheralId,
    this.peripheralName,
    this.error,
    this.rssi,
    this.bonded = false,
  });

  factory DeviceStatus.fromMap(Map<dynamic, dynamic> map) {
    return DeviceStatus(
      type: _parseEventType(map['type']),
      connected: map['connected'] ?? false,
      peripheralId: map['peripheralId']?.toString(),
      peripheralName: map['peripheralName']?.toString(),
      error: map['error']?.toString(),
      rssi: map['rssi'],
      bonded: map['bonded'] ?? false,
    );
  }

  static BluetoothConnectionEventType? _parseEventType(dynamic typeValue) {
    if (typeValue == null) return null;

    final typeString = typeValue.toString();
    switch (typeString) {
      case 'device_connected':
        return BluetoothConnectionEventType.deviceConnected;
      case 'device_disconnected':
        return BluetoothConnectionEventType.deviceDisconnected;
      case 'device_found':
        return BluetoothConnectionEventType.deviceFound;
      case 'scan_started':
        return BluetoothConnectionEventType.scanStarted;
      case 'scan_stopped':
        return BluetoothConnectionEventType.scanStopped;
      case 'scan_error':
        return BluetoothConnectionEventType.scanError;
      case 'connection_attempt':
        return BluetoothConnectionEventType.connectionAttempt;
      case 'connection_error':
        return BluetoothConnectionEventType.connectionError;
      default:
        return null;
    }
  }

  /// Check if this is a connection-related event
  bool get isConnectionEvent {
    return type == BluetoothConnectionEventType.deviceConnected ||
        type == BluetoothConnectionEventType.deviceDisconnected ||
        type == BluetoothConnectionEventType.connectionAttempt ||
        type == BluetoothConnectionEventType.connectionError;
  }


  bool get hasError => error != null;

  @override
  String toString() {
    return 'BluetoothConnectionStatus {'
        'type: $type, '
        'connected: $connected, '
        'device: ${peripheralName ?? 'Unknown'}, '
        'bonded: ${bonded ?? 'Unknown'}, '
        '${error != null ? ', error: $error' : ''}'
        ' }';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceStatus &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          connected == other.connected &&
          peripheralId == other.peripheralId;

  @override
  int get hashCode =>
      type.hashCode ^ connected.hashCode ^ peripheralId.hashCode;
}
