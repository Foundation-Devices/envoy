// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/pages/pp/pp_restore_seed_backup.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/generated/l10n.dart';

class PpRestoreSeedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      key: Key("pp_restore_seed"),
      clipArt: Image.asset("assets/pp_restore_seed.png"),
      text: [
        OnboardingText(
            header: S().envoy_pp_restore_seed_heading,
            text: S().envoy_pp_restore_seed_subheading),
      ],
      navigationDots: 3,
      navigationDotsIndex: 0,
      buttons: [
        OnboardingButton(
            label: S().envoy_pp_restore_seed_cta,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return PpRestoreSeedBackupPage();
              }));
            }),
      ],
    );
  }
}
