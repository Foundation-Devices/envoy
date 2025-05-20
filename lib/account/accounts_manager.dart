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

  String getPreferredAddress() {
    return nextAddress
        .where(
          (addressRecord) => addressRecord.$2 == preferredAddressType,
        )
        .first
        .$1;
  }
}

class NgAccountManager extends ChangeNotifier {
  static const String ACCOUNT_ORDER = "accounts_order";

  static String walletsDirectory =
      "${LocalStorage().appDocumentsDir.path}/wallets_v2/";
  final LocalStorage _ls = LocalStorage();
  static final NgAccountManager _instance = NgAccountManager._internal();

  late SyncManager _syncManager;
  final StreamController<List<String>> _accountsOrder =
      StreamController<List<String>>.broadcast(sync: true);

  final List<(EnvoyAccount, EnvoyAccountHandler)> _accountsHandler = [];
  var s = Settings();

  List<EnvoyAccount> get accounts => _accountsHandler
      .map(
        (e) => e.$1,
      )
      .toList();

  List<EnvoyAccountHandler> get handlers => _accountsHandler
      .map(
        (e) => e.$2,
      )
      .toList();

  Stream<List<String>> get order => _accountsOrder.stream;

  List<Stream<EnvoyAccount>> get streams =>
      _accountsHandler.map((e) => e.$2.stream()).toList();

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

  Future restore() async {
    _accountsHandler.clear();
    _syncManager = SyncManager(
        accountsCallback: () => _accountsHandler
            .map(
              (e) => e.$1,
            )
            .toList());
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
              await EnvoyAccountHandler.openAccount(dbPath: dir.path);
          final state = await accountHandler.state();
          _accountsHandler.add((state, accountHandler));
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
    return accounts.firstWhereOrNull((element) => element.id == id);
  }

  SyncManager get syncManager => _syncManager;

  Future updateAccountOrder(List<String> accountsOrder) async {
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
    return handlers
        .firstWhereOrNull((element) => element.id() == envoyAccount.id);
  }

  bool hotAccountsExist() {
    for (var account in accounts) {
      if (account.isHot) {
        return true;
      }
    }
    return false;
  }

  Future<bool> checkIfWalletFromSeedExists(String seed,
      {String? passphrase,
      required AddressType type,
      required Network network}) async {
    final derivations = await EnvoyBip39.deriveDescriptorFromSeed(
        seedWords: seed, network: network, passphrase: passphrase);
    final descriptor = derivations.firstWhereOrNull(
      (element) => element.addressType == type,
    );
    if (descriptor != null) {
      for (var account in accounts) {
        for (var desc in account.descriptors) {
          if (desc.external_ == descriptor.externalPubDescriptor ||
              desc.external_ == descriptor.externalDescriptor) {
            return true;
          }
        }
      }
    }
    return false;
  }

  addAccount(EnvoyAccount state, EnvoyAccountHandler handler) async {
    final accountOrder = _ls.prefs.getString(ACCOUNT_ORDER);
    List<String> order = List<String>.from(jsonDecode(accountOrder ?? "[]"));
    order.add(state.id);
    _accountsHandler.add((state, handler));
    await updateAccountOrder(order);
    notifyListeners();
    //wait for the stream to propagate
    await Future.delayed(const Duration(milliseconds: 100));
  }

  //generates unique directory for account
  //uniqueness is based on device serial, network and account number
  //eg. hot wallet will look like this ( deviceSerial will be "envoy")
  // unified    :  wallets_v2/envoy_testnet_acc_0
  // non-unified:  wallets_v2/envoy_testnet_acc_0_d68ab671
  // non-unified will include unique id
  static Directory getAccountDirectory({
    required String deviceSerial,
    required String network,
    required int number,
    String? accountId,
  }) {
    if (accountId != null) {
      return Directory(
          "$walletsDirectory${deviceSerial}_${network.toLowerCase()}_acc_${number}_${accountId.substring(0, 8)}");
    } else {
      return Directory(
          "$walletsDirectory${deviceSerial}_${network.toLowerCase()}_acc_$number");
    }
  }

  void setTaprootEnabled(bool taprootEnabled) async {
    for (var handler in handlers) {
      try {
        //if wallets contains taproot and p2wpkh, then set the preferred address type
        List<AddressType> types = handler
            .config()
            .descriptors
            .map(
              (e) => e.addressType,
            )
            .toList();
        if (types.contains(AddressType.p2Tr) &&
            types.contains(AddressType.p2Wpkh)) {
          await handler.setPreferredAddressType(
              addressType:
                  taprootEnabled ? AddressType.p2Tr : AddressType.p2Wpkh);
        }
      } catch (e) {
        EnvoyReport().log(
          "Error setting taproot address type",
          e.toString(),
        );
      }
    }
  }
}
