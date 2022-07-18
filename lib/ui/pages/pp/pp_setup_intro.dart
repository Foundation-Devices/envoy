// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/pages/pp/pp_new_seed.dart';
import 'package:envoy/ui/pages/pp/pp_restore_backup.dart';
import 'package:envoy/ui/pages/pp/pp_restore_seed.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/templates/onboarding_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PpSetupIntroPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    return OnboardingPage(
      key: Key("pp_setup_intro"),
      clipArt: Image.asset("assets/pp_setup_intro.png"),
      text: [
        OnboardingText(
            header: loc.envoy_pp_setup_intro_card1_heading,
            text: loc.envoy_pp_setup_intro_card1_subheading),
      ],
      buttons: [
        OnboardingButton(
            light: true,
            label: loc.envoy_pp_setup_intro_card4_heading,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return PpRestoreBackupPage();
              }));
            }),
        OnboardingButton(
            light: true,
            label: loc.envoy_pp_setup_intro_card3_heading,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return PpRestoreSeedPage();
              }));
            }),
        OnboardingButton(
            label: loc.envoy_pp_setup_intro_card2_heading,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return PpNewSeedPage();
              }));
            }),
      ],
    );
  }
}
