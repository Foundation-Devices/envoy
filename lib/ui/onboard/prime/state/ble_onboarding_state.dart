// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// ignore_for_file: constant_identifier_names

import 'package:envoy/ui/widgets/envoy_step_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StepNotifier extends StateNotifier<StepModel> {
  StepNotifier({stepName = "Loading", state = EnvoyStepState.HIDDEN})
      : super(StepModel(stepName: stepName, state: state));

  Future<void> updateStep(String stepName, EnvoyStepState state) async {
    this.state = StepModel(stepName: stepName, state: state);
  }
}

final bleConnectionProvider =
    StateNotifierProvider<StepNotifier, StepModel>((ref) {
  return StepNotifier();
});

final deviceSecurityProvider =
    StateNotifierProvider<StepNotifier, StepModel>((ref) {
  return StepNotifier();
});

final firmWareUpdateProvider =
    StateNotifierProvider<StepNotifier, StepModel>((ref) {
  return StepNotifier();
});
