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
      if (_pauseSync) {
        return;
      }
      if (_fullScanRequest.isNotEmpty) {
        _startFullScan();
        return;
      }
      _syncAll();
    });
  }

  //sync a single account,other syncs will be paused
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

  void _syncAll() async {
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
          bool? isScanned = await LocalStorage()
              .prefs
              .getAccountScanStatus(account.id, descriptor.addressType);
          //only sync accounts that are passed full scans
          if (isScanned == true) {
            final request = await account.handler!
                .syncRequest(addressType: descriptor.addressType);
            _synRequests[(account, descriptor.addressType)] = request;
          } else {
            _fullScanRequest[(account, descriptor.addressType)] = await account
                .handler!
                .requestFullScan(addressType: descriptor.addressType);
            _startFullScan();
          }
        }
      }
    }
    _startSync();
  }

  Future<void> initiateFullScan() async {
    final accounts = NgAccountManager().accounts;
    for (var account in accounts) {
      //skip testnet accounts if not enabled
      for (var descriptor in account.descriptors) {
        bool isScanned = await LocalStorage()
                .prefs
                .getAccountScanStatus(account.id, descriptor.addressType) ??
            false;
        if (!isScanned) {
          FullScanRequest request = await account.handler!
              .requestFullScan(addressType: descriptor.addressType);
          _fullScanRequest[(account, descriptor.addressType)] = request;
        }
      }
    }
    await _startFullScan();
  }

  void _startSync() async {
    for (final accountWithType in _synRequests.keys) {
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
            if (_fullScanRequest.isNotEmpty) {
              return;
            }
            kPrint(
                "⏳Syncing account ${account.name} | ${account.network} | $server  |Tor : $port");
            while (_pauseSync) {
              await Future.delayed(const Duration(milliseconds: 100));
            }
            await _performWalletSync(account, server, port, type);
            if (account.network == Network.testnet4) {
              print("\n\n\n account \n ${account.descriptors.map(
                (element) => "${element.external_},\n ${element.addressType}\n",
              )}\n\n\n ");
            }
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
          await LocalStorage().prefs.getAccountScanStatus(account.id, type) ??
              false;
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
          } catch (e) {
            kPrint("Error fullScan account ${account.name}: $e");
          } finally {
            _fullScanRequest.remove(accountWithType);
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
    // if (port == -1) {
    //   port = null;
    // }
    kPrint(
        "🔍 PerformFullScan ${account.name} | ${account.network} | $server  |Tor : ${port != null}");
    _currentLoading.sink.add(Scanning(account.id));
    WalletUpdate update = await EnvoyAccountHandler.scanWallet(
      scanRequest: fullScanRequest,
      electrumServer: server,
      torPort: null,
    );
    try {
      await handler.applyUpdate(update: update, addressType: addressType);
      LocalStorage().prefs.setAccountScanStatus(account.id, addressType, true);
      kPrint(
          "✨ Finished FullScan account ${account.name} | ${account.network} | $server  |Tor : ${port != null}");
    } catch (e) {
      kPrint(
          "Error fullScan: for ${account.name} | ${account.network} | $server  |Tor : $port $e");
      EnvoyReport().log(
          "Error fullScan: for ${account.name} | ${account.network} | $server  |Tor : $port",
          e.toString());
    } finally {
      _fullScanRequest.remove((account, addressType));
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
      torPort: null,
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
        server = Settings.MUTINYNET_ELECTRUM_SERVER;
        break;
      default:
        server = "Unknown server";
        break;
    }
    return server;
  }

  dispose() {
    _syncTimer.cancel();
  }

  void pauseSync() {
    _pauseSync = true;
  }

  void resumeSync() {
    _pauseSync = false;
  }
}
