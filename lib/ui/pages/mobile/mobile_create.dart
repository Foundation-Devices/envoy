// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/pages/mobile/mobile_backup_intro.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/templates/onboarding_page.dart';
import 'package:envoy/generated/l10n.dart';

class MobileCreatePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      key: Key("mobile_create"),
      text: [
        OnboardingText(header: S().envoy_mobile_create_heading),
      ],
      buttons: [
        OnboardingButton(
            label: S().envoy_mobile_intro_cta,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return MobileBackupIntroPage();
              }));
            }),
      ],
    );
  }
}
