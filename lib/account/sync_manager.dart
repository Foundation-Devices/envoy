// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:envoy/account/accounts_manager.dart';
import 'package:envoy/account/electrum_sync_health.dart';
import 'package:envoy/business/connectivity_manager.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:envoy/util/list_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:ngwallet/ngwallet.dart';
import 'package:tor/tor.dart';

sealed class WalletProgress {}

typedef _ElectrumSyncResult = ({
  Network network,
  bool viaTor,
  ElectrumSyncReachability reachability,
});

class Scanning extends WalletProgress {
  final String id;

  Scanning(this.id);
}

class Syncing extends WalletProgress {
  final String id;

  Syncing(this.id);
}

class None extends WalletProgress {}

/// Outcome of a single-descriptor [SyncManager._performFullScan].
enum FullScanOutcome {
  /// Scan completed and the update was applied.
  success,

  /// Skipped because a scan for this descriptor is already running. Not a
  /// failure — the in-flight scan will report its own outcome.
  skipped,

  /// Scan could not run or errored (Tor not ready, disposed request, missing
  /// handler, scan/apply error).
  failure,
}

typedef _FullScanResult = ({
  FullScanOutcome outcome,
  _ElectrumSyncResult health,
});

class SyncManager {
  static const int _syncInterval = 10;

  final bool _enableLogging = false;
  Function(EnvoyAccount, bool)? _onAccFullScanFinished;

  // Track sync and scan requests
  final Map<(EnvoyAccount, AddressType), SyncRequest> _syncRequests = {};
  final Map<(EnvoyAccount, AddressType), FullScanRequest> _fullScanRequests =
      {};

  // Track active operations to prevent duplicates
  final Set<(String, AddressType)> _activeSyncOperations = {};
  final Set<(String, AddressType)> _activeFullScanOperations = {};

  Function(EnvoyAccount)? _onUpdateFinished;
  late Timer _syncTimer;

  final StreamController<WalletProgress> _currentLoading =
      StreamController<WalletProgress>.broadcast();

  Stream<WalletProgress> get currentLoading => _currentLoading.stream;

  // Per-account full-scan tracking. The global `_currentLoading` stream is
  // shared across all accounts and gets clobbered by unrelated `Syncing`
  // events from the periodic `_syncAll`, so the UI can't rely on it to know
  // whether a specific account is being rescanned. This set is set once in
  // `initiateAccountFullScan` and cleared only when *all* descriptors finish.
  final Set<String> _fullScanningAccountIds = {};
  final StreamController<Set<String>> _fullScanningAccountsController =
      StreamController<Set<String>>.broadcast();

  Stream<Set<String>> get fullScanningAccountsStream =>
      _fullScanningAccountsController.stream;

  Set<String> get fullScanningAccounts =>
      Set.unmodifiable(_fullScanningAccountIds);

  bool isAccountFullScanning(String accountId) =>
      _fullScanningAccountIds.contains(accountId);

  void _emitFullScanningAccounts() {
    _fullScanningAccountsController
        .add(Set<String>.from(_fullScanningAccountIds));
  }

  static final SyncManager _instance = SyncManager._internal();

  SyncManager._internal();

  factory SyncManager() {
    return _instance;
  }

  void startSync() {
    _syncTimer =
        Timer.periodic(const Duration(seconds: _syncInterval), (timer) {
      if (NgAccountManager().accounts.isEmpty) {
        return;
      }
      //wait for any active operations to finish
      if (_activeSyncOperations.isEmpty) {
        _syncAll();
      }

      dumpProgress();
    });
  }

  // Expose sync for integration tests
  Future<void> sync() async {
    if (_enableLogging) {
      kPrint("SyncManager: Manual sync() called");
    }
    await _syncAll();
  }

// Sync a single account
  Future<void> syncAccount(EnvoyAccount account) async {
    final handler = account.handler;
    if (handler == null) return;

    final server = Settings().electrumAddress(account.network);
    int? port = Settings().getTorPort(account.network, server);
    try {
      _ElectrumSyncResult result(
        ElectrumSyncReachability reachability,
      ) =>
          (
            network: account.network,
            viaTor: port != null,
            reachability: reachability,
          );

      final futures = account.descriptors.map((descriptor) async {
        try {
          final request = await handler.syncRequest(
            addressType: descriptor.addressType,
          );
          final reachability = await _performWalletSync(
            account,
            server,
            request,
            port,
            descriptor.addressType,
          );
          return result(reachability);
        } catch (e, stack) {
          debugPrintStack(stackTrace: stack);
          if (_enableLogging) {
            kPrint(
              "SyncManager: unable to prepare sync for ${descriptor.addressType}: $e",
            );
          }
          return result(ElectrumSyncReachability.notAttempted);
        }
      });

      // Actually wait for all descriptor syncs
      final results = await Future.wait(futures);
      _reportElectrumSyncReachability(results);

      // Notify listeners that this account finished syncing
      _onUpdateFinished?.call(account);

      if (_enableLogging) {
        kPrint("SyncManager: Single Account Sync Finished ${account.name}");
      }
    } catch (e) {
      if (_enableLogging) {
        kPrint("SyncManager: single error $e");
      }
    }
  }

  void onUpdateFinished(Function(EnvoyAccount) onUpdateFinished) {
    _onUpdateFinished = onUpdateFinished;
  }

  Future<void> _syncAll() async {
    bool syncTestnet = Settings().showTestnetAccounts();
    bool syncSignet = Settings().showSignetAccounts();
    final accounts = NgAccountManager().accounts;

    for (var account in accounts) {
      // Skip accounts based on network settings
      if ((!syncTestnet && account.network == Network.testnet4) ||
          (!syncTestnet && account.network == Network.testnet) ||
          (!syncSignet && account.network == Network.signet)) {
        if (_enableLogging) {
          kPrint("Skipping account ${account.name} | ${account.network}");
        }
        continue;
      }

      if (account.handler != null) {
        for (var descriptor in account.descriptors) {
          final accountKey = (account.id, descriptor.addressType);

          // Skip if already being processed
          if (_activeSyncOperations.contains(accountKey) ||
              _activeFullScanOperations.contains(accountKey)) {
            continue;
          }

          // Check if account is scanned
          bool isScanned = await EnvoyStorage()
              .getAccountScanStatus(account.id, descriptor.addressType);

          if (isScanned) {
            if (_syncRequests.containsKey((account, descriptor.addressType))) {
              continue;
            }
            final request = await account.handler!
                .syncRequest(addressType: descriptor.addressType);
            _syncRequests[(account, descriptor.addressType)] = request;
          } else if (_fullScanRequests[(account, descriptor.addressType)] ==
              null) {
            FullScanRequest request = await account.handler!
                .requestFullScan(addressType: descriptor.addressType);
            _fullScanRequests[(account, descriptor.addressType)] = request;
          }
        }
      }
    }

    // Start sync and scan operations in parallel
    final resultBatches = await Future.wait([_startSync(), _startFullScan()]);
    _reportElectrumSyncReachability(resultBatches.expand((batch) => batch));
  }

  Future<void> initiateFullScan() async {
    final accounts = NgAccountManager().accounts;
    _fullScanRequests.clear();

    for (var account in accounts) {
      for (var descriptor in account.descriptors) {
        bool isScanned = await EnvoyStorage()
            .getAccountScanStatus(account.id, descriptor.addressType);

        if (!isScanned) {
          final accountKey = (account.id, descriptor.addressType);
          if (_activeFullScanOperations.contains(accountKey)) {
            continue;
          }

          FullScanRequest request = await account.handler!
              .requestFullScan(addressType: descriptor.addressType);
          _fullScanRequests[(account, descriptor.addressType)] = request;
        }
      }
    }

    final results = await _startFullScan();
    _reportElectrumSyncReachability(results);
  }

  Future<void> initiateAccountFullScan(
    EnvoyAccount account,
    int stopGap,
  ) async {
    // Clear previous queued full-scan requests for this account only
    _fullScanRequests.removeWhere(
      (key, _) => key.$1.id == account.id,
    );

    bool anyFailure = false;
    bool anySkipped = false;
    final healthResults = <_ElectrumSyncResult>[];
    // Hold the per-account "scanning" flag for the full duration so the UI
    // doesn't flicker off between descriptors or when the shared progress
    // stream emits an unrelated `Syncing` event.
    _fullScanningAccountIds.add(account.id);
    _emitFullScanningAccounts();

    try {
      for (var descriptor in account.descriptors) {
        final handler = account.handler;
        if (handler == null) {
          anyFailure = true;
          continue;
        }

        final request =
            await handler.requestFullScan(addressType: descriptor.addressType);

        final result = await _performFullScan(
          handler,
          descriptor.addressType,
          request,
          stopGap: stopGap,
        );
        healthResults.add(result.health);
        switch (result.outcome) {
          case FullScanOutcome.failure:
            anyFailure = true;
          case FullScanOutcome.skipped:
            // Another scan for this descriptor is already in flight; this
            // rescan didn't actually run it and can't know its result.
            anySkipped = true;
          case FullScanOutcome.success:
            break;
        }
      }
    } catch (e, stack) {
      debugPrintStack(stackTrace: stack);
      anyFailure = true;
    } finally {
      _reportElectrumSyncReachability(healthResults);
      _fullScanningAccountIds.remove(account.id);
      _emitFullScanningAccounts();
      // Report failure if anything failed. Otherwise report success only when
      // every descriptor actually completed — if any was skipped because a
      // scan was already running, suppress the callback rather than claim a
      // premature success the in-flight scan hasn't earned yet.
      if (anyFailure) {
        _onAccFullScanFinished?.call(account, false);
      } else if (!anySkipped) {
        _onAccFullScanFinished?.call(account, true);
      }
    }
  }

  bool isAccountFullScanInProgress(EnvoyAccount account) {
    final id = account.id;
    return _activeFullScanOperations.any((e) => e.$1 == id);
  }

  void onFullScanFinished(
    void Function(EnvoyAccount account, bool success) cb,
  ) {
    _onAccFullScanFinished = cb;
  }

  Future<List<_ElectrumSyncResult>> _startSync() async {
    final entries = _syncRequests.entries.toList();
    final futures = <Future<_ElectrumSyncResult>>[];

    for (final entry in entries) {
      final account = entry.key.$1;
      final type = entry.key.$2;
      final accountKey = (account.id, type);

      // Skip if already being processed
      if (_activeSyncOperations.contains(accountKey)) {
        continue;
      }

      final request = _syncRequests[entry.key];
      if (request == null || account.handler == null) {
        _syncRequests.remove(entry.key);
        continue;
      }

      _activeSyncOperations.add(accountKey);

      final server = Settings().electrumAddress(account.network);
      int? port = Settings().getTorPort(account.network, server);
      Future<_ElectrumSyncResult> sync() async {
        try {
          final reachability = await _performWalletSync(
            account,
            server,
            request,
            port,
            type,
          );
          return (
            network: account.network,
            viaTor: port != null,
            reachability: reachability,
          );
        } catch (e, stack) {
          debugPrintStack(stackTrace: stack);
          if (account.network == Network.bitcoin) {
            EnvoyReport().log(
              "Unexpected sync setup error $type - ${account.name} | ${account.network}",
              e.toString(),
            );
          } else {
            kPrint(
              "Unexpected sync setup error $type - ${account.name} | ${account.network}: $e",
            );
          }
          return (
            network: account.network,
            viaTor: port != null,
            reachability: ElectrumSyncReachability.notAttempted,
          );
        } finally {
          _activeSyncOperations.remove(accountKey);
          _syncRequests.remove(entry.key);
          _onUpdateFinished?.call(account);
        }
      }

      futures.add(sync());
    }

    return Future.wait(futures);
  }

  void _reportElectrumSyncReachability(Iterable<_ElectrumSyncResult> results) {
    final mainnetResults =
        results.where((result) => result.network == Network.bitcoin).toList();

    // A descriptor batch is one reachability observation: any response proves
    // Electrum is reachable, while an all-failed batch counts as one strike.
    final reachability = aggregateElectrumSyncReachability(
      mainnetResults.map((result) => result.reachability),
    );

    switch (reachability) {
      case ElectrumSyncReachability.reachable:
        final reachedViaTor = mainnetResults.any(
          (result) =>
              result.viaTor &&
              result.reachability == ElectrumSyncReachability.reachable,
        );
        ConnectivityManager().electrumSuccess(viaTor: reachedViaTor);
      case ElectrumSyncReachability.unreachable:
        ConnectivityManager().electrumFailure();
      case ElectrumSyncReachability.notAttempted:
        break;
    }
  }

  Future<List<_ElectrumSyncResult>> _startFullScan() async {
    final entries = _fullScanRequests.entries.toList();
    final futures = <Future<_ElectrumSyncResult?>>[];

    for (final entry in entries) {
      final account = entry.key.$1;
      final type = entry.key.$2;
      final accountKey = (account.id, type);

      // Skip if already being processed
      if (_activeFullScanOperations.contains(accountKey)) {
        continue;
      }

      Future<_ElectrumSyncResult?> sync() async {
        try {
          final fullScanRequest = _fullScanRequests[entry.key];
          final handler = account.handler;
          if (fullScanRequest == null || handler == null) {
            return null;
          }

          final result = await _performFullScan(handler, type, fullScanRequest);
          return result.health;
        } catch (e, stack) {
          debugPrintStack(stackTrace: stack);
          if (_enableLogging) {
            kPrint(
                "Error fullScan account ${account.name} | ${account.network}: $e");
          }
          EnvoyReport().log(
              "Error fullScan account ${account.name} | ${account.network}",
              e.toString());
          return null;
        } finally {
          _fullScanRequests.remove(entry.key);
          _onUpdateFinished?.call(account);
        }
      }

      futures.add(sync());
    }

    final results = await Future.wait(futures);
    return results.whereType<_ElectrumSyncResult>().toList();
  }

  /// The UI outcome and Electrum reachability are reported independently so
  /// local apply failures cannot masquerade as network failures.
  Future<_FullScanResult> _performFullScan(
    EnvoyAccountHandler handler,
    AddressType addressType,
    FullScanRequest fullScanRequest, {
    int? stopGap,
  }) async {
    final account = await handler.state();
    final server = Settings().electrumAddress(account.network);
    final port = Settings().getTorPort(account.network, server);
    final viaTor = port != null;
    _FullScanResult scanResult(
      FullScanOutcome outcome,
      ElectrumSyncReachability reachability,
    ) =>
        (
          outcome: outcome,
          health: (
            network: account.network,
            viaTor: viaTor,
            reachability: reachability,
          ),
        );

    if (_activeFullScanOperations.contains((account.id, addressType))) {
      return scanResult(
        FullScanOutcome.skipped,
        ElectrumSyncReachability.notAttempted,
      );
    }
    _activeFullScanOperations.add((account.id, addressType));

    if (_enableLogging) {
      kPrint(
          "🔍 PerformFullScan $addressType - ${account.name} | ${account.network} | $server | Tor: ${port != null} | request_disposed:${fullScanRequest.isDisposed}");
    }

    try {
      if (fullScanRequest.isDisposed || _currentLoading.isClosed) {
        if (_enableLogging) {
          kPrint("FullScanRequest is disposed");
        }
        return scanResult(
          FullScanOutcome.failure,
          ElectrumSyncReachability.notAttempted,
        );
      }
      if (Settings().usingTor && Tor.instance.port == -1) {
        if (_enableLogging) {
          kPrint(
              "Skipping Scan because Tor is not ready yet $addressType - ${account.name} | ${account.network} | $server | Tor: $port");
        }
        return scanResult(
          FullScanOutcome.failure,
          ElectrumSyncReachability.notAttempted,
        );
      }

      _currentLoading.sink.add(Scanning(account.id));

      late final WalletUpdate update;
      try {
        update = await EnvoyAccountHandler.scanWallet(
          scanRequest: fullScanRequest,
          electrumServer: server,
          torPort: port,
          stopGap: stopGap,
          validateDomain: Settings().validateDomain(server),
        );
      } catch (e, stack) {
        debugPrintStack(stackTrace: stack);
        // ngwallet emits this message when its one-shot Rust scan request is
        // missing; keep it distinct from an Electrum connection failure.
        final scanRequestMissing =
            e.toString().contains("No Scan request found");
        if (fullScanRequest.isDisposed || scanRequestMissing) {
          return scanResult(
            FullScanOutcome.failure,
            ElectrumSyncReachability.notAttempted,
          );
        }
        EnvoyReport().log(
          "Error scanning $addressType - ${account.name} | ${account.network} | $server | Tor: $port",
          e.toString(),
        );
        return scanResult(
          FullScanOutcome.failure,
          ElectrumSyncReachability.unreachable,
        );
      }

      final liveHandler = account.handler;
      if (liveHandler == null) {
        if (_enableLogging) {
          kPrint(
              "FullScan completed but handler is null, cannot apply update $addressType - ${account.name}");
        }
        EnvoyReport().log(
          "Cannot apply Electrum scan $addressType - ${account.name} | ${account.network}",
          "Account handler is no longer available",
        );
        return scanResult(
          FullScanOutcome.failure,
          ElectrumSyncReachability.reachable,
        );
      }

      try {
        await liveHandler.applyUpdate(
          update: update,
          addressType: addressType,
        );
        await EnvoyStorage()
            .setAccountScanStatus(account.id, addressType, true);
      } catch (e, stack) {
        debugPrintStack(stackTrace: stack);
        EnvoyReport().log(
          "Error applying Electrum scan $addressType - ${account.name} | ${account.network}",
          e.toString(),
        );
        return scanResult(
          FullScanOutcome.failure,
          ElectrumSyncReachability.reachable,
        );
      }

      if (_enableLogging) {
        kPrint(
            "✨Finished FullScan $addressType - ${account.name} | ${account.network} | $server | Tor: ${port != null}");
      }
      return scanResult(
        FullScanOutcome.success,
        ElectrumSyncReachability.reachable,
      );
    } finally {
      if (!_currentLoading.isClosed) {
        _currentLoading.sink.add(None());
      }
      _activeFullScanOperations.remove((account.id, addressType));
    }
  }

  Future<ElectrumSyncReachability> _performWalletSync(
    EnvoyAccount account,
    String server,
    SyncRequest syncRequest,
    int? port,
    AddressType addressType,
  ) async {
    if (Settings().usingTor && Tor.instance.port == -1) {
      if (_enableLogging) {
        kPrint(
          "Skipping sync because Tor is not ready yet $addressType - ${account.name} | ${account.network} | $server | Tor: $port",
        );
      }
      return ElectrumSyncReachability.notAttempted;
    }
    if (syncRequest.isDisposed || _currentLoading.isClosed) {
      if (_enableLogging) {
        kPrint(
          "Skipping disposed sync request $addressType - ${account.name} | ${account.network}",
        );
      }
      return ElectrumSyncReachability.notAttempted;
    }

    _currentLoading.sink.add(Syncing(account.id));
    final time = DateTime.now();
    if (_enableLogging) {
      kPrint(
        "⏳Syncing account $addressType - ${account.name}| ${account.network} | $server  |Tor : $port",
      );
    }

    try {
      late final WalletUpdate update;
      try {
        update = await EnvoyAccountHandler.syncWallet(
          syncRequest: syncRequest,
          electrumServer: server,
          torPort: port,
          validateDomain: Settings().validateDomain(server),
        );
      } catch (e, stack) {
        debugPrintStack(stackTrace: stack);
        // The Rust request can be empty even while its Dart handle is alive.
        if (syncRequest.isDisposed ||
            e.toString().contains("No sync request found")) {
          return ElectrumSyncReachability.notAttempted;
        }
        if (_enableLogging) {
          kPrint(
            "Error syncing $addressType - ${account.name} | ${account.network} | $server | Tor: $port $e",
          );
        }
        // Less noisy logging for non-mainnet networks.
        if (account.network == Network.bitcoin) {
          EnvoyReport().log(
            "Error syncing $addressType - ${account.name} | ${account.network} | $server | Tor: $port",
            e.toString(),
          );
        } else {
          kPrint(
            "Unable to reach Electrum for sync $addressType - ${account.name} | ${account.network} | $server | Tor: $port",
          );
        }
        return ElectrumSyncReachability.unreachable;
      }

      final duration = DateTime.now().difference(time);
      final handler = account.handler;
      if (handler != null) {
        try {
          await handler.applyUpdate(
            update: update,
            addressType: addressType,
          );

          await handler.sendUpdate();

          if (_enableLogging) {
            kPrint(
              "✨Finished Sync ${addressType.toString().split('.').last} - ${account.name} | ${account.network} | $server | Tor: ${port != null} | Time: ${duration.inMilliseconds / 1000} seconds",
            );
          }
        } catch (e, stack) {
          debugPrintStack(stackTrace: stack);
          if (_enableLogging) {
            kPrint("❌ Error applying update: $e");
          }
          EnvoyReport().log(
            "Error applying Electrum update $addressType - ${account.name} | ${account.network}",
            e.toString(),
          );
        }
      } else {
        if (_enableLogging) {
          kPrint("Sync failed because account handler is null");
        }
        EnvoyReport().log(
          "Cannot apply Electrum update $addressType - ${account.name} | ${account.network}",
          "Account handler is no longer available",
        );
      }
      return ElectrumSyncReachability.reachable;
    } finally {
      if (!_currentLoading.isClosed) {
        _currentLoading.sink.add(None());
      }
    }
  }

  void dispose() {
    if (_enableLogging) {
      kPrint("SyncManager: Disposing and cancelling timer");
    }
    _syncTimer.cancel();
    _currentLoading.close();
    _fullScanningAccountsController.close();
  }

  /// Dumps the current progress of sync and scan operations to the log
  String dumpProgress() {
    final StringBuffer buffer = StringBuffer();

    buffer.writeln('=== SyncManager Progress Dump ===');
    buffer.writeln('Active sync operations: ${_activeSyncOperations.length}');
    buffer.writeln(
        'Active full scan operations: ${_activeFullScanOperations.length}');
    buffer.writeln('Pending sync requests: ${_syncRequests.length}');
    buffer.writeln('Pending full scan requests: ${_fullScanRequests.length}');

    if (_activeSyncOperations.isNotEmpty) {
      buffer.writeln('\nActive sync operations:');
      for (final op in _activeSyncOperations) {
        final account =
            NgAccountManager().accounts.firstWhereOrNull((a) => a.id == op.$1);
        if (account != null) {
          buffer.writeln(
              '  - Account Name: ${account.name}, Address Type: ${op.$2}, Network: ${account.network}');
        }
      }
    }

    if (_activeFullScanOperations.isNotEmpty) {
      buffer.writeln('\nActive full scan operations:');
      for (final op in _activeFullScanOperations) {
        final account =
            NgAccountManager().accounts.firstWhereOrNull((a) => a.id == op.$1);
        if (account != null) {
          buffer.writeln(
              '  - Account Name: ${account.name}, Address Type: ${op.$2}, Network: ${account.network}');
        }
      }
    }

    final String result = buffer.toString();
    if (_enableLogging) {
      kPrint(result);
    }
    return result;
  }
}
