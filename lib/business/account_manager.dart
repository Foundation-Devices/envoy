// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:envoy/business/account.dart';
import 'package:envoy/business/azteco_voucher.dart';
import 'package:envoy/business/btcPay_voucher.dart';
import 'package:envoy/business/connectivity_manager.dart';
import 'package:envoy/business/devices.dart';
import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/business/fees.dart';
import 'package:envoy/business/local_storage.dart';
import 'package:envoy/business/notifications.dart';
import 'package:envoy/business/scheduler.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/business/uniform_resource.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:envoy/util/xfp_endian.dart';
import 'package:flutter/material.dart';
import 'package:tor/tor.dart';
import 'package:wallet/exceptions.dart';
import 'package:wallet/wallet.dart';

class AccountAlreadyPaired implements Exception {}

class AccountManager extends ChangeNotifier {
  List<Account> accounts = [];
  LocalStorage _ls = LocalStorage();

  Timer? _syncTimer;
  bool _syncBlocked = false;

  // prevents concurrent modification of accounts list, when moving accounts
  bool _accountSchedulerMutex = false;

  final _syncScheduler = EnvoyScheduler().parallel;

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
        accounts.where((account) {
          if (!Settings().showTestnetAccounts() &&
              account.wallet.network == Network.Testnet) {
            return false;
          }

          if (!Settings().taprootEnabled() &&
              account.wallet.type == WalletType.taproot) {
            return false;
          }

          return true;
        }).forEach((account) {
          _syncScheduler.run(() async {
            final syncedAccount = await _syncAccount(account);

            // prevent concurrent modification of accounts list
            if (_accountSchedulerMutex) {
              return;
            }

            final syncAccountIndex =
                accounts.indexWhere((a) => a.id == syncedAccount.id);
            if (syncAccountIndex != -1) {
              accounts[syncAccountIndex] = accounts[syncAccountIndex].copyWith(
                  wallet: syncedAccount.wallet,
                  dateSynced: syncedAccount.dateSynced);
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
        var amountUSD = ExchangeRate().getUsdValue(account.wallet.balance);
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
      account.wallet.transactions.where((tx) {
        return tx.txId == pendingTx.txId;
      }).forEach((txToRemove) {
        EnvoyStorage().deletePendingTx(pendingTx.txId);
      });
    }
  }

  Future<Account> _syncAccount(Account account) async {
    bool? changed = null;

    try {
      changed = await account.wallet.sync(
          Settings().electrumAddress(account.wallet.network),
          Tor.instance.port);
    } on Exception catch (e) {
      // Let ConnectivityManager know that we can't reach Electrum
      if (account.wallet.network == Network.Mainnet) {
        ConnectivityManager().electrumFailure();
      }

      EnvoyReport().log("wallet", "Couldn't sync: ${e}");
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
      btcPaySync(account);
      pendingSync(account);
    }
    ;

    return account;
  }

  Future<Account?> addHotWalletAccount(Wallet wallet) async {
    // TODO: look & feel of hot wallet accounts
    Account account = Account(
        wallet: wallet,
        name: S().accounts_screen_walletType_defaultName,
        deviceSerial: "envoy",
        // Device code for wallets derived on phone
        dateAdded: DateTime.now(),
        number: 0,
        id: Account.generateNewId(),
        dateSynced: null);

    addAccount(account);
    return account;
  }

  bool checkIfWalletFromSeedExists(String seed,
      {String? passphrase, WalletType type = WalletType.witnessPublicKeyHash}) {
    try {
      var mainnet = Wallet.deriveWallet(
          seed,
          EnvoySeed.hotWalletDerivationPaths[type]![Network.Mainnet]!,
          AccountManager.walletsDirectory,
          Network.Mainnet,
          privateKey: true,
          passphrase: passphrase,
          initWallet: false,
          type: type);
      for (final account in accounts) {
        if (account.wallet.externalDescriptor == mainnet.externalDescriptor) {
          return true;
        }
      }
    } on InvalidMnemonic {
      return false;
    }

    return false;
  }

  // Returned account is the one used for address verification
  Future<Account?> addPassportAccounts(Binary binary) async {
    var jsonIndex = binary.decoded.indexOf("{");
    var decoded = binary.decoded.substring(jsonIndex);
    var json = jsonDecode(decoded);

    bool oldJsonFormat = json['xpub'] != null;

    if (oldJsonFormat) {
      // Old format with single WPKH account
      Account newAccount = await getPassportAccountJson(json);
      addAccount(newAccount);
      return newAccount;
    } else {
      // New format can handle multiple accounts
      List<Account> newAccounts = await getPassportAccountsFromJson(json);
      int alreadyPairedAccountsCount = 0;

      newAccountsLoop:
      for (var newAccount in newAccounts) {
        // Check if account already paired
        for (var account in accounts) {
          if (account.wallet.name == newAccount.wallet.name) {
            // Don't add this one
            alreadyPairedAccountsCount++;
            continue newAccountsLoop;
          }
        }

        _initWallet(newAccount.wallet);
        addAccount(newAccount);
      }
      ;

      if (newAccounts.length == alreadyPairedAccountsCount) {
        throw AccountAlreadyPaired();
      } else {
        // We will verify the address on WPKH account only
        return newAccounts[0];
      }
    }
  }

  static Future<List<Account>> getPassportAccountsFromJson(dynamic json) async {
    List<Wallet> wallets = [];

    final bip84 = json["bip84"];
    if (bip84 != null) {
      // TODO: try here
      wallets.add(await getWalletFromJson(bip84));
    }

    final bip86 = json["bip86"];
    if (bip86 != null) {
      wallets.add(await getWalletFromJson(bip86));
    }

    Device device = getDeviceFromJson(json);
    Devices().add(device);

    int accountNumber = json["acct_num"];

    List<Account> accounts = [];
    wallets.forEach((wallet) {
      accounts.add(Account(
          wallet: wallet,
          name: json["acct_name"] + " (#" + accountNumber.toString() + ")",
          deviceSerial: device.serial,
          dateAdded: DateTime.now(),
          number: accountNumber,
          id: Account.generateNewId(),
          dateSynced: null));
    });

    return accounts;
  }

  Future<Account> getPassportAccountJson(dynamic json) async {
    // Check if account already present
    for (var account in accounts) {
      if (account.wallet.name == json["xpub"].toString()) {
        throw AccountAlreadyPaired();
      }
    }

    Wallet wallet = await getWalletFromJson(json);
    _initWallet(wallet);

    Device device = getDeviceFromJson(json);
    Devices().add(device);

    int accountNumber = json["acct_num"];

    // Create an account & store
    Account account = Account(
        wallet: wallet,
        name: json["acct_name"] + " (#" + accountNumber.toString() + ")",
        deviceSerial: device.serial,
        dateAdded: DateTime.now(),
        number: accountNumber,
        id: Account.generateNewId(),
        dateSynced: null);
    return account;
  }

  static Device getDeviceFromJson(json) {
    var fwVersion = json["fw_version"].toString();
    var serial = json["serial"].toString();
    String deviceName = json.containsKey("device_name") &&
            json["device_name"].toString().isNotEmpty
        ? json["device_name"].toString()
        : "Passport";

    // Pick colours
    int colorIndex =
        Devices().devices.length % (EnvoyColors.listTileColorPairs.length);

    Device device = Device(
        deviceName,
        json["hw_version"] == 1
            ? DeviceType.passportGen1
            : DeviceType.passportGen12,
        serial,
        DateTime.now(),
        fwVersion,
        EnvoyColors.listAccountTileColors[colorIndex]);
    return device;
  }

  static Future<Wallet> getWalletFromJson(json) async {
    String scriptType = json["derivation"].contains("86") ? "tr" : "wpkh";
    String xfp = reverseXfpStringEndianness(json["xfp"].toRadixString(16));
    String derivation =
        json["derivation"].toString().replaceAll("'", "h").replaceAll("m", "");
    String xpub = json["xpub"];

    var partialDescriptor = "$scriptType([$xfp$derivation]$xpub";

    var externalDescriptor = partialDescriptor + "/0/*)";
    var internalDescriptor = partialDescriptor + "/1/*)";

    var wallet = await _getWallet(xpub, externalDescriptor, internalDescriptor);
    return wallet;
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

    _startPeriodicSync();
  }

  _startPeriodicSync() {
    // Sync periodically
    _syncTimer = Timer.periodic(Duration(seconds: 15), (timer) {
      syncAll();
    });
  }

  static Future<Wallet> _getWallet(String fingerprint,
      String externalDescriptor, String internalDescriptor) async {
    int publicKeyIndex = externalDescriptor.indexOf("]") + 1;
    String publicKeyType =
        externalDescriptor.substring(publicKeyIndex, publicKeyIndex + 4);

    Network network;
    if (publicKeyType == "tpub") {
      network = Network.Testnet;
    } else {
      network = Network.Mainnet;
    }

    WalletType type = externalDescriptor.startsWith("wpkh")
        ? WalletType.witnessPublicKeyHash
        : WalletType.taproot;

    Wallet wallet = Wallet(
        fingerprint, network, externalDescriptor, internalDescriptor,
        type: type);

    return wallet;
  }

  static void _initWallet(Wallet wallet) {
    wallet.init(walletsDirectory);
  }

  Future storeAccounts() async {
    String json = jsonEncode(accounts);
    await _ls.prefs.setString(ACCOUNTS_PREFS, json);
  }

  void addAccounts(List<Account> accounts) {
    accounts.forEach((Account account) => addAccount(account));
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
    accounts[accounts.indexOf(oldAccount)] = oldAccount.copyWith(name: newName);

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

  moveAccount(
      int oldIndex, int newIndex, List<Account> accountFromListView) async {
    _accountSchedulerMutex = true;
    //Make a copy of current account set to prevent concurrent modification
    //sync might interfere with reordering so making a copy will prevent moving the same account
    try {
      final visibleAccountsIds = accountFromListView.map((e) => e.id);
      final _accountCopy = [
        ...accounts.where((element) => visibleAccountsIds.contains(element.id))
      ];

      //accounts that are not visible in the list (testnet). the move should not affect them,
      //so they are added to the end of the list
      final _accountsThatNotVisible = [
        ...accounts.where((element) => !visibleAccountsIds.contains(element.id))
      ];
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

      // updated accounts with new order, testnet accounts are added to the end of the list if they are not visible
      accounts = [..._accountCopy, ..._accountsThatNotVisible];
      notifyListeners();
      await storeAccounts();
    } catch (e) {
      print(e);
    } finally {
      _accountSchedulerMutex = false;
    }
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

  bool passportAccountsExist() {
    for (var account in accounts) {
      if (!account.wallet.hot) {
        return true;
      }
    }

    return false;
  }

  bool passportTaprootAccountsExist() {
    for (var account in accounts) {
      if (!account.wallet.hot && account.wallet.type == WalletType.taproot) {
        return true;
      }
    }

    return false;
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

  bool isAccountTestnet(String id) {
    for (var account in accounts) {
      if (account.id == id) {
        if (account.wallet.network == Network.Testnet) return true;
      }
    }
    return false;
  }

  Wallet? getWallet(String accountId) {
    for (var account in accounts) {
      if (account.id == accountId) {
        return account.wallet;
      }
    }
    return null;
  }

  Account? getAccountById(String accountId) {
    for (var account in accounts) {
      if (account.id == accountId) {
        return account;
      }
    }
    return null;
  }
}
