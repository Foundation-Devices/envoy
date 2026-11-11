// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:envoy/ble/handlers/scv_handler.dart';
import 'package:envoy/ble/qlv2/rpc_handler.dart';
import 'package:envoy/channels/ql_connection.dart';
import 'package:envoy/business/scv_server.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/onboard/prime/state/prime_onboarding_controller.dart';
import 'package:envoy/ui/widgets/envoy_step_item.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:http_tor/http_tor.dart';
import 'package:qlv2/qlv2.dart' as qlv2;

typedef SecurityCheckDuplex = QLV2DuplexSession<
    qlv2.RunSecurityCheckInitiatorEvent, qlv2.RunSecurityCheckResponderEvent>;

class PrimeOnboardingQlv2SecurityCheckHandler
    implements
        QLV2DuplexRpcHandler<
            qlv2.InboundRpc_SecurityCheck,
            qlv2.RunSecurityCheckInitiatorEvent,
            qlv2.RunSecurityCheckResponderEvent> {
  PrimeOnboardingQlv2SecurityCheckHandler(
    this._controller, {
    required this.skipSecurityCheck,
    PrimeSecurityCheckService? securityCheckService,
    bool Function()? shouldHandle,
  })  : _securityCheckService = securityCheckService ?? ScvServer(),
        _shouldHandle = shouldHandle ?? _alwaysHandle;

  final PrimeOnboardingController _controller;
  final bool skipSecurityCheck;
  final PrimeSecurityCheckService _securityCheckService;
  final bool Function() _shouldHandle;
  static const _challengeTimeout = Duration(seconds: 15);
  static const _responseTimeout = Duration(seconds: 15);
  static const _proofTimeout = Duration(seconds: 30);
  static const _maxDeadlineRetries = 3;

  void _updateSecurity(
    String message,
    EnvoyStepState step, {
    ScvErrorType errorType = ScvErrorType.none,
  }) {
    if (!_shouldHandle()) return;
    _controller.updateSecurity(message, step, errorType: errorType);
  }

  @override
  SecurityCheckDuplex createSession(qlv2.InboundRpc_SecurityCheck rpc) {
    final duplex = rpc.field0;
    return SecurityCheckDuplex(
      listen: duplex.listen,
      send: (event) => duplex.send(event: event),
      finish: duplex.finish,
    );
  }

  @override
  Future<void> handleDuplex(
    SecurityCheckDuplex duplex,
    QLConnection device,
  ) async {
    _logQlv2SecurityCheck(
      "received duplex skipSecurityCheck=$skipSecurityCheck",
    );
    _updateSecurity(
      S().onboarding_connectionIntro_checkingDeviceSecurity,
      EnvoyStepState.LOADING,
    );
    await _handleSecurityCheck(duplex);
  }

  Future<void> _handleSecurityCheck(SecurityCheckDuplex duplex) async {
    _logQlv2SecurityCheck("duplex started");
    try {
      final events = duplex.events;
      final startEvent = await events.next.timeout(_responseTimeout);
      if (startEvent is! qlv2.RunSecurityCheckInitiatorEvent_Start) {
        _logQlv2SecurityCheck(
          "expected start event, got ${startEvent.runtimeType}",
        );
        await _sendProtocolError(duplex, "Expected security check start event");
        return;
      }

      for (var attempt = 0; attempt <= _maxDeadlineRetries; attempt++) {
        _logQlv2SecurityCheck(
          "passport requested challenge attempt=${attempt + 1}",
        );
        final sent = await _sendSecurityChallenge(duplex);
        if (!sent) return;

        final responseEvent = await events.next.timeout(_responseTimeout);
        if (responseEvent
            is! qlv2.RunSecurityCheckInitiatorEvent_ChallengeResponse) {
          await _sendProtocolError(
            duplex,
            "Expected security check challenge response event",
          );
          return;
        }
        final result = responseEvent.field0;
        if (result is qlv2.ChallengeResponseResult_Error &&
            _isDeadlineExpired(result.error) &&
            attempt < _maxDeadlineRetries) {
          _logQlv2SecurityCheck(
            "challenge deadline expired; retrying attempt=${attempt + 2}",
          );
          continue;
        }
        await _handleChallengeResponse(duplex, result);
        return;
      }
      await _sendProtocolError(duplex, "Security challenge deadline expired");
    } on TimeoutException {
      await _sendNetworkError(duplex);
    } on StateError catch (e, stack) {
      _logQlv2SecurityCheck(
        "event stream ended early (${e.runtimeType})",
        stackTrace: stack,
      );
      await _trySendVerificationResult(
        duplex,
        const qlv2.VerificationResult.error(
          error: "security_check_stream_closed",
        ),
      );
      _updateSecurity(
        S().onboarding_connectionIntroError_securityCheckFailed,
        EnvoyStepState.ERROR,
        errorType: ScvErrorType.verificationFailed,
      );
    } catch (e, stack) {
      _logQlv2SecurityCheck(
        "failed (${e.runtimeType})",
        stackTrace: stack,
      );
      await _trySendVerificationResult(
        duplex,
        const qlv2.VerificationResult.error(
          error: "security_check_failed",
        ),
      );
      _updateSecurity(
        S().onboarding_connectionIntroErrorInternet_securityCheckPending,
        EnvoyStepState.ERROR,
        errorType: ScvErrorType.networkError,
      );
    }
  }

  Future<bool> _sendSecurityChallenge(SecurityCheckDuplex duplex) async {
    _logQlv2SecurityCheck("sending security challenge");
    _updateSecurity(
      S().onboarding_connectionIntro_checkingDeviceSecurity,
      EnvoyStepState.LOADING,
    );

    final challengeData = (await _securityCheckService
            .getPrimeChallenge()
            .timeout(_serverTimeout(_challengeTimeout)))
        ?.data;
    if (challengeData == null) {
      _logQlv2SecurityCheck("challenge fetch returned null");
      await _sendNetworkError(duplex);
      return false;
    }

    _logQlv2SecurityCheck(
      "challenge fetched sizeBytes=${challengeData.length}",
    );
    await duplex.send(
      qlv2.RunSecurityCheckResponderEvent.challengeRequest(
        qlv2.ChallengeRequest(data: challengeData),
      ),
    );
    return true;
  }

  Future<void> _handleChallengeResponse(
    SecurityCheckDuplex duplex,
    qlv2.ChallengeResponseResult result,
  ) async {
    if (skipSecurityCheck) {
      _logQlv2SecurityCheck("proof verification skipped by settings");
      await _sendVerificationResult(
        duplex,
        const qlv2.VerificationResult.success(),
      );
      _updateSecurity(
        S().onboarding_connectionChecking_SecurityPassed,
        EnvoyStepState.FINISHED,
      );
      return;
    }

    switch (result) {
      case qlv2.ChallengeResponseResult_Success(:final data):
        _logQlv2SecurityCheck(
          "verifying proof sizeBytes=${data.length}",
        );
        final verificationResult = await _securityCheckService
            .verifyProof(data)
            .timeout(_serverTimeout(_proofTimeout));
        switch (verificationResult) {
          case ScvVerificationResult.success:
            _logQlv2SecurityCheck("proof verified");
            _updateSecurity(
              S().onboarding_connectionChecking_SecurityPassed,
              EnvoyStepState.FINISHED,
            );
            await _sendVerificationResult(
              duplex,
              const qlv2.VerificationResult.success(),
            );
          case ScvVerificationResult.networkError:
            _logQlv2SecurityCheck("proof verification network error");
            await _sendNetworkError(duplex);
          case ScvVerificationResult.verificationFailed:
            _logQlv2SecurityCheck("proof verification failed");
            await _sendVerificationResult(
              duplex,
              const qlv2.VerificationResult.failure(),
            );
            _updateSecurity(
              S().onboarding_connectionIntroError_securityCheckFailed,
              EnvoyStepState.ERROR,
              errorType: ScvErrorType.verificationFailed,
            );
        }
      case qlv2.ChallengeResponseResult_Error(:final error):
        _logQlv2SecurityCheck("challenge proof failed error=$error");
        await _sendVerificationResult(
          duplex,
          const qlv2.VerificationResult.failure(),
        );
        _updateSecurity(
          S().onboarding_connectionIntroError_securityCheckFailed,
          EnvoyStepState.ERROR,
          errorType: ScvErrorType.verificationFailed,
        );
    }
  }

  Future<void> _sendNetworkError(SecurityCheckDuplex duplex) async {
    _logQlv2SecurityCheck("network error; notifying Prime");
    await _sendVerificationResult(
      duplex,
      const qlv2.VerificationResult.error(
        error: "Network error: Unable to reach Foundation servers",
      ),
    );
    _updateSecurity(
      S().onboarding_connectionIntroErrorInternet_securityCheckPending,
      EnvoyStepState.ERROR,
      errorType: ScvErrorType.networkError,
    );
  }

  Future<void> _sendProtocolError(
    SecurityCheckDuplex duplex,
    String error,
  ) async {
    _logQlv2SecurityCheck("protocol error=$error");
    await _sendVerificationResult(
      duplex,
      qlv2.VerificationResult.error(error: error),
    );
    _updateSecurity(
      S().onboarding_connectionIntroError_securityCheckFailed,
      EnvoyStepState.ERROR,
      errorType: ScvErrorType.verificationFailed,
    );
  }

  Future<void> _trySendVerificationResult(
    SecurityCheckDuplex duplex,
    qlv2.VerificationResult result,
  ) async {
    try {
      await _sendVerificationResult(duplex, result);
    } catch (sendError, stack) {
      _logQlv2SecurityCheck(
        "failed sending verification result error=$sendError",
        stackTrace: stack,
      );
    }
  }

  Future<void> _sendVerificationResult(
    SecurityCheckDuplex duplex,
    qlv2.VerificationResult result,
  ) {
    _logQlv2SecurityCheck("sending verification result");
    return duplex.send(
      qlv2.RunSecurityCheckResponderEvent.verificationResult(result),
    );
  }

  bool _isDeadlineExpired(String error) {
    return error
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z]'), '')
        .contains('deadlineexpired');
  }

  Duration _serverTimeout(Duration clearnet) {
    return Settings().torEnabled()
        ? HttpTor.foregroundTorRequestTimeout + const Duration(seconds: 5)
        : clearnet;
  }
}

bool _alwaysHandle() => true;

void _logQlv2SecurityCheck(String message, {StackTrace? stackTrace}) {
  try {
    unawaited(
      EnvoyReport()
          .log(
            "qlv2_security_check",
            "[PrimeOnboarding] qlv2_scv: $message",
            stackTrace: stackTrace,
          )
          .catchError((Object error, StackTrace stackTrace) {}),
    );
  } catch (_) {}
}
