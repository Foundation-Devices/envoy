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
import 'package:envoy/ui/widgets/envoy_step_item.dart';
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
        "Connecting to Prime", EnvoyStepState.LOADING);

    await Future.delayed(const Duration(seconds: 1));
    await bleStepNotifier.updateStep(
        "Connected to Passport Prime", EnvoyStepState.FINISHED);

    await deviceSecurityStepNotifier.updateStep(
        "Checking Device Security", EnvoyStepState.LOADING);
    await Future.delayed(const Duration(seconds: 2));
    await deviceSecurityStepNotifier.updateStep(
        "Checked Device Security", EnvoyStepState.FINISHED);

    await firmWareUpdateStepNotifier.updateStep(
        "Checking firmware updates", EnvoyStepState.LOADING);
    await Future.delayed(const Duration(seconds: 3));
    await firmWareUpdateStepNotifier.updateStep(
        "New Update available", EnvoyStepState.FINISHED);
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
                  child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: EnvoySpacing.xs,
                    horizontal: EnvoySpacing.medium1),
                child: Column(
                  children: [
                    Text(
                      //TODO: copy update
                      "Passport Prime Connected",
                      textAlign: TextAlign.center,
                      style: EnvoyTypography.heading,
                    ),
                    Expanded(child: Consumer(builder: (context, ref, child) {
                      final bleStep = ref.watch(bleConnectionProvider);
                      final deviceCheck = ref.watch(deviceSecurityProvider);
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: EnvoySpacing.medium1,
                          horizontal: EnvoySpacing.medium2,
                        ),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          direction: Axis.horizontal,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          runSpacing: EnvoySpacing.medium1,
                          children: [
                            EnvoyStepItem(step: bleStep),
                            EnvoyStepItem(step: deviceCheck),
                            EnvoyStepItem(
                                step: firmWareCheck,
                                highlight: updateAvailable),
                          ],
                        ),
                      );
                    })),
                    const Text(
                      "Optional place for a detailed message for\nour users so they understand the step.",
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
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
                            type: EnvoyButtonTypes.primary,
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
