// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/pages/pin/pin_intro.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/templates/onboarding_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

//ignore: must_be_immutable
class ScvResultOkPage extends StatelessWidget {
  bool mustUpdateFirmware;
  ScvResultOkPage({this.mustUpdateFirmware: true});

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    return OnboardingPage(
      key: Key("scv_result_ok"),
      clipArt: Image.asset("assets/shield_ok.png"),
      text: [
        OnboardingText(
            header: loc.envoy_scv_result_ok_heading,
            text: loc.envoy_scv_result_ok_subheading)
      ],
      buttons: [
        OnboardingButton(
            label: loc.envoy_scv_result_ok_cta,
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
