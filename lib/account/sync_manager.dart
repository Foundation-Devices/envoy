// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:envoy/account/accounts_manager.dart';
import 'package:envoy/business/local_storage.dart';
import 'package:envoy/business/scheduler.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/envoy_storage.dart';
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
  final _syncScheduler = EnvoyScheduler().parallel;
  final Map<(EnvoyAccount, AddressType), SyncRequest> _synRequests = {};
  final Map<(EnvoyAccount, AddressType), FullScanRequest> _fullScanRequest = {};
  Function(EnvoyAccount)? _onUpdateFinished;
  late Timer _syncTimer;
  bool _pauseSync = false;
  //bool _fullScanInProgress = false;

  final StreamController<WalletProgress> _currentLoading =
      StreamController<WalletProgress>.broadcast(sync: true);

  Stream<WalletProgress> get currentLoading => _currentLoading.stream;

  static final SyncManager _instance = SyncManager._internal();

  SyncManager._internal();

  factory SyncManager() {
    return _instance;
  }

  startSync() {
    _syncTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (NgAccountManager().accounts.isEmpty || _pauseSync) {
        return;
      }
      _syncAll();
    });
  }

  // Expose sync for integration tests
  Future<void> sync() async {
    kPrint("SyncManager: Manual sync() called");
    await _syncAll();
  }

  //sync a single account, other syncs will be paused
  void syncAccount(EnvoyAccount account) async {
    final server = SyncManager.getElectrumServer(account.network);
    int? port = Settings().getPort(account.network);
    if (port == -1) {
      port = null;
    }
    if (account.handler != null) {
      pauseSync();
      for (var descriptor in account.descriptors) {
        final request = await account.handler!
            .syncRequest(addressType: descriptor.addressType);
        _synRequests[(account, descriptor.addressType)] = request;
        await _performWalletSync(account, server, port, descriptor.addressType);
      }
      resumeSync();
    }
  }

  void onUpdateFinished(Function(EnvoyAccount) onUpdateFinished) {
    _onUpdateFinished = onUpdateFinished;
  }

  Future<void> _syncAll() async {
    bool synTestnet = Settings().showTestnetAccounts();
    bool syncSignet = Settings().showSignetAccounts();
    final accounts = NgAccountManager().accounts;
    for (var account in accounts) {
      //skip testnet accounts if not enabled
      if (!synTestnet && account.network == Network.testnet4 ||
          !syncSignet && account.network == Network.testnet) {
        kPrint("Skipping account ${account.name} | ${account.network}");
        continue;
      }
      //skip signet accounts if not enabled
      if (!syncSignet && account.network == Network.signet) {
        continue;
      }
      if (account.handler != null) {
        for (var descriptor in account.descriptors) {
          //only sync accounts that are passed full scans
          bool isScanned = await EnvoyStorage()
              .getAccountScanStatus(account.id, descriptor.addressType);
          //only sync accounts that are passed full scans
          if (!isScanned) {
            kPrint(
                "SyncManager: Account ${account.name} | ${account.network} is not scanned");
          }
          if (isScanned == true) {
            final request = await account.handler!
                .syncRequest(addressType: descriptor.addressType);
            _synRequests[(account, descriptor.addressType)] = request;
          } else {
            if (_fullScanRequest[(account, descriptor.addressType)] == null) {
              initiateFullScan();
            }
          }
        }
      }
    }
    await _startSync();
  }

  //initiate full scan for all non scanned accounts
  Future<void> initiateFullScan() async {
    final accounts = NgAccountManager().accounts;
    _fullScanRequest.clear();
    for (var account in accounts) {
      //skip testnet accounts if not enabled
      for (var descriptor in account.descriptors) {
        bool isScanned = await LocalStorage()
            .prefs
            .getAccountScanStatus(account.id, descriptor.addressType);
        if (!isScanned) {
          FullScanRequest request = await account.handler!
              .requestFullScan(addressType: descriptor.addressType);
          _fullScanRequest[(account, descriptor.addressType)] = request;
        }
      }
    }
    await _startFullScan();
  }

  Future<void> _startSync() async {
    final iterator = _synRequests.keys.iterator;
    while (iterator.moveNext()) {
      final accountWithType = iterator.current;
      final account = accountWithType.$1;
      final type = accountWithType.$2;
      final server = SyncManager.getElectrumServer(account.network);
      int? port = Settings().getPort(account.network);
      if (port == -1) {
        port = null;
      }
      _syncScheduler.run(
        () async {
          try {
            kPrint(
                "⏳Syncing account ${account.name} | ${account.network} | $server  |Tor : $port");
            while (_pauseSync) {
              //wait until resume
              await Future.delayed(const Duration(milliseconds: 100));
            }
            await _performWalletSync(account, server, port, type);
            kPrint(
                "✨Finished Syncing account ${account.name} | ${account.network} | $server  |Tor : $port");
          } catch (e) {
            kPrint("Error syncing account ${account.name}: $e");
          } finally {
            _synRequests.remove(accountWithType);
          }
        },
      );
    }
  }

  Future _startFullScan() async {
    for (final accountWithType in _fullScanRequest.keys) {
      final account = accountWithType.$1;
      final type = accountWithType.$2;
      bool isScanned =
          await LocalStorage().prefs.getAccountScanStatus(account.id, type);
      if (isScanned) {
        return;
      }
      _syncScheduler.run(
        () async {
          try {
            final fullScanRequest = _fullScanRequest[(account, type)];
            if (fullScanRequest == null) {
              return;
            }
            if (account.handler == null) {
              kPrint("Handler is null for ${account.name} ${account.network}");
              return;
            }
            await performFullScan(account.handler!, type, fullScanRequest);
          } catch (e, stack) {
            debugPrintStack(stackTrace: stack);
            kPrint("Error fullScan account ${account.name} | ${account.network}"
                ": $e");
          } finally {
            _onUpdateFinished?.call(account);
          }
        },
      );
    }
  }

  Future<void> performFullScan(EnvoyAccountHandler handler,
      AddressType addressType, FullScanRequest fullScanRequest) async {
    final account = await handler.state();
    final server = SyncManager.getElectrumServer(account.network);
    int? port = Settings().getPort(account.network);
    if (port == -1) {
      port = null;
    }
    kPrint(
        "🔍 PerformFullScan ${account.name} | ${account.network} | $server  |Tor : ${port != null} | request_disposed:${fullScanRequest.isDisposed}");
    _currentLoading.sink.add(Scanning(account.id));
    if (fullScanRequest.isDisposed) {
      kPrint("FullScanRequest is disposed");
      return;
    }
    try {
      WalletUpdate update = await EnvoyAccountHandler.scanWallet(
        scanRequest: fullScanRequest,
        electrumServer: server,
        torPort: port,
      );
      await handler.applyUpdate(update: update, addressType: addressType);
      await EnvoyStorage().setAccountScanStatus(account.id, addressType, true);
      kPrint(
          "✨Finished FullScan account ${account.name} | ${account.network} | $server  |Tor : ${port != null}");
    } catch (e) {
      kPrint(
          "Error fullScan: for ${account.name} | ${account.network} | $server  |Tor : $port $e");
      EnvoyReport().log(
          "Error fullScan: for ${account.name} | ${account.network} | $server  |Tor : $port",
          e.toString());
    } finally {
      _fullScanRequest
          .removeWhere((k, v) => k.$1.id == account.id && k.$2 == addressType);
      _currentLoading.sink.add(None());
    }
  }

  Future<void> _performWalletSync(EnvoyAccount account, String server,
      int? port, AddressType addressType) async {
    final syncRequest = _synRequests[(account, addressType)];
    if (syncRequest == null) {
      return;
    }
    WalletUpdate update = await EnvoyAccountHandler.syncWallet(
      syncRequest: syncRequest,
      electrumServer: server,
      torPort: port,
    );
    try {
      _currentLoading.sink.add(Syncing(account.id));
      await account.handler!
          .applyUpdate(update: update, addressType: addressType);
    } catch (e) {
      EnvoyReport().log(
          "Error applying sync for ${account.name} | ${account.network} | $server  |Tor : $port",
          e.toString());
    } finally {
      _currentLoading.sink.add(None());
    }
  }

  static String getElectrumServer(Network network) {
    String server;
    switch (network) {
      case Network.bitcoin:
        if (Settings().customElectrumEnabled()) {
          server = Settings().selectedElectrumAddress.toString();
        } else {
          server = Settings.currentDefaultServer;
        }
        break;
      case Network.testnet4:
        server = Settings.TESTNET4_ELECTRUM_SERVER;
        break;
      case Network.testnet:
        server = Settings.TESTNET_ELECTRUM_SERVER;
        break;
      case Network.signet:
        server = Settings.SIGNET_ELECTRUM_SERVER;
        break;
      default:
        server = "Unknown server";
        break;
    }
    return server;
  }

  dispose() {
    kPrint("SyncManager: Disposing and cancelling timer");
    _syncTimer.cancel();
  }

  void pauseSync() {
    kPrint("SyncManager: Pausing sync");
    _pauseSync = true;
  }

  void resumeSync() {
    kPrint("SyncManager: Resuming sync");
    _pauseSync = false;
  }
}
