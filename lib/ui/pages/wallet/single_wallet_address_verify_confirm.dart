// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:url_launcher/url_launcher.dart';

class SingleWalletAddressVerifyConfirmPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      key: Key("single_wallet_verify_confirm"),
      clipArt: Image.asset("assets/address_verify.png"),
      text: [
        OnboardingText(
            header: S().single_envoy_wallet_address_verify_confirm_heading,
            text: S().single_envoy_wallet_address_verify_confirm_subheading),
      ],
      buttons: [
        OnboardingButton(
          label: S().single_envoy_wallet_address_verify_confirm_cta1,
          onTap: () {
            launchUrl(Uri.parse("mailto:hello@foundationdevices.com"));
          },
          light: true,
        ),
        OnboardingButton(
            label: S().single_envoy_wallet_address_verify_confirm_cta,
            onTap: () {
              OnboardingPage.goHome(context);
            }),
      ],
    );
  }
}
