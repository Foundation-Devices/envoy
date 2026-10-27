// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/onboard/prime/state/ble_onboarding_state.dart';
import 'package:envoy/ui/widgets/envoy_step_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:envoy/ui/onboard/prime/state/prime_onboarding_controller.dart'
    show PrimeFwUpdateStep;

final primeUpdateStateProvider = Provider<PrimeFwUpdateStep>((ref) {
  return ref.watch(primeOnboardingControllerProvider).firmwareUpdateStep;
});

final fwDownloadStateProvider = Provider<StepModel>((ref) {
  return ref.watch(primeOnboardingControllerProvider).firmwareDownload ??
      StepModel(
        stepName: S().firmware_updatingDownload_downloading,
        state: EnvoyStepState.IDLE,
      );
});

StepModel _firmwareStep({
  required PrimeFwUpdateStep update,
  required Set<PrimeFwUpdateStep> completed,
  required PrimeFwUpdateStep activeStep,
  required Set<PrimeFwUpdateStep> finishedBy,
  required String loadingMessage,
  required String finishedMessage,
  required String idleMessage,
}) {
  if (update == activeStep) {
    return StepModel(stepName: loadingMessage, state: EnvoyStepState.LOADING);
  }
  if (completed.any(finishedBy.contains)) {
    return StepModel(stepName: finishedMessage, state: EnvoyStepState.FINISHED);
  }
  return StepModel(stepName: idleMessage, state: EnvoyStepState.IDLE);
}

final fwTransferStateProvider = StateNotifierProvider<StepNotifier, StepModel>((
  ref,
) {
  final updateState = ref.watch(primeUpdateStateProvider);
  if (updateState == PrimeFwUpdateStep.transferring) {
    return StepNotifier(
      stepName: S().firmware_downloadingUpdate_transferring,
      state: EnvoyStepState.LOADING,
    );
  } else {
    return StepNotifier(
      stepName: S().firmware_updatingDownload_transfer,
      state: EnvoyStepState.IDLE,
    );
  }
});

final primeFwSigVerifyStateProvider = Provider<StepModel>((ref) {
  final update = ref.watch(primeUpdateStateProvider);
  return _firmwareStep(
    update: update,
    completed:
        ref.watch(primeOnboardingControllerProvider).completedFirmwareSteps,
    activeStep: PrimeFwUpdateStep.verifying,
    finishedBy: const {
      PrimeFwUpdateStep.installing,
      PrimeFwUpdateStep.rebooting,
      PrimeFwUpdateStep.finished,
    },
    loadingMessage: S().firmware_updatingPrime_verifying,
    finishedMessage: S().firmware_updatingPrime_verified,
    //TODO: localization
    idleMessage: "Verifying Signatures",
  );
});

final primeFwInstallStateProvider = Provider<StepModel>((ref) {
  final update = ref.watch(primeUpdateStateProvider);
  return _firmwareStep(
    update: update,
    completed:
        ref.watch(primeOnboardingControllerProvider).completedFirmwareSteps,
    activeStep: PrimeFwUpdateStep.installing,
    finishedBy: const {
      PrimeFwUpdateStep.installing,
      PrimeFwUpdateStep.rebooting,
      PrimeFwUpdateStep.finished,
    },
    loadingMessage: S().firmware_updatingPrime_installingUpdate,
    finishedMessage: S().firmware_updatingPrime_updateInstalled,
    idleMessage: S().firmware_updatingPrime_installUpdate,
  );
});

final primeFwRebootStateProvider = Provider<StepModel>((ref) {
  final update = ref.watch(primeUpdateStateProvider);
  return _firmwareStep(
    update: update,
    completed:
        ref.watch(primeOnboardingControllerProvider).completedFirmwareSteps,
    activeStep: PrimeFwUpdateStep.rebooting,
    finishedBy: const {PrimeFwUpdateStep.rebooting},
    loadingMessage: S().firmware_updatingPrime_primeRestarting,
    finishedMessage: S().firmware_updatingPrime_primeRestarting,
    idleMessage: S().firmware_updatingPrime_restartPrime,
  );
});
