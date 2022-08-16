// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/pages/pin/pin_intro.dart';
import 'package:envoy/ui/pages/scv/scv_show_qr.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/templates/onboarding_page.dart';
import 'package:envoy/generated/l10n.dart';

class ScvResultUpdatePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      key: Key("scv_result_update"),
      clipArt: Image.asset("assets/shield_ok_info.png"),
      text: [
        OnboardingText(header: S().envoy_scv_result_update_heading),
        ActionText(
          header: S().envoy_scv_result_update_card1_subheading,
          text: S().envoy_scv_result_update_card1_subheading1,
          action: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return PinIntroPage(); // TODO: Is this right?
            }));
          },
        ),
        ActionText(
          header: S().envoy_scv_result_update_card2_subheading,
          text: S().envoy_scv_result_update_card2_subheading,
          action: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return PinIntroPage();
            }));
          },
        ),
      ],
      buttons: [
        OnboardingButton(label: S().envoy_scv_result_fail_cta, onTap: () {}),
        OnboardingButton(
            label: S().envoy_scv_result_fail_cta1,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return ScvShowQrPage();
              }));
            }),
      ],
    );
  }
}
