// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:envoy/account/sync_manager.dart';
import 'package:envoy/business/local_storage.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/list_utils.dart';
import 'package:flutter/material.dart';
import 'package:ngwallet/ngwallet.dart';

class AccountAlreadyPaired implements Exception {}

extension AccountExtension on EnvoyAccount {
  EnvoyAccountHandler? get handler {
    return NgAccountManager().getHandler(this);
  }
}

class NgAccountManager extends ChangeNotifier {
  static const String ACCOUNT_ORDER = "accounts_order";

  static String walletsDirectory =
      "${LocalStorage().appDocumentsDir.path}/wallets_new/";
  final LocalStorage _ls = LocalStorage();
  static final NgAccountManager _instance = NgAccountManager._internal();

  late SyncManager _syncManager;
  List<EnvoyAccount> _accounts = [];
  final StreamController<List<String>> _accountsOrder =
      StreamController<List<String>>.broadcast(sync: true);

  final List<EnvoyAccountHandler> _accountsHandler = [];
  var s = Settings();

  List<EnvoyAccount> get accounts => _accounts;

  List<EnvoyAccountHandler> get handlers => _accountsHandler;

  Stream<List<String>> get order => _accountsOrder.stream;

  List<Stream<EnvoyAccount>> get streams =>
      _accountsHandler.map((e) => e.stream()).toList();

  factory NgAccountManager() {
    return _instance;
  }

  static Future<NgAccountManager> init() async {
    var singleton = NgAccountManager._instance;
    try {
      await RustLib.init();
    } catch (e, stack) {
      kPrint("Error initializing RustLib: $e");
      EnvoyReport().log("Envoy init", e.toString(), stackTrace: stack);
    }
    return singleton;
  }

  NgAccountManager._internal();

  restore() async {
    _syncManager = SyncManager(accountsCallback: () => _accounts);
    _accounts = [];
    final accountOrder = _ls.prefs.getString(ACCOUNT_ORDER);
    List<String> order = List<String>.from(jsonDecode(accountOrder ?? "[]"));
    _accountsOrder.sink.add(order);

    final walletDirectory = Directory(walletsDirectory);

    if (!walletDirectory.existsSync()) {
      await walletDirectory.create(recursive: true);
    }

    final dirs = await walletDirectory.list().toList();
    for (var dir in dirs) {
      if (dir is Directory) {
        try {
          final accountHandler =
              await EnvoyAccountHandler.openWallet(dbPath: dir.path);
          _accountsHandler.add(accountHandler);
          _accounts.add((await accountHandler.state()));
          await accountHandler.sendUpdate();
        } catch (e) {
          kPrint("Error opening wallet: $e");
        }
      }
    }
    _syncManager.startSync();
    _accountsOrder.sink.add(order);
    notifyListeners();
  }

  EnvoyAccount? getAccountById(String id) {
    return _accounts.firstWhereOrNull((element) => element.id == id);
  }

  SyncManager get syncManager => _syncManager;

  updateAccountOrder(List<String> accountsOrder) async {
    _accountsOrder.sink.add(accountsOrder);
    await _ls.prefs.setString(ACCOUNT_ORDER, jsonEncode(accountsOrder));
    return;
  }

  BitcoinTransaction? getTransactionById(EnvoyAccount account, String txId) {
    for (var transaction in account.transactions) {
      if (transaction.txId == txId) {
        return transaction;
      }
    }
    return null;
  }

  String? getAccountIdByTransaction(String txId) {
    for (var account in accounts) {
      var transaction = getTransactionById(account, txId);
      if (transaction != null) {
        return account.id;
      }
    }
    return null;
  }

  @override
  // ignore: must_call_super
  void dispose({bool? force}) {
    _syncManager.dispose();
    if (force == true) {
      super.dispose();
    }
  }

  EnvoyAccountHandler? getHandler(EnvoyAccount envoyAccount) {
    return _accountsHandler
        .firstWhereOrNull((element) => element.id() == envoyAccount.id);
  }
}
