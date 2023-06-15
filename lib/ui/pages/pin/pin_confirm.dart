// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/pages/fw/fw_intro.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/generated/l10n.dart';

class PinConfirmPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      key: Key("pin_confirm"),
      text: [
        OnboardingText(
            header: S().envoy_pin_confirm_heading,
            text: S().envoy_pin_confirm_subheading),
      ],
      navigationDots: 2,
      navigationDotsIndex: 1,
      buttons: [
        OnboardingButton(
            label: S().envoy_pin_confirm_cta,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return FwIntroPage();
              }));
            }),
      ],
    );
  }
}
