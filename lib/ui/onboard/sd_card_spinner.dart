// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/fw_uploader.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SdCardSpinner extends ConsumerStatefulWidget {
  const SdCardSpinner({Key? key}) : super(key: key);

  @override
  ConsumerState<SdCardSpinner> createState() => _SdCardSpinnerState();
}

class _SdCardSpinnerState extends ConsumerState<SdCardSpinner> {
  SMIBool? happy;
  SMIBool? unHappy;
  SMIBool? indeterminate;
  StateMachineController? stateMachineController;

  var key = UniqueKey();

  void _onRiveInit(Artboard artboard) {
    stateMachineController =
        StateMachineController.fromArtboard(artboard, 'STM');
    artboard.addController(stateMachineController!);

    //State machine inputs
    happy = stateMachineController?.findInput<bool>('happy') as SMIBool;
    unHappy = stateMachineController?.findInput<bool>('unhappy') as SMIBool;
    indeterminate =
        stateMachineController?.findInput<bool>('indeterminate') as SMIBool;
    indeterminate?.change(true);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool?>(sdFwUploadProgressProvider, (_, newState) async {
      if (newState == null) return;
      indeterminate?.change(false);
      if (newState) {
        await Future.delayed(Duration(seconds: 5));
        happy?.change(true);
      } else {
        happy?.change(false);
        unHappy?.change(true);
      }
    });

    return Container(
        height: 300,
        alignment: Alignment.center,
        width: double.infinity,
        key: key,
        child: RiveAnimation.asset(
          'assets/envoy_loader.riv',
          onInit: _onRiveInit,
        ));
  }
}
