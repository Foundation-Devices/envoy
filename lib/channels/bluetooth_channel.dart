// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:io';

import 'package:envoy/business/devices.dart';
import 'package:envoy/channels/accessory.dart';
import 'package:envoy/channels/ble_status.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/stream_replay_cache.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// Manages Bluetooth communication via platform channels for iOS
/// Handles method channel calls and event streams for BLE operations
class BluetoothChannel {
  // Method channel for BLE operations (setup/control operations)
  final bleMethodChannel = const MethodChannel("envoy/bluetooth");
  final writeProgressChannel = const EventChannel('envoy/ble/write/progress');

  // Binary message channel for BLE data (incoming data from device)
  final bleReadChannel = const BasicMessageChannel(
    'envoy/ble/read',
    BinaryCodec(),
  );

  // Binary message channel for BLE writes (outgoing data to device)
  final bleWriteChannel = const BasicMessageChannel(
    'envoy/ble/write',
    BinaryCodec(),
  );

  // Event channel for BLE connection state events
  final bleConnectionEventChannel =
      const EventChannel('envoy/bluetooth/connection/stream');

  var _lastDeviceStatus = DeviceStatus(connected: false);

  DeviceStatus get lastDeviceStatus => _lastDeviceStatus;

  final _readController = StreamController<Uint8List>.broadcast();

  Stream<Uint8List> get dataStream => listenToDataEvents();

  // Replay stream for device status with latest value caching
  // New subscribers immediately receive the last known status
  Stream<DeviceStatus> get deviceStatusStream =>
      _deviceStatusStatusStream.replayLatest(_lastDeviceStatus);

  StreamSubscription? _deviceStatusSubscription;

  static final BluetoothChannel _instance = BluetoothChannel._internal();

  factory BluetoothChannel() {
    return _instance;
  }

  late final Stream<DeviceStatus> _deviceStatusStatusStream =
      bleConnectionEventChannel.receiveBroadcastStream().map((dynamic event) {
    if (event is Map<dynamic, dynamic>) {
      return DeviceStatus.fromMap(event);
    } else {
      return DeviceStatus(connected: false);
    }
  }).asBroadcastStream();

  late final Stream<WriteProgress> _writeProgressStream =
      writeProgressChannel.receiveBroadcastStream().map((dynamic event) {
    if (event is Map<dynamic, dynamic>) {
      return WriteProgress.fromMap(event);
    } else {
      return WriteProgress(
          progress: 0.0, id: "", totalBytes: 0, bytesProcessed: 0);
    }
  }).asBroadcastStream();

  Stream<DeviceStatus> get listenToDeviceConnectionEvents =>
      deviceStatusStream.where((status) => status.isConnectionEvent);

  BluetoothChannel._internal() {
    bleReadChannel.setMessageHandler((ByteData? message) async {
      if (message != null) {
        final data = message.buffer.asUint8List();
        _readController.add(data);
      }
      return ByteData(0);
    });

    _deviceStatusSubscription =
        _deviceStatusStatusStream.listen((DeviceStatus event) {
      _lastDeviceStatus = event;
      debugPrint(
          "Ble Connection Event: connected=${event.connected}, bonded=${event.bonded}, "
          "peripheralId=${event.peripheralId}");
    });
  }

  Future<DeviceStatus> getCurrentDeviceStatus() async {
    try {
      final result = await bleMethodChannel
          .invokeMethod<Map<dynamic, dynamic>>('getCurrentDeviceStatus');

      if (result != null) {
        return DeviceStatus.fromMap(result);
      } else {
        return DeviceStatus(connected: false);
      }
    } catch (e, stack) {
      debugPrintStack(
          label: "Error getting current device status: $e", stackTrace: stack);
      return DeviceStatus(connected: false);
    }
  }

  /// Write all data chunks to the connected BLE device
  /// Returns true if successful, false otherwise
  Future<bool> writeAll(List<Uint8List> data) async {
    if (!Platform.isIOS && !Platform.isAndroid) {
      throw Exception("BLE write is only supported on iOS and Android");
    }

    try {
      // Concatenate all chunks into single binary data
      var totalLength = 0;
      for (final chunk in data) {
        totalLength += chunk.length;
      }

      final combinedData = Uint8List(totalLength);
      var offset = 0;
      for (final chunk in data) {
        combinedData.setRange(offset, offset + chunk.length, chunk);
        offset += chunk.length;
      }
      // Send binary data through write channel
      final result =
          await bleWriteChannel.send(ByteData.sublistView(combinedData));

      if (result != null && result.lengthInBytes > 0) {
        final successByte = result.getUint8(0);
        debugPrint("BLE binary write result: success=$successByte");
        return successByte == 1;
      }

      return false;
    } catch (e, stack) {
      debugPrintStack(
          label: "Error writing binary data over BLE: $e", stackTrace: stack);
      return false;
    }
  }

  /// Get the device name of the  Host device (iOS and Android)
  Future<String> getDeviceName() async {
    final String name = await bleMethodChannel.invokeMethod('deviceName');
    return name;
  }

  /// Pair with a BLE device (iOS and Android)
  /// Returns the BluetoothConnectionStatus after pairing and connecting
  /// on IOS this will show the accessory setup sheet
  /// on Android this will initiate the android bonding dialog
  Future<DeviceStatus> setupBle(String deviceId, int colorWay) async {
    if (Platform.isIOS) {
      final status = await bleMethodChannel
          .invokeMethod("showAccessorySetup", {"c": colorWay});
      if (status is bool && !status) {
        return DeviceStatus(connected: false);
      }
    } else {
      //Android will wait for event after initiating pairing
      unawaited(bleMethodChannel.invokeMethod("pair", {"deviceId": deviceId}));
    }
    bool initiateBonding = false;
    final connect = await listenToDeviceConnectionEvents.firstWhere(
      (event) {
        try {
          if (event.connected && !initiateBonding && !event.bonded) {
            initiateBonding = true;
            kPrint("Initiating bonding ");
            bleMethodChannel.invokeMethod(
              "bond",
            );
          }
        } catch (e) {
          debugPrint("Error during bonding initiation: $e");
        }
        return event.connected;
      },
    );
    return connect;
  }

  /// Show the iOS accessory sheet for BLE pairing
  Future<bool> showAccessorySetup() async {
    if (!Platform.isIOS) {
      throw Exception("showAccessorySetup is only supported on iOS");
    }
    try {
      return await bleMethodChannel.invokeMethod<bool?>("showAccessorySetup") ??
          false;
    } catch (e) {
      debugPrint("Error showing accessory sheet: $e");
      return false;
    }
  }

  /// Listen to BLE data events (iOS and Android)
  /// Returns a stream of BLE data events
  Stream<Uint8List> listenToDataEvents() {
    if (!Platform.isIOS && !Platform.isAndroid) {
      return Stream.empty();
    }
    return _readController.stream;
  }

  Future<void> disconnect() async {
    await bleMethodChannel.invokeMethod("disconnect");
  }

  /// Dispose of stream subscriptions
  void dispose() {
    _deviceStatusSubscription?.cancel();
  }

  Stream<WriteProgress> writeProgressStream() {
    return _writeProgressStream;
  }

  Stream<WriteProgress> getWriteProgress(String id) {
    kPrint("Getting write progress for id: $id");
    return _writeProgressStream
        .where((progress) => progress.id == id)
        .asBroadcastStream();
  }

  /// Send large data by writing to file and passing path to host platform
  Future<bool> transmitFromFile(String path) async {
    try {
      await bleMethodChannel.invokeMethod("transmitFromFile", {"path": path});
      return true;
    } catch (e, stack) {
      debugPrintStack(label: "Error sending large data: $e", stackTrace: stack);
      return false;
    }
  }

  /// Cancel ongoing transfer
  Future<bool> cancelTransfer() async {
    try {
      await bleMethodChannel.invokeMethod("cancelTransfer");
      return true;
    } catch (e, stack) {
      debugPrintStack(label: ": $e", stackTrace: stack);
      return false;
    }
  }

  // Create a file in the ble cache directory
  // file will be removed after transmission
  static Future<File> getBleCacheFile(String filename) async {
    final appPath = await getApplicationCacheDirectory();
    final bleCacheDir = Directory('${appPath.path}/ble_cache');
    if (!await bleCacheDir.exists()) {
      await bleCacheDir.create(recursive: true);
    }
    // quantum link file, .qlf ? maybe ? this includes chunked QL messages
    final file = File('${bleCacheDir.path}/ble_$filename.qlf');
    return file;
  }

  Future reconnect(Device device) async {
    final bluetoothId = Platform.isIOS ? device.peripheralId : device.bleId;
    await bleMethodChannel.invokeMethod("reconnect", {"bleId": bluetoothId});
  }

  //IOS only
  Future<List<AccessoryInfo>> getAccessories() async {
    if (!Platform.isIOS) {
      throw Exception("getAccessories is only supported on iOS");
    }
    try {
      final result = await bleMethodChannel.invokeMethod('getAccessories');

      if (result is List) {
        return result
            .map((item) =>
                AccessoryInfo.fromMap(Map<String, dynamic>.from(item)))
            .toList();
      }

      return [];
    } catch (e, stack) {
      kPrint('Error getting accessories: $e', stackTrace: stack);
      return [];
    }
  }
}
