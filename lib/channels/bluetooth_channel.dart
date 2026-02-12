// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:io';

import 'package:envoy/channels/accessory.dart';
import 'package:envoy/channels/ble_status.dart';
import 'package:envoy/channels/ql_connection.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class BleSetupTimeoutException implements Exception {
  final String message;

  BleSetupTimeoutException(this.message);

  @override
  String toString() => 'BleSetupTimeoutException: $message';
}

/// Manages shared Bluetooth operations and multiple BLE device connections.
///
/// Shared operations (handled here):
/// - Bluetooth permissions and enabling
/// - Device scanning and discovery
/// - Managing known device MAC addresses
///
/// Device-specific operations (handled by QLConnection):
/// - GATT connection and state
/// - Data transfer (read/write)
/// - Connection events and progress tracking
///
/// Channel naming:
/// - Main channel: envoy/bluetooth (for shared operations)
/// - Device channels: envoy/bluetooth/{deviceId}, envoy/ble/read/{deviceId}, etc.
class BluetoothChannel {
  // Main method channel for shared BLE operations
  final _methodChannel = const MethodChannel("envoy/bluetooth");

  // Map of device channels, keyed by device ID (MAC address/Device UUID)
  final Map<String, QLConnection> _deviceChannels = {};

  // Stream controller for device channel changes
  final _deviceChannelsController =
      StreamController<List<QLConnection>>.broadcast();

  /// Stream that emits the current list of device channels whenever it changes
  Stream<List<QLConnection>> get deviceChannelsStream =>
      _deviceChannelsController.stream.asBroadcastStream();

  /// Get the current list of device channels
  List<QLConnection> get deviceChannels => _deviceChannels.values.toList();

  static final BluetoothChannel _instance = BluetoothChannel._internal();

  factory BluetoothChannel() {
    return _instance;
  }

  BluetoothChannel._internal();

  /// Get or create a device channel for the given device ID.
  /// This creates the device-specific channels if they don't exist.
  QLConnection getDeviceChannel(String deviceId) {
    if (!_deviceChannels.containsKey(deviceId)) {
      kPrint("Creating new QLConnection for device: $deviceId");
      _deviceChannels[deviceId] = QLConnection(deviceId);
      _notifyDeviceChannelsChanged();
    } else {
      kPrint("Reusing existing QLConnection for device: $deviceId");
    }
    return _deviceChannels[deviceId]!;
  }

  /// Check if a device channel exists
  bool hasDeviceChannel(String deviceId) {
    return _deviceChannels.containsKey(deviceId);
  }

  /// Remove and dispose a device channel
  void removeDeviceChannel(String deviceId) {
    final channel = _deviceChannels.remove(deviceId);
    channel?.dispose();
    kPrint("Removed device channel: $deviceId");
    _notifyDeviceChannelsChanged();
  }

  void _notifyDeviceChannelsChanged() {
    _deviceChannelsController.add(_deviceChannels.values.toList());
  }

  /// Get all device IDs with active channels
  List<String> get activeDeviceIds => _deviceChannels.keys.toList();

  // ==================== Shared Operations ====================

  /// Get the device name of the host device (iOS and Android)
  Future<String> getDeviceName() async {
    final String name = await _methodChannel.invokeMethod('deviceName');
    return name;
  }

  /// Get the device name of the host device (iOS and Android)
  Future<int> getAPILevel() async {
    if (!Platform.isAndroid) {
      throw Exception("getAPILevel is only supported on Android");
    }
    final int name = await _methodChannel.invokeMethod('apiLevel');
    return name;
  }

  /// Request to enable Bluetooth
  Future<bool?> requestEnableBle() async {
    return await _methodChannel.invokeMethod<bool>("enableBluetooth");
  }

  /// Get list of connected devices
  Future<List<ConnectedDeviceInfo>> getConnectedDevices() async {
    try {
      final result = await _methodChannel.invokeMethod('getConnectedDevices');
      if (result is List) {
        return result
            .map(
              (item) =>
                  ConnectedDeviceInfo.fromMap(Map<dynamic, dynamic>.from(item)),
            )
            .toList();
      }
      return [];
    } catch (e, stack) {
      kPrint('Error getting connected devices: $e', stackTrace: stack);
      return [];
    }
  }

  /// Remove a device from the native side
  Future<bool> removeDevice(String deviceId) async {
    try {
      final result = await _methodChannel.invokeMethod<bool>('removeDevice', {
        'deviceId': deviceId,
      });
      if (result == true) {
        removeDeviceChannel(deviceId);
      }
      return result ?? false;
    } catch (e) {
      debugPrint("Error removing device: $e");
      return false;
    }
  }

  /// Start scanning for BLE devices
  Future<bool> startScan({String? deviceId}) async {
    try {
      final result = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>(
        'startScan',
        deviceId != null ? {'deviceId': deviceId} : null,
      );
      return result?['scanning'] == true;
    } catch (e) {
      debugPrint("Error starting scan: $e");
      return false;
    }
  }

  /// Stop scanning for BLE devices
  Future<bool> stopScan() async {
    try {
      final result = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>(
        'stopScan',
      );
      return result?['scanning'] == false;
    } catch (e) {
      debugPrint("Error stopping scan: $e");
      return false;
    }
  }

  // ==================== Pairing and Connection ====================

  /// Pair with a BLE device (iOS and Android).
  /// Returns the QLConnection after pairing and connecting.
  /// On iOS this will show the accessory setup sheet.
  /// On Android this will initiate the android bonding dialog.
  Future<QLConnection> setupBle(String deviceId, int colorWay) async {
    kPrint(
      "setupBle start: requestedDeviceId=$deviceId colorWay=$colorWay platform=${Platform.operatingSystem}",
    );
    var resolvedDeviceId = deviceId;
    if (Platform.isIOS) {
      kPrint("setupBle iOS: invoking showAccessorySetup");
      final iosDeviceId = await _methodChannel.invokeMethod<String?>(
        "showAccessorySetup",
        {"c": colorWay},
      );
      if (iosDeviceId == null || iosDeviceId.isEmpty) {
        throw BleSetupTimeoutException("Accessory setup cancelled");
      }
      resolvedDeviceId = iosDeviceId;
      kPrint(
          "setupBle iOS: showAccessorySetup returned deviceId=$resolvedDeviceId");
    } else {
      // Android: Call native pair first to create QLConnection and register channels
      // This must happen before we create QLConnection on Dart side
      kPrint("setupBle android: invoking pair for deviceId=$deviceId");
      await _methodChannel.invokeMethod("pair", {"deviceId": deviceId}).timeout(
        Duration(seconds: 10),
        onTimeout: () {
          throw BleSetupTimeoutException("Pairing timed out");
        },
      );
    }

    // Now create the device channel after native side has registered its channels
    kPrint("setupBle: obtaining device channel for $resolvedDeviceId");
    final deviceChannel = getDeviceChannel(resolvedDeviceId);

    bool initiateBonding = false;
    kPrint("setupBle: waiting for connected event on $resolvedDeviceId");
    final connect = await deviceChannel.connectionEvents.firstWhere((event) {
      debugPrint("[$resolvedDeviceId] events $event");
      try {
        if (event.connected &&
            !initiateBonding &&
            !event.bonded &&
            Platform.isAndroid) {
          initiateBonding = true;
          kPrint("[$resolvedDeviceId] Initiating bonding");
          deviceChannel.bond();
        }
      } catch (e) {
        debugPrint(
          "[$resolvedDeviceId] Error during bonding initiation: $e",
        );
      }
      // iOS doesn't have bonding state, just connected state
      if (Platform.isIOS) {
        return event.connected;
      }
      return event.connected && event.bonded;
    }).timeout(
      Duration(seconds: 10),
      onTimeout: () {
        throw BleSetupTimeoutException("Pairing timed out");
      },
    );
    if (connect.connected) {
      kPrint(
          "setupBle success: deviceId=$resolvedDeviceId connected=${connect.connected}");
      return deviceChannel;
    } else {
      throw BleSetupTimeoutException("Pairing timed out");
    }
  }

  /// Prepare a device for connection by creating native QLConnection and registering channels.
  /// This must be called BEFORE creating the Dart QLConnection.
  Future<void> prepareDevice(String deviceId) async {
    kPrint("prepareDevice: $deviceId");
    await _methodChannel.invokeMethod("prepareDevice", {"deviceId": deviceId});
  }

  /// Reconnect to a previously paired device.
  /// prepareDevice() should be called first to register native channels.
  Future<void> reconnect(String deviceId) async {
    kPrint("reconnect request to native: deviceId=$deviceId");
    await _methodChannel.invokeMethod("reconnect", {"deviceId": deviceId});
  }

  /// Show the iOS accessory sheet for BLE pairing and return the device UUID
  Future<String?> showAccessorySetup({int? colorWay}) async {
    if (!Platform.isIOS) {
      throw Exception("showAccessorySetup is only supported on iOS");
    }
    try {
      final args = colorWay == null ? null : {"c": colorWay};
      return await _methodChannel.invokeMethod<String?>(
        "showAccessorySetup",
        args,
      );
    } catch (e) {
      debugPrint("Error showing accessory sheet: $e");
      return null;
    }
  }

  // ==================== iOS Specific ====================

  /// Get accessories (iOS only)
  Future<List<AccessoryInfo>> getAccessories() async {
    if (!Platform.isIOS) {
      throw Exception("getAccessories is only supported on iOS");
    }
    try {
      final result = await _methodChannel.invokeMethod('getAccessories');

      if (result is List) {
        return result
            .map(
              (item) => AccessoryInfo.fromMap(Map<String, dynamic>.from(item)),
            )
            .toList();
      }

      return [];
    } catch (e, stack) {
      kPrint('Error getting accessories: $e', stackTrace: stack);
      return [];
    }
  }

  /// Create a file in the BLE cache directory.
  /// File will be removed after transmission.
  static Future<File> getBleCacheFile(String filename) async {
    final appPath = await getApplicationCacheDirectory();
    final bleCacheDir = Directory('${appPath.path}/ble_cache');
    if (!await bleCacheDir.exists()) {
      await bleCacheDir.create(recursive: true);
    }
    // quantum link file, .qlf - this includes chunked QL messages
    final file = File('${bleCacheDir.path}/ble_$filename.qlf');
    return file;
  }

  /// Dispose all device channels
  void dispose() {
    for (final channel in _deviceChannels.values) {
      channel.dispose();
    }
    _deviceChannels.clear();
  }

  Future<void> removeAccessory(String deviceId) async {
    if (!Platform.isIOS) {
      return;
    }

    try {
      await _methodChannel.invokeMethod<bool>('removeDevice', {
        'deviceId': deviceId,
      }).timeout(
        Duration(seconds: 5),
        onTimeout: () {
          throw Exception("Timeout removing accessory");
        },
      );
    } catch (e, stack) {
      kPrint('Error removing accessory: $e', stackTrace: stack);
    } finally {
      removeDeviceChannel(deviceId);
    }
  }

  void resetDeviceChannels() {
    for (final channel in _deviceChannels.values) {
      channel.dispose();
    }
    _deviceChannels.clear();
  }
}
