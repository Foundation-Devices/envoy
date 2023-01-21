// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/pages/pp/pp_setup_intro.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/generated/l10n.dart';

class MobileBackupConfirmPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      key: Key("mobile_backup_confirm"),
      text: [
        OnboardingText(
            header: S().envoy_mobile_backup_confirm_card1_heading,
            text: S().envoy_mobile_backup_confirm_card1_subheading),
        OnboardingText(
            header: S().envoy_mobile_backup_confirm_card2_heading,
            text: S().envoy_mobile_backup_confirm_card2_subheading),
      ],
      buttons: [
        OnboardingButton(
            label: S().envoy_mobile_backup_confirm_cta,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return PpSetupIntroPage();
              }));
            }),
      ],
    );
  }
}
