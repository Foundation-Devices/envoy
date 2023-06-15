// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/pages/account/account_email_verify.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/generated/l10n.dart';

class AccountPrivacyPolicy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      key: Key("account_privacy_policy"),
      text: [
        OnboardingText(
            header: S().envoy_account_intro_heading,
            text: S().envoy_account_intro_cta2)
      ],
      buttons: [
        OnboardingButton(
            label: S().envoy_account_intro_cta1,
            onTap: () {
              // TODO: contact the server here and show on response
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return AccountEmailVerifyPage();
              }));
            }),
      ],
    );
  }
}
