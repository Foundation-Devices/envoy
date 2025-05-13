// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:envoy/account/accounts_manager.dart';
import 'package:envoy/business/scheduler.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/console.dart';
import 'package:ngwallet/ngwallet.dart';

class SyncManager {
  final _syncScheduler = EnvoyScheduler().parallel;
  final Map<(EnvoyAccount, AddressType), SyncRequest> _synRequests = {};
  final List<EnvoyAccount> Function() accountsCallback;
  Function(EnvoyAccount)? _onUpdateFinished;
  late Timer _syncTimer;
  bool _pauseSync = false;

  SyncManager({required this.accountsCallback}) {
    _syncAll();
  }

  startSync() {
    _syncTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (_pauseSync) {
        return;
      }
      _syncAll();
    });
  }

  void onUpdateFinished(Function(EnvoyAccount) onUpdateFinished) {
    _onUpdateFinished = onUpdateFinished;
  }

  void _syncAll() async {
    final accounts = accountsCallback();
    for (var account in accounts) {
      if (account.handler != null) {
        for (var descriptor in account.descriptors) {
          final request = await account.handler!
              .syncRequest(addressType: descriptor.addressType);
          _synRequests[(account, descriptor.addressType)] = request;
        }
      }
    }
    _startSync();
  }

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
            kPrint(
                "⏳Syncing  account ${account.name} | ${account.network} | $server  |Tor : $port");
            while (_pauseSync) {
              await Future.delayed(const Duration(milliseconds: 100));
            }
            await _performWalletSync(account, server, port, type);
            kPrint(
                "✨Finished account account ${account.name} | ${account.network} | $server  |Tor : $port");
          } catch (e) {
            kPrint("Error syncing account ${account.name}: $e");
          } finally {
            _synRequests.remove(accountWithType);
            _onUpdateFinished?.call(account);
          }
        },
      );
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
      await account.handler!
          .applyUpdate(update: update, addressType: addressType);
    } catch (e) {
      EnvoyReport().log(
          "Error applying sync for ${account.name} | ${account.network} | $server  |Tor : $port",
          e.toString());
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
        server = Settings.TESTNET_ELECTRUM_SERVER;
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
