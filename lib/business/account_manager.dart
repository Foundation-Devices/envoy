// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:envoy/business/account.dart';
import 'package:envoy/business/azteco_voucher.dart';
import 'package:envoy/business/connectivity_manager.dart';
import 'package:envoy/business/devices.dart';
import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/business/fees.dart';
import 'package:envoy/business/local_storage.dart';
import 'package:envoy/business/notifications.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/business/uniform_resource.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/util/xfp_endian.dart';
import 'package:flutter/material.dart';
import 'package:schedulers/schedulers.dart';
import 'package:tor/tor.dart';
import 'package:wallet/wallet.dart';
import 'package:envoy/util/envoy_storage.dart';

class AccountAlreadyPaired implements Exception {}

class AccountManager extends ChangeNotifier {
  List<Account> accounts = [];
  LocalStorage _ls = LocalStorage();

  Timer? _syncTimer;
  bool _syncBlocked = false;

  // SFT-1544: never sync more than 4 account at once
  final _syncScheduler = ParallelScheduler(4);

  static const String ACCOUNTS_PREFS = "accounts";
  static final AccountManager _instance = AccountManager._internal();

  static String walletsDirectory =
      LocalStorage().appDocumentsDir.path + "/wallets/";

  factory AccountManager() {
    return _instance;
  }

  static Future<AccountManager> init() async {
    var singleton = AccountManager._instance;
    return singleton;
  }

  AccountManager._internal() {
    print("Instance of AccountManager created!");
    restore();
  }

  void syncAll() {
    if (!_syncBlocked) {
      _syncBlocked = true;

      // Rate limit syncs
      Timer(Duration(seconds: 5), () {
        _syncBlocked = false;
      });

      if (!ConnectivityManager().torEnabled ||
          ConnectivityManager().torCircuitEstablished) {
        accounts.forEach((account) {
          _syncScheduler.run(() async {
            final syncedAccount = await _syncAccount(account);

            final syncAccountIndex =
                accounts.indexWhere((a) => a.id == syncedAccount.id);
            if (syncAccountIndex != -1) {
              accounts[syncAccountIndex] = syncedAccount;
            }
            notifyListeners();
            storeAccounts();
            if (!isAccountBalanceHigherThanUsd1000Stream.isClosed) {
              notifyIfAccountBalanceHigherThanUsd1000();
            }
          });
        });
      }
    }
  }

  StreamController<bool> isAccountBalanceHigherThanUsd1000Stream =
      StreamController();

  notifyIfAccountBalanceHigherThanUsd1000() {
    for (var account in accounts) {
      if (account.wallet.hot && account.wallet.network == Network.Mainnet) {
        var amountUSD =
            double.parse(ExchangeRate().getUsdValue(account.wallet.balance));
        if (amountUSD >= 1000) {
          isAccountBalanceHigherThanUsd1000Stream.add(true);
        }
      }
    }
  }

  pendingSync(Account account) async {
    final pendingTxs = await EnvoyStorage()
        .getPendingTxs(account.id!, TransactionType.pending);

    if (pendingTxs.isEmpty) return;

    for (var pendingTx in pendingTxs) {
      account.wallet.transactions
          .where((tx) => tx.txId == pendingTx.txId)
          .forEach((txToRemove) {
        EnvoyStorage().deletePendingTx(pendingTx.txId);
      });
    }
  }

  Future<Account> _syncAccount(Account account) async {
    bool? changed = null;

    try {
      changed = await account.wallet
          .sync(Settings().electrumAddress(account.wallet.network), Tor().port);
    } on Exception catch (_) {
      // Let ConnectivityManager know that we can't reach Electrum
      if (account.wallet.network == Network.Mainnet) {
        ConnectivityManager().electrumFailure();
      }
    }

    if (changed != null) {
      // Let ConnectivityManager know that we've synced
      if (account.wallet.network == Network.Mainnet) {
        ConnectivityManager().electrumSuccess();
      }

      // Update the Fees singleton
      Fees().fees[account.wallet.network]!.electrumFastRate =
          account.wallet.feeRateFast;
      Fees().fees[account.wallet.network]!.electrumSlowRate =
          account.wallet.feeRateSlow;

      // This does away with amounts "ghosting" in UI
      account = account.copyWith(dateSynced: DateTime.now());

      aztecoSync(account);
      pendingSync(account);
    }
    ;

    return account;
  }

  Future<Account?> addHotWalletAccount(Wallet wallet) async {
    // TODO: look & feel of hot wallet accounts
    Account account = Account(
        wallet: wallet,
        name: S().accounts_screen_account_default_name,
        deviceSerial: "envoy",
        // Device code for wallets derived on phone
        dateAdded: DateTime.now(),
        number: 0,
        id: Account.generateNewId(),
        dateSynced: null);

    addAccount(account);
    return account;
  }

  Future<Account?> addEnvoyAccountFromJson(Binary binary) async {
    var jsonIndex = binary.decoded.indexOf("{");
    var decoded = binary.decoded.substring(jsonIndex);
    var json = jsonDecode(decoded);

    // Check if account already present
    for (var account in accounts) {
      if (account.wallet.name == json["xpub"].toString()) {
        throw AccountAlreadyPaired();
      }
    }

    var partialDescriptor = "wpkh([" +
        reverseXfpStringEndianness(json["xfp"].toRadixString(16)) +
        json["derivation"].toString().replaceAll("'", "h").replaceAll("m", "") +
        "]" +
        json["xpub"];

    var externalDescriptor = partialDescriptor + "/0/*)";
    var internalDescriptor = partialDescriptor + "/1/*)";

    var wallet = await _initWallet(
        json["xpub"].toString(), externalDescriptor, internalDescriptor);

    // Add a device
    var fwVersion = json["fw_version"].toString();
    var serial = json["serial"].toString();

    // Pick colours
    int colorIndex =
        Devices().devices.length % (EnvoyColors.listTileColorPairs.length);

    Device device = Device(
        "Passport",
        json["hw_version"] == 1
            ? DeviceType.passportGen1
            : DeviceType.passportGen12,
        serial,
        DateTime.now(),
        fwVersion,
        EnvoyColors.listAccountTileColors[colorIndex]);

    Devices().add(device);

    int accountNumber = json["acct_num"];

    // Create an account & store
    colorIndex = accountNumber % (EnvoyColors.listAccountTileColors.length);
    Account account = Account(
        wallet: wallet,
        name: json["acct_name"] + " (#" + accountNumber.toString() + ")",
        deviceSerial: device.serial,
        dateAdded: DateTime.now(),
        number: accountNumber,
        id: Account.generateNewId(),
        dateSynced: null);

    addAccount(account);
    return account;
  }

  _dropAccounts() {
    for (Account account in accounts) {
      account.wallet.drop();
    }

    accounts.clear();
  }

  restore() {
    if (_syncTimer != null) {
      _syncTimer!.cancel();
    }

    _dropAccounts();
    if (_ls.prefs.containsKey(ACCOUNTS_PREFS)) {
      var storedAccounts = jsonDecode(_ls.prefs.getString(ACCOUNTS_PREFS)!);
      for (var account in storedAccounts) {
        Account restoredAccount = Account.fromJson(account);
        accounts.add(restoredAccount);
        restoredAccount.wallet.init(walletsDirectory);
      }
    }

    syncAll();
    _startPeriodicSync();
  }

  _startPeriodicSync() {
    // Sync periodically
    _syncTimer = Timer.periodic(Duration(seconds: 15), (timer) {
      syncAll();
    });
  }

  Future<Wallet> _initWallet(String fingerprint, String externalDescriptor,
      String internalDescriptor) async {
    int publicKeyIndex = externalDescriptor.indexOf("]") + 1;
    String publicKeyType =
        externalDescriptor.substring(publicKeyIndex, publicKeyIndex + 4);

    var network;
    if (publicKeyType == "tpub") {
      network = Network.Testnet;
    } else {
      network = Network.Mainnet;
    }

    Wallet wallet =
        Wallet(fingerprint, network, externalDescriptor, internalDescriptor);
    wallet.init(walletsDirectory);

    return wallet;
  }

  storeAccounts() {
    String json = jsonEncode(accounts);
    _ls.prefs.setString(ACCOUNTS_PREFS, json);
  }

  void addAccount(Account account) {
    accounts.add(account);
    storeAccounts();
    notifyListeners();

    EnvoySeed().backupData();

    syncAll();
  }

  renameAccount(Account account, String newName) {
    final oldAccount = accounts.firstWhere((a) {
      return a.id! == account.id!;
    });
    accounts[accounts.indexOf(oldAccount)] = account.copyWith(name: newName);
    storeAccounts();
    notifyListeners();
  }

  deleteAccount(Account account) {
    final accountToDeleteIndex = accounts.indexWhere((a) => a.id == account.id);
    if (accountToDeleteIndex != -1) {
      var accountToDelete = accounts[accountToDeleteIndex];
      accountToDelete.wallet.drop();

      // Delete the BDK DB so it doesn't get confused on re-pair
      final dir = Directory(walletsDirectory + accountToDelete.wallet.name);
      dir.delete(recursive: true);

      accounts.remove(accountToDelete);
      storeAccounts();
      notifyListeners();

      Notifications().deleteFromAccount(accountToDelete);
    }
    ;
  }

  deleteDeviceAccounts(Device device) {
    List<Account> accountsToDelete = [];
    for (var account in accounts) {
      if (account.deviceSerial == device.serial) {
        accountsToDelete.add(account);
      }
    }

    for (var account in accountsToDelete) {
      deleteAccount(account);
    }
  }

  moveAccount(int oldIndex, int newIndex) async {
    //Make a copy of current account set to prevent concurrent modification
    //sync might interfere with reordering so making a copy will prevent moving the same account
    final _accountCopy = [...accounts];
    //moving down, the list is shifted so the index is off by one
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    try {
      //Check if the items are not the same to prevent unnecessary duplication
      if (_accountCopy[newIndex].id == _accountCopy[oldIndex].id) {
        return;
      }
    } catch (_) {}
    var movedAccount = _accountCopy.removeAt(oldIndex);
    _accountCopy.insert(newIndex, movedAccount);

    accounts = _accountCopy;
    notifyListeners();
    storeAccounts();
  }

  // There is only one hot wallet for now (mainnet/testnet pair)
  Account? getHotWalletAccount({testnet = false}) {
    for (var account in accounts) {
      if (account.wallet.hot) {
        if (account.wallet.network == Network.Testnet && testnet) {
          return account;
        }

        if (account.wallet.network == Network.Mainnet && !testnet) {
          return account;
        }
      }
    }

    return null;
  }

  bool hotWalletAccountsEmpty() {
    for (var account in accounts) {
      if (account.wallet.hot) {
        if (account.wallet.balance > 0) {
          return false;
        }
      }
    }

    return true;
  }

  deleteHotWalletAccounts() {
    List<Account> accountsToDelete = [];
    for (var account in accounts) {
      if (account.wallet.hot) {
        accountsToDelete.add(account);
      }
    }

    for (var account in accountsToDelete) {
      deleteAccount(account);
    }
  }
}
