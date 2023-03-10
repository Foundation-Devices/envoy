// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/pages/pp/pp_new_seed.dart';
import 'package:envoy/ui/pages/pp/pp_restore_backup.dart';
import 'package:envoy/ui/pages/pp/pp_restore_seed.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/generated/l10n.dart';

class PpSetupIntroPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      key: Key("pp_setup_intro"),
      clipArt: Image.asset("assets/pp_setup_intro.png"),
      text: [
        OnboardingText(
            header: S().envoy_pp_setup_intro_card1_heading,
            text: S().envoy_pp_setup_intro_card1_subheading),
      ],
      buttons: [
        OnboardingButton(
            type: EnvoyButtonTypes.SECONDARY,
            label: S().envoy_pp_setup_intro_card4_heading,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return PpRestoreBackupPage();
              }));
            }),
        OnboardingButton(
            type: EnvoyButtonTypes.SECONDARY,
            label: S().envoy_pp_setup_intro_card3_heading,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return PpRestoreSeedPage();
              }));
            }),
        OnboardingButton(
            label: S().envoy_pp_setup_intro_card2_heading,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return PpNewSeedPage();
              }));
            }),
      ],
    );
  }
}
