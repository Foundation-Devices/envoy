// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class RiveExample extends StatefulWidget {
  const RiveExample({Key? key}) : super(key: key);

  @override
  State<RiveExample> createState() => _RiveExampleAnimationState();
}

class _RiveExampleAnimationState extends State<RiveExample> {
  SMIBool? happy;
  SMIBool? unhappy;
  SMIBool? indeterminate;
  StateMachineController? stateMachineController;

  var key = UniqueKey();

  void _onRiveInit(Artboard artboard) {
    stateMachineController =
        StateMachineController.fromArtboard(artboard, 'STM');
    artboard.addController(stateMachineController!);

    //State machine inputs
    happy = stateMachineController?.findInput<bool>('happy') as SMIBool;
    unhappy = stateMachineController?.findInput<bool>('unhappy') as SMIBool;
    indeterminate =
        stateMachineController?.findInput<bool>('indeterminate') as SMIBool;

    //triggering indeterminate animation
    indeterminate?.change(true);
  }

  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
            height: 300,
            alignment: Alignment.center,
            width: double.infinity,
            key: key,
            child: RiveAnimation.asset(
              'assets/envoy_loader.riv',
              onInit: _onRiveInit,
            )),
        Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    key = UniqueKey();
                  });
                },
                child: Text("Indeterminate")),
            ElevatedButton(
                onPressed: () {
                  happy?.change(true);
                },
                child: Text("Happy")),
            ElevatedButton(
                onPressed: () {
                  unhappy?.change(true);
                },
                child: Text("Unhappy")),
          ],
        )
      ],
    );
  }
}
