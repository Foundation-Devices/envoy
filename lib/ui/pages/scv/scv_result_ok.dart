// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/pages/pin/pin_intro.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/generated/l10n.dart';

//ignore: must_be_immutable
class ScvResultOkPage extends StatelessWidget {
  bool mustUpdateFirmware;
  ScvResultOkPage({super.key, this.mustUpdateFirmware = true});

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      key: Key("scv_result_ok"),
      clipArt: Image.asset("assets/shield_ok.png"),
      text: [
        OnboardingText(
            header: S().envoy_scv_result_ok_heading,
            text: S().envoy_scv_result_ok_subheading)
      ],
      buttons: [
        OnboardingButton(
            label: S().component_continue,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return PinIntroPage(
                  mustUpdateFirmware: mustUpdateFirmware,
                );
              }));
            }),
      ],
    );
  }
}
