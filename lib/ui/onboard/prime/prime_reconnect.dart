// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ble/bluetooth_manager.dart';
import 'package:envoy/business/devices.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/envoy_scaffold.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/onboard/onboard_page_wrapper.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/routes/accounts_router.dart';
import 'package:envoy/ui/routes/devices_router.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rive/rive.dart' as rive;

// Reconnect page for Prime device.
// this page specifically for devices that have been already onboarded once.
class PrimeReconnect extends ConsumerStatefulWidget {
  const PrimeReconnect({super.key});

  @override
  ConsumerState createState() => _PrimeReconnectState();
}

class _PrimeReconnectState extends ConsumerState<PrimeReconnect> {
  rive.File? _riveFile;
  rive.RiveWidgetController? _controller;

  bool _success = false;
  bool _isInitialized = false;
  VoidCallback? _deviceListener;

  static const Duration _pairingTimeout = Duration(seconds: 10);

  @override
  void initState() {
    super.initState();
    _loadRiveAnimation();
  }

  @override
  void dispose() {
    if (_deviceListener != null) {
      Devices().removeListener(_deviceListener!);
    }
    _controller?.dispose();
    super.dispose();
  }

  void _loadRiveAnimation() async {
    _listenForPairingState();
    try {
      _riveFile = await rive.File.asset('assets/envoy_loader.riv',
          riveFactory: rive.Factory.rive);
      _controller = rive.RiveWidgetController(
        _riveFile!,
        stateMachineSelector: rive.StateMachineSelector.byName('STM'),
      );

      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      kPrint('Error loading Rive file: $e');
    }
  }

  void _listenForPairingState() async {
    try {
      final devices = Devices();
      final targetBleId = BluetoothManager().bleId;
      bool foundDevice = false;

      _deviceListener = () {
        final primes = devices.getPrimeDevices;
        if (primes.where((d) => d.bleId == targetBleId).isNotEmpty) {
          foundDevice = true;
          kPrint("Device found with matching BLE ID: $targetBleId");
        }
      };

      devices.addListener(_deviceListener!);

      await Future.doWhile(() async {
        await Future.delayed(Duration(milliseconds: 200));
        return !foundDevice && _controller?.active != true;
      }).timeout(_pairingTimeout, onTimeout: () {
        throw Exception("Pairing response timeout - device not found");
      });

      await Future.delayed(Duration(milliseconds: 1500));

      if (mounted) {
        setState(() {
          _success = true;
        });
        _updateRiveState(happy: true);
      }
    } catch (e) {
      kPrint('Pairing failed: $e');
      if (mounted) {
        setState(() {
          _success = false;
        });
        _updateRiveState(unhappy: true);
      }
    }
  }

  void _updateRiveState({bool happy = false, bool unhappy = false}) {
    if (_controller?.stateMachine == null) return;
    final stateMachine = _controller!.stateMachine;
    //TODO: fix rive with databindings.
    // ignore: deprecated_member_use
    stateMachine.boolean("indeterminate")?.value = false;
    //TODO: fix rive with databindings.
    // ignore: deprecated_member_use
    stateMachine.boolean("happy")?.value = happy;
    //TODO: fix rive with databindings.
    // ignore: deprecated_member_use
    stateMachine.boolean("unhappy")?.value = unhappy;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) {
        context.goNamed(ROUTE_ACCOUNTS_HOME);
      },
      child: OnboardPageBackground(
          child: EnvoyScaffold(
        removeAppBarPadding: true,
        topBarActions: const [],
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: EnvoySpacing.small, vertical: EnvoySpacing.xs),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 24,
            children: [
              SizedBox(
                height: 260,
                child: _isInitialized && _controller != null
                    ? rive.RiveWidget(
                        controller: _controller!,
                        fit: rive.Fit.contain,
                      )
                    : const SizedBox(),
              ),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: EnvoySpacing.xs,
                    horizontal: EnvoySpacing.medium1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _success
                          ? "Device Paired Successfully!"
                          : "Waiting for Device to Pair...",
                      style: Theme.of(context).textTheme.titleSmall,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                        width: double.infinity,
                        child: _success
                            ? OnboardingButton(
                                type: EnvoyButtonTypes.primaryModal,
                                label: S().component_continue,
                                onTap: () {
                                  context.go(ROUTE_DEVICES);
                                })
                            : const SizedBox()),
                  ],
                ),
              )),
            ],
          ),
        ),
      )),
    );
  }
}
