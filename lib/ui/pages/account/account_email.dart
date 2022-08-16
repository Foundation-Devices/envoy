// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/templates/onboarding_page.dart';
import 'package:envoy/ui/pages/fw/fw_microsd.dart';
import 'package:envoy/generated/l10n.dart';

class AccountEmailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      key: Key("account_email"),
      text: [
        OnboardingText(
            header: S().envoy_account_email_card1_heading,
            text: S().envoy_account_email_card1_subheading)
      ],
      helperTextAbove: OnboardingHelperText(
        text: S().envoy_account_email_card2_subheading1,
        onTap: () {},
      ),
      buttons: [
        OnboardingButton(
            label: S().envoy_account_email_cta,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return FwMicrosdPage();
              }));
            }),
      ],
    );
  }
}
