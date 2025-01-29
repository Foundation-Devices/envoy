// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// ignore_for_file: constant_identifier_names

import 'package:envoy/ui/components/envoy_scaffold.dart';
import 'package:envoy/ui/onboard/onboard_page_wrapper.dart';
import 'package:envoy/ui/onboard/prime/onboarding_icon_loader.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart' as rive;

class PrimePinSetup extends ConsumerStatefulWidget {
  const PrimePinSetup({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PrimePinSetupState();
}

class _PrimePinSetupState extends ConsumerState<PrimePinSetup> {
  IconLoaderState _state = IconLoaderState.indeterminate;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: OnboardPageBackground(
          child: EnvoyScaffold(
        removeAppBarPadding: true,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: EnvoySpacing.small, vertical: EnvoySpacing.small),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 24,
            children: [
              IconLoader(
                state: _state,
                child: SizedBox.square(
                  dimension: 180,
                  child: rive.RiveAnimation.asset(
                    "assets/anim/lock.riv",
                    fit: BoxFit.contain,
                    onInit: (artBoard) async {
                      final stateMachineController =
                          rive.StateMachineController.fromArtboard(
                              artBoard, 'STM');
                      if (stateMachineController != null) {
                        artBoard.addController(stateMachineController);
                        await Future.delayed(const Duration(seconds: 3));
                        setState(() {
                          _state = IconLoaderState.noIcon;
                        });
                        stateMachineController
                            .findInput<bool>("Lock")
                            ?.change(true);
                      }
                    },
                  ),
                ),
              ),
              Text("Secure your Passport Prime",
                  style: EnvoyTypography.heading),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: EnvoySpacing.small,
                  vertical: EnvoySpacing.small,
                ),
                child: Text(
                  IconLoaderState.noIcon == _state
                      ? "Continue on Passport Prime."
                      : "Continue on Passport Prime, Envoy will never know your PIN or Password.\n\nPassport Prime will be wiped after 10 failed attempts.",
                  style: EnvoyTypography.body
                      .copyWith(color: EnvoyColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
