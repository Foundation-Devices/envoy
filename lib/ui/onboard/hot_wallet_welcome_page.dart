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

class HotWalletWelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Only onboard once
    //TODO: uncomment this line
    // LocalStorage().prefs.setBool("onboarded", true);
    return OnboardingPage(
      key: Key("hot_wallet_welcome_page"),
      leftFunction: null,
      clipArt: Image.asset("assets/envoy.png"),
      text: [
        OnboardingText(
            header: S().splash_screen_heading,
            text: S().splash_screen_subheading)
      ],
      buttons: [
        TextButton(
            child: Text(S().splash_screen_cta3,
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
            label: S().splash_screen_cta2,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return ExpertSetupPage();
              }));
            }),
        OnboardingButton(
            label: S().splash_screen_cta1,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return MagicSetup();
              }));
            }),
      ],
    );
  }
}
