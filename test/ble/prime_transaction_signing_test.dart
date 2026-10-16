// SPDX-FileCopyrightText: 2026 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:envoy/ui/home/cards/accounts/spend/tx_review.dart';
import 'package:envoy/ui/onboard/prime/state/ble_onboarding_state.dart';
import 'package:envoy/ui/widgets/envoy_step_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('QLv2 shows signing progress before waiting and handles rejection',
      () async {
    final request = Completer<void>();
    final transferStep = StepNotifier(state: EnvoyStepState.IDLE);
    final signingStep = StepNotifier(state: EnvoyStepState.IDLE);
    addTearDown(transferStep.dispose);
    addTearDown(signingStep.dispose);

    final flow = sendPrimePsbtWithProgress(
      sendPsbt: () => request.future,
      waitsForSigningResponse: true,
      transferStep: transferStep,
      signingStep: signingStep,
      transferringLabel: 'Transferring',
      transferredLabel: 'Transferred',
      signingLabel: 'Signing',
    );

    expect(transferStep.state.state, EnvoyStepState.FINISHED);
    expect(signingStep.state.state, EnvoyStepState.LOADING);

    request.completeError(StateError('rejected'), StackTrace.current);
    await flow;

    expect(transferStep.state.state, EnvoyStepState.FINISHED);
    expect(signingStep.state.state, EnvoyStepState.ERROR);
  });

  test('QLv1 waits for transfer before showing signing progress', () async {
    final request = Completer<void>();
    final transferStep = StepNotifier(state: EnvoyStepState.IDLE);
    final signingStep = StepNotifier(state: EnvoyStepState.IDLE);
    addTearDown(transferStep.dispose);
    addTearDown(signingStep.dispose);

    final flow = sendPrimePsbtWithProgress(
      sendPsbt: () => request.future,
      waitsForSigningResponse: false,
      transferStep: transferStep,
      signingStep: signingStep,
      transferringLabel: 'Transferring',
      transferredLabel: 'Transferred',
      signingLabel: 'Signing',
    );

    expect(transferStep.state.state, EnvoyStepState.LOADING);
    expect(signingStep.state.state, EnvoyStepState.IDLE);

    request.complete();
    await flow;

    expect(transferStep.state.state, EnvoyStepState.FINISHED);
    expect(signingStep.state.state, EnvoyStepState.LOADING);
  });
}
