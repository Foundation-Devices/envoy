// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:io';

import 'package:envoy/channels/ble_status.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

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
  final _writeProgressController = StreamController<double>.broadcast();

  Stream<Uint8List> get dataStream => listenToDataEvents();

  Stream<double> get writeProgressStream => _writeProgressController.stream;

  Stream<DeviceStatus> get deviceStatusStream => _deviceStatusStatusStream;

  StreamSubscription? _deviceStatusSubscription;
  StreamSubscription? _writeProgressSubscription;

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
    _writeProgressSubscription =
        writeProgressChannel.receiveBroadcastStream().listen((dynamic event) {
      if (event is double) {
        _writeProgressController.add(event);
      } else if (event is int) {
        _writeProgressController.add(event.toDouble());
      } else {
        _writeProgressController.add(0.0);
      }
    });

    _deviceStatusSubscription =
        _deviceStatusStatusStream.listen((DeviceStatus event) {
      _lastDeviceStatus = event;
      debugPrint(
          "Ble Connection Event: connected=${event.connected}, bonded=${event.bonded}, "
          "peripheralId=${event.peripheralId}");
    });
  }

  /// Write all data chunks to the connected BLE device
  /// Returns true if successful, false otherwise
  Future<bool> writeAll(List<Uint8List> data) async {
    if (!Platform.isIOS && !Platform.isAndroid) {
      return false;
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
  Future<DeviceStatus> connect(String deviceId, int colorWay) async {
    if (Platform.isIOS) {
      final result = await bleMethodChannel
          .invokeMethod("showAccessorySetup", {"c": colorWay});
      if (result != true) {
        throw Exception("User cancelled accessory setup");
      }
    } else {
      //Android will wait for event after initiating pairing
      unawaited(bleMethodChannel.invokeMethod("pair", {"deviceId": deviceId}));
    }
    final connect = await listenToDeviceConnectionEvents.firstWhere(
      (event) {
        if (Platform.isAndroid) {
          return event.bonded && event.connected;
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
    _writeProgressSubscription?.cancel();
  }
}
