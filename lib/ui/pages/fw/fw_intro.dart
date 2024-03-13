// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/pages/fw/fw_microsd.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';

//ignore: must_be_immutable
class FwIntroPage extends StatelessWidget {
  bool onboarding;
  int deviceId;

  FwIntroPage({super.key, this.onboarding = true, this.deviceId = 1});

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      key: const Key("fw_intro"),
      rightFunction: (_) {
        onboarding
            ? OnboardingPage.popUntilHome(context)
            : OnboardingPage.popUntilGoRoute(context);
      },
      clipArt: Image.asset("assets/fw_intro.png"),
      text: [
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                OnboardingText(header: S().envoy_fw_intro_heading),
                LinkText(
                    text: S().envoy_fw_intro_subheading,
                    linkStyle: EnvoyTypography.button
                        .copyWith(color: EnvoyColors.accentPrimary),
                    onTap: () {
                      launchUrlString(
                          "https://github.com/Foundation-Devices/passport2/releases");
                    }),
              ],
            ),
          ),
        )
      ],
      navigationDots: 6,
      navigationDotsIndex: 0,
      buttons: [
        OnboardingButton(
            label: S().envoy_fw_intro_cta,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return FwMicrosdPage(
                  onboarding: onboarding,
                  deviceId: deviceId,
                );
              }));
            }),
      ],
    );
  }
}
