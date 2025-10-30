// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/envoy_button.dart';
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
    return CustomOnboardingPage(
      key: const Key("fw_passport"),
      mainWidget: Image.asset(
        "assets/fw_passport.png",
        height: 270,
      ),
      title: S().envoy_fw_passport_heading,
      subheading: onboarding
          ? S().envoy_fw_passport_subheading
          : S().envoy_fw_passport_onboarded_subheading,
      buttons: [
        EnvoyButton(S().component_done,
            borderRadius:
                BorderRadius.all(Radius.circular(EnvoySpacing.medium1)),
            onTap: () {
          if (!onboarding) {
            context.go("/");
          } else {
            context.pushNamed(PASSPORT_INTRO);
          }
        }),
      ],
    );
  }
}
