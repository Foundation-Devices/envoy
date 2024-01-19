// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/pages/fw/fw_passport.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:rive/rive.dart';

class FwIosSuccessPage extends StatelessWidget {
  final bool onboarding;

  FwIosSuccessPage({required this.onboarding});

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      leftFunction: (context) {
        Navigator.of(context).pop();
      },
      rightFunction: (_) {
        onboarding
            ? OnboardingPage.popUntilHome(context)
            : OnboardingPage.popUntilGoRoute(context);
      },
      key: Key("fw_ios_success"),
      text: [
        OnboardingText(
          header: S().envoy_fw_success_heading,
          text: S().envoy_fw_success_subheading_ios,
        ),
      ],
      clipArt: RiveAnimation.asset(
        "assets/envoy_loader.riv",
        fit: BoxFit.contain,
        animations: ["happy"],
      ),
      navigationDots: 6,
      navigationDotsIndex: 4,
      buttons: [
        OnboardingButton(
            label: S().component_continue,
            onTap: () {
              Navigator.of(context)
                  .pushReplacement(MaterialPageRoute(builder: (context) {
                return FwPassportPage(
                  onboarding: onboarding,
                );
              }));
            })
      ],
    );
  }
}
