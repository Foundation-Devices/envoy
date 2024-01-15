// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:tor/tor.dart';
import 'package:envoy/business/settings.dart';

enum ConnectivityManagerEvent {
  TorStatusChange,
  TorConnectedDoesntWork,
  ElectrumUnreachable,
  ElectrumReachable
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

  bool get usingDefaultServer => Settings().usingDefaultElectrumServer;

  bool electrumConnected = true;
  bool nguConnected = false;

  DateTime? torTemporarilyDisabledTimeStamp;

  Timer? _torWarningTimer;
  bool _torWarningDisplayedMoreThan5minAgo = true;

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
    print("Instance of ConnectivityManager created!");

    Tor.instance.events.stream.listen((event) {
      // Nudge listeners
      events.add(ConnectivityManagerEvent.TorStatusChange);
    });

    _resetTorWarningTimer();
  }

  void dispose() {
    _torWarningTimer?.cancel();
    events.close();
  }

  electrumSuccess() {
    electrumConnected = true;
    events.add(ConnectivityManagerEvent.ElectrumReachable);
    checkTor();
  }

  electrumFailure() {
    electrumConnected = false;
    events.add(ConnectivityManagerEvent.ElectrumUnreachable);
    checkTor();
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

      if (_torWarningDisplayedMoreThan5minAgo) {
        events.add(ConnectivityManagerEvent.TorConnectedDoesntWork);
        _torWarningDisplayedMoreThan5minAgo = false;
        _resetTorWarningTimer();
      }
    }
  }

  restartTor() {
    // ENV-175
    if (torEnabled) {
      Tor.instance.restart();
    }
  }

  void _resetTorWarningTimer() {
    _torWarningTimer = Timer.periodic(Duration(minutes: 5), (_) async {
      _torWarningDisplayedMoreThan5minAgo = true;
    });
  }
}
