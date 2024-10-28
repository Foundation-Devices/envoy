// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/envoy_button.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';

class SingleWalletAddressVerifyConfirmPage extends StatelessWidget {
  const SingleWalletAddressVerifyConfirmPage({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      key: const Key("single_wallet_verify_confirm"),
      clipArt: Padding(
        padding: const EdgeInsets.all(EnvoySpacing.large1),
        child: Image.asset("assets/fi_shield.png", height: 140),
      ),
      text: [
        OnboardingText(
          header: S().pair_new_device_address_heading,
          text: S().pair_new_device_address_subheading,
          subtitleTopPadding: EnvoySpacing.medium3,
        ),
      ],
      buttons: [
        OnboardingButton(
          label: S().pair_new_device_address_cta2,
          onTap: () {
            launchUrl(Uri.parse("mailto:hello@foundation.xyz"));
          },
          type: EnvoyButtonTypes.secondary,
        ),
        OnboardingButton(
            label: S().component_continue,
            onTap: () {
              OnboardingPage.popUntilHome(context);
            }),
      ],
    );
  }
}
