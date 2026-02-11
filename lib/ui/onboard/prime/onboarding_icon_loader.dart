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
  rive.File? _riveFile;
  rive.RiveWidgetController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initRive();
  }

  void _initRive() async {
    _riveFile = await rive.File.asset(
      "assets/envoy_loader.riv",
      riveFactory: rive.Factory.rive,
    );
    _controller = rive.RiveWidgetController(
      _riveFile!,
      stateMachineSelector: rive.StateMachineSelector.byName('STM'),
    );

    // Set initial state
    _updateStateMachineInputs();

    setState(() => _isInitialized = true);
  }

  void _updateStateMachineInputs() {
    if (_controller?.stateMachine == null) return;

    final stateMachine = _controller!.stateMachine;

    // Reset all inputs first
    // ignore: deprecated_member_use
    stateMachine.boolean('Indeterminate')?.value = false;
    // ignore: deprecated_member_use
    stateMachine.boolean('no_icon_state')?.value = false;
    // ignore: deprecated_member_use
    stateMachine.boolean('happy')?.value = false;
    // ignore: deprecated_member_use
    stateMachine.boolean('unhappy')?.value = false;

    // Set the appropriate input based on current state
    switch (widget.state) {
      case IconLoaderState.indeterminate:
        // ignore: deprecated_member_use
        stateMachine.boolean('Indeterminate')?.value = true;
        break;
      case IconLoaderState.noIcon:
        // ignore: deprecated_member_use
        stateMachine.boolean('no_icon_state')?.value = true;
        break;
      case IconLoaderState.success:
        // ignore: deprecated_member_use
        stateMachine.boolean('happy')?.value = true;
        break;
      case IconLoaderState.error:
        // ignore: deprecated_member_use
        stateMachine.boolean('unhappy')?.value = true;
    }
  }

  @override
  void didUpdateWidget(covariant IconLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state != oldWidget.state) {
      _updateStateMachineInputs();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _riveFile?.dispose();
    super.dispose();
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
              child: _isInitialized && _controller != null
                  ? rive.RiveWidget(
                      controller: _controller!,
                      fit: rive.Fit.contain,
                    )
                  : const SizedBox(),
            ),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: widget.child ?? const SizedBox.shrink(),
        ),
      ],
    );
  }
}
