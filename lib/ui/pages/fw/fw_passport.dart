// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/pages/pp/pp_setup_intro.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/generated/l10n.dart';

//ignore: must_be_immutable
class FwPassportPage extends StatelessWidget {
  bool onboarding;

  FwPassportPage({super.key, this.onboarding = true});

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      key: const Key("fw_passport"),
      clipArt: Image.asset("assets/fw_passport.png"),
      rightFunction: (_) {
        onboarding
            ? OnboardingPage.popUntilHome(context)
            : OnboardingPage.popUntilGoRoute(context);
      },
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
        Padding(
          padding: const EdgeInsets.only(
              bottom: EnvoySpacing.medium2,
              left: EnvoySpacing.xs,
              right: EnvoySpacing.xs),
          child: OnboardingButton(
              label: S().component_continue,
              onTap: () {
                if (!onboarding) {
                  OnboardingPage.popUntilGoRoute(context);
                } else {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return const PpSetupIntroPage();
                  }));
                }
              }),
        ),
      ],
    );
  }
}
