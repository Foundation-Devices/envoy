// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

class BleDeviceInfo {
  final String peripheralId;
  final String peripheralName;
  final bool isConnected;
  final int state;
  final bool bondState;

  BleDeviceInfo({
    required this.peripheralId,
    required this.peripheralName,
    required this.isConnected,
    required this.state,
    this.bondState = false,
  });

  factory BleDeviceInfo.fromMap(Map<String, dynamic> map) {
    final isConnected = map['isConnected'] as bool? ?? false;

    return BleDeviceInfo(
      peripheralId: (map['peripheralId'] ?? map['deviceId']) as String? ?? '',
      peripheralName: (map['peripheralName'] ?? map['name']) as String? ?? '',
      isConnected: isConnected,
      state: map['state'] as int? ?? (isConnected ? 2 : 0),
      bondState: (map['bondState'] ?? map['bonded']) == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'peripheralId': peripheralId,
      'peripheralName': peripheralName,
      'isConnected': isConnected,
      'state': state,
      'bondState': bondState,
    };
  }

  @override
  String toString() {
    return 'BleDeviceInfo(peripheralId: $peripheralId, peripheralName: $peripheralName, isConnected: $isConnected, state: $state, bondState: $bondState)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BleDeviceInfo &&
        other.peripheralId == peripheralId &&
        other.peripheralName == peripheralName &&
        other.isConnected == isConnected &&
        other.state == state &&
        other.bondState == bondState;
  }

  @override
  int get hashCode {
    return peripheralId.hashCode ^
        peripheralName.hashCode ^
        isConnected.hashCode ^
        state.hashCode ^
        bondState.hashCode;
  }
}
