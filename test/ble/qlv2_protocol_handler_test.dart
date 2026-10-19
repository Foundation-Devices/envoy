// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:typed_data';

import 'package:envoy/ble/qlv2/protocol_handler.dart';
import 'package:envoy/channels/ble_status.dart';
import 'package:envoy/channels/ql_connection.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge.dart'
    show AnyhowException;
import 'package:flutter_test/flutter_test.dart';
import 'package:qlv2/qlv2.dart' as qlv2;

void main() {
  test('serializes inbound delivery', () async {
    final transport = _FakeTransport();
    final session = _FakeSessionDriver();
    final handler = QLV2ProtocolHandler.createForTransportTest(
      transport: transport,
      sessionDriver: session,
    );

    await Future.wait([
      handler.handleBleData(Uint8List.fromList([1])),
      handler.handleBleData(Uint8List.fromList([2])),
    ]);

    expect(session.incoming, [1, 2]);
    expect(session.maxConcurrentIncoming, 1);
    handler.dispose();
  });

  test('serializes complete logical writes and reports final success',
      () async {
    final transport = _FakeTransport();
    final session = _FakeSessionDriver();
    final handler = QLV2ProtocolHandler.createForTransportTest(
      transport: transport,
      sessionDriver: session,
    );
    final first = Completer<bool>();
    final second = Completer<bool>();

    session.outgoing.add(
      _writeRequest([
        [1],
        [2],
      ], first),
    );
    session.outgoing.add(_writeRequest([
      [3],
    ], second));

    expect(await Future.wait([first.future, second.future]), [true, true]);
    expect(transport.writes, [1, 2, 3]);
    handler.dispose();
  });

  test('retries one failed chunk and reports the final result', () async {
    final transport = _FakeTransport()..writeResults.addAll([false, true]);
    final session = _FakeSessionDriver();
    final handler = QLV2ProtocolHandler.createForTransportTest(
      transport: transport,
      sessionDriver: session,
    );
    final result = Completer<bool>();

    session.outgoing.add(_writeRequest([
      [7],
    ], result));

    expect(await result.future, isTrue);
    expect(transport.writes, [7, 7]);
    handler.dispose();
  });

  test('becomes active only after permission negotiation', () async {
    final transport = _FakeTransport();
    final session = _FakeSessionDriver();
    final handler = QLV2ProtocolHandler.createForTransportTest(
      transport: transport,
      sessionDriver: session,
    );
    final active = handler.activeStream.firstWhere((value) => value);

    session.peerStatus.add(
      const qlv2.PeerStatusEvent(
        status: qlv2.ConnectionStatus.connected,
      ),
    );

    expect(await active, isTrue);
    await Future<void>.delayed(Duration.zero);
    expect(session.permissionRequests, 1);
    expect(session.routerProvisionCount, 1);
    expect(session.routerEnabled, isTrue);
    handler.dispose();
  });

  test('restores balanced priority when a benchmark fails', () async {
    final transport = _FakeTransport();
    final session = _FakeSessionDriver()
      ..benchmarkError = StateError('benchmark failed');
    final handler = QLV2ProtocolHandler.createForTransportTest(
      transport: transport,
      sessionDriver: session,
    );
    final active = handler.activeStream.firstWhere((value) => value);
    session.peerStatus.add(
      const qlv2.PeerStatusEvent(
        status: qlv2.ConnectionStatus.connected,
      ),
    );
    await active;

    await expectLater(
      handler.runPassportBenchmark(bytes: 1024, receiveWindow: 1024),
      throwsStateError,
    );
    expect(transport.highPriorityRequests, 1);
    expect(transport.balancedPriorityRequests, 1);
    handler.dispose();
  });

  test('retries permission negotiation after a transient failure', () async {
    final transport = _FakeTransport();
    final session = _FakeSessionDriver()..permissionFailures = 1;
    final handler = QLV2ProtocolHandler.createForTransportTest(
      transport: transport,
      sessionDriver: session,
    );
    final active = handler.activeStream.firstWhere((value) => value);

    session.peerStatus.add(
      const qlv2.PeerStatusEvent(
        status: qlv2.ConnectionStatus.connected,
      ),
    );

    expect(await active, isTrue);
    expect(session.permissionRequests, 2);
    handler.dispose();
  });

  test('reuses granted permissions after a transport reconnect', () async {
    final transport = _FakeTransport();
    final session = _FakeSessionDriver();
    final handler = QLV2ProtocolHandler.createForTransportTest(
      transport: transport,
      sessionDriver: session,
    );

    var active = handler.activeStream.firstWhere((value) => value);
    session.peerStatus.add(
      const qlv2.PeerStatusEvent(
        status: qlv2.ConnectionStatus.connected,
      ),
    );
    await active;
    expect(session.permissionRequests, 1);

    transport.currentStatus =
        const DeviceStatus(connected: false, ready: false);
    transport.status.add(transport.currentStatus);
    session.peerStatus.add(
      const qlv2.PeerStatusEvent(
        status: qlv2.ConnectionStatus.initiator,
      ),
    );
    await Future<void>.delayed(Duration.zero);
    expect(handler.isActive, isFalse);

    transport.currentStatus = const DeviceStatus(connected: true, ready: true);
    transport.status.add(transport.currentStatus);
    active = handler.activeStream.firstWhere((value) => value);
    session.peerStatus.add(
      const qlv2.PeerStatusEvent(
        status: qlv2.ConnectionStatus.connected,
      ),
    );

    await active;
    expect(session.permissionRequests, 1);
    handler.dispose();
  });

  test('opens the onboarding RPC stream only when its owner subscribes',
      () async {
    final transport = _FakeTransport();
    final session = _FakeSessionDriver();
    final handler = QLV2ProtocolHandler.createForTransportTest(
      transport: transport,
      sessionDriver: session,
    );

    expect(session.onboardingSubscriptions, 0);
    final subscription = handler.subscribeOnboardingStatus().listen((_) {});

    expect(session.onboardingSubscriptions, 1);
    await subscription.cancel();
    handler.dispose();
  });

  test('does not retry an unsupported global subscription after it closes',
      () async {
    final transport = _FakeTransport();
    final session = _FakeSessionDriver();
    final handler = QLV2ProtocolHandler.createForTransportTest(
      transport: transport,
      sessionDriver: session,
      device: _FakeQLConnection(),
    );
    final active = handler.activeStream.firstWhere((value) => value);

    session.peerStatus.add(
      const qlv2.PeerStatusEvent(
        status: qlv2.ConnectionStatus.connected,
      ),
    );
    await active;
    await Future<void>.delayed(Duration.zero);
    expect(session.accountUpdateSubscriptions, 1);
    expect(session.accountUpdates.hasListener, isTrue);

    session.accountUpdates.addError(
      AnyhowException('qlv2.unsupported_subscription'),
    );
    await session.accountUpdates.close();
    await Future<void>.delayed(const Duration(milliseconds: 30));

    expect(session.accountUpdateSubscriptions, 1);
    handler.dispose();
    await session.close();
  });

  test('retries a stalled QL handshake without reconnecting BLE', () async {
    final transport = _FakeTransport();
    final session = _FakeSessionDriver();
    final handler = QLV2ProtocolHandler.createForTransportTest(
      transport: transport,
      sessionDriver: session,
    );

    await handler.connect();
    expect(session.connectCount, 1);
    session.peerStatus.add(
      const qlv2.PeerStatusEvent(
        status: qlv2.ConnectionStatus.initiator,
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 30));

    expect(session.connectCount, 2);
    expect(transport.reconnectCount, 0);
    handler.dispose();
  });

  test('starts a requested reconnect when repaired BLE becomes ready',
      () async {
    final transport = _FakeTransport()
      ..currentStatus = const DeviceStatus(connected: true, ready: false);
    final session = _FakeSessionDriver();
    final handler = QLV2ProtocolHandler.createForTransportTest(
      transport: transport,
      sessionDriver: session,
    );

    await handler.connect();
    expect(session.connectCount, 0);

    transport.currentStatus = const DeviceStatus(connected: true, ready: true);
    transport.status.add(transport.currentStatus);
    await Future<void>.delayed(Duration.zero);

    expect(session.connectCount, 1);
    handler.dispose();
  });

  test('a paired session reconnects without repeating pairing', () async {
    final transport = _FakeTransport();
    final session = _FakeSessionDriver();
    final handler = QLV2ProtocolHandler.createForTransportTest(
      transport: transport,
      sessionDriver: session,
    );

    await handler.pair(Uint8List.fromList([1, 2, 3]));
    session.peerStatus.add(
      const qlv2.PeerStatusEvent(
        status: qlv2.ConnectionStatus.disconnected,
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 30));

    expect(session.pairCount, 1);
    expect(session.connectCount, greaterThanOrEqualTo(1));
    expect(transport.reconnectCount, 0);
    handler.dispose();
  });

  test('disposal stops session work', () async {
    final transport = _FakeTransport();
    final session = _FakeSessionDriver();
    final handler = QLV2ProtocolHandler.createForTransportTest(
      transport: transport,
      sessionDriver: session,
    );

    handler.dispose();
    session.outgoing.add(
      QLV2WriteRequest(
        chunks: () async => [
          Uint8List.fromList([9])
        ],
        notifyStatus: ({required status}) async {},
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(session.disposed, isTrue);
    expect(transport.writes, isEmpty);
    await session.close();
  });

  test('disposal stops an in-flight write before the next chunk', () async {
    final writeStarted = Completer<void>();
    final releaseWrite = Completer<void>();
    final transport = _FakeTransport(
      writeStarted: writeStarted,
      releaseWrite: releaseWrite,
    );
    final session = _FakeSessionDriver();
    final handler = QLV2ProtocolHandler.createForTransportTest(
      transport: transport,
      sessionDriver: session,
    );
    final result = Completer<bool>();

    session.outgoing.add(
      _writeRequest(
        [
          [1],
          [2],
        ],
        result,
      ),
    );
    await writeStarted.future;

    handler.dispose();
    releaseWrite.complete();

    expect(await result.future, isFalse);
    expect(transport.writes, [1]);
    await session.close();
  });
}

QLV2WriteRequest _writeRequest(
  List<List<int>> chunks,
  Completer<bool> result,
) {
  return QLV2WriteRequest(
    chunks: () async => chunks.map(Uint8List.fromList).toList(),
    notifyStatus: ({required status}) async => result.complete(status),
  );
}

class _FakeTransport implements QLBleTransport {
  _FakeTransport({this.writeStarted, this.releaseWrite});

  final status = StreamController<DeviceStatus>.broadcast();
  final writes = <int>[];
  final writeResults = <bool>[];
  final Completer<void>? writeStarted;
  final Completer<void>? releaseWrite;
  var highPriorityRequests = 0;
  var balancedPriorityRequests = 0;
  var reconnectCount = 0;
  var currentStatus = const DeviceStatus(connected: true, ready: true);

  @override
  String get deviceId => 'test-prime';

  @override
  DeviceStatus get lastDeviceStatus => currentStatus;

  @override
  Stream<DeviceStatus> get deviceStatusStream => status.stream;

  @override
  Future<bool> isBleConnected() async => currentStatus.connected;

  @override
  Future<void> reconnectBle() async {
    reconnectCount++;
  }

  @override
  Future<bool> requestBalancedBlePriority() async {
    balancedPriorityRequests++;
    return true;
  }

  @override
  Future<bool> requestHighBlePriority() async {
    highPriorityRequests++;
    return true;
  }

  @override
  Future<bool> writeBleChunk(Uint8List data) async {
    writes.add(data.single);
    if (writeStarted case final started? when !started.isCompleted) {
      started.complete();
    }
    await releaseWrite?.future;
    await Future<void>.delayed(const Duration(milliseconds: 2));
    return writeResults.isEmpty ? true : writeResults.removeAt(0);
  }
}

class _FakeQLConnection implements QLConnection {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeSessionDriver implements QLV2SessionDriver {
  final peerStatus = StreamController<qlv2.PeerStatusEvent>.broadcast();
  final outgoing = StreamController<QLV2WriteRequest>.broadcast();
  final accountUpdates = StreamController<qlv2.AccountUpdatedEvent>.broadcast();
  final activeSeedFingerprints =
      StreamController<qlv2.ActiveSeedFingerprint>.broadcast();
  final firmwareInstallEvents =
      StreamController<qlv2.FirmwareInstallEvent>.broadcast();
  final magicBackupRestoreResults =
      StreamController<qlv2.MagicBackupRestoreResult>.broadcast();
  final onboardingStates = StreamController<qlv2.OnboardingState>.broadcast();
  final passportDetails =
      StreamController<qlv2.PassportDetailsResponse>.broadcast();
  final fiatPreferences =
      StreamController<qlv2.PassportFiatPreferenceEvent>.broadcast();
  final magicBackupEnabled =
      StreamController<qlv2.PassportMagicBackupEnabled>.broadcast();
  final incoming = <int>[];
  var concurrentIncoming = 0;
  var maxConcurrentIncoming = 0;
  var permissionRequests = 0;
  var permissionFailures = 0;
  var pairCount = 0;
  var connectCount = 0;
  var routerProvisionCount = 0;
  var onboardingSubscriptions = 0;
  var accountUpdateSubscriptions = 0;
  var routerEnabled = false;
  var disposed = false;
  Object? benchmarkError;

  @override
  Future<void> sendIncoming(List<int> chunk) async {
    concurrentIncoming++;
    if (concurrentIncoming > maxConcurrentIncoming) {
      maxConcurrentIncoming = concurrentIncoming;
    }
    await Future<void>.delayed(const Duration(milliseconds: 2));
    incoming.add(chunk.single);
    concurrentIncoming--;
  }

  @override
  Future<void> connect() async {
    connectCount++;
  }

  @override
  Future<qlv2.PassportEchoResult> requestPassportEcho(String message) async =>
      qlv2.PassportEchoResult(message: message, milliseconds: 1);

  @override
  Future<qlv2.PassportBenchmarkResult> downloadPassportBenchmark({
    required int bytes,
    required int receiveWindow,
  }) async {
    final error = benchmarkError;
    if (error != null) throw error;
    return qlv2.PassportBenchmarkResult(
      bytes: bytes,
      seconds: 1,
      mibPerSecond: bytes / (1024 * 1024),
    );
  }

  @override
  Future<qlv2.PeerPermissionsResponse> requestPermissions() async {
    permissionRequests++;
    if (permissionFailures > 0) {
      permissionFailures--;
      throw StateError('Transient permission failure');
    }
    return qlv2.PeerPermissionsResponse.updated;
  }

  @override
  Future<void> provisionRouter() async {
    routerProvisionCount++;
  }

  @override
  void setRouterEnabled(bool enabled) {
    routerEnabled = enabled;
  }

  @override
  Stream<qlv2.PeerStatusEvent> streamPeerStatus() => peerStatus.stream;

  @override
  Stream<QLV2WriteRequest> streamOutgoingMessages() => outgoing.stream;

  @override
  Stream<qlv2.InboundRpc> setUpRouter() => const Stream.empty();

  @override
  Future<Uint8List> ownIdentity() async => Uint8List.fromList([1]);

  @override
  Future<Uint8List> ownBundle() async => Uint8List.fromList([2]);

  @override
  Future<Uint8List?> getPersistedPeer() async => Uint8List.fromList([3]);

  @override
  Future<Uint8List> xid() async => Uint8List(16);

  @override
  Future<void> setPersistedPeer(List<int> bytes) async {}

  @override
  Future<void> bindPeer(List<int> peerBundleBytes) async {}

  @override
  Future<void> pair(List<int> invite) async {
    pairCount++;
  }

  @override
  Future<qlv2.PassportDetailsResponse> passportDetailsRequest() =>
      throw UnimplementedError();

  @override
  Future<qlv2.SignPsbtResponse> requestSignPsbt(
    String accountId,
    List<int> psbt,
  ) =>
      throw UnimplementedError();

  @override
  Stream<qlv2.AccountUpdatedEvent> subscribeAccountUpdated() {
    accountUpdateSubscriptions++;
    return accountUpdates.stream;
  }

  @override
  Stream<qlv2.ActiveSeedFingerprint> subscribePassportActiveSeedFingerprint() =>
      activeSeedFingerprints.stream;

  @override
  Stream<qlv2.FirmwareInstallEvent> subscribeFirmwareInstallStatus() =>
      firmwareInstallEvents.stream;

  @override
  Stream<qlv2.MagicBackupRestoreResult>
      subscribeMagicBackupRestoreCompleted() =>
          magicBackupRestoreResults.stream;

  @override
  Stream<qlv2.OnboardingState> subscribeOnboardingStatus() {
    onboardingSubscriptions++;
    return onboardingStates.stream;
  }

  @override
  Stream<qlv2.PassportDetailsResponse> subscribePassportDetails() =>
      passportDetails.stream;

  @override
  Stream<qlv2.PassportFiatPreferenceEvent> subscribePassportFiatPreference() =>
      fiatPreferences.stream;

  @override
  Stream<qlv2.PassportMagicBackupEnabled>
      subscribePassportMagicBackupEnabled() => magicBackupEnabled.stream;

  @override
  void dispose() {
    disposed = true;
  }

  Future<void> close() async {
    await Future.wait<void>([
      if (!peerStatus.isClosed) peerStatus.close(),
      if (!outgoing.isClosed) outgoing.close(),
      if (!accountUpdates.isClosed) accountUpdates.close(),
      if (!activeSeedFingerprints.isClosed) activeSeedFingerprints.close(),
      if (!firmwareInstallEvents.isClosed) firmwareInstallEvents.close(),
      if (!magicBackupRestoreResults.isClosed)
        magicBackupRestoreResults.close(),
      if (!onboardingStates.isClosed) onboardingStates.close(),
      if (!passportDetails.isClosed) passportDetails.close(),
      if (!fiatPreferences.isClosed) fiatPreferences.close(),
      if (!magicBackupEnabled.isClosed) magicBackupEnabled.close(),
    ]);
  }
}
