// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// ignore_for_file: constant_identifier_names///
import 'dart:async';

import 'package:envoy/ble/quantum_link_router.dart';
import 'package:envoy/business/scv_server.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/widgets/envoy_step_item.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/console.dart';
import 'package:foundation_api/foundation_api.dart' as api;

/// Type of security check error
enum ScvErrorType {
  /// No error
  none,

  /// Network error - couldn't reach Foundation servers
  networkError,

  /// Operational error while delivering or processing the challenge
  challengeError,

  /// Verification failed - device may be tampered with
  verificationFailed,
}

class ScvUpdateState {
  final String message;
  final EnvoyStepState step;
  final ScvErrorType errorType;

  ScvUpdateState({
    required this.message,
    required this.step,
    this.errorType = ScvErrorType.none,
  });
}

/// Handler for SCV messages over Quantum Link.
class ScvHandler extends PassportMessageHandler {
  static const Duration defaultChallengeFetchTimeout = Duration(seconds: 15);
  static const Duration defaultChallengeResponseTimeout = Duration(seconds: 15);
  static const Duration defaultProofVerificationTimeout = Duration(seconds: 30);
  static const int _maxExpiredChallengeRetries = 3;

  ScvHandler(
    super.connection, {
    PrimeSecurityCheckService? securityCheckService,
    Duration challengeFetchTimeout = defaultChallengeFetchTimeout,
    Duration challengeResponseTimeout = defaultChallengeResponseTimeout,
    Duration proofVerificationTimeout = defaultProofVerificationTimeout,
    void Function(String message)? logger,
  })  : _securityCheckService = securityCheckService ?? ScvServer(),
        _challengeFetchTimeout = challengeFetchTimeout,
        _challengeResponseTimeout = challengeResponseTimeout,
        _proofVerificationTimeout = proofVerificationTimeout,
        _logger = logger ?? _defaultLogger;

  final PrimeSecurityCheckService _securityCheckService;
  final Duration _challengeFetchTimeout;
  final Duration _challengeResponseTimeout;
  final Duration _proofVerificationTimeout;
  final void Function(String message) _logger;

  Future<void>? _sendInFlight;
  Timer? _challengeResponseTimer;
  bool _awaitingChallengeResponse = false;
  bool _disposed = false;
  int _attempt = 0;
  int _expiredChallengeRetries = 0;

  ScvUpdateState? _lastState;
  final StreamController<ScvUpdateState> _scvUpdateController =
      StreamController<ScvUpdateState>.broadcast();

  Stream<ScvUpdateState> get scvUpdateController =>
      _scvUpdateController.stream.asBroadcastStream();

  ScvUpdateState? get lastScvState => _lastState;

  @override
  bool canHandle(api.QuantumLinkMessage message) {
    return message is api.QuantumLinkMessage_SecurityCheck ||
        message is api.QuantumLinkMessage_PairingResponse;
  }

  @override
  Future<void> handleMessage(api.QuantumLinkMessage message) async {
    if (message
        case api.QuantumLinkMessage_SecurityCheck(
          field0: final check,
        )) {
      if (check is api.SecurityCheck_ChallengeResponse) {
        final proofResult = check.field0;

        //To test re-tries
        // proofResult = api.ChallengeResponseResult.error(error: "DeadlineExpired");

        _cancelChallengeResponseWait();
        if (proofResult is api.ChallengeResponseResult_Success) {
          final proofData = proofResult.data;
          final verificationStopwatch = Stopwatch()..start();
          ScvVerificationResult verificationResult;
          try {
            verificationResult = await _securityCheckService
                .verifyProof(proofData)
                .timeout(_proofVerificationTimeout);
            _logEvent(
              "proof verification completed durationMs=${verificationStopwatch.elapsedMilliseconds}",
            );
          } on TimeoutException {
            _logEvent(
              "proof verification timed out durationMs=${verificationStopwatch.elapsedMilliseconds}",
            );
            await sendNetworkError();
            return;
          } catch (e) {
            _logEvent(
              "proof verification failed durationMs=${verificationStopwatch.elapsedMilliseconds} error=$e",
            );
            await sendNetworkError();
            return;
          }

          switch (verificationResult) {
            case ScvVerificationResult.success:
              updateScvState(
                S().onboarding_connectionChecking_SecurityPassed,
                EnvoyStepState.FINISHED,
              );
              await _sendSecurityChallengeVerificationResult(
                api.VerificationResult.success(),
              );
              break;

            case ScvVerificationResult.networkError:
              // Network error - send Error to Prime and show pending state
              await sendNetworkError();
              return;

            case ScvVerificationResult.verificationFailed:
              // Only an explicit server-side proof rejection is a verification
              // failure. Device-side errors are operational and handled below.
              updateScvState(
                S().onboarding_connectionIntroError_securityCheckFailed,
                EnvoyStepState.ERROR,
                errorType: ScvErrorType.verificationFailed,
              );
              await _sendSecurityChallengeVerificationResult(
                api.VerificationResult.failure(),
              );
              return;
          }
        } else if (proofResult is api.ChallengeResponseResult_Error) {
          final proofError = proofResult.error;
          _logEvent("device challenge error=$proofError");
          if (_isDeadlineExpired(proofError) &&
              _expiredChallengeRetries < _maxExpiredChallengeRetries) {
            _expiredChallengeRetries++;
            _logEvent("retrying expired challenge");
            await _startChallengeAttempt();
            return;
          }
          await _showChallengeError(
            reason: _isDeadlineExpired(proofError)
                ? "challenge deadline expired after retry"
                : "device challenge error",
          );
        }
      } else if (check is api.SecurityCheck_ChallengeRequest) {
        kPrint("received unexpected security challenge request");
      } else if (check is api.SecurityCheck_VerificationResult) {
        kPrint("received invalid security verification message");
      }
    } else if (message case api.QuantumLinkMessage_PairingResponse _) {}
  }

  Future<void> sendNetworkError() async {
    updateScvState(
      S().onboarding_connectionIntroErrorInternet_securityCheckPending,
      EnvoyStepState.ERROR,
      errorType: ScvErrorType.networkError,
    );
    await _sendSecurityChallengeVerificationResult(
      api.VerificationResult.error(
        error: "Network error: Unable to reach Foundation servers",
      ),
    );
  }

  void updateScvState(
    String message,
    EnvoyStepState step, {
    ScvErrorType errorType = ScvErrorType.none,
  }) {
    final state = ScvUpdateState(
      message: message,
      step: step,
      errorType: errorType,
    );
    if (!_scvUpdateController.isClosed) {
      _scvUpdateController.add(state);
    }
    _lastState = state;
  }

  Future<void> _sendSecurityChallengeVerificationResult(
    api.VerificationResult result,
  ) async {
    final message = api.SecurityCheck.verificationResult(result);
    try {
      final success = await messageWriter.writeMessage(
        api.QuantumLinkMessage.securityCheck(message),
      );
      if (!success) {
        _logEvent(
          "failed to write verification result type=${result.runtimeType}",
        );
      }
    } catch (e) {
      _logEvent(
        "error writing verification result type=${result.runtimeType} error=$e",
      );
    }
  }

  Future<void> sendSecurityChallenge() {
    if (_disposed) {
      return Future.value();
    }
    final inFlight = _sendInFlight;
    if (inFlight != null) {
      _logEvent("ignored duplicate challenge request while sending");
      return inFlight;
    }
    if (_awaitingChallengeResponse) {
      _logEvent("ignored duplicate challenge request while awaiting response");
      return Future.value();
    }

    _expiredChallengeRetries = 0;
    return _startChallengeAttempt();
  }

  Future<void> _startChallengeAttempt() {
    final inFlight = _sendInFlight;
    if (inFlight != null) {
      return inFlight;
    }

    final attempt = ++_attempt;
    final operation = _fetchAndSendChallenge(attempt);
    _sendInFlight = operation;
    return operation;
  }

  Future<void> _fetchAndSendChallenge(int attempt) async {
    kPrint("sending security challenge");
    updateScvState(
      S().onboarding_connectionIntro_checkingDeviceSecurity,
      EnvoyStepState.LOADING,
    );
    final fetchStopwatch = Stopwatch()..start();
    try {
      final challenge = await _securityCheckService
          .getPrimeChallenge()
          .timeout(_challengeFetchTimeout);
      if (challenge == null) {
        _logEvent(
          "challenge fetch failed durationMs=${fetchStopwatch.elapsedMilliseconds}",
        );
        await sendNetworkError();
        return;
      }

      _logEvent(
        "challenge fetched durationMs=${fetchStopwatch.elapsedMilliseconds}",
      );
      final request = api.SecurityCheck.challengeRequest(challenge);
      final writeStopwatch = Stopwatch()..start();
      final success = await messageWriter.writeMessage(
        api.QuantumLinkMessage.securityCheck(request),
      );
      _logEvent(
        "challenge write completed success=$success durationMs=${writeStopwatch.elapsedMilliseconds}",
      );
      if (!success) {
        await _showChallengeError(reason: "challenge write failed");
        return;
      }

      if (_disposed || attempt != _attempt) {
        return;
      }
      _awaitingChallengeResponse = true;
      _challengeResponseTimer?.cancel();
      _challengeResponseTimer = Timer(_challengeResponseTimeout, () {
        if (_disposed || !_awaitingChallengeResponse || attempt != _attempt) {
          return;
        }
        _awaitingChallengeResponse = false;
        _logEvent("timed out waiting for device challenge response");
        unawaited(
          _showChallengeError(reason: "device challenge response timed out"),
        );
      });
    } on TimeoutException {
      _logEvent(
        "challenge fetch timed out durationMs=${fetchStopwatch.elapsedMilliseconds}",
      );
      await sendNetworkError();
    } catch (e) {
      _logEvent(
        "challenge attempt failed durationMs=${fetchStopwatch.elapsedMilliseconds} error=$e",
      );
      await _showChallengeError(reason: "challenge attempt exception");
    } finally {
      if (attempt == _attempt) {
        _sendInFlight = null;
      }
    }
  }

  Future<void> _showChallengeError({required String reason}) async {
    if (_disposed) {
      return;
    }
    _cancelChallengeResponseWait();
    _logEvent(reason);
    updateScvState(
      S().onboarding_connectionIntroErrorChallenge_securityCheckPending,
      EnvoyStepState.ERROR,
      errorType: ScvErrorType.challengeError,
    );
    await _sendSecurityChallengeVerificationResult(
      api.VerificationResult.error(
        error: "Security challenge could not be completed",
      ),
    );
  }

  void _cancelChallengeResponseWait() {
    _challengeResponseTimer?.cancel();
    _challengeResponseTimer = null;
    _awaitingChallengeResponse = false;
  }

  bool _isDeadlineExpired(String error) {
    return error.contains("DeadlineExpired");
  }

  void _logEvent(String message) {
    _logger(
      "attempt=$_attempt phoneTimeMs=${DateTime.now().millisecondsSinceEpoch} $message",
    );
  }

  static void _defaultLogger(String message) {
    unawaited(EnvoyReport().log("scv", message));
  }

  void reset() {
    updateScvState(
      S().firmware_updatingDownload_downloading,
      EnvoyStepState.IDLE,
    );
  }

  @override
  void dispose() {
    _disposed = true;
    _cancelChallengeResponseWait();
    _scvUpdateController.close();
    super.dispose();
  }
}
