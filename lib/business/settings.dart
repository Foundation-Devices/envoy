// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

// ignore_for_file: constant_identifier_names

import 'dart:math';
import 'package:envoy/account/accounts_manager.dart';
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
import 'package:ngwallet/ngwallet.dart';

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

final allowBuyInEnvoyProvider = Provider((ref) {
  return ref.watch(settingsProvider).isAllowedBuyInEnvoy();
});

@JsonSerializable()
class Settings extends ChangeNotifier {
  @override
  // ignore: must_call_super
  void dispose({bool? force}) {
    // prevents riverpods StateNotifierProvider from disposing it
    if (force == true) {
      super.dispose();
    }
  }

  static const String SETTINGS_PREFS = "settings";

  static const String MAINNET_ONION_ELECTRUM_SERVER =
      "mocmguuik7rws4bclpcoz2ldfzesjolatrzggaxfl37hjpreap777yqd.onion:50001";

  // FD testnet4 server
  static const String TESTNET4_ONION_ELECTRUM_SERVER =
      "7gohqoo7du3l3p72gld33hd5d6xtciych6plli6fwrixi2tsmyqc33yd.onion:50001";

  // FD signet server
  static const String SIGNET_ONION_ELECTRUM_SERVER =
      "qkpvnm3gn7x7yzxp7pddlcpn5h4tyxve7yx4olvi437fzw4gz3sxbmad.onion:50001";

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
  // FD testnet4 server

  static const String TESTNET4_ELECTRUM_SERVER =
      "ssl://testnet4.foundation.xyz:50002";

  // MutinyNet Electrum
  static const String SIGNET_ELECTRUM_SERVER =
      "ssl://signet.foundation.xyz:50002";

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
    if (network == Network.testnet || network == Network.testnet4) {
      if (usingTor) {
        return TESTNET4_ONION_ELECTRUM_SERVER;
      } else {
        return TESTNET4_ELECTRUM_SERVER;
      }
    }

    if (network == Network.signet) {
      if (usingTor) {
        return SIGNET_ONION_ELECTRUM_SERVER;
      }
      return SIGNET_ELECTRUM_SERVER;
    }

    if (usingDefaultElectrumServer) {
      if (usingTor) {
        return MAINNET_ONION_ELECTRUM_SERVER;
      } else {
        return currentDefaultServer;
      }
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

  bool usingTor = false;

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

  bool onTorWhitelist(String address) {
    return !torEnabled() || isPrivateAddress(address);
  }

  int? getTorPort(Network network, String server) {
    int? port =
        onTorWhitelist(electrumAddress(network)) ? -1 : Tor.instance.port;
    if (port == -1) {
      port = null;
    }
    if (isPrivateAddress(server)) {
      port = null;
    }
    return port;
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

  @JsonKey(defaultValue: true)
  bool syncToCloudSetting = true;

  @JsonKey(includeFromJson: false, includeToJson: false)
  bool get syncToCloud => syncToCloudSetting;

  set syncToCloud(bool syncToCloud) {
    syncToCloudSetting = syncToCloud;
  }

  setSyncToCloud(bool syncToCloud) {
    syncToCloudSetting = syncToCloud;
    store();
    notifyListeners();
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
        NgAccountManager().hotAccountsExist() &&
        !NgAccountManager().hotSignetAccountExist()) {
      await EnvoySeed()
          .deriveAndAddWalletsFromCurrentSeed(network: Network.signet);
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
    //TODO: add taproot derive on ngwallet
    // if (taprootEnabled &&
    //     EnvoySeed().walletDerived(type: WalletType.witnessPublicKeyHash) &&
    //     !EnvoySeed().walletDerived(type: WalletType.taproot)) {
    //   await EnvoySeed()
    //       .deriveAndAddWalletsFromCurrentSeed(type: WalletType.taproot);
    // }
    NgAccountManager().setTaprootEnabled(taprootEnabled);

    notifyListeners();
    store();
  }

  @JsonKey(defaultValue: true)
  bool allowBuyInEnvoy = true;

  bool isAllowedBuyInEnvoy() {
    return allowBuyInEnvoy;
  }

  setAllowBuyInEnvoy(bool allowBuy) async {
    allowBuyInEnvoy = allowBuy;

    notifyListeners();
    store();
  }

  // ENV-989: Trigger settings to show all restored accounts.
  updateAccountsViewSettings() {
    setShowTestnetAccounts(showTestnetAccountsSetting);
    setTaprootEnabled(enableTaprootSetting);
    setShowSignetAccounts(showSignetAccountsSetting);
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

    if (ExchangeRate().supportedFiat.contains(
        FiatCurrency(code: currencyCode, title: "", flag: "", symbol: ""))) {
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
