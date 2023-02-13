// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SdCardSpinner extends ConsumerStatefulWidget {
  final StateProvider<bool> sdCardUploadSuccessProvider;
  const SdCardSpinner(this.sdCardUploadSuccessProvider, {Key? key})
      : super(key: key);

  @override
  ConsumerState<SdCardSpinner> createState() => _MoodySpinnerAnimationState();
}

class _MoodySpinnerAnimationState extends ConsumerState<SdCardSpinner> {
  SMIBool? happy;
  SMIBool? indeterminate;
  StateMachineController? stateMachineController;

  var key = UniqueKey();

  void _onRiveInit(Artboard artboard) {
    stateMachineController =
        StateMachineController.fromArtboard(artboard, 'STM');
    artboard.addController(stateMachineController!);

    //State machine inputs
    happy = stateMachineController?.findInput<bool>('happy') as SMIBool;
    indeterminate =
        stateMachineController?.findInput<bool>('indeterminate') as SMIBool;

    if (ref.read(widget.sdCardUploadSuccessProvider) == true) {
      happy?.change(true);
    } else {
      indeterminate?.change(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(widget.sdCardUploadSuccessProvider, (_, newState) {
      happy?.change(newState as bool);
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
