// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/onboard/expert/expert_setup.dart';
import 'package:envoy/ui/onboard/magic/magic_setup.dart';
import 'package:envoy/ui/pages/import_pp/single_import_pp_intro.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/generated/l10n.dart';

class OnboardingWelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Only onboard once
    //TODO: uncomment this line
    // LocalStorage().prefs.setBool("onboarded", true);
    return OnboardingPage(
      key: Key("onboarding_welcome_page"),
      leftFunction: null,
      clipArt: Image.asset("assets/envoy_passport.png"),
      text: [
        OnboardingText(
            header: S().envoy_pp_setup_intro_card1_heading,
            text: S().envoy_welcome_card1_subheading)
      ],
      buttons: [
        TextButton(
            child: Text("Setup passport instead",
                style: Theme.of(context)
                    .textTheme
                    .bodyText2
                    ?.copyWith(color: EnvoyColors.teal)),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return SingleImportPpIntroPage();
              }));
            }),
        OnboardingButton(
            light: true,
            label: "Expert Setup",
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return ExpertSetupPage();
              }));
            }),
        OnboardingButton(
            label: "Magic sSetup",
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return MagicSetup();
              }));
            }),
      ],
    );
  }
}
