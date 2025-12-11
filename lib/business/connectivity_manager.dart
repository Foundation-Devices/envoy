// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'package:collection/collection.dart';
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
  nguStatusChanged,
}

enum PublicServer {
  blockstream("Blockstream", "ssl://blockstream.info:700"),
  diyNodes("DIYnodes", "ssl://electrum.diynodes.com:50022");

  final String label;
  final String address;

  const PublicServer(this.label, this.address);

  static PublicServer? fromAddress(String address) {
    return PublicServer.values
        .firstWhereOrNull((server) => server.address == address);
  }
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

  // Number of failed attempts before restarting Tor
  final maxFailedTorAttempts = 5;

  bool electrumConnected = true;
  bool nguConnected = true;
  int failedTorConnectivityAttempts = 0;

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

  void electrumSuccess() {
    failedFoundationServerAttempts = 0;
    electrumConnected = true;
    events.add(ConnectivityManagerEvent.electrumReachable);
    checkTor();
  }

  void electrumFailure() {
    electrumConnected = false;
    events.add(ConnectivityManagerEvent.electrumUnreachable);
    checkTor();
    checkFoundationServer();
  }

  void nguSuccess() {
    nguConnected = true;
    events.add(ConnectivityManagerEvent.nguStatusChanged);
    checkTor();
  }

  void nguFailure() {
    nguConnected = false;
    events.add(ConnectivityManagerEvent.nguStatusChanged);
    checkTor();
  }

  void checkTor() async {
    //if tor is enabled, but both electrum and ngu are unreachable, restart tor
    if (torEnabled && (!nguConnected && !electrumConnected)) {
      // tor can be flaky, so only restart after several failed attempts,
      // in this case after 5 failed network checks
      failedTorConnectivityAttempts++;

      await restartTor();

      EnvoyReport().log("tor",
          "Unreachable via Tor -> NGU: ${nguConnected ? 'ok' : 'fail'}, Electrum: ${electrumConnected ? 'ok' : 'fail'}");
      events.add(ConnectivityManagerEvent.torConnectedDoesntWork);
    }
  }

  Future<void> checkFoundationServer() async {
    if (usingDefaultServer) {
      failedFoundationServerAttempts++;
      if (failedFoundationServerAttempts >= 3) {
        events.add(ConnectivityManagerEvent.foundationServerDown);
      } else {
        await s.switchToNextDefaultServer();
      }
    }
  }

  Future restartTor() async {
    //if tor is enabled and we've had 5 failed connectivity attempts, restart tor
    if (torEnabled && failedTorConnectivityAttempts >= maxFailedTorAttempts) {
      if (Tor.instance.bootstrapped) {
        await Tor.instance.stop();
        await Future.delayed(const Duration(milliseconds: 200));
      }
      await Tor.instance.start();
      failedTorConnectivityAttempts = 0;
    }
  }
}
