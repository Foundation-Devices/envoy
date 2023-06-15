// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/pages/pp/pp_restore_backup_success.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/generated/l10n.dart';

class PpRestoreBackupPasswordPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      key: Key("pp_restore_backup_password"),
      clipArt: Image.asset("assets/pp_encryption_words.png"),
      text: [
        OnboardingText(
            header: S().envoy_pp_restore_backup_password_heading,
            text: S().envoy_pp_restore_backup_password_subheading),
      ],
      navigationDots: 3,
      navigationDotsIndex: 1,
      buttons: [
        OnboardingButton(
            label: S().envoy_pp_restore_backup_password_cta,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return PpRestoreBackupSuccessPage();
              }));
            }),
      ],
    );
  }
}
