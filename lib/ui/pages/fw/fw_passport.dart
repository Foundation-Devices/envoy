// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/pages/fw/fw_routes.dart';
import 'package:envoy/ui/routes/routes.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:go_router/go_router.dart';

//ignore: must_be_immutable
class FwPassportPage extends StatelessWidget {
  final FwPagePayload fwPagePayload;

  const FwPassportPage({super.key, required this.fwPagePayload});

  @override
  Widget build(BuildContext context) {
    bool onboarding = fwPagePayload.onboarding;
    return OnboardingPage(
      key: const Key("fw_passport"),
      leftFunction: (context) {
        context.go("/");
      },
      clipArt: Image.asset("assets/fw_passport.png"),
      text: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: EnvoySpacing.small),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  child: OnboardingText(
                    header: S().envoy_fw_passport_heading,
                    text: onboarding
                        ? S().envoy_fw_passport_subheading
                        : S().envoy_fw_passport_onboarded_subheading,
                  ),
                ),
              ),
            ],
          ),
        )
      ],
      navigationDots: 6,
      navigationDotsIndex: 5,
      buttons: [
        OnboardingButton(
            label: S().component_continue,
            onTap: () {
              if (!onboarding) {
                context.go("/");
              } else {
                context.goNamed(PASSPORT_INTRO);
              }
            }),
      ],
    );
  }
}
