// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/pages/pin/pin_intro.dart';
import 'package:envoy/ui/pages/scv/scv_show_qr.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/templates/onboarding_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ScvResultUpdatePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    return OnboardingPage(
      key: Key("scv_result_update"),
      clipArt: Image.asset("assets/shield_ok_info.png"),
      text: [
        OnboardingText(header: loc.envoy_scv_result_update_heading),
        ActionText(
          header: loc.envoy_scv_result_update_card1_subheading,
          text: loc.envoy_scv_result_update_card1_subheading1,
          action: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return PinIntroPage(); // TODO: Is this right?
            }));
          },
        ),
        ActionText(
          header: loc.envoy_scv_result_update_card2_subheading,
          text: loc.envoy_scv_result_update_card2_subheading,
          action: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return PinIntroPage();
            }));
          },
        ),
      ],
      buttons: [
        OnboardingButton(label: loc.envoy_scv_result_fail_cta, onTap: () {}),
        OnboardingButton(
            label: loc.envoy_scv_result_fail_cta1,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return ScvShowQrPage();
              }));
            }),
      ],
    );
  }
}
