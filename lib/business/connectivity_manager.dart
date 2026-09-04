// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'package:collection/collection.dart';
import 'package:envoy/business/tor_restart_policy.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/foundation.dart';
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
  diyNodes("DIYnodes", "ssl://electrum.diynodes.com:50022"),
  bitaroo("Bitaroo", "ssl://electrum.bitaroo.net:50002");

  final String label;
  final String address;

  const PublicServer(this.label, this.address);

  static PublicServer? fromAddress(String address) {
    return PublicServer.values.firstWhereOrNull(
      (server) => server.address == address,
    );
  }
}

const Duration _tempDisablementTimeout = Duration(hours: 24);

@visibleForTesting
Duration? torTemporaryDisablementRemaining(
        DateTime? disabledUntil, DateTime now) =>
    disabledUntil != null && disabledUntil.isAfter(now)
        ? disabledUntil.difference(now)
        : null;

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

  // Number of failed attempts before restarting Tor.
  static const int maxFailedTorAttempts = 5;
  static const Duration _torStopTimeout = Duration(seconds: 15);
  static const Duration _torStartTimeout = Duration(seconds: 90);
  final TorRestartPolicy _torRestartPolicy =
      TorRestartPolicy(failureThreshold: maxFailedTorAttempts);
  bool _restartSuppressionReported = false;
  String? _lastTorProbeFailure;

  bool electrumConnected = true;
  bool nguConnected = true;
  int get failedTorConnectivityAttempts =>
      _torRestartPolicy.consecutiveFailures;

  // Three strikes before we report services as unreachable to the UI
  int _consecutiveElectrumFailures = 0;
  int _consecutiveNguFailures = 0;
  static const int _maxFailuresBeforeUnreachable = 3;

  @visibleForTesting
  ({int electrum, int ngu}) get serviceFailureCounters => (
        electrum: _consecutiveElectrumFailures,
        ngu: _consecutiveNguFailures,
      );

  // Grace period after enabling Tor to allow circuits to stabilize
  DateTime? _torEnabledTimestamp;
  static const Duration _torGracePeriod = Duration(seconds: 45);

  bool get _inTorGracePeriod {
    if (_torEnabledTimestamp == null || !torEnabled) return false;
    return DateTime.now().difference(_torEnabledTimestamp!) < _torGracePeriod;
  }

  /// Flag to prevent concurrent restartTor() calls
  bool _isRestartingTor = false;

  /// Coalesces overlapping Tor health checks into one probe.
  Future<void>? _torCheckInFlight;
  Timer? _torRecoveryTimer;

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
    _torRecoveryTimer?.cancel();
    events.close();
  }

  /// Start a grace period after enabling Tor to allow circuits to stabilize.
  /// Failures from requests started against the previous route are ignored.
  void startTorGracePeriod() {
    _recordTorSuccess();
    _beginTorGracePeriod();
  }

  /// Gives newly started Tor routes time to settle without re-arming automatic
  /// restarts. Only a real Tor-routed success should start a new failure
  /// episode after a restart.
  void _beginTorGracePeriod() {
    _torEnabledTimestamp = DateTime.now();
    _consecutiveElectrumFailures = 0;
    _consecutiveNguFailures = 0;
    // Reset connected states to give a fresh start
    electrumConnected = true;
    nguConnected = true;
    events.add(ConnectivityManagerEvent.torStatusChange);
  }

  /// Reset failure counters to give the network a fresh start.
  /// Call this when the app resumes from background, since the OS may have
  /// suspended networking while backgrounded, causing stale failures to
  /// accumulate and trigger false-positive "server down" toasts on resume.
  /// Preserve the last observed service states until a real request changes
  /// them; resuming the app is not evidence that either service recovered.
  /// The Tor restart policy is deliberately left untouched: forgiving it on
  /// every resume kept pushing automatic recovery further away.
  void resetFailureCounters() {
    _consecutiveElectrumFailures = 0;
    _consecutiveNguFailures = 0;
    failedFoundationServerAttempts = 0;
  }

  void electrumSuccess({required bool viaTor}) {
    if (viaTor) {
      _recordTorSuccess();
    }
    failedFoundationServerAttempts = 0;
    _consecutiveElectrumFailures = 0;
    electrumConnected = true;
    events.add(ConnectivityManagerEvent.electrumReachable);
    checkTor();
  }

  void electrumFailure() {
    // A restart can leave old requests completing against the stopped route.
    // Ignore those results while the replacement route settles.
    if (_inTorGracePeriod) {
      return;
    }

    _consecutiveElectrumFailures++;
    kPrint(
        "Electrum failure strike $_consecutiveElectrumFailures/$_maxFailuresBeforeUnreachable");

    if (_consecutiveElectrumFailures >= _maxFailuresBeforeUnreachable) {
      electrumConnected = false;
      events.add(ConnectivityManagerEvent.electrumUnreachable);
      checkTor();
      checkFoundationServer();
    }
  }

  void nguSuccess() {
    // NGU uses HttpTor, so a success while Tor is enabled proves that the
    // current Tor route works and starts a new failure episode.
    if (torEnabled) {
      _recordTorSuccess();
    }
    _consecutiveNguFailures = 0;
    nguConnected = true;
    events.add(ConnectivityManagerEvent.nguStatusChanged);
    checkTor();
  }

  void nguFailure() {
    // A restart can leave old requests completing against the stopped route.
    // Ignore those results while the replacement route settles.
    if (_inTorGracePeriod) {
      return;
    }

    _consecutiveNguFailures++;
    kPrint(
        "NGU failure strike $_consecutiveNguFailures/$_maxFailuresBeforeUnreachable");

    if (_consecutiveNguFailures >= _maxFailuresBeforeUnreachable) {
      nguConnected = false;
      events.add(ConnectivityManagerEvent.nguStatusChanged);
      checkTor();
    }
  }

  Future<void> checkTor() {
    final inFlight = _torCheckInFlight;
    if (inFlight != null) {
      return inFlight;
    }

    late final Future<void> check;
    check = _checkTorOnce().whenComplete(() {
      if (identical(_torCheckInFlight, check)) {
        _torCheckInFlight = null;
      }
    });
    _torCheckInFlight = check;
    return check;
  }

  Future<void> _checkTorOnce() async {
    if (_shouldSkipTorCheck()) return;

    final reachable = await _isTorReachable();

    // A service may have recovered while the probe was running.
    if (_shouldSkipTorCheck()) return;

    if (reachable) {
      _recordTorSuccess();
      return;
    }

    final restartWasAlreadyAttempted = _torRestartPolicy.restartAttempted;
    final shouldRestart = Tor.instance.bootstrapped
        ? _torRestartPolicy.recordFailure()
        : _torRestartPolicy.recordConfirmedFailure();
    events.add(ConnectivityManagerEvent.torConnectedDoesntWork);

    if (shouldRestart) {
      _restartSuppressionReported = false;
      unawaited(EnvoyReport().log(
        "Tor recovery",
        "Tor health probe reached $maxFailedTorAttempts consecutive failures; "
            "starting an automatic restart. "
            "restartCooldown=${TorRestartPolicy.restartCooldown.inSeconds}s; "
            "port=${Tor.instance.port}; "
            "NGU=${nguConnected ? 'reachable' : 'unreachable'}; "
            "Electrum=${electrumConnected ? 'reachable' : 'unreachable'}; "
            "lastError=${_lastTorProbeFailure ?? 'unknown'}",
      ));
      await _restartTor();
    } else if (restartWasAlreadyAttempted) {
      _scheduleTorRecovery();
      if (!_restartSuppressionReported) {
        _restartSuppressionReported = true;
        unawaited(EnvoyReport().log(
          "Tor recovery",
          "Tor remains unreachable after the automatic restart attempt; "
              "suppressing another automatic restart during the "
              "${TorRestartPolicy.restartCooldown.inSeconds}s cooldown. "
              "port=${Tor.instance.port}; "
              "lastError=${_lastTorProbeFailure ?? 'unknown'}",
        ));
      }
    }
  }

  bool _shouldSkipTorCheck() {
    if (!torEnabled || Tor.instance.starting) {
      _deferTorRecoveryIfNeeded();
      return true;
    }
    return Tor.instance.bootstrapped && (nguConnected || electrumConnected);
  }

  Future<bool> _isTorReachable() async {
    // HttpTor waits in isReady() until bootstrap completes. Avoid creating a
    // poller that survives this probe's timeout when bootstrap is the failure.
    if (!Tor.instance.bootstrapped) {
      _lastTorProbeFailure = "Tor is not bootstrapped";
      return false;
    }

    try {
      final r = await HttpTor()
          .get(
              "http://sanityunhavm6aolhyye4h6kbdlxjmc7zw2y7nadbni6vd43agm7xvid.onion")
          .timeout(const Duration(seconds: 90));
      if (r.statusCode == 200) {
        _lastTorProbeFailure = null;
        return true;
      }
      _lastTorProbeFailure = "HTTP status ${r.statusCode}";
      return false;
    } on TimeoutException catch (e) {
      _lastTorProbeFailure = "timeout: ${_summarizeError(e)}";
      return false;
    } catch (e) {
      _lastTorProbeFailure = _summarizeError(e);
      return false;
    }
  }

  void _recordTorSuccess() {
    _torRecoveryTimer?.cancel();
    _torRecoveryTimer = null;
    _torRestartPolicy.recordSuccess();
    _restartSuppressionReported = false;
    _lastTorProbeFailure = null;
  }

  void _deferTorRecoveryIfNeeded() {
    if (_torRecoveryTimer != null) return;

    if (_torRestartPolicy.restartAttempted && torEnabled) {
      _scheduleTorRecovery(delay: TorRestartPolicy.restartCooldown);
    }
  }

  void _scheduleTorRecovery({Duration? delay}) {
    _torRecoveryTimer?.cancel();
    _torRecoveryTimer = Timer(
      delay ?? _torRestartPolicy.restartCooldownRemaining,
      () {
        _torRecoveryTimer = null;

        final disablementRemaining = torTemporaryDisablementRemaining(
          torTemporarilyDisabledTimeStamp,
          DateTime.now(),
        );
        if (disablementRemaining != null) {
          _scheduleTorRecovery(delay: disablementRemaining);
          return;
        }

        unawaited(checkTor());
      },
    );
  }

  String _summarizeError(Object error) {
    const maxLength = 500;
    final summary = error.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
    if (summary.length <= maxLength) return summary;
    return "${summary.substring(0, maxLength)}...";
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

  Future<void> _restartTor() async {
    if (_isRestartingTor || !torEnabled || Tor.instance.starting) {
      return;
    }

    _isRestartingTor = true;
    final previousPort = Tor.instance.port;
    try {
      // stop() clears the route before it can fail, so skipping the start
      // below would leave Tor enabled but never bootstrapped - a state where
      // isReady() parks every Tor-routed request indefinitely.
      try {
        await Tor.instance.stop().timeout(_torStopTimeout);
      } catch (e, stackTrace) {
        unawaited(EnvoyReport().log(
          "Tor recovery",
          "Tor teardown failed; starting a replacement route anyway. "
              "oldPort=$previousPort; error=${_summarizeError(e)}",
          stackTrace: stackTrace,
        ));
      }
      final stoppedPort = Tor.instance.port;
      await Future.delayed(const Duration(milliseconds: 200));

      if (!torEnabled) {
        unawaited(EnvoyReport().log(
          "Tor recovery",
          "Automatic Tor restart cancelled because Tor was disabled. "
              "oldPort=$previousPort; stoppedPort=$stoppedPort",
        ));
        return;
      }

      final start = Tor.instance.start();
      try {
        await start.timeout(_torStartTimeout);
      } on TimeoutException catch (e, stackTrace) {
        _beginTorGracePeriod();
        unawaited(EnvoyReport().log(
          "Tor recovery",
          "Automatic Tor restart is still bootstrapping after "
              "${_torStartTimeout.inSeconds}s. oldPort=$previousPort; "
              "currentPort=${Tor.instance.port}; error=${_summarizeError(e)}",
          stackTrace: stackTrace,
        ));
        unawaited(_observeTorStart(start, previousPort));
        return;
      }

      unawaited(EnvoyReport().log(
        "Tor recovery",
        "Automatic Tor restart completed. oldPort=$previousPort; "
            "stoppedPort=$stoppedPort; newPort=${Tor.instance.port}; "
            "another automatic restart is allowed after the "
            "${TorRestartPolicy.restartCooldown.inSeconds}s cooldown unless "
            "Tor-backed traffic succeeds first",
      ));
      _beginTorGracePeriod();
    } catch (e, stackTrace) {
      _handleTorRestartFailure(e, stackTrace, previousPort);
    } finally {
      _isRestartingTor = false;
    }
  }

  Future<void> _observeTorStart(Future<void> start, int previousPort) async {
    try {
      await start;
      if (!torEnabled) return;

      unawaited(EnvoyReport().log(
        "Tor recovery",
        "Automatic Tor restart completed after the foreground timeout. "
            "oldPort=$previousPort; newPort=${Tor.instance.port}",
      ));
      _beginTorGracePeriod();
    } catch (e, stackTrace) {
      if (!torEnabled) return;
      _handleTorRestartFailure(e, stackTrace, previousPort);
    }
  }

  void _handleTorRestartFailure(
    Object error,
    StackTrace stackTrace,
    int previousPort,
  ) {
    _lastTorProbeFailure = _summarizeError(error);
    _scheduleTorRecovery();
    unawaited(EnvoyReport().log(
      "Tor recovery",
      "Automatic Tor restart failed. oldPort=$previousPort; "
          "currentPort=${Tor.instance.port}; error=$_lastTorProbeFailure",
      stackTrace: stackTrace,
    ));
  }
}
