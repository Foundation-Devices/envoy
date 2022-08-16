// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/pages/pp/pp_new_seed_backup.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/templates/onboarding_page.dart';
import 'package:envoy/generated/l10n.dart';

class PpNewSeedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      key: Key("pp_new_seed"),
      clipArt: Image.asset("assets/pp_new_seed.png"),
      text: [
        OnboardingText(
            header: S().envoy_pp_new_seed_heading,
            text: S().envoy_pp_new_seed_subheading),
      ],
      navigationDots: 3,
      navigationDotsIndex: 0,
      buttons: [
        OnboardingButton(
            label: S().envoy_pp_new_seed_cta,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return PpNewSeedBackupPage();
              }));
            }),
      ],
    );
  }
}
