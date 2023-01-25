// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/pages/account/account_email.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/generated/l10n.dart';

class AccountIntroPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      key: Key("account_intro"),
      text: [
        OnboardingText(
            header: S().envoy_account_intro_heading,
            text: S().envoy_account_intro_cta2)
      ],
      navigationDots: 3,
      navigationDotsIndex: 0,
      buttons: [
        OnboardingButton(
            label: S().envoy_account_intro_cta,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return AccountEmailPage();
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
