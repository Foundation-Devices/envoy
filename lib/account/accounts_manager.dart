// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:envoy/account/device_manager.dart';
import 'package:envoy/account/sync_manager.dart';
import 'package:envoy/business/bip329.dart';
import 'package:envoy/business/devices.dart';
import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/business/local_storage.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/business/uniform_resource.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/list_utils.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:ngwallet/ngwallet.dart';

import '../util/envoy_storage.dart';

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

enum DeviceAccountResult {
  ADDED,
  UPDATED_WITH_NEW_DESCRIPTOR,
  ERROR,
}

class NgAccountManager extends ChangeNotifier {
  static const String ACCOUNT_ORDER = "accounts_order";

  static String walletsDirectory =
      "${LocalStorage().appDocumentsDir.path}/wallets_v2/";
  final LocalStorage _ls = LocalStorage();
  static final NgAccountManager _instance = NgAccountManager._internal();
  final List<StreamSubscription?> _syncSubscription = [];

  final StreamController<List<String>> _accountsOrder =
      StreamController<List<String>>.broadcast(sync: true);

  StreamController<bool> isAccountBalanceHigherThanUsd1000Stream =
      StreamController.broadcast();

  final List<(EnvoyAccount, EnvoyAccountHandler)> _accountsHandler = [];
  var s = Settings();
  static late final bool isTesting;

  static const String accountsPrefKey = "ng_accounts";
  static const String v1AccountsPrefKey = "accounts";

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
    // IS_TEST flag from run_integration_tests.sh
    isTesting = const bool.fromEnvironment('IS_TEST', defaultValue: true);

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
    SyncManager().startSync();
    _accountsOrder.sink.add(order);
    notifyListeners();
    // for (var stream in streams) {
    //   _syncSubscription.add(stream.listen((_) {
    //     notifyIfAccountBalanceHigherThanUsd1000();
    //   }));
    // }
  }

  EnvoyAccount? getAccountById(String id) {
    return accounts.firstWhereOrNull((element) => element.id == id);
  }

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
    for (var subscription in _syncSubscription) {
      subscription?.cancel();
    }

    if (!isTesting) {
      SyncManager().dispose();
      if (force == true) {
        super.dispose();
      }
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

  bool hotSignetAccountExist() {
    for (var account in accounts) {
      if (account.isHot && account.network == Network.signet) {
        return true;
      }
    }
    return false;
  }

  bool hotWalletAccountsEmpty() {
    for (var account in accounts) {
      if (account.isHot && account.balance != BigInt.zero) {
        return false;
      }
    }
    return true;
  }

  Future<bool> checkIfWalletFromSeedExists(String seed,
      {String? passphrase,
      required AddressType type,
      required Network network}) async {
    var dir = NgAccountManager.getAccountDirectory(
        deviceSerial: "envoy", network: network.toString(), number: 0);
    if (await dir.exists()) {
      if (dir.listSync().isNotEmpty) {
        return true;
      }
    }
    return false;
  }

  addAccount(EnvoyAccount state, EnvoyAccountHandler handler) async {
    if (_accountsHandler.any((element) => element.$1.id == state.id)) {
      return;
    }
    final accountOrder = _ls.prefs.getString(ACCOUNT_ORDER);
    Set<String> order =
        List<String>.from(jsonDecode(accountOrder ?? "[]")).toSet();
    order.add(state.id);

    _accountsHandler.add((state, handler));
    await updateAccountOrder(order.toList());
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

  notifyIfAccountBalanceHigherThanUsd1000() {
    for (var account in accounts) {
      if (account.isHot && account.network == Network.bitcoin) {
        var amountUSD = ExchangeRate().getUsdValue(account.balance.toInt());
        if (amountUSD >= 1000) {
          if (!isAccountBalanceHigherThanUsd1000Stream.isClosed) {
            isAccountBalanceHigherThanUsd1000Stream.add(true);
          }
        }
      }
    }
  }

  Future deleteHotWalletAccounts() async {
    final accountOrder = _ls.prefs.getString(ACCOUNT_ORDER);
    List<String> order = List<String>.from(jsonDecode(accountOrder ?? "[]"));
    final hotWallets = accounts.where((element) => element.isHot).toList();
    for (var element in hotWallets) {
      _accountsHandler.removeWhere((e) => e.$1.id == element.id);
      order.remove(element.id);
    }
    await _ls.prefs.setString(ACCOUNT_ORDER, jsonEncode(order));
    _accountsOrder.sink.add(order);
    for (var account in hotWallets) {
      try {
        await deleteAccount(account);
      } catch (e) {
        EnvoyReport().log("Error deleting account", e.toString());
      }
    }
    notifyListeners();
  }

  Future deleteAccount(EnvoyAccount account) async {
    account.handler?.dispose();
    final accountOrder = _ls.prefs.getString(ACCOUNT_ORDER);
    List<String> order = List<String>.from(jsonDecode(accountOrder ?? "[]"));
    order.remove(account.id);
    await _ls.prefs.setString(ACCOUNT_ORDER, jsonEncode(order));

    for (var descriptor in account.descriptors) {
      await EnvoyStorage()
          .removeAccountStatus(account.id, descriptor.addressType);
    }
    _accountsOrder.sink.add(order);
    await Future.delayed(const Duration(milliseconds: 50));
    final dir = Directory(account.walletPath!);
    await dir.delete(recursive: true);
    _accountsHandler.removeWhere((e) => e.$1.id == account.id);
    notifyListeners();
  }

  Future deleteDeviceAccounts(Device device) async {
    final accountsToDelete = accounts
        .where((element) => element.deviceSerial == device.serial)
        .toList();
    for (var account in accountsToDelete) {
      await deleteAccount(account);
    }
  }

  Future<void> exportBIP329() async {
    List<String> allData = [];

    for (EnvoyAccount account in accounts) {
      for (var descriptor in account.descriptors) {
        String xpub = getXpub(descriptor, account);
        String xpubData = buildKeyJson("xpub", xpub, account.name);
        allData.add(xpubData);

        // Get output data and add each entry to allData
        List<String> outputData = await getUtxosData(account);
        allData.addAll(outputData);

        // Get transaction data and add each entry to allData
        List<String> txData = await getTxData(account);
        allData.addAll(txData);
      }
      // Get xpub and create JSON data

      // Join each JSON string with a newline character

      // Save the file
    }
    String fileContent = allData.join('\n');
    Uint8List fileContentBytes = Uint8List.fromList(utf8.encode(fileContent));
    await FileSaver.instance.saveAs(
        mimeType: MimeType.json,
        name: 'bip329_export',
        bytes: fileContentBytes,
        ext: 'json');
  }

  EnvoyAccount? getHotWalletAccount({network = Network.bitcoin}) {
    return accounts.firstWhereOrNull(
        (element) => element.isHot && element.network == network);
  }

  Future<(DeviceAccountResult, EnvoyAccount?)> addPassportAccount(
      Binary binary) async {
    var jsonIndex = binary.decoded.indexOf("{");
    var decoded = binary.decoded.substring(jsonIndex);
    var json = jsonDecode(decoded);

    NgAccountConfig config = await getPassportAccountFromJson(json);

    final alreadyPairedAccount = accounts.firstWhereOrNull((account) {
      final existingAccountDescriptor = account.descriptors.firstOrNull;
      final newAccountDescriptor = config.descriptors.firstOrNull;
      if (existingAccountDescriptor == null || newAccountDescriptor == null) {
        return false;
      }

      String getOrigin(String descriptor) =>
          RegExp(r'\[(.*?)\]').firstMatch(descriptor)?.group(1) ?? '';

      return account.index == config.index &&
          account.network == config.network &&
          getOrigin(existingAccountDescriptor.internal) ==
              getOrigin(newAccountDescriptor.internal);
    });

    // If the account exists but is from a different device, delete it
    bool existingAccountFromDifferentDevice = false;
    if (alreadyPairedAccount != null &&
        alreadyPairedAccount.deviceSerial != config.deviceSerial) {
      await NgAccountManager().deleteAccount(alreadyPairedAccount);
      existingAccountFromDifferentDevice = true;
    }

    final List<NgDescriptor> missingDescriptors = [];
    if (alreadyPairedAccount != null && !existingAccountFromDifferentDevice) {
      if (alreadyPairedAccount.name != config.name) {
        await alreadyPairedAccount.handler?.renameAccount(name: config.name);
      }
      for (var descriptor in config.descriptors) {
        final found = alreadyPairedAccount.descriptors.firstWhereOrNull(
          (accountDescriptor) =>
              accountDescriptor.external_ == descriptor.external_ &&
              accountDescriptor.addressType == descriptor.addressType,
        );
        //if the descriptor is not found, add it to the list of missing descriptors
        if (found == null) {
          missingDescriptors.add(descriptor);
        }
      }
      if (missingDescriptors.isEmpty) {
        throw AccountAlreadyPaired();
      }
      final handler = alreadyPairedAccount.handler;
      if (handler == null) {
        return (DeviceAccountResult.ERROR, null);
      }
      if (missingDescriptors.isNotEmpty) {
        for (var descriptor in missingDescriptors) {
          try {
            bool taprootEnabled = Settings().taprootEnabled();
            await handler.addDescriptor(
              ngDescriptor: descriptor,
            );
            final state = await handler.state();
            //if the user added a taproot descriptor
            //and if taproot is enabled, set the preferred address type to taproot
            if (taprootEnabled) {
              var taprootDescriptor = state.descriptors.firstWhereOrNull(
                  (element) => element.addressType == AddressType.p2Tr);
              if (taprootDescriptor != null) {
                await handler.setPreferredAddressType(
                    addressType: AddressType.p2Tr);
              }
            }
          } catch (e) {
            EnvoyReport().log("AccountManager",
                "Error adding descriptor to account ${alreadyPairedAccount.name} $e");
          }
        }
        return (
          DeviceAccountResult.UPDATED_WITH_NEW_DESCRIPTOR,
          (await handler.state())
        );
      }
    }

    Directory dir = NgAccountManager.getAccountDirectory(
      deviceSerial: config.deviceSerial ?? "unknown-serial_${config.id}",
      network: config.network.toString(),
      number: config.index,
    );
    if (await dir.exists()) {
      EnvoyReport().log("AccountManager",
          "Failed to create account directory for ${config.name}:${config.deviceSerial}, already exists: ${dir.path}");
    } else {
      await dir.create(recursive: true);
    }

    try {
      final handler = await EnvoyAccountHandler.addAccountFromConfig(
          config: config, dbPath: dir.path);
      await addAccount(await handler.state(), handler);
      return (DeviceAccountResult.ADDED, (await handler.state()));
    } catch (e) {
      EnvoyReport().log("AccountManager", "Error Adding account: $e");
      kPrint("Error creating account directory: $e");
      return (DeviceAccountResult.ERROR, null);
    }
  }
}
