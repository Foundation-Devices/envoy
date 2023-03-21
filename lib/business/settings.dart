// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/business/node_url.dart';
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

@JsonSerializable()
class Settings extends ChangeNotifier {
  static const String SETTINGS_PREFS = "settings";
  static const String DEFAULT_ELECTRUM_SERVER =
      "ssl://mainnet.foundationdevices.com:50002";

  // FD testnet server
  static const String TESTNET_ELECTRUM_SERVER =
      "tcp://testnet.foundationdevices.com:50001";

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
  }

  String? selectedFiat;

  String? displayFiat() => selectedFiat;

  setDisplayFiat(String? displayFiat) {
    selectedFiat = displayFiat;

    if (selectedFiat != null) {
      ExchangeRate().setCurrency(selectedFiat!);
    }

    notifyListeners();
  }

  Environment environment = Environment.production;

  // Electrum and Tor require additional setter logic
  // Because at this point wallets on the Rust side are most likely already initialised
  //String _electrumAddress = "ssl://electrum.blockstream.info:60002";
  String selectedElectrumAddress = DEFAULT_ELECTRUM_SERVER;

  @JsonKey(defaultValue: true)
  bool usingDefaultElectrumServer = true;

  String electrumAddress(Network network) {
    if (network == Network.Testnet) {
      return TESTNET_ELECTRUM_SERVER;
    }

    if (usingDefaultElectrumServer) {
      return DEFAULT_ELECTRUM_SERVER;
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
  }

  useDefaultElectrumServer(bool enabled) {
    usingDefaultElectrumServer = enabled;
    notifyListeners();
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
      Tor().enable();
    } else {
      Tor().disable();
    }

    store();
  }

  String get envoyServerAddress {
    switch (environment) {
      case Environment.local:
        return "http://127.0.0.1:8000";
      case Environment.development:
        return "https://development.envoy.foundationdevices.com";
      case Environment.staging:
        return "https://staging.envoy.foundationdevices.com";
      case Environment.production:
        return "https://production.envoy.foundationdevices.com";
    }
  }

  String nguServerAddress = "https://ngu.foundationdevices.com";

  @JsonKey(defaultValue: false)
  bool syncToCloudSetting = false;

  @JsonKey(includeFromJson: false, includeToJson: false)
  bool get syncToCloud => syncToCloudSetting;

  set syncToCloud(bool syncToCloud) {
    syncToCloudSetting = syncToCloud;
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
    print("Instance of Settings created!");
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

  static restore() {
    if (ls.prefs.containsKey(SETTINGS_PREFS)) {
      var json = jsonDecode(ls.prefs.getString(SETTINGS_PREFS)!);
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
