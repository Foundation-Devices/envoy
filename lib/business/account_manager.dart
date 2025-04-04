// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:envoy/business/account.dart';
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
import 'package:envoy/util/console.dart';
import 'package:envoy/util/xfp_endian.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:ngwallet/src/exceptions.dart';
import 'package:ngwallet/src/wallet.dart';
import 'package:envoy/business/bip329.dart';

class AccountAlreadyPaired implements Exception {}

class AccountManager extends ChangeNotifier {
  @override
  // ignore: must_call_super
  void dispose({bool? force}) {
    // prevents riverpods StateNotifierProvider from disposing it
    if (force == true) {
      super.dispose();
    }
  }

  List<Account> accounts = [];
  final LocalStorage _ls = LocalStorage();
  var s = Settings();

  Timer? _syncTimer;
  bool _syncBlocked = false;

  // prevents concurrent modification of accounts list, when moving accounts
  bool _accountSchedulerMutex = false;

  final _syncScheduler = EnvoyScheduler().parallel;

  static const String ACCOUNTS_PREFS = "accounts";
  static final AccountManager _instance = AccountManager._internal();
  static String walletsDirectory =
      "${LocalStorage().appDocumentsDir.path}/wallets/";

  factory AccountManager() {
    return _instance;
  }

  static Future<AccountManager> init() async {
    var singleton = AccountManager._instance;
    return singleton;
  }

  AccountManager._internal() {
    kPrint("Instance of AccountManager created!");
    restore();
  }

  void syncAll() {
    if (!_syncBlocked) {
      _syncBlocked = true;

      // Rate limit syncs
      Timer(const Duration(seconds: 5), () {
        _syncBlocked = false;
      });

      if (!ConnectivityManager().torEnabled ||
          ConnectivityManager().torCircuitEstablished) {
        accounts.where((account) {
          if (!Settings().showTestnetAccounts() &&
              account.wallet.network == Network.Testnet) {
            return false;
          }

          if (!Settings().showSignetAccounts() &&
              account.wallet.network == Network.Signet) {
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
      StreamController.broadcast();

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

  Future<Account> _syncAccount(Account account) async {
    bool? changed;
    int port = Settings().getPort(account.wallet.network);
    String server;
    String network = account.wallet.network.toString();

    switch (account.wallet.network) {
      case Network.Mainnet:
        if (s.customElectrumEnabled()) {
          server = Settings().selectedElectrumAddress.toString();
        } else {
          server = Settings.currentDefaultServer;
        }
        break;
      case Network.Testnet:
        server = Settings.TESTNET_ELECTRUM_SERVER;
        break;
      case Network.Signet:
        server = Settings.MUTINYNET_ELECTRUM_SERVER;
        break;
      default:
        server = "Unknown server";
        break;
    }

    try {
      changed = await account.wallet
          .sync(Settings().electrumAddress(account.wallet.network), port);
    } on Exception catch (e) {
      // Let ConnectivityManager know that we can't reach Electrum
      if (account.wallet.network == Network.Mainnet) {
        ConnectivityManager().electrumFailure();
      }

      EnvoyReport().log("wallet", "Couldn't sync: $e to: $network ($server)");
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

      final firstTimeSync = account.dateSynced == null;

      // This does away with amounts "ghosting" in UI
      account = account.copyWith(dateSynced: DateTime.now());

      if (changed || firstTimeSync) {
        notifyListeners();
      }
    }

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
      {String? passphrase,
      WalletType type = WalletType.witnessPublicKeyHash,
      Network? network}) {
    try {
      var wallet = Wallet.deriveWallet(
          seed,
          EnvoySeed
              .hotWalletDerivationPaths[type]![network ?? Network.Mainnet]!,
          AccountManager.walletsDirectory,
          network ?? Network.Mainnet,
          privateKey: true,
          passphrase: passphrase,
          initWallet: false,
          type: type);
      for (final account in accounts) {
        if (account.wallet.externalDescriptor == wallet.externalDescriptor) {
          return true;
        }
      }
    } on InvalidMnemonic {
      return false;
    }

    return false;
  }

// Processes binary data to add Passport accounts, ensuring address verification
  Future<Account?> processPassportAccounts(Binary binary) async {
    // Extract JSON string from the binary data
    var jsonIndex = binary.decoded.indexOf("{");
    var decoded = binary.decoded.substring(jsonIndex);
    var json = jsonDecode(decoded);

    // Determine if the JSON follows the old format
    bool oldJsonFormat = json['xpub'] != null;

    if (oldJsonFormat) {
      // Handle old format with a single WPKH account
      Account newAccount = await getPassportAccountJson(json);
      return newAccount;
    } else {
      // Handle new format that supports multiple accounts
      List<Account> newAccounts = await getPassportAccountsFromJson(json);
      int alreadyPairedAccountsCount = 0;

      // Loop through the new accounts and check for duplicates
      newAccountsLoop:
      for (var entry in newAccounts.asMap().entries) {
        var index = entry.key;
        var newAccount = entry.value;

        for (var account in accounts) {
          // Check if the account is already paired
          if (account.wallet.name == newAccount.wallet.name) {
            // Rename the existing account if the names differ
            if (account.name != newAccount.name) {
              renameAccount(account, newAccount.name);
              return account;
            }
            // Skip adding this account as it already exists
            alreadyPairedAccountsCount++;

            // Add the existing account to the list for address verification
            newAccounts[index] = account;
            continue newAccountsLoop;
          }
        }

        // Initialize the wallet and add the new account
        _initWallet(newAccount.wallet);
        addAccount(newAccount);
      }

      // If all accounts are already paired, throw an error
      if (newAccounts.length == alreadyPairedAccountsCount) {
        throw AccountAlreadyPaired();
      } else {
        // Return the first WPKH account for address verification
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
    for (var wallet in wallets) {
      accounts.add(Account(
          wallet: wallet,
          name: json["acct_name"] + " (#${accountNumber.toString()})",
          deviceSerial: device.serial,
          dateAdded: DateTime.now(),
          number: accountNumber,
          id: Account.generateNewId(),
          dateSynced: null));
    }

    return accounts;
  }

  Future<Account> getPassportAccountJson(dynamic json) async {
    // Check if account already present
    for (var account in accounts) {
      if (account.wallet.name == json["xpub"].toString()) {
        if (account.name != json["acct_name"].toString()) {
          renameAccount(account, json["acct_name"].toString());
          return account;
        }
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
        name: json["acct_name"] + " (#${accountNumber.toString()})",
        deviceSerial: device.serial,
        dateAdded: DateTime.now(),
        number: accountNumber,
        id: Account.generateNewId(),
        dateSynced: null);

    addAccount(account);
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

    var externalDescriptor = "$partialDescriptor/0/*)";
    var internalDescriptor = "$partialDescriptor/1/*)";

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
        try {
          // restoredAccount.wallet.init(walletsDirectory);
        } on Exception catch (e) {
          EnvoyReport().log("recovery", e.toString());
        }
      }
    }

    _startPeriodicSync();
  }

  _startPeriodicSync() {
    // // Sync periodically
    // _syncTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
    //   syncAll();
    // });
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
    for (var account in accounts) {
      addAccount(account);
    }
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
      final accountCopy = [
        ...accounts.where((element) => visibleAccountsIds.contains(element.id))
      ];

      //accounts that are not visible in the list (testnet). the move should not affect them,
      //so they are added to the end of the list
      final accountsThatNotVisible = [
        ...accounts.where((element) => !visibleAccountsIds.contains(element.id))
      ];
      //moving down, the list is shifted so the index is off by one
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      try {
        //Check if the items are not the same to prevent unnecessary duplication
        if (accountCopy[newIndex].id == accountCopy[oldIndex].id) {
          return;
        }
      } catch (_) {}
      var movedAccount = accountCopy.removeAt(oldIndex);
      accountCopy.insert(newIndex, movedAccount);

      // updated accounts with new order, testnet accounts are added to the end of the list if they are not visible
      accounts = [...accountCopy, ...accountsThatNotVisible];
      notifyListeners();
      await storeAccounts();
    } catch (e) {
      kPrint(e);
    } finally {
      _accountSchedulerMutex = false;
    }
  }

  // There is only one hot wallet for now (mainnet/testnet/signet triplet)
  Account? getHotWalletAccount({network = Network.Mainnet}) {
    for (var account in accounts) {
      if (account.wallet.hot && account.wallet.network == network) {
        return account;
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

  bool hotAccountsExist({WalletType type = WalletType.witnessPublicKeyHash}) {
    for (var account in accounts) {
      if (account.wallet.hot && account.wallet.type == type) {
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

  bool hotSignetAccountExist() {
    for (var account in accounts) {
      if (account.wallet.hot && account.wallet.network == Network.Signet) {
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

  Transaction? getTransactionById(Account account, String txId) {
    for (var transaction in account.wallet.transactions) {
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

  Future<void> exportBIP329() async {
    List<String> allData = [];

    for (Account account in accounts) {
      Wallet wallet = account.wallet;

      // Get xpub and create JSON data
      String xpub = getXpub(wallet);
      String xpubData = buildKeyJson("xpub", xpub, account.name);
      allData.add(xpubData);

      // Get output data and add each entry to allData
      List<String> outputData = await getUtxosData(account);
      allData.addAll(outputData);

      // Get transaction data and add each entry to allData
      List<String> txData = await getTxData(wallet);
      allData.addAll(txData);
    }

    // Join each JSON string with a newline character
    String fileContent = allData.join('\n');
    Uint8List fileContentBytes = Uint8List.fromList(utf8.encode(fileContent));

    // Save the file
    await FileSaver.instance.saveAs(
        mimeType: MimeType.json,
        name: 'bip329_export',
        bytes: fileContentBytes,
        ext: 'json');
  }
}
