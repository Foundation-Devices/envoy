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
import 'package:envoy/business/scheduler.dart';

enum ConnectivityManagerEvent {
  torStatusChange,
  torConnectedDoesntWork,
  electrumUnreachable,
  electrumReachable,
  foundationServerDown,
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
const Duration _torHealthCheckInterval = Duration(seconds: 15);

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
  Timer? _torHealthTimer;
  bool _lastTorHealthStatus = true;
  bool _isInFastCheckMode = false;

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

    // Start proactive Tor health monitoring
    _startTorHealthMonitoring();
  }

  void dispose() {
    _torHealthTimer?.cancel();
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

  /// Starts proactive Tor health monitoring to detect connection drops faster
  void _startTorHealthMonitoring() {
    _torHealthTimer = Timer.periodic(_torHealthCheckInterval, (timer) {
      if (torEnabled && !torTemporarilyDisabled) {
        _checkTorHealth();
      }
    });
  }

  /// Switches to fast check mode for more frequent monitoring during issues
  void _enableFastCheckMode() {
    if (_isInFastCheckMode) return;

    _isInFastCheckMode = true;
    _torHealthTimer?.cancel();

    // Check every 5 seconds when in fast mode
    _torHealthTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (torEnabled && !torTemporarilyDisabled) {
        _checkTorHealth();
      }
    });

    // Return to normal mode after 2 minutes
    Timer(const Duration(minutes: 2), () {
      _isInFastCheckMode = false;
      _torHealthTimer?.cancel();
      _startTorHealthMonitoring();
    });
  }

  /// Performs a quick health check on the Tor connection
  void _checkTorHealth() async {
    if (!torEnabled || torTemporarilyDisabled) {
      return;
    }

    try {
      // First check if Tor circuit is established
      bool torBootstrapped = Tor.instance.bootstrapped;

      if (!torBootstrapped) {
        // Tor is not bootstrapped, mark as unhealthy
        if (_lastTorHealthStatus) {
          kPrint(
              "ConnectivityManager: Tor not bootstrapped, marking electrum as disconnected");
          electrumConnected = false;
          events.add(ConnectivityManagerEvent.electrumUnreachable);
          events.add(ConnectivityManagerEvent.torStatusChange);
          _lastTorHealthStatus = false;
          _enableFastCheckMode();
        }
        return;
      }

      // Tor claims to be bootstrapped, but let's test actual connectivity
      // by making a quick HTTP request through Tor
      await _testTorConnectivity();

      // If we reach here, Tor is working
      if (!_lastTorHealthStatus) {
        kPrint("ConnectivityManager: Tor connectivity restored");
        events.add(ConnectivityManagerEvent.torStatusChange);
        _lastTorHealthStatus = true;
      }
    } catch (e) {
      kPrint("ConnectivityManager: Tor connectivity test failed: $e");
      // Connection test failed, mark as unhealthy
      if (_lastTorHealthStatus) {
        kPrint(
            "ConnectivityManager: Tor connectivity lost, marking electrum as disconnected");
        electrumConnected = false;
        events.add(ConnectivityManagerEvent.electrumUnreachable);
        events.add(ConnectivityManagerEvent.torStatusChange);
        _lastTorHealthStatus = false;
        _enableFastCheckMode();
      }
    }
  }

  /// Tests actual Tor connectivity by making a quick HTTP request
  Future<void> _testTorConnectivity() async {
    final httpTor = HttpTor(Tor.instance, EnvoyScheduler().parallel);

    // Make a quick request to a reliable endpoint with short timeout
    try {
      final response = await httpTor
          .get("https://httpbin.org/ip")
          .timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) {
        throw Exception(
            "HTTP request failed with status: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Tor connectivity test failed: $e");
    }
  }
}
