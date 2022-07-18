// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/templates/onboarding_page.dart';
import 'package:envoy/ui/pages/fw/fw_microsd.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AccountEmailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    return OnboardingPage(
      key: Key("account_email"),
      text: [
        OnboardingText(
            header: loc.envoy_account_email_card1_heading,
            text: loc.envoy_account_email_card1_subheading)
      ],
      helperTextAbove: OnboardingHelperText(
        text: loc.envoy_account_email_card2_subheading1,
        onTap: () {},
      ),
      buttons: [
        OnboardingButton(
            label: loc.envoy_account_email_cta,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return FwMicrosdPage();
              }));
            }),
      ],
    );
  }
}
