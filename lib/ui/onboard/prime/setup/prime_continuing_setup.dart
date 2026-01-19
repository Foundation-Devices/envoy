// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// ignore_for_file: constant_identifier_names

import 'dart:async';

import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/envoy_scaffold.dart';
import 'package:envoy/ui/components/pop_up.dart';
import 'package:envoy/ui/onboard/onboard_page_wrapper.dart';
import 'package:envoy/ui/onboard/prime/connection_lost_dialog.dart';
import 'package:envoy/ui/onboard/prime/prime_routes.dart';
import 'package:envoy/ui/onboard/prime/state/ble_onboarding_state.dart';
import 'package:envoy/ui/routes/accounts_router.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/ui/widgets/envoy_step_item.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_api/foundation_api.dart';
import 'package:go_router/go_router.dart';
import 'package:rive/rive.dart' as rive;

class PrimeContinuingSetup extends ConsumerStatefulWidget {
  const PrimeContinuingSetup({super.key});

  @override
  ConsumerState<PrimeContinuingSetup> createState() =>
      _PrimeContinuingSetupState();
}

class _PrimeContinuingSetupState extends ConsumerState<PrimeContinuingSetup> {
  bool canPop = false;
  rive.File? _riveFile;
  rive.RiveWidgetController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadRiveAnimation();
  }

  void _loadRiveAnimation() async {
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
  //
  // void _updateRiveState({bool happy = false, bool unhappy = false}) {
  //   if (_controller?.stateMachine == null) return;
  //   final stateMachine = _controller!.stateMachine;
  //   stateMachine.boolean("indeterminate")?.value = false;
  //   stateMachine.boolean("happy")?.value = happy;
  //   stateMachine.boolean("unhappy")?.value = unhappy;
  // }

  Future<bool> showExitWarning(BuildContext context) {
    final Completer<bool> completer = Completer<bool>();
    showEnvoyDialog(
      context: context,
      dismissible: true,
      dialog: EnvoyPopUp(
        icon: EnvoyIcons.alert,
        typeOfMessage: PopUpState.warning,
        showCloseButton: true,
        content: S().onboarding_connectionModalAbort_content,
        primaryButtonLabel: S().component_cancel,
        secondaryButtonLabel: S().component_exit,
        onPrimaryButtonTap: (context) async {
          completer.complete(false);
          Navigator.pop(context);
        },
        onSecondaryButtonTap: (context) async {
          completer.complete(true);
          Navigator.pop(context);
        },
      ),
    );
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    startBluetoothDisconnectionListener(context, ref);

    ref.listen(onboardingStateStreamProvider, (prev, next) {
      next.whenData((state) {
        if (state == OnboardingState.firmwareUpdateScreen) {
          context.goNamed(ONBOARD_PRIME_FIRMWARE_UPDATE);
        } else if (state == OnboardingState.securingDevice) {
          context.goNamed(ONBOARD_PRIME_CONTINUING_SETUP);
        } else if (state == OnboardingState.walletConected) {
          context.goNamed(ONBOARD_PRIME_CONNECTED_SUCCESS);
        } else if (state == OnboardingState.completed) {
          context.go(ROUTE_ACCOUNTS_HOME);
        }
      });
    });

    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (_, __) async {
        final shouldExit = await showExitWarning(context);
        if (shouldExit && context.mounted) {
          context.go(ROUTE_ACCOUNTS_HOME);
        }
      },
      child: OnboardPageBackground(
          child: EnvoyScaffold(
        removeAppBarPadding: true,
        topBarActions: const [],
        topBarLeading: IconButton(
          icon: const EnvoyIcon(
            EnvoyIcons.chevron_left,
            color: Colors.black,
          ),
          onPressed: () async {
            if (context.canPop()) {
              final shouldExit = await showExitWarning(context);
              if (shouldExit && context.mounted) {
                context.go(ROUTE_ACCOUNTS_HOME);
              }
            }
          },
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: EnvoySpacing.small, vertical: EnvoySpacing.small),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 24,
            children: [
              SizedBox(
                width: 220,
                height: 220,
                child: _isInitialized && _controller != null
                    ? Transform.scale(
                        scale: 1.6,
                        child: rive.RiveWidget(
                          controller: _controller!,
                          fit: rive.Fit.contain,
                        ),
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
                  children: [
                    Text(
                      S().finalize_catchAll_header,
                      textAlign: TextAlign.center,
                      style: EnvoyTypography.heading,
                    ),
                    Expanded(child: Consumer(builder: (context, ref, child) {
                      final pinStep = ref.watch(creatingPinProvider);
                      final setUpMasterKey = ref.watch(setUpMasterKeyProvider);
                      final backUpMasterKey =
                          ref.watch(backUpMasterKeyProvider);
                      final connectAccount = ref.watch(connectAccountProvider);

                      return Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: EnvoySpacing.medium3,
                          horizontal: EnvoySpacing.medium2,
                        ),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          direction: Axis.horizontal,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          runSpacing: EnvoySpacing.medium1,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                EnvoyStepItem(step: pinStep),
                                SizedBox(
                                  height: EnvoySpacing.medium1,
                                ),
                                EnvoyStepItem(step: setUpMasterKey),
                                SizedBox(
                                  height: EnvoySpacing.medium1,
                                ),
                                EnvoyStepItem(step: backUpMasterKey),
                                SizedBox(
                                  height: EnvoySpacing.medium1,
                                ),
                                EnvoyStepItem(
                                  step: connectAccount,
                                )
                              ],
                            ),
                          ],
                        ),
                      );
                    })),
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
