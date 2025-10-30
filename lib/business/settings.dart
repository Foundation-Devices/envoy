// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

// ignore_for_file: constant_identifier_names

import 'dart:math';
import 'package:envoy/account/accounts_manager.dart';
import 'package:envoy/business/connectivity_manager.dart';
import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/business/node_url.dart';
import 'package:envoy/ui/amount_entry.dart';
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

  // FD testnet4 server
  static const String TESTNET4_ONION_ELECTRUM_SERVER =
      "7gohqoo7du3l3p72gld33hd5d6xtciych6plli6fwrixi2tsmyqc33yd.onion:50001";

  // FD signet server
  static const String SIGNET_ONION_ELECTRUM_SERVER =
      "qkpvnm3gn7x7yzxp7pddlcpn5h4tyxve7yx4olvi437fzw4gz3sxbmad.onion:50001";

  static final List<String> defaultServers = getDefaultFulcrumServers();
  static String currentDefaultServer = selectRandomServerFrom(defaultServers);

  static final List<String> defaultTorServers = [
    "mocmguuik7rws4bclpcoz2ldfzesjolatrzggaxfl37hjpreap777yqd.onion:50001",
    "l7wsl4yghqvdgp4ullod67ydb54ttxs3nnvctblbofl7umw6j72e5did.onion:50001",
    "vtdblqfka4iqbvjscagwglbg4wxmc42hvf5i7htr3dipnbqz5eiwqrqd.onion:50001"
  ];
  static String currentDefaultTorServer =
      selectRandomServerFrom(defaultTorServers);

  static String selectRandomServerFrom(List<String> servers) {
    return servers[Random().nextInt(servers.length)];
  }

  void switchToNextDefaultServer() {
    if (usingTor) {
      final currentIndex = defaultTorServers.indexOf(currentDefaultTorServer);
      currentDefaultTorServer =
          defaultTorServers[(currentIndex + 1) % defaultTorServers.length];
    } else {
      final currentIndex = defaultServers.indexOf(currentDefaultServer);
      currentDefaultServer =
          defaultServers[(currentIndex + 1) % defaultServers.length];
    }
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

  void setDisplayUnitSat(bool enable) {
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

  void setDisplayFiat(String? displayFiat) {
    selectedFiat = displayFiat;
    ExchangeRate().setCurrency(selectedFiat);

    notifyListeners();
    store();
  }

  @JsonKey(includeIfNull: false)
  AmountDisplayUnit? sendUnit;

  /// send and staging unit

  void setSendUnit(AmountDisplayUnit unit) {
    sendUnit = unit;
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
        return currentDefaultTorServer;
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

  void setCustomElectrumAddress(String electrumAddress) {
    selectedElectrumAddress = electrumAddress;
    usingDefaultElectrumServer = false;
    store();
  }

  void useDefaultElectrumServer(bool enabled) {
    currentDefaultServer = selectRandomServerFrom(defaultServers);
    usingDefaultElectrumServer = enabled;
    notifyListeners();
    store();
  }

  bool customElectrumEnabled() {
    return !usingDefaultElectrumServer;
  }

  @JsonKey(defaultValue: "")
  String personalElectrumAddress = "";

  String getPersonalElectrumAddress() {
    return personalElectrumAddress;
  }

  void setPersonalElectrumAddress(String address) {
    personalElectrumAddress = address;
    notifyListeners();
    store();
  }

  bool usingTor = false;

  bool torEnabled() {
    return usingTor;
  }

  void setTorEnabled(bool torEnabled) {
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

  void setSyncToCloud(bool syncToCloud) {
    syncToCloudSetting = syncToCloud;
    store();
    notifyListeners();
  }

  @JsonKey(defaultValue: false)
  bool allowScreenshotsSetting = false;

  bool allowScreenshots() {
    return allowScreenshotsSetting;
  }

  void setAllowScreenshots(bool allowScreenshots) {
    allowScreenshotsSetting = allowScreenshots;
    store();
  }

  @JsonKey(defaultValue: false)
  bool showTestnetAccountsSetting = false;

  bool showTestnetAccounts() {
    return showTestnetAccountsSetting;
  }

  void setShowTestnetAccounts(bool showTestnetAccounts) {
    showTestnetAccountsSetting = showTestnetAccounts;
    notifyListeners();
    store();
  }

  @JsonKey(defaultValue: false)
  bool showSignetAccountsSetting = false;

  bool showSignetAccounts() {
    return showSignetAccountsSetting;
  }

  Future<void> setShowSignetAccounts(bool showSignetAccounts) async {
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

  Future<void> setTaprootEnabled(bool taprootEnabled) async {
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

  Future<void> setAllowBuyInEnvoy(bool allowBuy) async {
    allowBuyInEnvoy = allowBuy;

    notifyListeners();
    store();
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  bool nodeChangedInAdvanced = false;
  @JsonKey(includeFromJson: false, includeToJson: false)
  bool torChangedInAdvanced = false;

  // ENV-989: Trigger settings to show all restored accounts.
  void updateAccountsViewSettings() {
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

    //ENV-2474 fix for issue due to new personalElectrumAddress field
    //introduced in 2.1.1, 2.2.0 will be using defaultTorServers array,
    //ENV-2474 only affects 2.1.0 users only
    final mainnetOnionElectrumServer =
        "mocmguuik7rws4bclpcoz2ldfzesjolatrzggaxfl37hjpreap777yqd.onion:50001";
    if (singleton.personalElectrumAddress.isEmpty) {
      final currentNode = singleton.selectedElectrumAddress;
      final isDiyNodes = PublicServer.diyNodes.address == currentNode;
      final isBlockstreamNodes =
          PublicServer.blockstream.address == currentNode;
      final isFoundationNodes = [
            ...getDefaultFulcrumServers(),
            getDefaultFulcrumServers(ssl: true)
          ].contains(currentNode) ||
          currentNode == mainnetOnionElectrumServer;

      if (!isDiyNodes && !isBlockstreamNodes && !isFoundationNodes) {
        singleton.personalElectrumAddress = currentNode;
        singleton.usingDefaultElectrumServer = false;
        await singleton.store();
      }
    }
    //if the personalElectrumAddress is set to default onion server,
    //this is probably due to 2.1.0 bug, so reset it to selectedElectrumAddress
    else if (singleton.personalElectrumAddress == mainnetOnionElectrumServer) {
      if (singleton.selectedElectrumAddress != mainnetOnionElectrumServer) {
        singleton.personalElectrumAddress = singleton.selectedElectrumAddress;
        singleton.usingDefaultElectrumServer = false;
        await singleton.store();
      }
    }

    // ENV-2224
    // Normalize default Electrum server: if current is not one of our defaults, pick a fresh one.
    if (singleton.usingDefaultElectrumServer) {
      final current = singleton.selectedElectrumAddress;

      // All current clearnet defaults (both tcp and ssl, though we prefer ssl when selecting)
      final allowedDefaults = <String>{
        ...getDefaultFulcrumServers(ssl: true),
        ...getDefaultFulcrumServers(ssl: false),
      };

      if (!allowedDefaults.contains(current)) {
        final newDefault =
            selectRandomServerFrom(getDefaultFulcrumServers(ssl: true));
        currentDefaultServer = newDefault; // update static default
        singleton.selectedElectrumAddress =
            newDefault; // persist chosen default
        await singleton.store();
      }
    }

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

  static Future<void> restore({bool fromBackup = false}) async {
    if (ls.prefs.containsKey(SETTINGS_PREFS)) {
      var json = jsonDecode(ls.prefs.getString(SETTINGS_PREFS)!);

      if (fromBackup) {
        if (Settings().nodeChangedInAdvanced ||
            Settings().torChangedInAdvanced) {
          json["usingTor"] = Settings().usingTor;
          json["usingDefaultElectrumServer"] =
              Settings().usingDefaultElectrumServer;
          json["selectedElectrumAddress"] = Settings().selectedElectrumAddress;
          json["personalElectrumAddress"] = Settings().personalElectrumAddress;
        }
      }
      Settings.fromJson(json);
    }

    await Settings.init();
  }

  Future store() async {
    String json = jsonEncode(this);
    await ls.prefs.setString(SETTINGS_PREFS, json);
  }

// Generated
  factory Settings.fromJson(Map<String, dynamic> json) =>
      _$SettingsFromJson(json);

  Map<String, dynamic> toJson() => _$SettingsToJson(this);
}
