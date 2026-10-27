// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:envoy/ble/qlv2/global_router.dart';
import 'package:envoy/ble/qlv2/handlers/account_update_handler.dart';
import 'package:envoy/ble/qlv2/handlers/active_seed_fingerprint_handler.dart';
import 'package:envoy/ble/qlv2/handlers/firmware_handler.dart';
import 'package:envoy/ble/qlv2/handlers/magic_backup_handler.dart';
import 'package:envoy/ble/qlv2/handlers/passport_details_updated_handler.dart';
import 'package:envoy/ble/qlv2/peer_status.dart';
import 'package:envoy/ble/qlv2/rpc_dispatcher.dart';
import 'package:envoy/ble/qlv2/session_controller.dart';
import 'package:envoy/business/devices.dart';
import 'package:envoy/channels/ble_status.dart';
import 'package:envoy/channels/ql_connection.dart';
import 'package:envoy/util/console.dart';
import 'package:qlv2/qlv2.dart' as qlv2;

abstract interface class QLBleTransport {
  String get deviceId;
  DeviceStatus get lastDeviceStatus;
  Stream<DeviceStatus> get deviceStatusStream;
  Future<bool> isBleConnected();
  Future<void> reconnectBle();
  Future<bool> writeBleChunk(Uint8List data);
  Future<bool> requestHighBlePriority();
  Future<bool> requestBalancedBlePriority();
}

class QLV2WriteRequest {
  QLV2WriteRequest({
    required Future<List<Uint8List>> Function() chunks,
    required Future<void> Function({required bool status}) notifyStatus,
  })  : _chunks = chunks,
        _notifyStatus = notifyStatus;

  final Future<List<Uint8List>> Function() _chunks;
  final Future<void> Function({required bool status}) _notifyStatus;

  factory QLV2WriteRequest.fromRust(qlv2.OutBoundWrite write) =>
      QLV2WriteRequest(chunks: write.chunks, notifyStatus: write.notifyStatus);

  Future<List<Uint8List>> chunks() => _chunks();
  Future<void> notifyStatus({required bool status}) =>
      _notifyStatus(status: status);
}

abstract interface class QLV2SessionDriver {
  Future<Uint8List> ownIdentity();
  Future<Uint8List> ownBundle();
  Future<Uint8List?> getPersistedPeer();
  Future<Uint8List> xid();
  Future<void> setPersistedPeer(List<int> bytes);
  Future<void> bindPeer(List<int> peerBundleBytes);
  Future<void> pair(List<int> invite);
  Future<qlv2.PeerPermissionsResponse> requestPermissions();
  Future<void> provisionRouter();
  void setRouterEnabled(bool enabled);
  Future<void> sendIncoming(List<int> chunk);
  Stream<qlv2.PeerStatusEvent> streamPeerStatus();
  Stream<QLV2WriteRequest> streamOutgoingMessages();
  Future<void> connect();
  Future<qlv2.PassportEchoResult> requestPassportEcho(String message);
  Future<qlv2.PassportBenchmarkResult> downloadPassportBenchmark({
    required int bytes,
    required int receiveWindow,
  });
  Future<qlv2.PassportDetailsResponse> passportDetailsRequest();
  Future<qlv2.SignPsbtResponse> requestSignPsbt(
    String accountId,
    List<int> psbt,
  );
  Stream<qlv2.AccountUpdatedEvent> subscribeAccountUpdated();
  Stream<qlv2.ActiveSeedFingerprint> subscribePassportActiveSeedFingerprint();
  Stream<qlv2.FirmwareInstallEvent> subscribeFirmwareInstallStatus();
  Stream<qlv2.MagicBackupRestoreResult> subscribeMagicBackupRestoreCompleted();
  Stream<qlv2.OnboardingState> subscribeOnboardingStatus();
  Stream<qlv2.PassportDetailsResponse> subscribePassportDetails();
  Stream<qlv2.PassportFiatPreferenceEvent> subscribePassportFiatPreference();
  Stream<qlv2.PassportMagicBackupEnabled> subscribePassportMagicBackupEnabled();
  Stream<qlv2.InboundRpc> setUpRouter();
  void dispose();
}

class QLV2ProtocolError {
  const QLV2ProtocolError(this.message, this.error, this.stackTrace);
  final String message;
  final Object error;
  final StackTrace stackTrace;
}

class QLV2ProtocolHandler {
  static const _defaultQlRetryInterval = Duration(seconds: 2);
  static const _defaultQlHandshakeTimeout = Duration(seconds: 7);
  static const _defaultBleReadyTimeout = Duration(seconds: 3);

  QLV2ProtocolHandler._({
    required QLBleTransport transport,
    required QLConnection? device,
    required QLV2SessionDriver session,
    QLV2RpcDispatcher? rpcDispatcher,
    Future<void> Function(Uint8List bytes)? onOwnIdentity,
    Future<void> Function(Uint8List bytes)? onPeerBundle,
    Duration qlRetryInterval = _defaultQlRetryInterval,
    Duration qlHandshakeTimeout = _defaultQlHandshakeTimeout,
    Duration bleReadyTimeout = _defaultBleReadyTimeout,
  })  : _transport = transport,
        _device = device,
        _session = session,
        _rpcDispatcher = rpcDispatcher ?? QLV2RpcDispatcher(),
        _onOwnIdentity = onOwnIdentity,
        _onPeerBundle = onPeerBundle,
        _qlRetryInterval = qlRetryInterval,
        _qlHandshakeTimeout = qlHandshakeTimeout,
        _bleReadyTimeout = bleReadyTimeout,
        firmwareEvents = QLV2FirmwareEvents(),
        accountUpdateEvents = QLV2AccountUpdateEvents() {
    _sessionController = QLV2SessionController(_rpcDispatcher);
    _globalRoutes = _rpcDispatcher.registerRoutes(
      buildQLV2GlobalRouter(firmwareEvents: firmwareEvents),
    );
  }

  final QLBleTransport _transport;
  final QLConnection? _device;
  final QLV2SessionDriver _session;
  final QLV2RpcDispatcher _rpcDispatcher;
  final Future<void> Function(Uint8List bytes)? _onOwnIdentity;
  final Future<void> Function(Uint8List bytes)? _onPeerBundle;
  final Duration _qlRetryInterval;
  final Duration _qlHandshakeTimeout;
  final Duration _bleReadyTimeout;
  final QLV2FirmwareEvents firmwareEvents;
  final QLV2AccountUpdateEvents accountUpdateEvents;
  late final QLV2SessionController _sessionController;
  late final QLV2RpcRegistration _globalRoutes;

  final _peerStatusController =
      StreamController<qlv2.PeerStatusEvent>.broadcast();
  final _inboundRequestController =
      StreamController<qlv2.InboundRpc>.broadcast();
  final _activeController = StreamController<bool>.broadcast();
  final _errorController = StreamController<QLV2ProtocolError>.broadcast();
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  final List<void Function()> _disposeCallbacks = [];

  Future<void> _incomingChain = Future.value();
  Future<void> _writeChain = Future.value();
  Timer? _qlRetryTimer;
  Timer? _permissionRetryTimer;
  Timer? _globalSubscriptionsRetryTimer;
  bool _started = false;
  bool _disposed = false;
  bool _isActive = false;
  bool _isPeerConnected = false;
  bool _permissionRequestInFlight = false;
  bool _permissionResolved = false;
  bool _qlConnectRequested = false;
  bool _qlConnectInFlight = false;
  bool _routerSetupInFlight = false;
  qlv2.PeerPermissionsResponse? _permissionStatus;

  Stream<qlv2.PeerStatusEvent> get peerStatusStream =>
      _peerStatusController.stream;
  Stream<qlv2.InboundRpc> get inboundRequestStream =>
      _inboundRequestController.stream;
  Stream<bool> get activeStream => _activeController.stream;
  Stream<QLV2ProtocolError> get errorStream => _errorController.stream;
  QLV2RpcDispatcher get rpcDispatcher => _rpcDispatcher;
  QLV2SessionController get sessionController => _sessionController;
  bool get isActive => _isActive;
  String get deviceId => _transport.deviceId;

  qlv2.QlSession? get session {
    final driver = _session;
    return driver is _RustQLV2SessionDriver ? driver.rawSession : null;
  }

  Future<Uint8List> ownIdentity() => _session.ownIdentity();
  Future<Uint8List> ownBundle() => _session.ownBundle();
  Future<Uint8List?> getPersistedPeer() => _session.getPersistedPeer();
  Future<Uint8List> xid() => _session.xid();
  Future<qlv2.PassportDetailsResponse> fetchPassportDetails() =>
      _session.passportDetailsRequest();
  Future<qlv2.SignPsbtResponse> requestSignPsbt({
    required String accountId,
    required Uint8List psbt,
  }) =>
      _session.requestSignPsbt(accountId, psbt);
  Stream<qlv2.OnboardingState> subscribeOnboardingStatus() =>
      _session.subscribeOnboardingStatus();
  Stream<qlv2.AccountUpdatedEvent> subscribeAccountUpdated() =>
      _session.subscribeAccountUpdated();
  Stream<qlv2.ActiveSeedFingerprint> subscribePassportActiveSeedFingerprint() =>
      _session.subscribePassportActiveSeedFingerprint();
  Stream<qlv2.FirmwareInstallEvent> subscribeFirmwareInstallStatus() =>
      _session.subscribeFirmwareInstallStatus();
  Stream<qlv2.MagicBackupRestoreResult>
      subscribeMagicBackupRestoreCompleted() =>
          _session.subscribeMagicBackupRestoreCompleted();
  Stream<qlv2.PassportDetailsResponse> subscribePassportDetails() =>
      _session.subscribePassportDetails();
  Stream<qlv2.PassportFiatPreferenceEvent> subscribePassportFiatPreference() =>
      _session.subscribePassportFiatPreference();
  Stream<qlv2.PassportMagicBackupEnabled>
      subscribePassportMagicBackupEnabled() =>
          _session.subscribePassportMagicBackupEnabled();

  Future<qlv2.PassportEchoResult> runPassportEcho(String message) {
    if (!isActive) {
      throw StateError('QL v2 session is not active');
    }
    return _session.requestPassportEcho(message);
  }

  Future<qlv2.PassportBenchmarkResult> runPassportBenchmark({
    required int bytes,
    required int receiveWindow,
  }) async {
    if (!isActive) {
      throw StateError('QL v2 session is not active');
    }
    await _transport.requestHighBlePriority();
    try {
      return await _session.downloadPassportBenchmark(
        bytes: bytes,
        receiveWindow: receiveWindow,
      );
    } finally {
      await _transport.requestBalancedBlePriority();
    }
  }

  Future<void> pair(Uint8List invite) async {
    await _session.pair(invite);
    // Pairing owns the initial handshake. Subsequent BLE reconnects should use
    // the normal QL connect command rather than re-running pairing.
    _qlConnectRequested = true;
  }

  void addDisposeCallback(void Function() callback) {
    if (_disposed) {
      callback();
      return;
    }
    _disposeCallbacks.add(callback);
  }

  Future<void> connect() {
    _qlConnectRequested = true;
    return _attemptQlConnect();
  }

  static Future<QLV2ProtocolHandler> create({
    required QLConnection transport,
    QLV2SessionDriver? sessionDriver,
    QLV2RpcDispatcher? rpcDispatcher,
    Uint8List? identityBytes,
    Uint8List? peerBundleBytes,
    Future<void> Function(Uint8List bytes)? onOwnIdentity,
    Future<void> Function(Uint8List bytes)? onPeerBundle,
    bool autoConnect = true,
  }) async {
    final session =
        sessionDriver ?? await _RustQLV2SessionDriver.create(identityBytes);
    QLV2ProtocolHandler? handler;
    try {
      if (peerBundleBytes != null && peerBundleBytes.isNotEmpty) {
        await session.setPersistedPeer(peerBundleBytes);
        await session.bindPeer(peerBundleBytes);
      }
      handler = QLV2ProtocolHandler._(
        transport: transport,
        device: transport,
        session: session,
        rpcDispatcher: rpcDispatcher,
        onOwnIdentity: onOwnIdentity,
        onPeerBundle: onPeerBundle,
      );
      await handler._persistOwnIdentity();
      handler._start();
      if (autoConnect) await handler.connect();
      return handler;
    } catch (_) {
      handler?.dispose();
      if (handler == null) session.dispose();
      rethrow;
    }
  }

  /// Creates a session over an injected transport. Pass [device] only when a
  /// test needs to exercise global app-service subscriptions.
  static QLV2ProtocolHandler createForTransportTest({
    required QLBleTransport transport,
    required QLV2SessionDriver sessionDriver,
    QLConnection? device,
    Duration qlRetryInterval = const Duration(milliseconds: 10),
    Duration qlHandshakeTimeout = const Duration(milliseconds: 20),
    Duration bleReadyTimeout = const Duration(milliseconds: 50),
  }) {
    final handler = QLV2ProtocolHandler._(
      transport: transport,
      device: device,
      session: sessionDriver,
      qlRetryInterval: qlRetryInterval,
      qlHandshakeTimeout: qlHandshakeTimeout,
      bleReadyTimeout: bleReadyTimeout,
    );
    handler._start();
    return handler;
  }

  Future<void> handleBleData(Uint8List data) {
    final chunk = Uint8List.fromList(data);
    final next = _incomingChain.then((_) => _sendIncoming(chunk));
    _incomingChain = next.catchError((_) {});
    return next;
  }

  void markTransportDisconnected() {
    _isPeerConnected = false;
    _permissionRequestInFlight = false;
    _permissionResolved = _permissionStatus != null;
    _cancelPermissionRetryTimer();
    _session.setRouterEnabled(false);
    _sessionController.disposeSubscriptions(QLV2RouteScopes.global);
    _cancelQlRetryTimer();
    _cancelGlobalSubscriptionsRetryTimer();
    _setActive(false);
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _cancelQlRetryTimer();
    _cancelPermissionRetryTimer();
    _cancelGlobalSubscriptionsRetryTimer();
    _session.setRouterEnabled(false);
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    _subscriptions.clear();
    for (final callback in _disposeCallbacks.reversed) {
      callback();
    }
    _disposeCallbacks.clear();
    _sessionController.dispose();
    _globalRoutes.dispose();
    _rpcDispatcher.dispose();
    firmwareEvents.dispose();
    accountUpdateEvents.dispose();
    _session.dispose();
    unawaited(_peerStatusController.close());
    unawaited(_inboundRequestController.close());
    unawaited(_activeController.close());
    unawaited(_errorController.close());
  }

  void _start() {
    if (_started) return;
    _started = true;
    _subscriptions.add(
      _session.streamPeerStatus().listen(
            _handleRawPeerStatus,
            onError: (Object error, StackTrace stack) =>
                _reportError('QL v2 peer-status stream failed', error, stack),
          ),
    );
    _subscriptions.add(
      _session.streamOutgoingMessages().listen(
            (write) => unawaited(_handleOutgoingWrite(write)),
            onError: (Object error, StackTrace stack) =>
                _reportError('QL v2 outgoing stream failed', error, stack),
          ),
    );
    _subscriptions.add(
      _session.setUpRouter().listen(
            _handleInboundRequest,
            onError: (Object error, StackTrace stack) =>
                _reportError('QL v2 router stream failed', error, stack),
          ),
    );
    _subscriptions.add(
      _transport.deviceStatusStream.listen((status) {
        if (status.readyForWrite) {
          unawaited(_attemptQlConnect());
        } else if (!status.connected) {
          markTransportDisconnected();
        }
      }),
    );
  }

  Future<void> _sendIncoming(Uint8List data) async {
    if (_disposed) return;
    try {
      await _session.sendIncoming(data);
    } catch (error, stack) {
      _reportError('QL v2 inbound BLE data failed', error, stack);
    }
  }

  void _handleRawPeerStatus(qlv2.PeerStatusEvent event) {
    if (event.status != qlv2.ConnectionStatus.connected) {
      _isPeerConnected = false;
      _permissionRequestInFlight = false;
      _cancelPermissionRetryTimer();
      if (event.status == qlv2.ConnectionStatus.unpair) {
        _permissionResolved = false;
        _permissionStatus = null;
        final device = _device;
        if (device != null) {
          unawaited(device.qlHandler.bleAccountHandler.handleQlv2Unpair());
        }
      } else {
        _permissionResolved = _permissionStatus != null;
      }
      _handlePeerStatus(event.withPermissionStatus(_permissionStatus));
      if (event.status == qlv2.ConnectionStatus.initiator) {
        _scheduleQlRetry(_qlHandshakeTimeout);
      } else if (event.status == qlv2.ConnectionStatus.disconnected) {
        _scheduleQlRetry(_qlRetryInterval);
      }
      return;
    }

    _cancelQlRetryTimer();
    final newConnection = !_isPeerConnected;
    _isPeerConnected = true;
    if (newConnection) {
      _permissionRequestInFlight = false;
      _permissionResolved = _permissionStatus != null;
      _cancelPermissionRetryTimer();
    }
    if (event.permissionStatus != null) {
      _permissionStatus = event.permissionStatus;
      _permissionResolved = true;
    }
    _handlePeerStatus(event.withPermissionStatus(_permissionStatus));
    if (!_permissionResolved && !_permissionRequestInFlight) {
      _permissionRequestInFlight = true;
      unawaited(_requestPermissions(event));
    }
  }

  Future<void> _requestPermissions(qlv2.PeerStatusEvent event) async {
    try {
      final response = await _session.requestPermissions();
      if (_disposed || !_isPeerConnected) return;
      _permissionStatus = response;
      _permissionResolved = true;
      _cancelPermissionRetryTimer();
      _handlePeerStatus(event.withPermissionStatus(response));
      if (response == qlv2.PeerPermissionsResponse.denied) {
        throw StateError('Passport denied QL v2 permissions');
      }
    } catch (error, stack) {
      if (!_disposed && _isPeerConnected) {
        _reportError('QL v2 permission negotiation failed', error, stack);
      }
    } finally {
      _permissionRequestInFlight = false;
      if (!_permissionResolved) {
        _schedulePermissionRetry(event);
      }
    }
  }

  void _schedulePermissionRetry(qlv2.PeerStatusEvent event) {
    if (_disposed ||
        !_isPeerConnected ||
        _permissionResolved ||
        _permissionRequestInFlight ||
        _permissionRetryTimer != null) {
      return;
    }
    _permissionRetryTimer = Timer(_qlRetryInterval, () {
      _permissionRetryTimer = null;
      if (_disposed ||
          !_isPeerConnected ||
          _permissionResolved ||
          _permissionRequestInFlight) {
        return;
      }
      _permissionRequestInFlight = true;
      unawaited(_requestPermissions(event));
    });
  }

  void _cancelPermissionRetryTimer() {
    _permissionRetryTimer?.cancel();
    _permissionRetryTimer = null;
  }

  void _handlePeerStatus(qlv2.PeerStatusEvent event) {
    if (!_peerStatusController.isClosed) _peerStatusController.add(event);
    _isPeerConnected = event.status == qlv2.ConnectionStatus.connected;
    final wasActive = _isActive;
    _setActive(event.isActive);
    if (_isActive) {
      _cancelQlRetryTimer();
      if (!wasActive) {
        _registerGlobalSubscriptions();
        unawaited(_persistPeerBundle());
        unawaited(_setupRouter());
      }
    } else {
      if (wasActive) {
        _sessionController.disposeSubscriptions(QLV2RouteScopes.global);
      }
      _cancelGlobalSubscriptionsRetryTimer();
      if (!_isPeerConnected) {
        _session.setRouterEnabled(false);
      }
    }
  }

  Future<void> _setupRouter() async {
    if (_routerSetupInFlight || _disposed || !_isActive) return;
    _routerSetupInFlight = true;
    try {
      await _session.provisionRouter();
      if (!_disposed && _isActive) {
        _session.setRouterEnabled(true);
      }
    } catch (error, stack) {
      _reportError('QL v2 router setup failed', error, stack);
    } finally {
      _routerSetupInFlight = false;
    }
  }

  void _registerGlobalSubscriptions() {
    if (_disposed) return;
    final device = _device;
    if (device == null) return;
    _cancelGlobalSubscriptionsRetryTimer();
    kPrint('[$deviceId] QL v2 registering global subscriptions');
    var retryFiatPreferenceOnDone = true;
    _sessionController.registerSubscriptions(QLV2RouteScopes.global, [
      _listenSessionEvent(
        _session.subscribeAccountUpdated(),
        QLV2AccountUpdateHandler(accountUpdateEvents),
        'account update',
        device,
      ),
      _listenSessionEvent(
        _session.subscribePassportActiveSeedFingerprint(),
        QLV2PassportActiveSeedFingerprintHandler(),
        'active seed fingerprint',
        device,
      ),
      _listenSessionEvent(
        _session.subscribeFirmwareInstallStatus(),
        QLV2FirmwareInstallStatusHandler(firmwareEvents),
        'firmware install status',
        device,
      ),
      _listenSessionEvent(
        _session.subscribePassportDetails(),
        QLV2PassportDetailsUpdatedHandler(),
        'Passport details',
        device,
      ),
      _listenSessionEvent(
        _session.subscribePassportMagicBackupEnabled(),
        QLV2PassportMagicBackupEnabledHandler(),
        'magic backup status',
        device,
      ),
      _listenSessionEvent(
        _session.subscribeMagicBackupRestoreCompleted(),
        QLV2MagicBackupRestoreCompletedHandler(),
        'magic backup restore',
        device,
      ),
      _session.subscribePassportFiatPreference().listen(
        (event) => unawaited(
          _handleSessionEvent(
            'fiat preference',
            () => _handleFiatPreference(event),
          ),
        ),
        onError: (Object error, StackTrace stack) {
          retryFiatPreferenceOnDone = _shouldRetrySubscription(
            'fiat preference',
            error,
            stack,
          );
          if (retryFiatPreferenceOnDone) {
            _scheduleGlobalSubscriptionsRetry();
          }
        },
        onDone: () {
          if (retryFiatPreferenceOnDone) {
            _scheduleGlobalSubscriptionsRetry();
          }
        },
      ),
    ]);
  }

  StreamSubscription<T> _listenSessionEvent<T>(
    Stream<T> stream,
    QLV2SessionEventHandler<T> handler,
    String label,
    QLConnection device,
  ) {
    kPrint('[$deviceId] QL v2 subscribing to $label');
    var retryOnDone = true;
    return stream.listen(
      (event) {
        kPrint('[$deviceId] QL v2 $label event received');
        unawaited(
          _handleSessionEvent(
            label,
            () => handler.handleEvent(event, device),
          ),
        );
      },
      onError: (Object error, StackTrace stack) {
        retryOnDone = _shouldRetrySubscription(label, error, stack);
        if (retryOnDone) {
          _scheduleGlobalSubscriptionsRetry();
        }
      },
      onDone: () {
        kPrint('[$deviceId] QL v2 $label stream ended');
        if (retryOnDone) {
          _scheduleGlobalSubscriptionsRetry();
        }
      },
    );
  }

  bool _shouldRetrySubscription(
    String label,
    Object error,
    StackTrace stack,
  ) {
    if (qlv2.isUnsupportedSubscriptionError(error)) {
      kPrint('[$deviceId] QL v2 $label subscription is not supported');
      return false;
    }
    _reportError('QL v2 $label stream failed', error, stack);
    return true;
  }

  Future<void> _handleSessionEvent(
    String label,
    Future<void> Function() handle,
  ) async {
    try {
      await handle();
    } catch (error, stack) {
      _reportError('QL v2 $label event failed', error, stack);
    }
  }

  void _scheduleGlobalSubscriptionsRetry() {
    if (_disposed || !_isActive || _globalSubscriptionsRetryTimer != null) {
      return;
    }
    _globalSubscriptionsRetryTimer = Timer(_qlRetryInterval, () {
      _globalSubscriptionsRetryTimer = null;
      if (_disposed || !_isActive) return;
      _sessionController.disposeSubscriptions(QLV2RouteScopes.global);
      _registerGlobalSubscriptions();
    });
  }

  void _cancelGlobalSubscriptionsRetryTimer() {
    _globalSubscriptionsRetryTimer?.cancel();
    _globalSubscriptionsRetryTimer = null;
  }

  Future<void> _handleFiatPreference(
    qlv2.PassportFiatPreferenceEvent event,
  ) async {
    final device = _device?.getDevice();
    final code = event.currencyCode.trim().toUpperCase();
    if (device == null || code.isEmpty || device.primeFiatCurrency == code) {
      return;
    }
    await Devices().updatePrimeFiatCurrency(code, device);
  }

  Future<void> _attemptQlConnect() async {
    if (_disposed ||
        _isPeerConnected ||
        !_qlConnectRequested ||
        _qlConnectInFlight ||
        !_transport.lastDeviceStatus.readyForWrite) {
      return;
    }
    _cancelQlRetryTimer();
    _qlConnectInFlight = true;
    try {
      await _session.connect();
    } catch (error, stack) {
      _reportError('QL v2 handshake failed', error, stack);
    } finally {
      _qlConnectInFlight = false;
    }
  }

  void _scheduleQlRetry(Duration delay) {
    if (_disposed ||
        _isPeerConnected ||
        !_qlConnectRequested ||
        _qlConnectInFlight ||
        _qlRetryTimer != null ||
        !_transport.lastDeviceStatus.readyForWrite) {
      return;
    }
    _qlRetryTimer = Timer(delay, () {
      _qlRetryTimer = null;
      unawaited(_attemptQlConnect());
    });
  }

  void _cancelQlRetryTimer() {
    _qlRetryTimer?.cancel();
    _qlRetryTimer = null;
  }

  void _handleInboundRequest(qlv2.InboundRpc request) {
    if (!_inboundRequestController.isClosed) {
      _inboundRequestController.add(request);
    }
    final device = _device;
    if (device != null) {
      unawaited(_rpcDispatcher.dispatch(request, device));
    }
  }

  Future<void> _handleOutgoingWrite(QLV2WriteRequest write) {
    final next = _writeChain.then((_) => _writeOutgoing(write));
    _writeChain = next.catchError((_) {});
    return next;
  }

  Future<void> _writeOutgoing(QLV2WriteRequest write) async {
    var success = false;
    try {
      if (_disposed || !await _waitForBleReady() || _disposed) return;

      final chunks = await write.chunks();
      if (_disposed) return;

      for (final chunk in chunks) {
        if (_disposed || !_transport.lastDeviceStatus.readyForWrite) return;

        if (Platform.isIOS) {
          await Future<void>.delayed(const Duration(milliseconds: 6));
          if (_disposed) return;
        }

        var written = await _transport.writeBleChunk(chunk);
        if (_disposed) return;

        if (!written && _transport.lastDeviceStatus.readyForWrite) {
          await Future<void>.delayed(const Duration(milliseconds: 150));
          if (_disposed) return;

          written = await _transport.writeBleChunk(chunk);
          if (_disposed) return;
        }

        if (!written) return;
      }

      success = true;
    } catch (error, stack) {
      _reportError('QL v2 BLE write failed', error, stack);
    } finally {
      try {
        await write.notifyStatus(status: success);
      } catch (error, stack) {
        _reportError('QL v2 write acknowledgement failed', error, stack);
      }
    }
  }

  Future<bool> _waitForBleReady() async {
    if (_transport.lastDeviceStatus.readyForWrite) return true;
    try {
      await _transport.deviceStatusStream
          .firstWhere((status) => status.readyForWrite)
          .timeout(_bleReadyTimeout);
      return true;
    } on TimeoutException {
      return false;
    }
  }

  void _setActive(bool active) {
    if (_isActive == active || _activeController.isClosed) return;
    _isActive = active;
    _activeController.add(active);
  }

  Future<void> _persistOwnIdentity() async {
    final callback = _onOwnIdentity;
    if (callback == null) return;
    final identity = await _session.ownIdentity();
    if (identity.isNotEmpty) await callback(identity);
  }

  Future<void> _persistPeerBundle() async {
    final callback = _onPeerBundle;
    if (callback == null) return;
    try {
      final peer = await _session.getPersistedPeer();
      if (peer != null && peer.isNotEmpty) await callback(peer);
    } catch (error, stack) {
      _reportError('QL v2 peer persistence failed', error, stack);
    }
  }

  void _reportError(String message, Object error, StackTrace stack) {
    kPrint('[$deviceId] $message: $error', stackTrace: stack);
    if (!_errorController.isClosed) {
      _errorController.add(QLV2ProtocolError(message, error, stack));
    }
  }
}

class _RustQLV2SessionDriver implements QLV2SessionDriver {
  _RustQLV2SessionDriver(this._session);
  final qlv2.QlSession _session;
  qlv2.QlSession get rawSession => _session;

  static Future<_RustQLV2SessionDriver> create(Uint8List? identityBytes) async {
    final session = identityBytes != null && identityBytes.isNotEmpty
        ? await qlv2.QlSession.newFromIdentity(identityBytes: identityBytes)
        : await qlv2.QlSession.newInstance();
    return _RustQLV2SessionDriver(session);
  }

  @override
  Future<Uint8List> ownIdentity() => _session.ownIdentity();
  @override
  Future<Uint8List> ownBundle() => _session.ownBundle();
  @override
  Future<Uint8List?> getPersistedPeer() => _session.getPersistedPeer();
  @override
  Future<Uint8List> xid() => _session.xid();
  @override
  Future<void> setPersistedPeer(List<int> bytes) =>
      _session.setPersistedPeer(bytes: bytes);
  @override
  Future<void> bindPeer(List<int> peerBundleBytes) =>
      _session.bindPeer(peerBundleBytes: peerBundleBytes);
  @override
  Future<void> pair(List<int> invite) => _session.pair(invite: invite);
  @override
  Future<qlv2.PeerPermissionsResponse> requestPermissions() =>
      _session.requestPermissions();
  @override
  Future<void> provisionRouter() => _session.provisionRouter();
  @override
  void setRouterEnabled(bool enabled) =>
      _session.setRouterEnabled(enabled: enabled);
  @override
  Future<void> sendIncoming(List<int> chunk) =>
      _session.sendIncoming(chunk: chunk);
  @override
  Stream<qlv2.PeerStatusEvent> streamPeerStatus() =>
      _session.streamPeerStatus();
  @override
  Stream<QLV2WriteRequest> streamOutgoingMessages() =>
      _session.streamOutgoingMessages().map(QLV2WriteRequest.fromRust);
  @override
  Future<void> connect() => _session.connect();
  @override
  Future<qlv2.PassportEchoResult> requestPassportEcho(String message) =>
      _session.requestPassportEcho(message: message);
  @override
  Future<qlv2.PassportBenchmarkResult> downloadPassportBenchmark({
    required int bytes,
    required int receiveWindow,
  }) =>
      _session.downloadPassportBenchmark(
        bytes: bytes,
        receiveWindow: receiveWindow,
      );
  @override
  Future<qlv2.PassportDetailsResponse> passportDetailsRequest() =>
      _session.requestPassportDetails(request: const qlv2.Empty());
  @override
  Future<qlv2.SignPsbtResponse> requestSignPsbt(
    String accountId,
    List<int> psbt,
  ) =>
      _session.requestSignPsbt(
        request: qlv2.SignPsbtParams(
          accountId: accountId,
          psbt: Uint8List.fromList(psbt),
        ),
      );
  @override
  Stream<qlv2.AccountUpdatedEvent> subscribeAccountUpdated() =>
      _session.subscribeAccountUpdated(request: const qlv2.Empty());
  @override
  Stream<qlv2.ActiveSeedFingerprint> subscribePassportActiveSeedFingerprint() =>
      _session.subscribePassportActiveSeedFingerprint(
        request: const qlv2.Empty(),
      );
  @override
  Stream<qlv2.FirmwareInstallEvent> subscribeFirmwareInstallStatus() =>
      _session.subscribeFirmwareInstallStatus(request: const qlv2.Empty());
  @override
  Stream<qlv2.MagicBackupRestoreResult>
      subscribeMagicBackupRestoreCompleted() =>
          _session.subscribeMagicBackupRestoreCompleted(
            request: const qlv2.Empty(),
          );
  @override
  Stream<qlv2.OnboardingState> subscribeOnboardingStatus() =>
      _session.subscribeOnboardingStatus(request: const qlv2.Empty());
  @override
  Stream<qlv2.PassportDetailsResponse> subscribePassportDetails() =>
      _session.subscribePassportDetails(request: const qlv2.Empty());
  @override
  Stream<qlv2.PassportFiatPreferenceEvent> subscribePassportFiatPreference() =>
      _session.subscribePassportFiatPreference(request: const qlv2.Empty());
  @override
  Stream<qlv2.PassportMagicBackupEnabled>
      subscribePassportMagicBackupEnabled() =>
          _session.subscribePassportMagicBackupEnabled(
            request: const qlv2.Empty(),
          );
  @override
  Stream<qlv2.InboundRpc> setUpRouter() => _session.setUpRouter();
  @override
  void dispose() => _session.dispose();
}
