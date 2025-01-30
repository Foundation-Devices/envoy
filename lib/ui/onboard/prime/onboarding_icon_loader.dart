// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

enum IconLoaderState { indeterminate, noIcon, success, error }

class IconLoader extends StatefulWidget {
  final Widget? child;
  final IconLoaderState state;
  const IconLoader({super.key, required this.state, this.child});

  @override
  State<IconLoader> createState() => _IconLoaderState();
}

class _IconLoaderState extends State<IconLoader> {
  rive.StateMachineController? _stateMachineController;

  @override
  void didUpdateWidget(covariant IconLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state != oldWidget.state) {
      _stateMachineController?.findInput<bool>("Indeterminate")?.change(false);
      _stateMachineController?.findInput<bool>("no_icon_state")?.change(false);
      _stateMachineController?.findInput<bool>("happy")?.change(false);
      _stateMachineController?.findInput<bool>("unhappy")?.change(false);
      switch (widget.state) {
        case IconLoaderState.indeterminate:
          _stateMachineController
              ?.findInput<bool>("Indeterminate")
              ?.change(true);
          break;
        case IconLoaderState.noIcon:
          _stateMachineController
              ?.findInput<bool>("no_icon_state")
              ?.change(true);
          break;
        case IconLoaderState.success:
          _stateMachineController?.findInput<bool>("happy")?.change(true);
          break;
        case IconLoaderState.error:
          _stateMachineController?.findInput<bool>("unhappy")?.change(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.center,
          child: Transform.scale(
            scale: 1.2,
            child: SizedBox(
              height: 260,
              child: rive.RiveAnimation.asset(
                "assets/envoy_loader.riv",
                fit: BoxFit.contain,
                onInit: (artboard) async {
                  _stateMachineController =
                      rive.StateMachineController.fromArtboard(artboard, 'STM');
                  artboard.addController(_stateMachineController!);
                  _stateMachineController
                      ?.findInput<bool>("indeterminate")
                      ?.change(true);
                },
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: widget.child ?? const SizedBox.shrink(),
        )
      ],
    );
  }
}
