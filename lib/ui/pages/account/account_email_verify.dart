// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/templates/onboarding_page.dart';
import 'package:envoy/ui/pages/fw/fw_microsd.dart';
import 'package:envoy/generated/l10n.dart';

class AccountEmailVerifyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      key: Key("account_email_verify"),
      text: [
        OnboardingText(
            header: S().envoy_account_intro_heading,
            text: S().envoy_account_intro_cta2)
      ],
      buttons: [
        OnboardingButton(
            label: S().envoy_account_intro_cta,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return FwMicrosdPage();
              }));
            }),
        OnboardingButton(
            label: S().envoy_account_intro_cta1,
            onTap: () {
              OnboardingPage.goHome(context);
            }),
      ],
    );
  }
}
