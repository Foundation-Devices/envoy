// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:envoy/account/accounts_manager.dart';
import 'package:envoy/business/scheduler.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/util/console.dart';
import 'package:ngwallet/ngwallet.dart';

class SyncManager {
  final _syncScheduler = EnvoyScheduler().parallel;
  final Map<EnvoyAccount, SyncRequest> _synRequests = {};
  final List<EnvoyAccount> Function() accountsCallback;
  Function(EnvoyAccount)? _onUpdateFinished;
  late Timer _syncTimer;
  bool _pauseSync = false;

  SyncManager({required this.accountsCallback}) {}

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
        _synRequests[account] = await account.handler!.requestSync();
      }
    }
    _startSync();
  }

  void _startSync() async {
    for (final account in _synRequests.keys) {
      final server = SyncManager.getElectrumServer(account.network);
      int? port = Settings().getPort(account.network);
      if (port == -1) {
        port = null;
      }
      _syncScheduler.run(
        () async {
          try {
            kPrint(
                "Syncing account ${account.name} | ${account.network} | ${server}  |Tor : ${port}");
            WalletUpdate update = await EnvoyAccountHandler.syncWallet(
              syncRequest: _synRequests[account]!,
              electrumServer: server,
              torPort: port,
            );
            while (_pauseSync) {
              await Future.delayed(const Duration(milliseconds: 50));
            }
            await account.handler!.applyUpdate(update: update);
            kPrint(
                "Finished account ${(await account.handler!.state()).balance} ");
          } catch (e) {
            kPrint("Error syncing account ${account.name}: $e");
          } finally {
            _synRequests.remove(account);
            _onUpdateFinished?.call(account);
          }
        },
      );
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
