// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// ignore_for_file: constant_identifier_names

import 'package:flutter_riverpod/flutter_riverpod.dart';

//TODO: add more concrete states based on bluetooth implementation
enum PairingStep { LOADING, FINISHED, ERROR, IDLE }

class StepModel {
  final String stepName;
  PairingStep state;

  StepModel({required this.stepName, this.state = PairingStep.LOADING});
}

class StepNotifier extends StateNotifier<StepModel> {
  StepNotifier()
      : super(StepModel(stepName: "Loading", state: PairingStep.IDLE));

  Future<void> updateStep(String stepName, PairingStep state) async {
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
