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
import 'package:envoy/business/devices.dart';
import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/business/local_storage.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/business/uniform_resource.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:envoy/util/list_utils.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  Directory? getWalletDir() {
    return NgAccountManager.getAccountDirectory(
        deviceSerial: deviceSerial ?? "envoy",
        network: network.toString(),
        number: index,
        fingerprint: xfp);
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
    kPrint("Restoring accounts");
    if (_accountsHandler.isNotEmpty) {
      for (var accountHandler in _accountsHandler) {
        accountHandler.$2.dispose();
      }
      //wait for the accounts to be disposed
      await Future.delayed(const Duration(milliseconds: 1500));
    }
    _accountsHandler.clear();
    final accountOrder = _ls.prefs.getString(ACCOUNT_ORDER);
    List<String> order = List<String>.from(jsonDecode(accountOrder ?? "[]"));
    _accountsOrder.sink.add(order);

    final walletDirectory = Directory(walletsDirectory);

    if (!(await walletDirectory.exists())) {
      await walletDirectory.create(recursive: true);
    }
    final dirs = await walletDirectory.list().toList();
    for (var dir in dirs) {
      if (dir is Directory) {
        try {
          kPrint("Opening wallet: ${dir.path}");
          final accountHandler =
              await EnvoyAccountHandler.openAccount(dbPath: dir.path);
          final state = await accountHandler.state();
          _accountsHandler.add((state, accountHandler));
          await accountHandler.sendUpdate();
        } catch (e) {
          kPrint("Error opening wallet: $e ${dir.path}");
        }
      }
    }

    sortByAccountOrder(_accountsHandler, order, (e) => e.$1.id);
    await deriveMissingTypes();

    _accountsOrder.sink.add(order);

    SyncManager().startSync();

    notifyListeners();
    for (var stream in streams) {
      _syncSubscription.add(stream.listen((_) {
        notifyIfAccountBalanceHigherThanUsd1000();
      }));
    }
    removeDuplicateHotWallets();
  }

  Future deriveMissingTypes() async {
    try {
      if (hotAccountsExist()) {
        for (var account in accounts) {
          if (account.isHot) {
            EnvoyAccountHandler? handler = account.handler;
            bool isP2TrDerived = account.descriptors
                .any((element) => element.addressType == AddressType.p2Tr);
            EnvoyReport()
                .log("AccountManager", "isP2TrDerived: $isP2TrDerived");
            if (handler == null) {
              continue;
            }
            if (!isP2TrDerived) {
              final seed = await EnvoySeed().get();
              if (seed != null && !account.seedHasPassphrase) {
                try {
                  final derivations = await EnvoyBip39.deriveDescriptorFromSeed(
                      seedWords: seed,
                      network: account.network,
                      passphrase: null);

                  final descriptor = derivations
                      .where(
                          (element) => element.addressType == AddressType.p2Tr)
                      .map((element) => NgDescriptor(
                            internal: element.internalDescriptor,
                            external_: element.externalDescriptor,
                            addressType: element.addressType,
                          ))
                      .first;

                  await handler.addDescriptor(ngDescriptor: descriptor);
                  final state = await handler.state();
                  final index =
                      _accountsHandler.indexWhere((e) => e.$1.id == state.id);
                  if (index != -1) {
                    _accountsHandler[index] = (state, handler);
                  } else {
                    _accountsHandler.add((state, handler));
                  }
                  EnvoyReport().log(
                      "Accounts", "P2Tr descriptor added to ${account.name}");
                } catch (e) {
                  EnvoyReport().log("Accounts",
                      "Error adding p2Tr descriptor to ${account.name} $e");
                }
              }
            }
          }
        }
      }
    } catch (e, stack) {
      EnvoyReport().log("Accounts", "Error deriving missing types: $e",
          stackTrace: stack);
    }
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
    final index =
        _accountsHandler.indexWhere((e) => e.$1.id == envoyAccount.id);
    return index != -1 ? _accountsHandler[index].$2 : null;
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

  static String? getFingerprint(String descriptor) {
    final regex = RegExp(r'\[([0-9a-f]{8})/');
    final matches = regex.allMatches(descriptor);
    try {
      if (matches.isEmpty) {
        EnvoyReport().log("NGAccounts", "Invalid fingerprint $descriptor");
        return null;
      }
      return matches.map((m) => m.group(1)).first;
    } catch (e) {
      return null;
    }
  }

  Future<bool> checkIfWalletFromSeedExists(String seed,
      {String? passphrase, required Network network}) async {
    try {
      final descriptors = await EnvoyBip39.deriveDescriptorFromSeed(
          seedWords: seed, network: network, passphrase: passphrase);
      final fingerPrint = getFingerprint(descriptors
          .firstWhere((element) => element.addressType == AddressType.p2Wpkh)
          .externalPubDescriptor);
      if (fingerPrint == null) {
        EnvoyReport().log("Accounts", "Invalid fingerprint $fingerPrint");
        return false;
      }
      var dir = NgAccountManager.getAccountDirectory(
          deviceSerial: "envoy",
          network: network.toString(),
          number: 0,
          fingerprint: fingerPrint);
      if (await dir.exists()) {
        final files = dir.listSync();
        bool hasP2tr = files
            .any((file) => file.path.toLowerCase().endsWith('p2tr.sqlite'));
        bool hasP2wpkh = files
            .any((file) => file.path.toLowerCase().endsWith('p2wpkh.sqlite'));
        if (hasP2tr || hasP2wpkh) {
          return true;
        }
      }
      return false;
    } catch (e) {
      EnvoyReport().log("Accounts", "Failed to check wallet existence: $e");
      return false;
    }
  }

  Future<void> addAccount(
      EnvoyAccount state, EnvoyAccountHandler handler) async {
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
    required String fingerprint,
  }) {
    return Directory("$walletsDirectory${getUniqueAccountId(
      deviceSerial: deviceSerial,
      network: network,
      number: number,
      fingerprint: fingerprint,
    )}");
  }

  static String getUniqueAccountId({
    required String deviceSerial,
    required String network,
    required int number,
    required String fingerprint,
  }) {
    return "${deviceSerial}_${network.toLowerCase()}_${fingerprint.toLowerCase()}_acc_$number";
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

  void notifyIfAccountBalanceHigherThanUsd1000() {
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

    _accountsOrder.sink.add(order);
    for (var account in hotWallets) {
      try {
        await deleteAccount(account);
      } catch (e) {
        EnvoyReport().log("Error deleting account", e.toString());
      }
    }
    for (var element in hotWallets) {
      order.remove(element.id);
    }
    await _ls.prefs.setString(ACCOUNT_ORDER, jsonEncode(order));
    notifyListeners();
  }

  Future deleteAccount(EnvoyAccount account) async {
    await account.handler?.deleteAccount();
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

  Future<void> exportBIP329(WidgetRef ref) async {
    List<String> allData = [];

    for (EnvoyAccount account in accounts) {
      List<String> accountData = await account.handler!.exportBip329Data();
      allData.addAll(accountData);
    }

    String fileContent = allData.join('\n');
    Uint8List fileContentBytes = Uint8List.fromList(utf8.encode(fileContent));
    await FileSaver.instance.saveAs(
        mimeType: MimeType.custom,
        customMimeType: 'application/jsonl',
        name: 'bip329_export',
        bytes: fileContentBytes,
        fileExtension: 'jsonl');
  }

  EnvoyAccount? getHotWalletAccount({Network network = Network.bitcoin}) {
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

    final fingerprint =
        NgAccountManager.getFingerprint(config.descriptors.first.internal);
    Directory dir = NgAccountManager.getAccountDirectory(
      deviceSerial: config.deviceSerial ?? "unknown-serial_${config.id}",
      network: config.network.toString(),
      number: config.index,
      fingerprint: fingerprint ?? config.id,
    );
    if (await dir.exists()) {
      EnvoyReport().log("AccountManager",
          "Failed to create account directory for ${config.name}:${config.deviceSerial}, already exists: ${dir.path}");
      throw AccountAlreadyPaired();
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

  //due to ENV-2272, there is a user might have duplicated accounts
  //any hot wallets that doesn't match the seed fingerprint and has 0 balance
  //should be removed
  void removeDuplicateHotWallets() async {
    try {
      final seed = await EnvoySeed().get();
      if (seed == null) {
        return;
      }
      final fingerprint = await EnvoyBip39.deriveFingerprintFromSeed(
          seedWords: seed, network: Network.bitcoin);

      for (var account in accounts) {
        if (account.isHot) {
          if (account.xfp != fingerprint && account.balance.toInt() == 0) {
            EnvoyReport().log("AccountManager",
                "Deleting duplicated account ${account.name} ${account.xfp}");
            await deleteAccount(account);
            _accountsHandler.removeWhere((e) => e.$1.id == account.id);
          }
        }
      }
    } catch (e, stacktrace) {
      EnvoyReport().log(
          "AccountManager", "Error checking duplicated accounts: $e",
          stackTrace: stacktrace);
    }
  }

  Future<void> renameAccountAndSync(
    EnvoyAccount account,
    String newName,
  ) async {
    final handler = account.handler;
    if (handler == null) return;

    final index =
        _accountsHandler.indexWhere((element) => element.$1.id == account.id);
    if (index != -1) {
      final (_, existingHandler) = _accountsHandler[index];
      _accountsHandler[index] = (
        account.copyWith(name: newName),
        existingHandler,
      );
      notifyListeners();
    }

    await handler.renameAccount(name: newName);
  }
}

List<T> sortByAccountOrder<T>(
  List<T> list,
  List<String> order,
  String Function(T item) getId,
) {
  list.sort((a, b) {
    final aIndex = order.indexOf(getId(a));
    final bIndex = order.indexOf(getId(b));
    if (aIndex == -1 && bIndex == -1) return 0;
    if (aIndex == -1) return 1;
    if (bIndex == -1) return -1;
    return aIndex.compareTo(bIndex);
  });
  return list;
}
