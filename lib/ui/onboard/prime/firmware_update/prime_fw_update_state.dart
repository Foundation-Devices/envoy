// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/onboard/prime/state/ble_onboarding_state.dart';
import 'package:envoy/ui/widgets/envoy_step_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PrimeFwUpdateStep {
  downloading,
  transferring,
  verifying,
  installing,
  rebooting,
  finished,
  error,
  idle,
}

final primeUpdateStateProvider = StateProvider((ref) => PrimeFwUpdateStep.idle);

final fwDownloadStateProvider =
    StateNotifierProvider<StepNotifier, StepModel>((ref) {
  //TODO: copy update
  return StepNotifier(
      stepName: "Downloading Firmware", state: EnvoyStepState.IDLE);
});

final fwDownloadProgressProvider = StateProvider<double>((ref) => 0.0);

final fwTransferStateProvider =
    StateNotifierProvider<StepNotifier, StepModel>((ref) {
  //TODO: copy update
  return StepNotifier(
      stepName: "Transfering to Passport Prime", state: EnvoyStepState.IDLE);
});

final primeFwSigVerifyStateProvider =
    StateNotifierProvider<StepNotifier, StepModel>((ref) {
  //TODO: copy update
  return StepNotifier(
      stepName: "Verifying Signatures", state: EnvoyStepState.IDLE);
});

final primeFwInstallStateProvider =
    StateNotifierProvider<StepNotifier, StepModel>((ref) {
  //TODO: copy update
  return StepNotifier(stepName: "Install Update", state: EnvoyStepState.IDLE);
});

final primeFwRebootStateProvider =
    StateNotifierProvider<StepNotifier, StepModel>((ref) {
  //TODO: copy update
  return StepNotifier(
      stepName: "Reboot Passport Prime", state: EnvoyStepState.IDLE);
});
