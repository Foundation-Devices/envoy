// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/pages/pp/pp_new_seed_success.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/generated/l10n.dart';

class PpNewSeedBackupPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      key: Key("pp_new_seed_backup"),
      clipArt: Image.asset("assets/pp_seed_backup.png"),
      text: [
        OnboardingText(
            header: S().envoy_pp_new_seed_backup_heading,
            text: S().envoy_pp_new_seed_backup_subheading),
      ],
      navigationDots: 3,
      navigationDotsIndex: 1,
      buttons: [
        OnboardingButton(
            label: S().envoy_pp_new_seed_backup_cta,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return PpNewSeedSuccessPage();
              }));
            }),
      ],
    );
  }
}
