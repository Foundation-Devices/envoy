// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// ignore_for_file: constant_identifier_names

import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/envoy_scaffold.dart';
import 'package:envoy/ui/onboard/onboard_page_wrapper.dart';
import 'package:envoy/ui/onboard/prime/state/ble_onboarding_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/envoy_step_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PrimeContinuingSetup extends ConsumerStatefulWidget {
  const PrimeContinuingSetup({super.key});

  @override
  ConsumerState<PrimeContinuingSetup> createState() =>
      _PrimeOnboardParingState();
}

class _PrimeOnboardParingState extends ConsumerState<PrimeContinuingSetup> {
  bool canPop = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canPop,
      child: OnboardPageBackground(
          child: EnvoyScaffold(
        removeAppBarPadding: true,
        topBarActions: const [],
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: EnvoySpacing.small, vertical: EnvoySpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 24,
            children: [
              SizedBox(
                height: 180,
                width: 180,
                child: CircularProgressIndicator(
                  color: EnvoyColors.tealLight,
                  backgroundColor: EnvoyColors.surface4,
                  strokeWidth: 15,
                  strokeCap: StrokeCap.round,
                ),
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
                          vertical: EnvoySpacing.medium1,
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
