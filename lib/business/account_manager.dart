// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:envoy/business/uniform_resource.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/util/xfp_endian.dart';
import 'package:envoy/business/settings.dart';
import 'package:tor/tor.dart';
import 'package:wallet/wallet.dart';
import 'package:envoy/business/local_storage.dart';
import 'package:envoy/business/account.dart';
import 'package:bip32/bip32.dart';
import 'package:flutter/material.dart';
import 'package:envoy/business/devices.dart';
import 'package:envoy/business/fees.dart';
import 'package:envoy/business/notifications.dart';
import 'package:envoy/business/connectivity_manager.dart';

import 'envoy_seed.dart';

class AccountAlreadyPaired implements Exception {}

class AccountManager extends ChangeNotifier {
  List<Account> accounts = [];
  LocalStorage _ls = LocalStorage();

  Timer? _syncTimer;
  bool _syncBlocked = false;

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
    _restoreAccounts();
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
        for (Account account in accounts) {
          account.wallet
              .sync(Settings().electrumAddress(account.wallet.network),
                  Tor().port)
              .then((changed) {
            if (changed != null) {
              // Let ConnectivityManager know that we've synced
              if (account.wallet.network == Network.Mainnet) {
                ConnectivityManager().electrumSuccess();
              }

              // This does away with amounts "ghosting" in UI
              if (account.initialSyncCompleted == false) {
                account.initialSyncCompleted = true;
                notifyListeners();
              }

              // Update the Fees singleton
              Fees().electrumFastRate = account.wallet.feeRateFast;
              Fees().electrumSlowRate = account.wallet.feeRateSlow;

              // Notify UI if txs or balance changed
              if (changed) {
                notifyListeners();
              }

              storeAccounts();
            }
          }, onError: (_) {
            // Let ConnectivityManager know that we can't reach Electrum
            if (account.wallet.network == Network.Mainnet) {
              ConnectivityManager().electrumFailure();
            }
          });
        }
      }
    }
  }

  Future<Account?> addHotWalletAccount(Wallet wallet) async {
    // TODO: look & feel of hot wallet accounts
    Account account = Account(
        wallet,
        "Hot Wallet",
        "envoy", // Device code for wallets derived on phone
        DateTime.now(),
        0);

    addAccount(account);
    return account;
  }

  Future<Account?> addEnvoyAccount(CryptoRequest request) async {
    var hdkey = (request).objects[0] as CryptoHdKey;

    // Check if account already present
    for (var account in accounts) {
      if (account.wallet.name == hdkey.parentFingerprint.toString()) {
        return null;
      }
    }

    var bip = BIP32.fromPublicKey(
        Uint8List.fromList(hdkey.keyData!),
        Uint8List.fromList(hdkey.chainCode!),
        NetworkType(
            wif: 0x80,
            bip32: new Bip32Type(public: 0x043587CF, private: 0x04358394)));
    var base58 = bip.toBase58();

    var externalDescriptor = "wpkh([" +
        hdkey.parentFingerprint!.toRadixString(16) +
        hdkey.path +
        "]" +
        base58 +
        "/0/*)";

    var wallet = await _initWallet(hdkey.parentFingerprint.toString(),
        externalDescriptor, externalDescriptor);

    // Add a device
    //var model = (request).objects[1] as PassportModel;
    var fw = (request).objects[2] as PassportFirmwareVersion;
    var serial = (request).objects[3] as PassportSerial;

    // Pick colours
    int colorIndex =
        Devices().devices.length % (EnvoyColors.listTileColorPairs.length);

    // TODO: stop the gen1.2 hardcoding, agree with Ken on model numbers
    Device device = Device(
        "Passport",
        DeviceType.passportGen12,
        serial.serial,
        DateTime.now(),
        fw.version,
        EnvoyColors.listTileColorPairs[colorIndex].darker);

    // TODO: we should decouple device pairing
    Devices().add(device);

    // Create an account & store
    colorIndex = accounts.length % (EnvoyColors.listTileColorPairs.length);
    Account account = Account(
        wallet,
        "Account " + (accounts.length + 1).toString(),
        device.serial,
        DateTime.now(),
        0);

    addAccount(account);
    return account;
  }

  Future<Account?> addEnvoyBetaAccount(Binary binary) async {
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
        wallet,
        json["acct_name"] + " (#" + accountNumber.toString() + ")",
        device.serial,
        DateTime.now(),
        accountNumber);

    addAccount(account);
    return account;
  }

  _dropAccounts() {
    for (Account account in accounts) {
      account.wallet.drop();
    }

    accounts.clear();
  }

  _restoreAccounts() {
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
    account.name = newName;
    storeAccounts();
    notifyListeners();
  }

  deleteAccount(Account account) {
    account.wallet.drop();

    // Delete the BDK DB so it doesn't get confused on re-pair
    final dir = Directory(walletsDirectory + account.wallet.name);
    dir.delete(recursive: true);

    accounts.remove(account);
    storeAccounts();
    notifyListeners();

    Notifications().deleteFromAccount(account);
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

  moveAccount(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) {
      return;
    }

    var movedAccount = accounts[oldIndex];
    accounts.remove(movedAccount);
    accounts.insert(newIndex, movedAccount);
    storeAccounts();
  }
}
