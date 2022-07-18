// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/pages/account/account_privacy_policy.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/templates/onboarding_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AccountTosPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    return OnboardingPage(
      key: Key("account_tos"),
      text: [
        OnboardingText(
            header: loc.envoy_account_intro_heading,
            text: loc.envoy_account_intro_cta2)
      ],
      buttons: [
        OnboardingButton(
            label: loc.envoy_account_intro_cta1,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return AccountPrivacyPolicy();
              }));
            }),
      ],
    );
  }
}
