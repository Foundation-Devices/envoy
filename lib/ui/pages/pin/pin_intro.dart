// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/pages/fw/fw_routes.dart';
import 'package:envoy/ui/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

//ignore: must_be_immutable
class PinIntroPage extends StatelessWidget {
  bool mustUpdateFirmware;

  PinIntroPage({super.key, this.mustUpdateFirmware = true});

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      key: const Key("pin_intro"),
      clipArt: Image.asset("assets/pin_intro.png"),
      text: [
        OnboardingText(
            header: S().envoy_pin_intro_heading,
            text: S().envoy_pin_intro_subheading),
      ],
      buttons: [
        OnboardingButton(
            label: S().component_continue,
            onTap: () {
              if (mustUpdateFirmware) {
                context.goNamed(PASSPORT_UPDATE,
                    extra: FwPagePayload(onboarding: true));
              } else {
                context.goNamed(PASSPORT_INTRO);
              }
            }),
      ],
    );
  }
}
