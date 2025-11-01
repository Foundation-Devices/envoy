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
  bondingStarted,
  bondingInProgress,
  bondingError,
  alreadyBonded,
}

class DeviceStatus {
  final BluetoothConnectionEventType? type;
  final bool connected;
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
  });

  factory DeviceStatus.fromMap(Map<dynamic, dynamic> map) {
    return DeviceStatus(
      type: _parseEventType(map['type']),
      connected: map['connected'] ?? false,
      peripheralId: map['peripheralId']?.toString(),
      peripheralName: map['peripheralName']?.toString(),
      error: map['error']?.toString(),
      rssi: map['rssi'],
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
      case 'bonding_started':
        return BluetoothConnectionEventType.bondingStarted;
      case 'bonding_in_progress':
        return BluetoothConnectionEventType.bondingInProgress;
      case 'bonding_error':
        return BluetoothConnectionEventType.bondingError;
      case 'already_bonded':
        return BluetoothConnectionEventType.alreadyBonded;
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

  /// Check if this is a scan-related event
  bool get isScanEvent {
    return type == BluetoothConnectionEventType.deviceFound ||
        type == BluetoothConnectionEventType.scanStarted ||
        type == BluetoothConnectionEventType.scanStopped ||
        type == BluetoothConnectionEventType.scanError;
  }

  /// Check if this is a bonding/pairing-related event
  bool get isBondingEvent {
    return type == BluetoothConnectionEventType.bondingStarted ||
        type == BluetoothConnectionEventType.bondingInProgress ||
        type == BluetoothConnectionEventType.bondingError ||
        type == BluetoothConnectionEventType.alreadyBonded;
  }

  bool get hasError => error != null;

  @override
  String toString() {
    return 'BluetoothConnectionStatus {'
        'type: $type, '
        'connected: $connected, '
        'device: ${peripheralName ?? 'Unknown'}, '
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
