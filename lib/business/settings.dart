// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

// ignore_for_file: constant_identifier_names

import 'dart:math';
import 'package:envoy/business/account_manager.dart';
import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/business/node_url.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:envoy/business/local_storage.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:tor/tor.dart';
import 'package:wallet/wallet.dart';

// Generated
part 'settings.g.dart';

LocalStorage ls = LocalStorage();

enum Environment { local, development, staging, production }

enum DisplayUnit { btc, sat }

final settingsProvider = ChangeNotifierProvider((ref) => Settings());

final showTestnetAccountsProvider = Provider((ref) {
  return ref.watch(settingsProvider).showTestnetAccounts();
});

final showSignetAccountsProvider = Provider((ref) {
  return ref.watch(settingsProvider).showSignetAccounts();
});

final torEnabledProvider = StateProvider<bool>((ref) => Settings().usingTor);

final showTaprootAccountsProvider = Provider((ref) {
  return ref.watch(settingsProvider).taprootEnabled();
});

@JsonSerializable()
class Settings extends ChangeNotifier {
  static const String SETTINGS_PREFS = "settings";

  static final List<String> defaultServers = getDefaultFulcrumServers();
  static String currentDefaultServer = selectRandomDefaultServer();

  static String selectRandomDefaultServer() {
    return defaultServers[Random().nextInt(defaultServers.length)];
  }

  void switchToNextDefaultServer() {
    final currentIndex = defaultServers.indexOf(currentDefaultServer);
    currentDefaultServer =
        defaultServers[(currentIndex + 1) % defaultServers.length];
    store();
    notifyListeners();
  }

  static List<String> getDefaultFulcrumServers({bool ssl = true}) {
    List<String> servers = [
      "mainnet-0.foundation.xyz",
      "mainnet-1.foundation.xyz",
      "mainnet-2.foundation.xyz"
    ];

    String protocol = ssl ? "ssl://" : "tcp://";
    String port = ssl ? ":50002" : ":50001";

    List<String> fullPaths = [];

    for (String server in servers) {
      String modifiedServer = protocol + server + port;
      fullPaths.add(modifiedServer);
    }

    return fullPaths;
  }

  // FD testnet server
  static const String TESTNET_ELECTRUM_SERVER =
      "ssl://testnet.foundation.xyz:50002";

  // MutinyNet Esplora
  static const String MUTINYNET_ESPLORA_SERVER = "https://mutinynet.com/api";

  DisplayUnit displayUnit = DisplayUnit.btc;

  bool displayUnitSat() {
    return displayUnit == DisplayUnit.sat;
  }

  setDisplayUnitSat(bool enable) {
    if (enable) {
      displayUnit = DisplayUnit.sat;
    } else {
      displayUnit = DisplayUnit.btc;
    }
    notifyListeners();
    store();
  }

  String? selectedFiat;

  String? displayFiat() => selectedFiat;

  setDisplayFiat(String? displayFiat) {
    selectedFiat = displayFiat;
    ExchangeRate().setCurrency(selectedFiat);

    notifyListeners();
    store();
  }

  Environment environment = Environment.production;

  // Electrum and Tor require additional setter logic
  // Because at this point wallets on the Rust side are most likely already initialised
  //String _electrumAddress = "ssl://electrum.blockstream.info:60002";
  String selectedElectrumAddress =
      currentDefaultServer; //servers[initialRandomIndex];

  @JsonKey(defaultValue: true)
  bool usingDefaultElectrumServer = true;

  String electrumAddress(Network network) {
    if (network == Network.Testnet) {
      return TESTNET_ELECTRUM_SERVER;
    }

    if (network == Network.Signet) {
      return MUTINYNET_ESPLORA_SERVER;
    }

    if (usingDefaultElectrumServer) {
      return currentDefaultServer;
    } else {
      return parseNodeUrl(selectedElectrumAddress);
    }
  }

  String customElectrumAddress() {
    return selectedElectrumAddress;
  }

  setCustomElectrumAddress(String electrumAddress) {
    selectedElectrumAddress = electrumAddress;
    usingDefaultElectrumServer = false;
    store();
  }

  useDefaultElectrumServer(bool enabled) {
    currentDefaultServer = selectRandomDefaultServer();
    usingDefaultElectrumServer = enabled;
    notifyListeners();
    store();
  }

  bool customElectrumEnabled() {
    return !usingDefaultElectrumServer;
  }

  bool usingTor = true;

  bool torEnabled() {
    return usingTor;
  }

  setTorEnabled(bool torEnabled) {
    usingTor = torEnabled;
    if (torEnabled) {
      Tor.instance.enable();
    } else {
      Tor.instance.disable();
    }

    store();
  }

  bool turnOffTorForThisCase(String address) {
    return !torEnabled() || isPrivateAddress(address);
  }

  int getPort(Network network) {
    return turnOffTorForThisCase(electrumAddress(network))
        ? -1
        : Tor.instance.port;
  }

  String get envoyServerAddress {
    switch (environment) {
      case Environment.local:
        return "http://127.0.0.1:8000";
      case Environment.development:
        return "https://development.envoy.foundation.xyz";
      case Environment.staging:
        return "https://staging.envoy.foundation.xyz";
      case Environment.production:
        return "https://envoy.foundation.xyz";
    }
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  String nguServerAddress = "https://ngu.foundation.xyz";

  @JsonKey(defaultValue: false)
  bool syncToCloudSetting = false;

  @JsonKey(includeFromJson: false, includeToJson: false)
  bool get syncToCloud => syncToCloudSetting;

  set syncToCloud(bool syncToCloud) {
    syncToCloudSetting = syncToCloud;
  }

  @JsonKey(defaultValue: false)
  bool allowScreenshotsSetting = false;

  bool allowScreenshots() {
    return allowScreenshotsSetting;
  }

  setAllowScreenshots(bool allowScreenshots) {
    allowScreenshotsSetting = allowScreenshots;
    store();
  }

  @JsonKey(defaultValue: false)
  bool showTestnetAccountsSetting = false;

  bool showTestnetAccounts() {
    return showTestnetAccountsSetting;
  }

  setShowTestnetAccounts(bool showTestnetAccounts) {
    showTestnetAccountsSetting = showTestnetAccounts;
    notifyListeners();
    store();
  }

  @JsonKey(defaultValue: false)
  bool showSignetAccountsSetting = false;

  bool showSignetAccounts() {
    return showSignetAccountsSetting;
  }

  setShowSignetAccounts(bool showSignetAccounts) async {
    showSignetAccountsSetting = showSignetAccounts;

    // if a other hot wallet exists and no signet then add one
    if (showSignetAccounts &&
        AccountManager().hotAccountsExist() &&
        !AccountManager().hotSignetAccountExist()) {
      await EnvoySeed()
          .deriveAndAddWalletsFromCurrentSeed(network: Network.Signet);
    }

    notifyListeners();
    store();
  }

  @JsonKey(defaultValue: false)
  bool enableTaprootSetting = false;

  bool taprootEnabled() {
    return enableTaprootSetting;
  }

  setTaprootEnabled(bool taprootEnabled) async {
    enableTaprootSetting = taprootEnabled;

    // If wpkh is derived but no taproot then do it
    if (taprootEnabled &&
        EnvoySeed().walletDerived(type: WalletType.witnessPublicKeyHash) &&
        !EnvoySeed().walletDerived(type: WalletType.taproot)) {
      await EnvoySeed()
          .deriveAndAddWalletsFromCurrentSeed(type: WalletType.taproot);
    }

    notifyListeners();
    store();
  }

  static final Settings _instance = Settings._internal();

  factory Settings() {
    return _instance;
  }

  static Future<Settings> init() async {
    var singleton = Settings._instance;

    return singleton;
  }

  Settings._internal() {
    kPrint("Instance of Settings created!");
  }

  static String getFiatFromLocale() {
    String? currencyCode =
        NumberFormat.simpleCurrency(locale: Intl.getCurrentLocale())
            .currencyName;
    if (currencyCode == null) {
      return "USD";
    }

    if (supportedFiat.contains(FiatCurrency(currencyCode, ""))) {
      return currencyCode;
    }

    return "USD";
  }

  static restore({bool fromBackup = false}) {
    if (ls.prefs.containsKey(SETTINGS_PREFS)) {
      var json = jsonDecode(ls.prefs.getString(SETTINGS_PREFS)!);
      if (fromBackup) {
        json["usingTor"] = Settings().usingTor;
      }
      Settings.fromJson(json);
    }
    Settings.init();
  }

  store() {
    String json = jsonEncode(this);
    ls.prefs.setString(SETTINGS_PREFS, json);
  }

// Generated
  factory Settings.fromJson(Map<String, dynamic> json) =>
      _$SettingsFromJson(json);

  Map<String, dynamic> toJson() => _$SettingsToJson(this);
}
