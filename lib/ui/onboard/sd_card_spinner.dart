// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/fw_uploader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart' as rive;

class SdCardSpinner extends ConsumerStatefulWidget {
  const SdCardSpinner({super.key});

  @override
  ConsumerState<SdCardSpinner> createState() => _SdCardSpinnerState();
}

class _SdCardSpinnerState extends ConsumerState<SdCardSpinner> {
  rive.File? _riveFile;
  rive.RiveWidgetController? _controller;
  bool _isInitialized = false;

  var key = UniqueKey();

  @override
  void initState() {
    super.initState();
    _initRive();
  }

  void _initRive() async {
    _riveFile = await rive.File.asset(
      'assets/envoy_loader.riv',
      riveFactory: rive.Factory.rive,
    );
    _controller = rive.RiveWidgetController(
      _riveFile!,
      stateMachineSelector: rive.StateMachineSelector.byName('STM'),
    );

    // Set initial indeterminate state
    //TODO: fix rive with databindings.
    // ignore: deprecated_member_use
    _controller?.stateMachine.boolean('indeterminate')?.value = true;

    setState(() => _isInitialized = true);
  }

  @override
  void dispose() {
    _controller?.dispose();
    _riveFile?.dispose();
    super.dispose();
  }

  void _setAnimationState({
    required bool happy,
    required bool unhappy,
    required bool indeterminate,
  }) {
    if (_controller?.stateMachine == null) return;
    final stateMachine = _controller!.stateMachine;

    //TODO: fix rive with databindings.
    // ignore: deprecated_member_use
    stateMachine.boolean('happy')?.value = happy;

    //TODO: fix rive with databindings.
    // ignore: deprecated_member_use
    stateMachine.boolean('unhappy')?.value = unhappy;

    //TODO: fix rive with databindings.
    // ignore: deprecated_member_use
    stateMachine.boolean('indeterminate')?.value = indeterminate;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool?>(sdFwUploadProgressProvider, (_, newState) async {
      if (newState == null) return;

      if (newState) {
        _setAnimationState(happy: false, unhappy: false, indeterminate: false);
        await Future.delayed(const Duration(seconds: 5));
        _setAnimationState(happy: true, unhappy: false, indeterminate: false);
      } else {
        _setAnimationState(happy: false, unhappy: true, indeterminate: false);
      }
    });

    return Container(
      height: 300,
      alignment: Alignment.center,
      width: double.infinity,
      key: key,
      child: _isInitialized && _controller != null
          ? rive.RiveWidget(controller: _controller!)
          : const SizedBox(),
    );
  }
}
