// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

class AccessoryInfo {
  final String peripheralId;
  final String peripheralName;
  final bool isConnected;
  final int state;

  AccessoryInfo({
    required this.peripheralId,
    required this.peripheralName,
    required this.isConnected,
    required this.state,
  });

  factory AccessoryInfo.fromMap(Map<String, dynamic> map) {
    return AccessoryInfo(
      peripheralId: map['peripheralId'] as String? ?? '',
      peripheralName: map['peripheralName'] as String? ?? '',
      isConnected: map['isConnected'] as bool? ?? false,
      state: map['state'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'peripheralId': peripheralId,
      'peripheralName': peripheralName,
      'isConnected': isConnected,
      'state': state,
    };
  }

  @override
  String toString() {
    return 'AccessoryInfo(peripheralId: $peripheralId, peripheralName: $peripheralName, isConnected: $isConnected, state: $state)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AccessoryInfo &&
        other.peripheralId == peripheralId &&
        other.peripheralName == peripheralName &&
        other.isConnected == isConnected &&
        other.state == state;
  }

  @override
  int get hashCode {
    return peripheralId.hashCode ^
        peripheralName.hashCode ^
        isConnected.hashCode ^
        state.hashCode;
  }
}
