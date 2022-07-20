// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/pages/pp/pp_setup_intro.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/templates/onboarding_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

//ignore: must_be_immutable
class FwPassportPage extends StatelessWidget {
  bool returnHome;
  FwPassportPage({this.returnHome: false});

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    return OnboardingPage(
      key: Key("fw_passport"),
      clipArt: Image.asset("assets/fw_passport.png"),
      text: [
        OnboardingText(
          header: loc.envoy_fw_passport_heading,
          text: loc.envoy_fw_passport_subheading,
        )
      ],
      navigationDots: 3,
      navigationDotsIndex: 2,
      buttons: [
        OnboardingButton(
            label: loc.envoy_fw_passport_cta,
            onTap: () {
              if (returnHome) {
                OnboardingPage.goHome(context);
              } else {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return PpSetupIntroPage();
                }));
              }
            }),
      ],
    );
  }
}
