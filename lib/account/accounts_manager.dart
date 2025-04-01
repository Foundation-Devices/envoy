// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:envoy/business/local_storage.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/material.dart';
import 'package:ngwallet/ngwallet.dart';

class AccountAlreadyPaired implements Exception {}

class NgAccountManager extends ChangeNotifier {
  @override
  // ignore: must_call_super
  void dispose({bool? force}) {
    // prevents riverpods StateNotifierProvider from disposing it
    if (force == true) {
      super.dispose();
    }
  }

  List<EnvoyAccount> accounts = [];
  StreamController<List<EnvoyAccount>> accountsStream =
      StreamController.broadcast();

  final LocalStorage _ls = LocalStorage();
  var s = Settings();

  static const String ACCOUNT_ORDER = "accounts_order";
  static final NgAccountManager _instance = NgAccountManager._internal();
  static String walletsDirectory =
      "${LocalStorage().appDocumentsDir.path}/wallets_new/";

  factory NgAccountManager() {
    return _instance;
  }

  static Future<NgAccountManager> init() async {
    var singleton = NgAccountManager._instance;
    await RustLib.init();
    return singleton;
  }

  NgAccountManager._internal() {
    restore();
  }

  //TODO:
  void syncAll() {}

  StreamController<bool> isAccountBalanceHigherThanUsd1000Stream =
      StreamController.broadcast();

  restore() async {
    accounts = [];
    final accountOrder = _ls.prefs.getString(ACCOUNT_ORDER);
    final order = jsonDecode(accountOrder ?? "[]");
    for (var dirPath in order) {
      final dir = Directory(dirPath);
      if (await dir.exists()) {
        try {
          final account = await EnvoyAccount.openWallet(dbPath: dir.path);
          accounts.add(account);
        } catch (e) {
          kPrint("Error opening wallet: $e");
        }
      }
    }
    accountsStream.add(accounts);
    notifyListeners();
  }

  moveAccount(int oldIndex, int newIndex,
      List<EnvoyAccount> accountFromListView) async {
    //Make a copy of current account set to prevent concurrent modification
    //sync might interfere with reordering so making a copy will prevent moving the same account
    try {
      final visibleAccountsIds =
          accountFromListView.map((e) => e.config().id).toList();
      final accountCopy = [
        ...accounts.where(
            (element) => visibleAccountsIds.contains(element.config().id))
      ];

      //accounts that are not visible in the list (testnet). the move should not affect them,
      //so they are added to the end of the list
      final accountsThatNotVisible = [
        ...accounts.where(
            (element) => !visibleAccountsIds.contains(element.config().id))
      ];
      //moving down, the list is shifted so the index is off by one
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      try {
        //Check if the items are not the same to prevent unnecessary duplication
        if (accountCopy[newIndex].config().id ==
            accountCopy[oldIndex].config().id) {
          return;
        }
      } catch (_) {}
      var movedAccount = accountCopy.removeAt(oldIndex);
      accountCopy.insert(newIndex, movedAccount);

      // updated accounts with new order, testnet accounts are added to the end of the list if they are not visible
      accounts = [...accountCopy, ...accountsThatNotVisible];

      final serializedAccountsPath =
          jsonEncode(accounts.map((e) => e.config().walletPath ?? "").toList());
      _ls.prefs.setString(ACCOUNT_ORDER, serializedAccountsPath);
      notifyListeners();
    } catch (e) {
      kPrint(e);
    } finally {}
  }
}
