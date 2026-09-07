// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:io';

import 'package:envoy/account/accounts_manager.dart';
import 'package:envoy/account/sync_manager.dart';
import 'package:envoy/business/connectivity_manager.dart';
import 'package:envoy/business/local_storage.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ngwallet/ngwallet.dart';
import 'package:ngwallet/src/rust/frb_generated.dart' show RustLibApi;
import 'package:sembast/sembast_io.dart';
import 'package:tor/tor.dart';
import 'package:tor/src/rust/api/tor.dart' as tor_api;
import 'package:tor/src/rust/frb_generated.dart' as tor_ffi;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final api = _WalletApi();
  final handler = _AccountHandler();
  final account = EnvoyAccount(
    id: 'sync-reporting-test',
    name: 'Sync reporting test',
    color: '',
    preferredAddressType: AddressType.p2Wpkh,
    seedHasPassphrase: false,
    index: 0,
    descriptors: const [
      NgDescriptor(internal: '', addressType: AddressType.p2Wpkh),
      NgDescriptor(internal: '', addressType: AddressType.p2Tr),
    ],
    network: Network.bitcoin,
    nextAddress: [],
    balance: BigInt.zero,
    unlockedBalance: BigInt.zero,
    isHot: false,
    transactions: [],
    utxo: [],
    tags: [],
    xfp: '',
    externalPublicDescriptors: [],
    archived: false,
  );
  late Directory directory;
  late StreamSubscription<ConnectivityManagerEvent> subscription;
  final events = <ConnectivityManagerEvent>[];

  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('envoy-sync-test-');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (_) async => directory.path,
    );
    await LocalStorage.init();
    await EnvoyStorage().init();
    final errorHandler = FlutterError.onError;
    await EnvoyReport().init();
    FlutterError.onError = errorHandler;
    RustLib.initMock(api: api);
    tor_ffi.RustLib.initMock(api: _TorApi());
    await NgAccountManager().addAccount(account, handler);
  });

  setUp(() async {
    handler.failedRequest = null;
    handler.failedApply = null;
    handler.preparation = null;
    handler.disposed = false;
    handler.requests.clear();
    handler.applied.clear();
    api.syncCalls.clear();
    api.scanCalls.clear();
    api.torPorts.clear();
    api.validations.clear();
    api.sync = (_) async => _Update();
    api.scan = (_, gap) async => _Update();
    events.clear();
    Settings().usingTor = false;
    Settings().usingDefaultElectrumServer = true;
    for (final descriptor in account.descriptors) {
      await EnvoyStorage()
          .setAccountScanStatus(account.id, descriptor.addressType, true);
    }
    final connectivity = ConnectivityManager();
    connectivity.resetFailureCounters();
    connectivity.electrumConnected = false;
    subscription = connectivity.events.stream.listen(events.add);
  });

  tearDown(() async {
    await subscription.cancel();
    Tor.instance.disable();
    await Tor.instance.stop();
    SyncManager().onFullScanFinished((_, success) {});
  });

  tearDownAll(() async {
    await databaseFactoryIo.deleteDatabase('${directory.path}/envoy.db');
    await databaseFactoryIo.deleteDatabase('${directory.path}/logs.db');
    await directory.delete(recursive: true);
  });

  test('a later request failure still waits for and reports an earlier sync',
      () async {
    final started = Completer<void>();
    final update = Completer<WalletUpdate>();
    api.sync = (_) {
      started.complete();
      return update.future;
    };
    handler.failedRequest = AddressType.p2Tr;

    var completed = false;
    final batch = SyncManager().syncAccount(account).then((_) {
      completed = true;
    });
    await started.future;
    await Future<void>.delayed(Duration.zero);
    expect(completed, isFalse);
    expect(events, isEmpty);

    update.complete(_Update());
    await batch;
    await Future<void>.delayed(Duration.zero);

    expect(handler.applied, [AddressType.p2Wpkh]);
    expect(completed, isTrue);
    expect(events, [ConnectivityManagerEvent.electrumReachable]);
    expect(ConnectivityManager().electrumConnected, isTrue);
  });

  test('missing local sync requests do not add Electrum failure strikes',
      () async {
    api.sync = (_) async => throw Exception('No sync request found');

    await SyncManager().syncAccount(account);
    await Future<void>.delayed(Duration.zero);

    expect(api.syncCalls, [AddressType.p2Wpkh, AddressType.p2Tr]);
    expect(handler.applied, isEmpty);
    expect(events, isEmpty);
    expect(ConnectivityManager().serviceFailureCounters.electrum, 0);
    expect(ConnectivityManager().electrumConnected, isFalse);
  });

  test('two network failures still count as one Electrum failure strike',
      () async {
    api.sync = (_) async => throw Exception('Electrum sync failed: timed out');

    await SyncManager().syncAccount(account);

    expect(api.syncCalls, [AddressType.p2Wpkh, AddressType.p2Tr]);
    expect(handler.applied, isEmpty);
    expect(ConnectivityManager().serviceFailureCounters.electrum, 1);
  });

  test('periodic and manual refreshes share ownership during preparation',
      () async {
    ConnectivityManager().electrumConnected = true;
    final preparation = Completer<void>();
    handler.preparation = preparation.future;
    final periodic = SyncManager().sync();
    final secondRound = SyncManager().sync();
    final manual = SyncManager().syncAccount(account);
    await Future<void>.delayed(Duration.zero);
    expect(api.syncCalls, isEmpty);
    preparation.complete();
    await Future.wait([periodic, secondRound, manual]);
    await Future<void>.delayed(Duration.zero);
    expect(api.syncCalls, [AddressType.p2Wpkh, AddressType.p2Tr]);
    expect(events, [ConnectivityManagerEvent.electrumReachable]);
  });

  test('a rescan abandons prepared background work and uses its own stop gap',
      () async {
    ConnectivityManager().electrumConnected = true;
    final preparation = Completer<void>();
    handler.preparation = preparation.future;
    final periodic = SyncManager().sync();
    await Future<void>.delayed(Duration.zero);
    expect(handler.requests, hasLength(2));
    final scan = SyncManager().initiateAccountFullScan(account, 500);
    expect(SyncManager().isAccountFullScanning(account.id), isTrue);
    preparation.complete();
    await Future.wait([periodic, scan]);
    expect(api.syncCalls, isEmpty);
    expect(api.scanCalls, [(AddressType.p2Wpkh, 500), (AddressType.p2Tr, 500)]);
    expect(handler.requests.every((request) => request.isDisposed), isTrue);
    expect(SyncManager().isAccountFullScanning(account.id), isFalse);
  });

  test('periodic rounds refresh other accounts during an automatic scan',
      () async {
    ConnectivityManager().electrumConnected = true;
    await EnvoyStorage()
        .setAccountScanStatus(account.id, AddressType.p2Tr, false);
    final other = account.copyWith(id: 'already-scanned-account');
    final otherHandler = _AccountHandler();
    await NgAccountManager().addAccount(other, otherHandler);
    addTearDown(() => NgAccountManager().deleteAccount(other));
    for (final descriptor in other.descriptors) {
      await EnvoyStorage()
          .setAccountScanStatus(other.id, descriptor.addressType, true);
    }

    final update = Completer<WalletUpdate>();
    api.scan = (_, gap) => update.future;
    final first = SyncManager().sync();
    await Future<void>.delayed(Duration.zero);
    final firstUpdates = otherHandler.applied.length;
    final second = SyncManager().sync();
    await Future<void>.delayed(Duration.zero);
    final updatesWhileScanning = otherHandler.applied.length;
    final scans = List.of(api.scanCalls);
    update.complete(_Update());
    await Future.wait([first, second]);

    expect(firstUpdates, 2);
    expect(updatesWhileScanning, 4);
    expect(scans, [(AddressType.p2Tr, null)]);
  });

  test('a manual scan waits for native sync owners without overlapping them',
      () async {
    final update = Completer<WalletUpdate>();
    api.sync = (_) => update.future;
    final sync = SyncManager().syncAccount(account);
    await Future<void>.delayed(Duration.zero);
    expect(api.syncCalls, hasLength(2));
    final scan = SyncManager().initiateAccountFullScan(account, 300);
    await Future<void>.delayed(Duration.zero);
    expect(api.scanCalls, isEmpty);
    update.complete(_Update());
    await Future.wait([sync, scan]);
    expect(api.scanCalls, [(AddressType.p2Wpkh, 300), (AddressType.p2Tr, 300)]);
  });

  test('a manual rescan waits for background scans then runs the requested gap',
      () async {
    ConnectivityManager().electrumConnected = true;
    for (final descriptor in account.descriptors) {
      await EnvoyStorage()
          .setAccountScanStatus(account.id, descriptor.addressType, false);
    }
    final update = Completer<WalletUpdate>();
    api.scan =
        (_, gap) => gap == null ? update.future : Future.value(_Update());
    final background = SyncManager().sync();
    await Future<void>.delayed(Duration.zero);
    expect(
        api.scanCalls,
        unorderedEquals(
            [(AddressType.p2Wpkh, null), (AddressType.p2Tr, null)]));
    final manual = SyncManager().initiateAccountFullScan(account, 1000);
    await Future<void>.delayed(Duration.zero);
    expect(api.scanCalls, hasLength(2));
    update.complete(_Update());
    await Future.wait([background, manual]);
    expect(api.scanCalls.skip(2),
        [(AddressType.p2Wpkh, 1000), (AddressType.p2Tr, 1000)]);
  });

  test('setup and apply failures do not skip remaining scan descriptors',
      () async {
    bool? succeeded;
    SyncManager().onFullScanFinished((_, success) => succeeded = success);
    handler.failedRequest = AddressType.p2Wpkh;
    await SyncManager().initiateAccountFullScan(account, 300);
    expect(succeeded, isFalse);
    expect(handler.applied, [AddressType.p2Tr]);
    expect(ConnectivityManager().serviceFailureCounters.electrum, 0);

    handler.failedRequest = null;
    handler.failedApply = AddressType.p2Wpkh;
    handler.applied.clear();
    await SyncManager().initiateAccountFullScan(account, 300);
    expect(succeeded, isFalse);
    expect(handler.applied, [AddressType.p2Tr]);
    expect(ConnectivityManager().electrumConnected, isTrue);
  });

  test('changed endpoints and retired handlers discard work before native I/O',
      () async {
    for (final retireHandler in [false, true]) {
      final preparation = Completer<void>();
      handler.preparation = preparation.future;
      final sync = SyncManager().syncAccount(account);
      await Future<void>.delayed(Duration.zero);
      if (retireHandler) {
        handler.disposed = true;
      } else {
        Settings().usingDefaultElectrumServer = false;
        Settings().selectedElectrumAddress = 'ssl://other.example.com:50002';
      }
      preparation.complete();
      await sync;
      expect(api.syncCalls, isEmpty);
      expect(handler.requests.every((request) => request.isDisposed), isTrue);
    }
    expect(ConnectivityManager().serviceFailureCounters.electrum, 0);
  });

  test('an old route success cannot hide a replacement route failure',
      () async {
    Settings().usingTor = true;
    await Tor.instance.enable();
    final pending = Completer<WalletUpdate>();
    api.sync = (request) =>
        (request as _Request).addressType == AddressType.p2Wpkh
            ? Future.value(_Update())
            : pending.future;
    final batch = SyncManager().syncAccount(account);
    await Future<void>.delayed(Duration.zero);
    expect(handler.applied, [AddressType.p2Wpkh]);

    await Tor.instance.stop();
    await Tor.instance.start();
    api.sync = (_) async => throw Exception('Replacement route failed');
    pending.completeError(Exception('Old route closed'));
    await batch;

    expect(api.syncCalls, hasLength(3));
    expect(ConnectivityManager().electrumConnected, isFalse);
    expect(ConnectivityManager().serviceFailureCounters.electrum, 1);
  });

  for (final fails in [false, true]) {
    test(
        'a buffered ${fails ? 'failure' : 'success'} ignores a changed endpoint',
        () async {
      final pending = Completer<WalletUpdate>();
      api.sync = (request) async {
        if ((request as _Request).addressType == AddressType.p2Tr) {
          return pending.future;
        }
        if (fails) throw Exception('Original endpoint failed');
        return _Update();
      };
      final batch = SyncManager().syncAccount(account);
      await Future<void>.delayed(Duration.zero);
      expect(api.syncCalls, hasLength(2));
      expect(handler.applied, fails ? isEmpty : [AddressType.p2Wpkh]);

      Settings().usingDefaultElectrumServer = false;
      Settings().selectedElectrumAddress = 'ssl://other.example.com:50002';
      pending.completeError(Exception('Original endpoint closed'));
      await batch;

      expect(ConnectivityManager().electrumConnected, isFalse);
      expect(ConnectivityManager().serviceFailureCounters.electrum, 0);
    });
  }

  test('a consumed request retries once on a replacement Tor route', () async {
    Settings().usingTor = true;
    await Tor.instance.enable();
    final first = Completer<WalletUpdate>();
    api.sync = (_) =>
        api.syncCalls.length <= 2 ? first.future : Future.value(_Update());
    final sync = SyncManager().syncAccount(account);
    await Future<void>.delayed(Duration.zero);
    expect(api.syncCalls, hasLength(2));
    expect(handler.requests.every((request) => request.isDisposed), isTrue);
    await Tor.instance.stop();
    await Tor.instance.start();
    first.completeError(Exception('Electrum sync failed: old SOCKS route'));
    await sync;
    expect(api.syncCalls, hasLength(4));
    expect(handler.requests, hasLength(4));
    expect(api.torPorts.take(2).toSet(), hasLength(1));
    expect(api.torPorts.first, isNot(api.torPorts.last));
    expect(api.validations, everyElement(isFalse));
    expect(handler.applied, hasLength(2));
    expect(ConnectivityManager().serviceFailureCounters.electrum, 0);
  });

  test('a stale failure while Tor is unavailable does not poison recovery',
      () async {
    Settings().usingTor = true;
    await Tor.instance.enable();
    final update = Completer<WalletUpdate>();
    api.sync = (_) => update.future;
    final sync = SyncManager().syncAccount(account);
    await Future<void>.delayed(Duration.zero);
    await Tor.instance.stop();
    update.completeError(Exception('Electrum sync failed: closed route'));
    await sync;
    expect(api.syncCalls, hasLength(2));
    expect(ConnectivityManager().serviceFailureCounters.electrum, 0);
    expect(events, isNot(contains(ConnectivityManagerEvent.electrumReachable)));
  });

  test('disconnected periodic rounds wait for the active recovery probe',
      () async {
    final update = Completer<WalletUpdate>();
    api.sync = (_) => update.future;
    final first = SyncManager().sync();
    await Future<void>.delayed(Duration.zero);
    final second = SyncManager().sync();
    await Future<void>.delayed(Duration.zero);
    final callsWhileProbing = api.syncCalls.length;
    update.complete(_Update());
    await Future.wait([first, second]);

    expect(callsWhileProbing, 1);
  });

  test('a probe skipped while Tor is unavailable does not delay recovery',
      () async {
    Settings().usingTor = true;
    await Tor.instance.enable();
    await Tor.instance.stop();

    await SyncManager().sync();
    expect(api.syncCalls, isEmpty);
    expect(ConnectivityManager().serviceFailureCounters.electrum, 0);

    await Tor.instance.start();
    await SyncManager().sync();
    expect(api.syncCalls, hasLength(1));
    expect(ConnectivityManager().electrumConnected, isTrue);
  });

  test('disconnected periodic rounds probe one descriptor and respect cooldown',
      () async {
    api.sync = (_) async => throw Exception('Electrum sync failed: timed out');
    await SyncManager().sync();
    final calls = api.syncCalls.length;
    expect(calls, 1);
    await SyncManager().sync();
    expect(api.syncCalls, hasLength(calls));
  });

  test('Tor admits three requests and discards a retired queued account',
      () async {
    Settings().usingTor = true;
    await Tor.instance.enable();
    final other = account.copyWith(id: 'queued-account');
    final otherHandler = _AccountHandler();
    await NgAccountManager().addAccount(other, otherHandler);
    addTearDown(() => NgAccountManager().deleteAccount(other));
    final release = Completer<void>();
    api.sync = (_) async {
      await release.future;
      return _Update();
    };
    final first = SyncManager().syncAccount(account);
    final queued = SyncManager().syncAccount(other);
    await Future<void>.delayed(Duration.zero);
    expect(api.syncCalls, hasLength(3));
    expect(otherHandler.requests, hasLength(1));
    otherHandler.disposed = true;
    release.complete();
    await Future.wait([first, queued]);
    expect(api.syncCalls, hasLength(3));
    expect(otherHandler.applied, isEmpty);
    expect(ConnectivityManager().serviceFailureCounters.electrum, 0);
  });

  test(
      'initial scanning skips scanned descriptors and shares periodic ownership',
      () async {
    await EnvoyStorage()
        .setAccountScanStatus(account.id, AddressType.p2Tr, false);
    final update = Completer<WalletUpdate>();
    api.scan = (_, gap) => update.future;
    final initial = SyncManager().initiateFullScan();
    final periodic = SyncManager().sync();
    await Future<void>.delayed(Duration.zero);
    expect(api.scanCalls, [(AddressType.p2Tr, null)]);
    expect(api.syncCalls, isEmpty);
    update.complete(_Update());
    await Future.wait([initial, periodic]);
    expect(
        await EnvoyStorage().getAccountScanStatus(account.id, AddressType.p2Tr),
        isTrue);
  });

  test('a skipped initial scan still lets a waiting manual refresh run',
      () async {
    final initial = SyncManager().initiateFullScan();
    final manual = SyncManager().syncAccount(account);
    await Future.wait([initial, manual]);
    expect(api.syncCalls, [AddressType.p2Wpkh, AddressType.p2Tr]);
    expect(api.scanCalls, isEmpty);
  });
}

class _AccountHandler extends Fake
    with _NativeHandle
    implements EnvoyAccountHandler {
  AddressType? failedRequest;
  AddressType? failedApply;
  Future<void>? preparation;
  final requests = <_NativeHandle>[];
  final applied = <AddressType>[];

  @override
  Future<SyncRequest> syncRequest({required AddressType addressType}) async {
    if (addressType == failedRequest) throw StateError('Request unavailable');
    final request = _Request(addressType);
    requests.add(request);
    await preparation;
    return request;
  }

  @override
  Future<FullScanRequest> requestFullScan(
      {required AddressType addressType}) async {
    if (addressType == failedRequest) throw StateError('Request unavailable');
    final request = _ScanRequest(addressType);
    requests.add(request);
    return request;
  }

  @override
  Future<void> applyUpdate({
    required WalletUpdate update,
    required AddressType addressType,
  }) async {
    if (addressType == failedApply) throw StateError('Apply failed');
    applied.add(addressType);
  }

  @override
  Future<void> sendUpdate() async {}

  @override
  Future<void> deleteAccount() async {}
}

mixin _NativeHandle {
  bool disposed = false;

  bool get isDisposed => disposed;
  void dispose() => disposed = true;
}

class _Request extends Fake with _NativeHandle implements SyncRequest {
  _Request(this.addressType);

  final AddressType addressType;
}

class _ScanRequest extends Fake with _NativeHandle implements FullScanRequest {
  _ScanRequest(this.addressType);
  final AddressType addressType;
}

class _Update extends Fake with _NativeHandle implements WalletUpdate {}

class _WalletApi extends Fake implements RustLibApi {
  late Future<WalletUpdate> Function(SyncRequest) sync;
  late Future<WalletUpdate> Function(FullScanRequest, int?) scan;
  final syncCalls = <AddressType>[];
  final scanCalls = <(AddressType, int?)>[];
  final torPorts = <int?>[];
  final validations = <bool?>[];

  @override
  Future<WalletUpdate> crateApiEnvoyWalletEnvoyAccountHandlerSyncWallet({
    required SyncRequest syncRequest,
    required String electrumServer,
    int? torPort,
    bool? validateDomain,
  }) {
    syncCalls.add((syncRequest as _Request).addressType);
    syncRequest.dispose(); // FRB moves the handle before network I/O.
    torPorts.add(torPort);
    validations.add(validateDomain);
    return sync(syncRequest);
  }

  @override
  Future<WalletUpdate> crateApiEnvoyWalletEnvoyAccountHandlerScanWallet({
    required FullScanRequest scanRequest,
    required String electrumServer,
    int? torPort,
    int? stopGap,
    bool? validateDomain,
  }) {
    scanCalls.add(((scanRequest as _ScanRequest).addressType, stopGap));
    scanRequest.dispose();
    return scan(scanRequest, stopGap);
  }
}

class _TorApi extends Fake implements tor_ffi.RustLibApi {
  int _port = 19050;

  @override
  tor_api.TorBootstrapCancellationToken
      crateApiTorTorBootstrapCancellationTokenNew() => _TorCancellationToken();

  @override
  Future<tor_api.TorInstance> crateApiTorStartTor({
    required int socksPort,
    required String stateDir,
    required String cacheDir,
    required tor_api.TorBootstrapCancellationToken cancellationToken,
  }) async =>
      _TorInstance(_port++);

  @override
  Future<String?> crateApiTorWaitForProxyExit(
          {required tor_api.TorProxyMonitor monitor}) =>
      (monitor as _TorProxy).exit.future;

  @override
  Future<void> crateApiTorStopProxy(
      {required tor_api.TorProxyHandle proxy}) async {
    (proxy as _TorProxy).exit.complete(null);
    proxy.dispose();
  }
}

class _TorCancellationToken extends Fake
    with _NativeHandle
    implements tor_api.TorBootstrapCancellationToken {
  @override
  void cancel() {}
}

class _TorInstance extends Fake
    with _NativeHandle
    implements tor_api.TorInstance {
  _TorInstance(this.socksPort);
  @override
  final int socksPort;
  @override
  tor_api.TorClientWrapper get client => _TorClient();
  @override
  final _TorProxy proxy = _TorProxy();
  @override
  tor_api.TorProxyMonitor get proxyMonitor => proxy;
}

class _TorClient extends Fake
    with _NativeHandle
    implements tor_api.TorClientWrapper {}

class _TorProxy extends Fake
    with _NativeHandle
    implements tor_api.TorProxyHandle, tor_api.TorProxyMonitor {
  final exit = Completer<String?>();
}
