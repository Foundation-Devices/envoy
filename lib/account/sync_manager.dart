// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:envoy/account/accounts_manager.dart';
import 'package:envoy/business/local_storage.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:envoy/util/list_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:ngwallet/ngwallet.dart';

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

class SyncManager {
  static const int _syncInterval = 10;

  // Track sync and scan requests
  final Map<(EnvoyAccount, AddressType), SyncRequest> _syncRequests = {};
  final Map<(EnvoyAccount, AddressType), FullScanRequest> _fullScanRequests =
      {};

  // Track active operations to prevent duplicates
  final Set<(String, AddressType)> _activeSyncOperations = {};
  final Set<(String, AddressType)> _activeFullScanOperations = {};

  // Batch size for parallel sync/scan
  static const int _syncBatchSize = 6;

  Function(EnvoyAccount)? _onUpdateFinished;
  late Timer _syncTimer;
  bool _pauseSync = false;

  final StreamController<WalletProgress> _currentLoading =
      StreamController<WalletProgress>.broadcast(sync: true);

  Stream<WalletProgress> get currentLoading => _currentLoading.stream;

  static final SyncManager _instance = SyncManager._internal();

  SyncManager._internal();

  factory SyncManager() {
    return _instance;
  }

  void startSync() {
    kPrint("SyncManager: Starting sync");
    _syncTimer =
        Timer.periodic(const Duration(seconds: _syncInterval), (timer) {
      if (NgAccountManager().accounts.isEmpty || _pauseSync) {
        return;
      }
      //_syncAll();
      //dumpProgress();
    });
  }

  // Expose sync for integration tests
  Future<void> sync() async {
    kPrint("SyncManager: Manual sync() called");
    await _syncAll();
  }

  //sync a single account
  void syncAccount(EnvoyAccount account) async {
    final server = Settings().electrumAddress(account.network);
    int? port = Settings().getTorPort(account.network, server);
    try {
      if (account.handler != null) {
        kPrint("SyncManager: Syncing single account ${account.name}");
        final futures = <Future>[];
        for (var descriptor in account.descriptors) {
          final request = await account.handler!
              .syncRequest(addressType: descriptor.addressType);
          futures.add(_performWalletSync(
              account, server, request, port, descriptor.addressType));
          kPrint(
              "SyncManager: added sync future for ${descriptor.addressType}");
        }
        await Future.wait(futures);
        kPrint("SyncManager: Single Account Sync Finished ${account.name}");
      }
    } catch (e) {
      kPrint("SyncManager: single error $e");
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
        kPrint("Skipping account ${account.name} | ${account.network}");
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
            final request = await account.handler!
                .syncRequest(addressType: descriptor.addressType);
            _syncRequests[(account, descriptor.addressType)] = request;
          } else if (_fullScanRequests[(account, descriptor.addressType)] ==
              null) {
            FullScanRequest request = await account.handler!
                .requestFullScan(addressType: descriptor.addressType);
            performFullScan(account.handler!, descriptor.addressType, request);
          }
        }
      }
    }

    // Start sync and scan operations in parallel
    await Future.wait([_startSync(), _startFullScan()]);
  }

  Future<void> initiateFullScan() async {
    final accounts = NgAccountManager().accounts;
    _fullScanRequests.clear();

    for (var account in accounts) {
      for (var descriptor in account.descriptors) {
        bool isScanned = await LocalStorage()
            .prefs
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

    await _startFullScan();
  }

  Future<void> _startSync() async {
    // Process sync requests in batches
    final entries = _syncRequests.entries.toList();

    for (int i = 0; i < entries.length; i += _syncBatchSize) {
      final batch = entries.skip(i).take(_syncBatchSize);
      final futures = <Future>[];

      for (final entry in batch) {
        final account = entry.key.$1;
        final type = entry.key.$2;
        final accountKey = (account.id, type);

        // Skip if already being processed
        if (_activeSyncOperations.contains(accountKey)) {
          continue;
        }

        _activeSyncOperations.add(accountKey);

        final server = Settings().electrumAddress(account.network);
        int? port = Settings().getTorPort(account.network, server);

        final request = _syncRequests[entry.key];
        if (request == null || account.handler == null) {
          continue;
        }
        futures.add(_performWalletSync(account, server, request, port, type)
            .whenComplete(() {
          _activeSyncOperations.remove(accountKey);
          _syncRequests.remove(entry.key);
          _onUpdateFinished?.call(account);
        }));
      }

      await Future.wait(futures);
    }
  }

  Future<void> _startFullScan() async {
    final entries = _fullScanRequests.entries.toList();
    for (int i = 0; i < entries.length; i += _syncBatchSize) {
      final batch = entries.skip(i).take(_syncBatchSize);
      final futures = <Future>[];

      for (final entry in batch) {
        final account = entry.key.$1;
        final type = entry.key.$2;
        final accountKey = (account.id, type);

        // Skip if already being processed
        if (_activeFullScanOperations.contains(accountKey)) {
          continue;
        }

        _activeFullScanOperations.add(accountKey);
        Future sync() async {
          try {
            final fullScanRequest = _fullScanRequests[entry.key];
            if (fullScanRequest == null || account.handler == null) {
              return;
            }

            await performFullScan(account.handler!, type, fullScanRequest);
          } catch (e, stack) {
            debugPrintStack(stackTrace: stack);
            kPrint(
                "Error fullScan account ${account.name} | ${account.network}: $e");
            EnvoyReport().log(
                "Error fullScan account ${account.name} | ${account.network}",
                e.toString());
          } finally {
            _activeFullScanOperations.remove(accountKey);
            _fullScanRequests.remove(entry.key);
            _onUpdateFinished?.call(account);
          }
        }

        futures.add(sync());
      }

      await Future.wait(futures);
    }
  }

  Future<void> performFullScan(EnvoyAccountHandler handler,
      AddressType addressType, FullScanRequest fullScanRequest) async {
    final account = await handler.state();
    if (_activeFullScanOperations.contains((account.id, addressType))) {
      return;
    }
    _activeFullScanOperations.add((account.id, addressType));
    final server = Settings().electrumAddress(account.network);
    int? port = Settings().getTorPort(account.network, server);

    kPrint(
        "🔍 PerformFullScan $addressType - ${account.name} | ${account.network} | $server | Tor: ${port != null} | request_disposed:${fullScanRequest.isDisposed}");
    _currentLoading.sink.add(Scanning(account.id));

    if (fullScanRequest.isDisposed) {
      _currentLoading.sink.add(None());
      kPrint("FullScanRequest is disposed");
      return;
    }

    try {
      // Use the scheduler to run this task in the background
      WalletUpdate update = await EnvoyAccountHandler.scanWallet(
          scanRequest: fullScanRequest, electrumServer: server, torPort: port);

      if (account.handler != null) {
        await account.handler!
            .applyUpdate(update: update, addressType: addressType);
        await EnvoyStorage()
            .setAccountScanStatus(account.id, addressType, true);
      }

      kPrint(
          "✨Finished FullScan $addressType - ${account.name} | ${account.network} | $server | Tor: ${port != null}");
    } catch (e, stack) {
      debugPrintStack(stackTrace: stack);
      kPrint(
          "Error fullScan: $addressType - ${account.name} | ${account.network} | $server | Tor: $port $e");
      EnvoyReport().log(
          "Error fullScan: $addressType - ${account.name} | ${account.network} | $server | Tor: $port",
          e.toString());
    } finally {
      _currentLoading.sink.add(None());
      _activeFullScanOperations.remove((account.id, addressType));
    }
  }

  Future<void> _performWalletSync(EnvoyAccount account, String server,
      SyncRequest syncRequest, int? port, AddressType addressType) async {
    try {
      _currentLoading.sink.add(Syncing(account.id));
      DateTime time = DateTime.now();
      kPrint(
          "⏳Syncing account $addressType - ${account.name}| ${account.network} | $server  |Tor : $port");
      // Use the scheduler to run this task in the background
      final WalletUpdate update = await EnvoyAccountHandler.syncWallet(
        syncRequest: syncRequest,
        electrumServer: server,
        torPort: port,
      );
      DateTime finish = DateTime.now();
      final duration = finish.difference(time);

      if (account.handler != null) {
        await account.handler!
            .applyUpdate(update: update, addressType: addressType);

        kPrint(
            "✨Finished Sync ${addressType.toString().split(".").last} - ${account.name} | ${account.network} | $server | Tor: ${port != null} | Time: ${duration.inMilliseconds / 1000} seconds");
      } else {
        kPrint("Sync failed because account handler is null");
      }
    } catch (e, stack) {
      debugPrintStack(stackTrace: stack);
      kPrint(
          "Error syncing $addressType - ${account.name} | ${account.network} | $server | Tor: $port $e");
      EnvoyReport().log(
          "Error applying sync $addressType - ${account.name} | ${account.network} | $server | Tor: $port",
          e.toString());
    } finally {
      _currentLoading.sink.add(None());
    }
  }

  void dispose() {
    kPrint("SyncManager: Disposing and cancelling timer");
    _syncTimer.cancel();
    _currentLoading.close();
  }

  void pauseSync() {
    kPrint("SyncManager: Pausing sync");
    _pauseSync = true;
  }

  void resumeSync() {
    kPrint("SyncManager: Resuming sync");
    _pauseSync = false;
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
    buffer.writeln('Sync paused: $_pauseSync');

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
    kPrint(result);
    return result;
  }
}
