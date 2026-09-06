// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:envoy/account/accounts_manager.dart';
import 'package:envoy/account/electrum_route.dart';
import 'package:envoy/account/electrum_sync_health.dart';
import 'package:envoy/account/electrum_sync_schedule.dart';
import 'package:envoy/business/connectivity_manager.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:ngwallet/ngwallet.dart';
import 'package:tor/tor.dart';

sealed class WalletProgress {}

class Scanning extends WalletProgress {
  final String id;

  Scanning(this.id);
}

class Syncing extends WalletProgress {
  final String id;

  Syncing(this.id);
}

class None extends WalletProgress {}

enum _RefreshKind { sync, scan, automatic, unscanned }

typedef _RefreshResult = ({
  Network network,
  String? server,
  ElectrumRoute? route,
  bool viaTor,
  ElectrumSyncReachability reachability,
  bool success,
  bool fullScan,
});

class _ElectrumWorkChanged implements Exception {
  const _ElectrumWorkChanged();
}

class SyncManager {
  static const _maxConcurrentTorRequests = 3;
  static const _backgroundWait = Duration(seconds: 30);
  static const _manualScanWait = Duration(minutes: 15);
  static const _scanJoinWait = Duration(seconds: 3);

  // Ownership includes local preparation, admission, network I/O and applying
  // the update. Register it before the first await; no separate request queue.
  final Map<(String, AddressType),
      ({_RefreshKind kind, Future<_RefreshResult> future})> _operations = {};
  final _torRequests = ElectrumRequestGate(
    maxConcurrent: _maxConcurrentTorRequests,
  );
  final _probeCooldown = ElectrumProbeCooldown();
  int _probeIndex = 0;
  final Set<(String, AddressType, int, String)> _reportedLocalFailures = {};

  void Function(EnvoyAccount, bool)? _onAccFullScanFinished;
  Timer? _syncTimer;
  final _currentLoading = StreamController<WalletProgress>.broadcast();
  final Set<String> _fullScanningAccountIds = {};
  final _fullScanningAccountsController =
      StreamController<Set<String>>.broadcast();

  Stream<WalletProgress> get currentLoading => _currentLoading.stream;
  Stream<Set<String>> get fullScanningAccountsStream =>
      _fullScanningAccountsController.stream;
  Set<String> get fullScanningAccounts =>
      Set.unmodifiable(_fullScanningAccountIds);

  bool isAccountFullScanning(String accountId) =>
      _fullScanningAccountIds.contains(accountId);

  void _emitFullScanningAccounts() {
    if (!_fullScanningAccountsController.isClosed) {
      _fullScanningAccountsController.add(Set.of(_fullScanningAccountIds));
    }
  }

  static final SyncManager _instance = SyncManager._internal();
  SyncManager._internal();
  factory SyncManager() => _instance;

  void startSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (NgAccountManager().accounts.isNotEmpty) {
        unawaited(sync());
      }
    });
  }

  // Descriptor ownership prevents overlap without holding up unrelated wallets.
  Future<void> sync() => _syncAll();

  Future<void> initiateFullScan() async {
    final accounts = NgAccountManager().accounts;
    final results = await Future.wait([
      for (final account in accounts)
        for (final descriptor in account.descriptors)
          _refreshDescriptor(
              account, descriptor.addressType, _RefreshKind.unscanned),
    ]);
    _reportReachability(results);
  }

  Future<void> syncAccount(EnvoyAccount account) async {
    if (account.handler == null) return;
    final results = await Future.wait([
      for (final descriptor in account.descriptors)
        _refreshDescriptor(account, descriptor.addressType, _RefreshKind.sync),
    ]);
    _reportReachability(results);
  }

  void onFullScanFinished(void Function(EnvoyAccount, bool) callback) {
    _onAccFullScanFinished = callback;
  }

  Future<void> _syncAll() async {
    final settings = Settings();
    final probeOnly = !ConnectivityManager().electrumConnected;
    final endpoint = settings.electrumAddress(Network.bitcoin);
    final accounts = NgAccountManager().accounts;
    final mainnetRefreshActive = accounts.any((account) =>
        account.network == Network.bitcoin &&
        account.descriptors.any((descriptor) =>
            _operations.containsKey((account.id, descriptor.addressType))));
    final candidates = <({EnvoyAccount account, AddressType addressType})>[];
    for (final account in accounts) {
      if (isAccountFullScanning(account.id) || account.handler == null) {
        continue;
      }
      if ((!settings.showTestnetAccounts() &&
              (account.network == Network.testnet ||
                  account.network == Network.testnet4)) ||
          (!settings.showSignetAccounts() &&
              account.network == Network.signet)) {
        continue;
      }
      for (final descriptor in account.descriptors) {
        if (!_operations.containsKey((account.id, descriptor.addressType))) {
          candidates
              .add((account: account, addressType: descriptor.addressType));
        }
      }
    }

    final selection = selectElectrumSyncCandidates(
      candidates: candidates,
      isMainnet: (candidate) => candidate.account.network == Network.bitcoin,
      mainnetProbeOnly: probeOnly,
      mainnetProbeAllowed:
          !mainnetRefreshActive && _probeCooldown.canProbe(endpoint),
      probeIndex: _probeIndex,
      connectedRotationStep: _maxConcurrentTorRequests,
    );
    _probeIndex = selection.nextProbeIndex;
    kPrint('[ElectrumSync] periodic candidates=${candidates.length} '
        'selected=${selection.selected.length} probeOnly=$probeOnly '
        'probeSelected=${selection.probeSelected}');
    final results = await Future.wait([
      for (final candidate in selection.selected)
        _refreshDescriptor(
          candidate.account,
          candidate.addressType,
          _RefreshKind.automatic,
        ),
    ]);
    final reachability = _reportReachability(results);
    if (!ConnectivityManager().electrumConnected &&
        (reachability == ElectrumSyncReachability.unreachable ||
            (probeOnly && selection.probeSelected))) {
      _probeCooldown.recordFailure(endpoint);
      kPrint('[ElectrumSync] probe-cooldown '
          'seconds=${_probeCooldown.cooldown.inSeconds}');
    }
  }

  Future<void> initiateAccountFullScan(
      EnvoyAccount account, int stopGap) async {
    if (!_fullScanningAccountIds.add(account.id)) return;
    _emitFullScanningAccounts();
    final waitBudget = ElectrumPermitWaitBudget(_manualScanWait);
    final results = <_RefreshResult>[];
    try {
      for (final descriptor in account.descriptors) {
        results.add(await _refreshDescriptor(
          account,
          descriptor.addressType,
          _RefreshKind.scan,
          stopGap: stopGap,
          waitBudget: waitBudget,
        ));
      }
    } finally {
      _reportReachability(results);
      _fullScanningAccountIds.remove(account.id);
      _emitFullScanningAccounts();
      _onAccFullScanFinished?.call(
        account,
        results.length == account.descriptors.length &&
            results.every((result) => result.success),
      );
    }
  }

  _RefreshResult _notAttempted(EnvoyAccount account) => (
        network: account.network,
        server: null,
        route: null,
        viaTor: false,
        reachability: ElectrumSyncReachability.notAttempted,
        success: false,
        fullScan: false,
      );

  Future<_RefreshResult> _refreshDescriptor(
    EnvoyAccount account,
    AddressType addressType,
    _RefreshKind kind, {
    int? stopGap,
    ElectrumPermitWaitBudget? waitBudget,
  }) async {
    final manualScan = stopGap != null;
    if (!manualScan && isAccountFullScanning(account.id)) {
      _trace(account, addressType, 'skip kind=${kind.name} reason=manual-scan');
      return _notAttempted(account);
    }
    final key = (account.id, addressType);
    final active = _operations[key];
    if (active != null) {
      _trace(
          account,
          addressType,
          'owner-active kind=${kind.name} owner=${active.kind.name} '
          'action=${kind == _RefreshKind.automatic || kind == _RefreshKind.unscanned ? 'skip' : 'join'}');
      if (kind == _RefreshKind.automatic || kind == _RefreshKind.unscanned) {
        return _notAttempted(account);
      }
      try {
        if (manualScan) {
          await waitBudget!.waitForOwner(active.future);
        } else if (active.kind == _RefreshKind.sync) {
          await active.future;
          // Only the owner contributes a health observation.
          return _notAttempted(account);
        } else {
          final result = await active.future.timeout(_scanJoinWait);
          if (active.kind != _RefreshKind.unscanned && !result.fullScan) {
            return _notAttempted(account);
          }
        }
      } on TimeoutException {
        // A timeout only releases this waiter, never the native owner.
        _trace(
            account, addressType, 'owner-wait-timeout ownerStillRunning=true');
        return _notAttempted(account);
      }
      return _refreshDescriptor(account, addressType, kind,
          stopGap: stopGap, waitBudget: waitBudget);
    }

    final completion = Completer<_RefreshResult>();
    _operations[key] = (kind: kind, future: completion.future);
    final elapsed = Stopwatch()..start();
    _trace(account, addressType, 'begin kind=${kind.name} stopGap=$stopGap');
    var result = _notAttempted(account);
    try {
      result = await _performRefresh(
        account,
        addressType,
        kind,
        stopGap: stopGap,
        waitBudget: waitBudget ?? ElectrumPermitWaitBudget(_backgroundWait),
      );
    } catch (error) {
      _logError(account, addressType, 'preparing refresh', error);
    } finally {
      _operations.remove(key);
      completion.complete(result);
      _trace(
          account,
          addressType,
          'complete success=${result.success} fullScan=${result.fullScan} '
          'health=${result.reachability.name} elapsedMs=${elapsed.elapsedMilliseconds}');
    }
    return result;
  }

  Future<_RefreshResult> _performRefresh(
    EnvoyAccount account,
    AddressType addressType,
    _RefreshKind kind, {
    int? stopGap,
    required ElectrumPermitWaitBudget waitBudget,
  }) async {
    final handler = account.handler;
    final server = Settings().electrumAddress(account.network);
    var route = _electrumRoute(account.network, server);
    if (handler == null || !route.isReady) {
      _trace(
          account,
          addressType,
          'skip reason=${handler == null ? 'missing-handler' : 'tor-unavailable'} '
          'route=${_routeLabel(route)}');
      return _notAttempted(account);
    }

    bool isCurrent() =>
        !_currentLoading.isClosed &&
        !handler.isDisposed &&
        identical(account.handler, handler) &&
        Settings().electrumAddress(account.network) == server;

    final fullScan = kind == _RefreshKind.scan ||
        ((kind == _RefreshKind.automatic || kind == _RefreshKind.unscanned) &&
            !await EnvoyStorage()
                .getAccountScanStatus(account.id, addressType));
    if (kind == _RefreshKind.unscanned && !fullScan) {
      _trace(account, addressType, 'skip reason=already-scanned');
      return _notAttempted(account);
    }
    if (!isCurrent() ||
        (stopGap == null && isAccountFullScanning(account.id))) {
      _trace(
          account, addressType, 'skip reason=work-changed-before-preparation');
      return _notAttempted(account);
    }
    final key = (account.id, addressType);
    _operations[key] = (
      kind: fullScan ? _RefreshKind.scan : _RefreshKind.sync,
      future: _operations[key]!.future,
    );
    _currentLoading.add(fullScan ? Scanning(account.id) : Syncing(account.id));
    _RefreshResult result(ElectrumSyncReachability health,
            {bool success = false}) =>
        (
          network: account.network,
          server: server,
          route: route,
          viaTor: route.requiresTor,
          reachability: health,
          success: success,
          fullScan: fullScan,
        );

    WalletUpdate? update;
    try {
      for (var attempt = 0; attempt < 2; attempt++) {
        var attempted = false;
        void checkCurrent() {
          if (!isCurrent() ||
              (stopGap == null && isAccountFullScanning(account.id)) ||
              !route.isSameRoute(_electrumRoute(account.network, server))) {
            throw const _ElectrumWorkChanged();
          }
        }

        Future<WalletUpdate> request() async {
          checkCurrent();
          // Construct the one-shot handle only after admission. Every retry
          // gets a fresh handle; abandoned handles are released locally.
          FullScanRequest? scanRequest;
          SyncRequest? syncRequest;
          try {
            final validateDomain = Settings().validateDomain(
              server,
              viaTor: route.port != null,
            );
            if (fullScan) {
              scanRequest =
                  await handler.requestFullScan(addressType: addressType);
              checkCurrent();
              if (scanRequest.isDisposed) throw const _ElectrumWorkChanged();
              attempted = true;
              _trace(
                  account,
                  addressType,
                  'network-start request=${identityHashCode(request)} '
                  'scan=true validateDomain=$validateDomain');
              return await EnvoyAccountHandler.scanWallet(
                scanRequest: scanRequest,
                electrumServer: server,
                torPort: route.port,
                stopGap: stopGap,
                validateDomain: validateDomain,
              );
            }
            syncRequest = await handler.syncRequest(addressType: addressType);
            checkCurrent();
            if (syncRequest.isDisposed) throw const _ElectrumWorkChanged();
            attempted = true;
            _trace(
                account,
                addressType,
                'network-start request=${identityHashCode(request)} '
                'scan=false validateDomain=$validateDomain');
            return await EnvoyAccountHandler.syncWallet(
              syncRequest: syncRequest,
              electrumServer: server,
              torPort: route.port,
              validateDomain: validateDomain,
            );
          } finally {
            if (scanRequest != null && !scanRequest.isDisposed) {
              scanRequest.dispose();
            }
            if (syncRequest != null && !syncRequest.isDisposed) {
              syncRequest.dispose();
            }
          }
        }

        try {
          _trace(
              account,
              addressType,
              'attempt=${attempt + 1}/2 request=${identityHashCode(request)} '
              'route=${_routeLabel(route)} priority=${stopGap != null} '
              'waitBudgetMs=${waitBudget.remaining.inMilliseconds}');
          update = await (route.requiresTor
              ? _torRequests.run(
                  (server, route.port, route.generation),
                  request,
                  waitBudget: waitBudget,
                  prioritize: stopGap != null,
                )
              : request());
          _trace(account, addressType,
              'network-complete request=${identityHashCode(request)}');
          break;
        } catch (error) {
          if (!isCurrent()) {
            _trace(account, addressType,
                'discard reason=handler-or-endpoint-changed');
            return _notAttempted(account);
          }
          // FRB consumes the handle before I/O, even on a network error.
          // Only ngwallet's explicit missing-request error is a local failure.
          final missingRequest =
              error.toString().contains('No Scan request found') ||
                  error.toString().contains('No sync request found');
          if (missingRequest) {
            _trace(
                account, addressType, 'discard reason=missing-local-request');
            if (fullScan) {
              _logError(
                  account,
                  addressType,
                  attempt == 0
                      ? 'missing scan request'
                      : 'missing retry request',
                  error,
                  generation: route.generation);
            }
            return _notAttempted(account);
          }
          final replacement = _electrumRoute(account.network, server);
          if (attempt == 0 && route.canRetryOn(replacement)) {
            _trace(
                account,
                addressType,
                'retry reason=replaced-route old=${_routeLabel(route)} '
                'new=${_routeLabel(replacement)} freshRequest=true');
            route = replacement;
            continue;
          }
          if (!route.isSameRoute(replacement)) {
            _trace(
                account,
                addressType,
                'discard reason=replaced-route old=${_routeLabel(route)} '
                'new=${_routeLabel(replacement)} health=notAttempted');
            _logError(account, addressType, 'discarding replaced-route failure',
                '$error | old route: ${route.port}/${route.generation}, current route: ${replacement.port}/${replacement.generation}',
                generation: replacement.generation);
            return _notAttempted(account);
          }
          if (error is ElectrumRequestPermitTimeout ||
              error is _ElectrumWorkChanged) {
            _trace(account, addressType,
                'skip reason=${error is ElectrumRequestPermitTimeout ? 'queue-timeout' : 'work-changed'}');
            return _notAttempted(account);
          }
          _trace(account, addressType,
              'failed attempted=$attempted errorType=${error.runtimeType}');
          _logError(
              account, addressType, fullScan ? 'scanning' : 'syncing', error);
          return result(attempted
              ? ElectrumSyncReachability.unreachable
              : ElectrumSyncReachability.notAttempted);
        }
      }

      // A response from an old route may update this wallet, but cannot prove
      // the currently selected endpoint or replacement route is reachable.
      final health = Settings().electrumAddress(account.network) == server &&
              route.isSameRoute(_electrumRoute(account.network, server))
          ? ElectrumSyncReachability.reachable
          : ElectrumSyncReachability.notAttempted;
      if (handler.isDisposed || !identical(account.handler, handler)) {
        _trace(account, addressType, 'discard-update reason=retired-handler');
        return result(health);
      }
      try {
        await handler.applyUpdate(update: update!, addressType: addressType);
        if (fullScan) {
          await EnvoyStorage()
              .setAccountScanStatus(account.id, addressType, true);
        } else {
          await handler.sendUpdate();
        }
        return result(health, success: true);
      } catch (error) {
        _trace(account, addressType,
            'apply-failed errorType=${error.runtimeType}');
        _logError(account, addressType, 'applying update', error);
        return result(health);
      }
    } finally {
      if (update != null && !update.isDisposed) update.dispose();
      if (!_currentLoading.isClosed) _currentLoading.add(None());
    }
  }

  ElectrumRoute _electrumRoute(Network network, String server) => ElectrumRoute(
        requiresTor: !Settings().onTorWhitelist(server),
        port: Settings().getTorPort(network, server),
        generation: Tor.instance.routeGeneration,
      );

  ElectrumSyncReachability _reportReachability(
      Iterable<_RefreshResult> results) {
    final server = Settings().electrumAddress(Network.bitcoin);
    final route = _electrumRoute(Network.bitcoin, server);
    // Results may have waited for other descriptors or for updates to apply.
    final mainnet = results
        .where((r) =>
            r.network == Network.bitcoin &&
            r.server == server &&
            r.route?.isSameRoute(route) == true)
        .toList();
    final reachability = aggregateElectrumSyncReachability(
      mainnet.map((r) => r.reachability),
    );
    switch (reachability) {
      case ElectrumSyncReachability.reachable:
        _probeCooldown.recordSuccess();
        ConnectivityManager().electrumSuccess(
            viaTor: mainnet.any((r) =>
                r.viaTor &&
                r.reachability == ElectrumSyncReachability.reachable));
      case ElectrumSyncReachability.unreachable:
        ConnectivityManager().electrumFailure();
      case ElectrumSyncReachability.notAttempted:
        break;
    }
    kPrint('[ElectrumSync] health result=${reachability.name} '
        'mainnetResults=${mainnet.length} '
        'connected=${ConnectivityManager().electrumConnected}');
    return reachability;
  }

  String _routeLabel(ElectrumRoute route) => route.requiresTor
      ? 'tor(port=${route.port},generation=${route.generation})'
      : 'direct';

  void _trace(EnvoyAccount account, AddressType addressType, String message) {
    // Session-local identity avoids logging account IDs, names or descriptors.
    kPrint('[ElectrumSync] wallet=${identityHashCode(account)} '
        'type=${addressType.name} network=${account.network} $message');
  }

  void _logError(EnvoyAccount account, AddressType addressType,
      String operation, Object error,
      {int? generation}) {
    if (generation != null) {
      _reportedLocalFailures.removeWhere((key) => key.$3 < generation);
      if (!_reportedLocalFailures
          .add((account.id, addressType, generation, operation))) {
        return;
      }
    }
    final context =
        'Electrum $operation $addressType | ${account.name} | ${account.network}';
    if (account.network == Network.bitcoin) {
      EnvoyReport().log(context, error.toString());
    } else {
      kPrint(context);
    }
  }

  void dispose() {
    _syncTimer?.cancel();
    _currentLoading.close();
    _fullScanningAccountsController.close();
  }
}
