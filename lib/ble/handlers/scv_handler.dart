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

class ScvUpdateState {
  final String message;
  final EnvoyStepState step;

  ScvUpdateState({required this.message, required this.step});
}

/// Handler for SCV messages over Quantum Link.
class ScvHandler extends PassportMessageHandler {
  ScvHandler(super.writer);

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
  Future<void> handleMessage(
      api.QuantumLinkMessage message, String bleId) async {
    if (message
        case api.QuantumLinkMessage_SecurityCheck(field0: final check)) {
      if (check is api.SecurityCheck_ChallengeResponse) {
        final proofResult = check.field0;
        if (proofResult is api.ChallengeResponseResult_Success) {
          final proofData = proofResult.data;
          bool isVerified = await ScvServer().isProofVerified(proofData);
          if (isVerified) {
            updateScvState(S().onboarding_connectionChecking_SecurityPassed,
                EnvoyStepState.FINISHED);
            await sendSecurityChallengeVerificationResult(
                api.VerificationResult.success());
          } else {
            await sendSecurityChallengeVerificationResult(
                api.VerificationResult.error(error: "SVC verification failed"));

            updateScvState(
                S().onboarding_connectionIntroError_securityCheckFailed,
                EnvoyStepState.ERROR);
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

  void updateScvState(String message, EnvoyStepState step) {
    final state = ScvUpdateState(message: message, step: step);
    _scvUpdateController.add(state);
    _lastState = state;
  }

  Future<void> sendSecurityChallengeVerificationResult(
      api.VerificationResult result) async {
    final message = api.SecurityCheck.verificationResult(result);
    await writer.writeMessage(api.QuantumLinkMessage.securityCheck(message));
  }

  void sendSecurityChallenge() async {
    kPrint("sending security challenge");
    updateScvState(S().onboarding_connectionIntro_checkingDeviceSecurity,
        EnvoyStepState.LOADING);
    api.ChallengeRequest? challenge = await ScvServer().getPrimeChallenge();
    if (challenge == null) {
      // TODO: SCV what now?
      kPrint("No challenge available");
      return;
    }

    final request = api.SecurityCheck.challengeRequest(challenge);
    kPrint("writing security challenge");
    await writer.writeMessage(api.QuantumLinkMessage.securityCheck(request));
    kPrint("successfully wrote security challenge");
  }

  void reset() {
    updateScvState(
        S().firmware_updatingDownload_downloading, EnvoyStepState.IDLE);
  }
}
