// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// ignore_for_file: constant_identifier_names

import 'package:envoy/ui/components/envoy_scaffold.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/onboard/onboard_page_wrapper.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/onboard/prime/prime_routes.dart';
import 'package:envoy/ui/onboard/prime/state/ble_onboarding_state.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/util/build_context_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PrimeOnboardParing extends ConsumerStatefulWidget {
  const PrimeOnboardParing({super.key});

  @override
  ConsumerState<PrimeOnboardParing> createState() => _PrimeOnboardParingState();
}

class _PrimeOnboardParingState extends ConsumerState<PrimeOnboardParing> {
  bool canPop = false;
  //TODO: use provider to get firmware update status
  bool updateAvailable = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _mimicBleConnection();
    });
  }

  _mimicBleConnection() async {
    if (mounted) {
      setState(() {
        canPop = false;
      });
    }
    final bleStepNotifier = ref.read(bleConnectionProvider.notifier);
    final deviceSecurityStepNotifier =
        ref.read(deviceSecurityProvider.notifier);
    final firmWareUpdateStepNotifier =
        ref.read(firmWareUpdateProvider.notifier);

    await bleStepNotifier.updateStep(
        "Connecting to Prime", PairingStep.LOADING);

    await Future.delayed(const Duration(seconds: 1));
    await bleStepNotifier.updateStep(
        "Connected to Prime", PairingStep.FINISHED);

    await deviceSecurityStepNotifier.updateStep(
        "Checking Device Security", PairingStep.LOADING);
    await Future.delayed(const Duration(seconds: 2));
    await deviceSecurityStepNotifier.updateStep(
        "Checked Device Security", PairingStep.FINISHED);

    await firmWareUpdateStepNotifier.updateStep(
        "Checking firmware updates", PairingStep.LOADING);
    await Future.delayed(const Duration(seconds: 3));
    await firmWareUpdateStepNotifier.updateStep(
        "New Update available", PairingStep.FINISHED);
    if (mounted) {
      setState(() {
        canPop = true;
        updateAvailable = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final firmWareCheck = ref.watch(firmWareUpdateProvider);

    return PopScope(
      canPop: canPop,
      child: OnboardPageBackground(
          child: EnvoyScaffold(
        removeAppBarPadding: true,
        topBarActions: const [],
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: EnvoySpacing.small, vertical: EnvoySpacing.small),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 24,
            children: [
              Image.asset(
                "assets/images/prime_envoy_devices.png",
                alignment: Alignment.bottomCenter,
                width: MediaQuery.of(context).size.width * 0.8,
                height: 320,
              ),
              Expanded(
                  child: Column(
                children: [
                  Text(
                    //TODO: copy update
                    "Passport Prime Connected",
                    textAlign: TextAlign.center,
                    style: EnvoyTypography.heading,
                  ),
                  Expanded(
                      child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                                  vertical: EnvoySpacing.small)
                              .add(const EdgeInsets.only(
                            left: EnvoySpacing.medium2,
                          )),
                          child: Consumer(builder: (context, ref, child) {
                            final bleStep = ref.watch(bleConnectionProvider);
                            final deviceCheck =
                                ref.watch(deviceSecurityProvider);
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: EnvoySpacing.medium3,
                                vertical: EnvoySpacing.small,
                              ),
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                runSpacing: EnvoySpacing.medium1,
                                children: [
                                  PairingStepItem(step: bleStep),
                                  PairingStepItem(step: deviceCheck),
                                  PairingStepItem(
                                      step: firmWareCheck,
                                      updateAvailabe: updateAvailable),
                                ],
                              ),
                            );
                          }))),
                  const Text(
                    "Optional place for a detailed message for\nour users so they understand the step.",
                    textAlign: TextAlign.center,
                  )
                ],
              )),
              IntrinsicHeight(
                child: AnimatedOpacity(
                  opacity: updateAvailable ? 1 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Offstage(
                    offstage: !updateAvailable,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        OnboardingButton(
                            label: "Update Device",
                            type: EnvoyButtonTypes.secondary,
                            fontWeight: FontWeight.w600,
                            onTap: () {
                              context.goNamed(ONBOARD_PRIME_FIRMWARE_UPDATE);
                            }),
                        SizedBox(
                            height: context.isSmallScreen
                                ? EnvoySpacing.xs
                                : EnvoySpacing.medium2),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      )),
    );
  }
}

class PairingStepItem extends StatefulWidget {
  final StepModel? step;
  final bool updateAvailabe;
  const PairingStepItem({super.key, this.step, this.updateAvailabe = false});

  @override
  State<PairingStepItem> createState() => _PairingStepItemState();
}

class _PairingStepItemState extends State<PairingStepItem> {
  @override
  Widget build(BuildContext context) {
    final step = widget.step;
    if (step == null || step.state == PairingStep.IDLE) {
      return const SizedBox.shrink();
    }
    return Opacity(
      opacity: step.state == PairingStep.LOADING ? 1 : 0.6,
      child: Row(
        spacing: EnvoySpacing.small,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (step.state == PairingStep.LOADING)
            const CupertinoActivityIndicator(
              color: Colors.black,
              radius: 12,
            ),
          if (step.state == PairingStep.FINISHED)
            const Icon(CupertinoIcons.checkmark_alt, color: Colors.black),
          Padding(
            padding: const EdgeInsets.only(left: EnvoySpacing.xs),
            child: Text(
              step.stepName,
              style: EnvoyTypography.body.copyWith(
                fontWeight: widget.updateAvailabe ? FontWeight.w800 : null,
              ),
            ),
          )
        ],
      ),
    );
  }
}
