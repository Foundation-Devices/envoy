// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'package:envoy/business/feed_manager.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/console.dart';
import 'package:http_tor/http_tor.dart';
import 'package:tor/tor.dart';
import 'package:envoy/business/settings.dart';

enum ConnectivityManagerEvent {
  torStatusChange,
  torConnectedDoesntWork,
  electrumUnreachable,
  electrumReachable,
  foundationServerDown,
}

const Duration _tempDisablementTimeout = Duration(hours: 24);

class ConnectivityManager {
  bool get torEnabled {
    if (torTemporarilyDisabled) {
      return false;
    }

    return Tor.instance.enabled;
  }

  bool get torCircuitEstablished => Tor.instance.bootstrapped;

  bool get usingDefaultServer => s.usingDefaultElectrumServer;

  var s = Settings();
  int failedFoundationServerAttempts = 0;

  bool electrumConnected = true;
  bool nguConnected = false;

  DateTime? torTemporarilyDisabledTimeStamp;

  final StreamController<ConnectivityManagerEvent> events =
      StreamController.broadcast();

  static final ConnectivityManager _instance = ConnectivityManager._internal();

  //Checks if the timeout has expired and if so, resets the temporary disablement
  bool get torTemporarilyDisabled {
    if (torTemporarilyDisabledTimeStamp != null &&
        torTemporarilyDisabledTimeStamp!.isAfter(DateTime.now())) {
      return true;
    }
    torTemporarilyDisabledTimeStamp = null;
    return false;
  }

  set torTemporarilyDisabled(bool value) {
    torTemporarilyDisabledTimeStamp =
        value ? DateTime.now().add(_tempDisablementTimeout) : null;
  }

  factory ConnectivityManager() {
    return _instance;
  }

  static Future<ConnectivityManager> init() async {
    var singleton = ConnectivityManager._instance;
    return singleton;
  }

  ConnectivityManager._internal() {
    kPrint("Instance of ConnectivityManager created!");

    Tor.instance.events.stream.listen((event) {
      // Nudge listeners
      events.add(ConnectivityManagerEvent.torStatusChange);
    });
  }

  void dispose() {
    events.close();
  }

  electrumSuccess() {
    failedFoundationServerAttempts = 0;
    electrumConnected = true;
    events.add(ConnectivityManagerEvent.electrumReachable);
    checkTor();
  }

  electrumFailure() {
    electrumConnected = false;
    events.add(ConnectivityManagerEvent.electrumUnreachable);
    checkTor();
    checkFoundationServer();
  }

  nguSuccess() {
    nguConnected = true;
    checkTor();
  }

  nguFailure() {
    nguConnected = false;
    checkTor();
  }

  void checkTor() {
    if (torEnabled && !nguConnected && !electrumConnected) {
      restartTor();
      EnvoyReport().log("tor", "Both Electrum and NGU unreachable through Tor");
      events.add(ConnectivityManagerEvent.torConnectedDoesntWork);
    }
  }

  Future<void> checkFoundationServer() async {
    if (usingDefaultServer) {
      Response response = await FeedManager().getVimeoData();
      if (response.code == 200) {
        failedFoundationServerAttempts++;
        if (failedFoundationServerAttempts >= 3) {
          events.add(ConnectivityManagerEvent.foundationServerDown);
        } else {
          s.switchToNextDefaultServer();
        }
      }
    }
  }

  restartTor() {
    // ENV-175
    if (torEnabled) {
      Tor.instance.start();
    }
  }
}
