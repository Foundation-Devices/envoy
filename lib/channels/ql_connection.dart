// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:envoy/ble/ql_handlers.dart';
import 'package:envoy/ble/quantum_link_router.dart';
import 'package:envoy/business/devices.dart';
import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/channels/ble_status.dart';
import 'package:envoy/channels/bluetooth_channel.dart';
import 'package:envoy/ui/widgets/envoy_step_item.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/list_utils.dart';
import 'package:envoy/util/ntp.dart';
import 'package:envoy/util/stream_replay_cache.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:foundation_api/foundation_api.dart' as api;

/// QLConnection clas Handles BLE physical connection and quantum link message encoding/decoding
/// Manages Bluetooth communication for a specific BLE device.
/// Each device has its own channels for communication.
///
/// Channel naming convention:
/// - Method channel: envoy/bluetooth/{deviceId}
/// - Read channel: envoy/ble/read/{deviceId}
/// - Write channel: envoy/ble/write/{deviceId}
/// - Connection stream: envoy/bluetooth/connection/stream/{deviceId}
/// - Write progress stream: envoy/ble/write/progress/{deviceId}
///
class QLConnection with EnvoyMessageWriter {
  //Mac address on android, Device UUID on iOS
  final String deviceId;

  // Device-specific method channel for BLE operations
  late final MethodChannel _methodChannel;

  // Device-specific write progress channel
  late final EventChannel _writeProgressChannel;
  late final QLHandlers _qlHandlers;

  // Device-specific binary message channel for BLE data (incoming data from device)
  late final BasicMessageChannel<ByteData> _bleReadChannel;

  // Device-specific binary message channel for BLE writes (outgoing data to device)
  late final BasicMessageChannel<ByteData> _bleWriteChannel;

  // Device-specific event channel for BLE connection state events
  late final EventChannel _connectionEventChannel;

  var _lastDeviceStatus = DeviceStatus(connected: false);

  DeviceStatus get lastDeviceStatus => _lastDeviceStatus;

  final _readController = StreamController<Uint8List>.broadcast();

  Stream<Uint8List> get dataStream => _readController.stream;

  StreamSubscription? _deviceStatusSubscription;

  late final Stream<DeviceStatus> _deviceStatusStream;
  late final Stream<WriteProgress> _writeProgressStream;

  api.EnvoyMasterDechunker? _decoder;
  api.EnvoyAridCache? _aridCache;

  //identity associated with this device
  api.QuantumLinkIdentity? _qlIdentity;
  api.XidDocument? _recipientXid;

  api.XidDocument? get recipientXid => _recipientXid;

  api.QuantumLinkIdentity? get senderXid => _qlIdentity;

  /// Replay stream for device status with latest value caching.
  /// New subscribers immediately receive the last known status.
  Stream<DeviceStatus> get deviceStatusStream =>
      _deviceStatusStream.replayLatest(_lastDeviceStatus);

  Stream<DeviceStatus> get connectionEvents =>
      deviceStatusStream.where((status) => status.isConnectionEvent);

  QLConnection(this.deviceId) {
    _initChannels();
  }

  void _initChannels() {
    // Initialize device-specific channels with deviceId suffix
    _methodChannel = MethodChannel('envoy/bluetooth/$deviceId');

    _writeProgressChannel = EventChannel('envoy/ble/write/progress/$deviceId');

    _bleReadChannel = BasicMessageChannel(
      'envoy/ble/read/$deviceId',
      const BinaryCodec(),
    );

    _bleWriteChannel = BasicMessageChannel(
      'envoy/ble/write/$deviceId',
      const BinaryCodec(),
    );

    _connectionEventChannel =
        EventChannel('envoy/bluetooth/connection/stream/$deviceId');

    // Setup read channel message handler
    _bleReadChannel.setMessageHandler((ByteData? message) async {
      if (message != null) {
        final data = message.buffer.asUint8List();
        _readController.add(data);
      }
      return ByteData(0);
    });

    // Setup device status stream
    _deviceStatusStream =
        _connectionEventChannel.receiveBroadcastStream().map((dynamic event) {
      if (event is Map<dynamic, dynamic>) {
        return DeviceStatus.fromMap(event);
      } else {
        return DeviceStatus(connected: false);
      }
    });

    // Setup write progress stream
    _writeProgressStream =
        _writeProgressChannel.receiveBroadcastStream().map((dynamic event) {
      if (event is Map<dynamic, dynamic>) {
        return WriteProgress.fromMap(event);
      } else {
        return WriteProgress(
            progress: 0.0, id: "", totalBytes: 0, bytesProcessed: 0);
      }
    }).asBroadcastStream();

    // Listen to device status updates
    _deviceStatusSubscription =
        _deviceStatusStream.listen((DeviceStatus event) {
      _lastDeviceStatus = event;
      if (event.type == BluetoothConnectionEventType.deviceConnected) {
        //wait for system to find characteristics
        Future.delayed(const Duration(seconds: 2), () {
          onConnect();
        });
      }
      kPrint(
          "[$deviceId] BLE Connection Event: connected=${event.connected}, bonded=${event.bonded}");
    });

    _qlHandlers = QLHandlers(this);

    dataStream.asBroadcastStream().listen((data) {
      _handleData(data);
    });
  }

  QLHandlers get qlHandler => _qlHandlers;

  Future _handleData(Uint8List data) async {
    // Don't auto-generate identity here - it should be set via pair() or reconnect()
    if (_qlIdentity == null || _recipientXid == null) {
      kPrint("[$deviceId] Identity not set yet, skipping data handling");
      return;
    }
    final message = await _decode(data, _qlIdentity!);
    if (message != null) {
      _qlHandlers.dispatch(message);
    }
  }

  /// Get the current device status
  Future<DeviceStatus> getCurrentDeviceStatus() async {
    try {
      final result = await _methodChannel
          .invokeMethod<Map<dynamic, dynamic>>('getCurrentDeviceStatus');

      if (result != null) {
        return DeviceStatus.fromMap(result);
      } else {
        return DeviceStatus(connected: false);
      }
    } catch (e, stack) {
      debugPrintStack(
          label: "[$deviceId] Error getting current device status: $e",
          stackTrace: stack);
      return DeviceStatus(connected: false);
    }
  }

  void onConnect() {
    if (getDevice()?.onboardingComplete == true) {
      qlHandler.bleAccountHandler.sendExchangeRateHistory();
    }
  }

  /// Check if the device is connected
  Future<bool> isConnected() async {
    try {
      final result = await _methodChannel.invokeMethod<bool>('isConnected');
      return result ?? false;
    } catch (e) {
      debugPrint("[$deviceId] Error checking connection: $e");
      return false;
    }
  }

  /// Write all data chunks to this BLE device.
  /// Returns true if successful, false otherwise.
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
          await _bleWriteChannel.send(ByteData.sublistView(combinedData));

      if (result != null && result.lengthInBytes > 0) {
        final successByte = result.getUint8(0);
        kPrint("[$deviceId] BLE binary write result: success=$successByte");
        return successByte == 1;
      }

      return false;
    } catch (e, stack) {
      debugPrintStack(
          label: "[$deviceId] Error writing binary data over BLE: $e",
          stackTrace: stack);
      return false;
    }
  }

  /// Initiate bonding with this device (Android only)
  Future<bool> bond() async {
    try {
      final result = await _methodChannel.invokeMethod<bool>('bond');
      return result ?? false;
    } catch (e) {
      debugPrint("[$deviceId] Error bonding: $e");
      return false;
    }
  }

  /// Disconnect from this device
  Future<void> disconnect() async {
    try {
      await _methodChannel.invokeMethod("disconnect");
      kPrint("[$deviceId] Disconnected");
    } catch (e) {
      debugPrint("[$deviceId] Error disconnecting: $e");
    }
  }

  /// Get write progress stream for this device
  Stream<WriteProgress> writeProgressStream() {
    return _writeProgressStream;
  }

  /// Get write progress for a specific transfer ID
  Stream<WriteProgress> getWriteProgress(String id) {
    kPrint("[$deviceId] Getting write progress for id: $id");
    return _writeProgressStream
        .where((progress) => progress.id == id)
        .asBroadcastStream();
  }

  /// Send large data by writing to file and passing path to native platform
  Future<bool> transmitFromFile(String path) async {
    try {
      await _methodChannel.invokeMethod("transmitFromFile", {"path": path});
      return true;
    } catch (e, stack) {
      debugPrintStack(
          label: "[$deviceId] Error sending large data: $e", stackTrace: stack);
      return false;
    }
  }

  /// Cancel ongoing transfer for this device
  Future<bool> cancelTransfer() async {
    try {
      final result = await _methodChannel.invokeMethod<bool>("cancelTransfer");
      return result ?? false;
    } catch (e, stack) {
      debugPrintStack(
          label: "[$deviceId] Error cancelling transfer: $e",
          stackTrace: stack);
      return false;
    }
  }

  /// Get the connected peripheral ID (MAC address/ Device UUID on ios)
  Future<String?> getConnectedPeripheralId() async {
    try {
      return await _methodChannel
          .invokeMethod<String>('getConnectedPeripheralId');
    } catch (e) {
      debugPrint("[$deviceId] Error getting peripheral ID: $e");
      return null;
    }
  }

  Future<api.PassportMessage?> _decode(
      Uint8List bleData, api.QuantumLinkIdentity identity) async {
    _decoder ??= await api.getDecoder();
    _aridCache ??= await api.getAridCache();

    api.DecoderStatus decoderStatus = await api.decode(
        data: bleData.toList(),
        decoder: _decoder!,
        quantumLinkIdentity: identity,
        aridCache: _aridCache!);
    if (decoderStatus.payload != null) {
      return decoderStatus.payload;
    } else {
      return null;
    }
  }

  @override
  Future<bool> writeMessage(api.QuantumLinkMessage message) async {
    final data = await encodeMessage(message: message);
    kPrint("Encoded message! Size: ${data.length}");
    if (Platform.isIOS || Platform.isAndroid) {
      await writeAll(data);
    } else {
      throw UnimplementedError(
          "Bluetooth write not implemented for this platform");
    }
    return true;
  }

  @override
  Future<Stream<double>> writeMessageWithProgress(
      api.QuantumLinkMessage message) async {
    final data = await encodeMessage(message: message);
    await writeAll(data);
    return Stream.empty();
  }

  Future<List<Uint8List>> encodeMessage(
      {required api.QuantumLinkMessage message}) async {
    DateTime dateTime = DateTime.now();
    if (_recipientXid == null) {
      throw Exception(
          "Recipient XID not set for encoding message for device $deviceId");
    }
    if (_qlIdentity == null) {
      throw Exception(
          "Sender XID not set for encoding message for device $deviceId");
    }
    try {
      dateTime = await NTP.now(timeout: const Duration(seconds: 1));
    } catch (e) {
      kPrint("NTP error: $e");
    }
    final timestampSeconds = (dateTime.millisecondsSinceEpoch ~/ 1000);
    kPrint("Encoding Message timestamp: $timestampSeconds");

    api.EnvoyMessage envoyMessage =
        api.EnvoyMessage(message: message, timestamp: timestampSeconds);
    kPrint("Encoded Message $timestampSeconds");

    kPrint("Encoding message: $envoyMessage");
    return await api.encode(
      message: envoyMessage,
      sender: _qlIdentity!,
      recipient: _recipientXid!,
    );
  }

  /// Dispose of stream subscriptions and cleanup
  void dispose() {
    _deviceStatusSubscription?.cancel();
    _readController.close();
    _bleReadChannel.setMessageHandler(null);
    kPrint("[$deviceId] QLConnection disposed");
  }

  Future<bool> pair(api.XidDocument payload) async {
    _qlIdentity ??= await api.generateQlIdentity();
    _recipientXid = payload;
    debugIdentities(
        message: "Pairing to device...",
        identity: _qlIdentity!,
        recipient: _recipientXid!);
    //
    //reset onboarding state
    qlHandler.bleOnboardHandler.reset();
    qlHandler.bleOnboardHandler
        .updateBlePairState("Connecting to Prime", EnvoyStepState.LOADING);

    kPrint("Pairing...");
    final xid = await api.serializeXid(quantumLinkIdentity: _qlIdentity!);

    final deviceName = await BluetoothChannel().getDeviceName();

    final success = await writeMessage(api.QuantumLinkMessage.pairingRequest(
        api.PairingRequest(xidDocument: xid, deviceName: deviceName)));
    kPrint("Pairing... success ?  $success");
    return true;
  }

  /// Set up the QuantumLink identity for an existing connection.
  /// The actual BLE connection is handled by BluetoothChannel.reconnect().
  Future<void> reconnect(Device device) async {
    _qlIdentity = await device.getQlIdentity();
    _recipientXid = await device.getXidDocument();

    if (_qlIdentity == null || _recipientXid == null) {
      kPrint("[$deviceId] Warning: Could not load XIDs for reconnect");
      return;
    }

    debugIdentities(
        message: "[$deviceId] reconnect",
        identity: _qlIdentity!,
        recipient: _recipientXid!);
    kPrint("[$deviceId] QL identity set up for reconnect");
  }


  Device? getDevice() {
    final device = Devices().getPrimeDevices.firstWhereOrNull(
        (d) => d.bleId == deviceId || d.peripheralId == deviceId);
    return device;
  }

  static void debugIdentities(
      {String message = "",
      required api.QuantumLinkIdentity identity,
      required api.XidDocument recipient}) async {
    final serialXidSerial =
        await api.serializeQlIdentity(quantumLinkIdentity: identity);
    final recipientSerial =
        await api.serializeXidDocument(xidDocument: recipient);
    kPrint(
        "\n\n$message DebugIdentities serializeXidDocument: ${sha256.convert(recipientSerial).toString()}");
    kPrint(
        "$message DebugIdentities quantumLinkIdentity: ${sha256.convert(serialXidSerial).toString()}\n\n");
  }


  Future<bool> encodeToFile(
      {required Uint8List message,
      required String filePath,
      required int chunkSize}) async {
    DateTime dateTime = DateTime.now();
    try {
      dateTime = await NTP.now(timeout: const Duration(seconds: 1));
    } catch (e) {
      kPrint("NTP error: $e");
    }
    if (_recipientXid == null) {
      throw Exception(
          "Recipient XID not set for encoding message for device $deviceId");
    }
    if (_qlIdentity == null) {
      throw Exception(
          "Sender XID not set for encoding message for device $deviceId");
    }
    final timestampSeconds = (dateTime.millisecondsSinceEpoch ~/ 1000);
    kPrint("Encoding Message timestamp: $timestampSeconds");
    //
    // List<api.EnvoyMessage> envoyMessages = messages.map((message) =>
    //     api.EnvoyMessage(message: message, timestamp: timestampSeconds)).toList();
    // kPrint("Encoded Message $timestampSeconds");
    kPrint("Encoding message: $message to file: $filePath");
    return await api.encodeToMagicBackupFile(
        payload: message,
        sender: _qlIdentity!,
        recipient: _recipientXid!,
        path: filePath,
        chunkSize: BigInt.from(chunkSize),
        timestamp: timestampSeconds);
  }

  static void debugIdentitiesQuantumLinkIdentity(
      {String message = "", required api.QuantumLinkIdentity identity}) async {
    final serialXidSerial =
        await api.serializeQlIdentity(quantumLinkIdentity: identity);
    kPrint(
        "$message debugIdentities QuantumLinkIdentity : ${sha256.convert(serialXidSerial).toString()}\n\n");
  }

  static void debugIdentitiesXidDocument(
      {String message = "", required api.XidDocument recipient}) async {
    final recipientSerial =
        await api.serializeXidDocument(xidDocument: recipient);
    kPrint(
        "\n\n$message debugIdentities XidDocument: ${sha256.convert(recipientSerial).toString()}");
  }
}
