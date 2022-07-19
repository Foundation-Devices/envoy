// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/templates/onboarding_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:envoy/ui/pages/fw/fw_intro.dart';
import 'package:envoy/ui/pages/pp/pp_setup_intro.dart';

class PinIntroPage extends StatelessWidget {
  bool mustUpdateFirmware;
  PinIntroPage({this.mustUpdateFirmware: true});

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    return OnboardingPage(
      key: Key("pin_intro"),
      clipArt: Image.asset("assets/pin_intro.png"),
      text: [
        OnboardingText(
            header: loc.envoy_pin_intro_heading,
            text: loc.envoy_pin_intro_subheading),
      ],
      buttons: [
        OnboardingButton(
            label: loc.envoy_pin_intro_cta,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                if (mustUpdateFirmware) {
                  return FwIntroPage();
                }
                else {
                  return PpSetupIntroPage();
                }
              }));
            }),
      ],
    );
  }
}
