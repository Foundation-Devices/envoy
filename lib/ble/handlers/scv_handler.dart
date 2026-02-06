// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// ignore_for_file: constant_identifier_names///
import 'dart:async';

import 'package:envoy/ble/quantum_link_router.dart';
import 'package:envoy/business/scv_server.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/widgets/envoy_step_item.dart';
import 'package:envoy/util/console.dart';
import 'package:foundation_api/foundation_api.dart' as api;

/// Type of security check error
enum ScvErrorType {
  /// No error
  none,

  /// Network error - couldn't reach Foundation servers
  networkError,

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
  ScvHandler(super.connection);

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
        case api.QuantumLinkMessage_SecurityCheck(field0: final check)) {
      if (check is api.SecurityCheck_ChallengeResponse) {
        final proofResult = check.field0;
        if (proofResult is api.ChallengeResponseResult_Success) {
          final proofData = proofResult.data;
          final verificationResult = await ScvServer().verifyProof(proofData);

          switch (verificationResult) {
            case ScvVerificationResult.success:
              updateScvState(S().onboarding_connectionChecking_SecurityPassed,
                  EnvoyStepState.FINISHED);
              await sendSecurityChallengeVerificationResult(
                  api.VerificationResult.success());
              break;

            case ScvVerificationResult.networkError:
              // Network error - send Error to Prime and show pending state
              await sendNetworkError();
              return;

            case ScvVerificationResult.verificationFailed:
              // Actual verification failure - send Failure to Prime
              await sendSecurityChallengeVerificationResult(
                  api.VerificationResult.failure());
              updateScvState(
                  S().onboarding_connectionIntroError_securityCheckFailed,
                  EnvoyStepState.ERROR,
                  errorType: ScvErrorType.verificationFailed);
              return;
          }
        } else if (proofResult is api.ChallengeResponseResult_Error) {
          final proofError = proofResult.error;
          //TODO: fix SCV .
          kPrint("challege proof failed $proofError");
          await sendSecurityChallengeVerificationResult(
              api.VerificationResult.success());
          updateScvState(S().onboarding_connectionChecking_SecurityPassed,
              EnvoyStepState.FINISHED);
          // await ref.read(deviceSecurityProvider.notifier).updateStep(
          //     S().onboarding_connectionChecking_SecurityPassed,
          //     EnvoyStepState.FINISHED);
          // await ref.read(deviceSecurityProvider.notifier).updateStep(
          //     S().onboarding_connectionIntroError_securityCheckFailed,
          //     EnvoyStepState.ERROR);
        }
      } else if (check is api.SecurityCheck_ChallengeRequest) {
        kPrint("received unexpected security challenge request");
      } else if (check is api.SecurityCheck_VerificationResult) {
        kPrint("received invalid security message $message");
      }
    } else if (message case api.QuantumLinkMessage_PairingResponse _) {}
  }

  Future<void> sendNetworkError() async {
    // Network error - send Error to Prime and show pending state
    await sendSecurityChallengeVerificationResult(api.VerificationResult.error(
        error: "Network error: Unable to reach Foundation servers"));
    updateScvState(
        S().onboarding_connectionIntroErrorInternet_securityCheckPending,
        EnvoyStepState.ERROR,
        errorType: ScvErrorType.networkError);
  }

  void updateScvState(String message, EnvoyStepState step,
      {ScvErrorType errorType = ScvErrorType.none}) {
    final state =
        ScvUpdateState(message: message, step: step, errorType: errorType);
    _scvUpdateController.add(state);
    _lastState = state;
  }

  Future<void> sendSecurityChallengeVerificationResult(
      api.VerificationResult result) async {
    final message = api.SecurityCheck.verificationResult(result);
    await qlConnection
        .writeMessage(api.QuantumLinkMessage.securityCheck(message));
  }

  void sendSecurityChallenge() async {
    kPrint("sending security challenge");
    updateScvState(S().onboarding_connectionIntro_checkingDeviceSecurity,
        EnvoyStepState.LOADING);
    api.ChallengeRequest? challenge = await ScvServer().getPrimeChallenge();
    if (challenge == null) {
      sendNetworkError();
      return;
    }

    final request = api.SecurityCheck.challengeRequest(challenge);
    kPrint("writing security challenge");
    await qlConnection
        .writeMessage(api.QuantumLinkMessage.securityCheck(request));
    kPrint("successfully wrote security challenge");
  }

  void reset() {
    updateScvState(
        S().firmware_updatingDownload_downloading, EnvoyStepState.IDLE);
  }
}
