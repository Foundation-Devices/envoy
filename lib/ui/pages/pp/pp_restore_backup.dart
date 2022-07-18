// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/pages/pp/pp_restore_backup_password.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/templates/onboarding_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PpRestoreBackupPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    return OnboardingPage(
      key: Key("pp_restore_backup"),
      clipArt: Image.asset("assets/pp_restore_backup.png"),
      text: [
        OnboardingText(
            header: loc.envoy_pp_restore_backup_heading,
            text: loc.envoy_pp_restore_backup_subheading),
      ],
      navigationDots: 3,
      navigationDotsIndex: 0,
      buttons: [
        OnboardingButton(
            label: loc.envoy_pp_restore_backup_cta,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return PpRestoreBackupPasswordPage();
              }));
            }),
      ],
    );
  }
}
