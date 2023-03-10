// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/pages/wallet/single_wallet_address_verify.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:wallet/wallet.dart';

class SingleWalletPairSuccessPage extends StatelessWidget {
  final Wallet pairedWallet;

  SingleWalletPairSuccessPage(this.pairedWallet);

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      key: Key("single_wallet_pair_success"),
      clipArt: Image.asset("assets/circle_ok.png"),
      text: [
        OnboardingText(
            header: S().single_envoy_wallet_pair_success_heading,
            text: S().single_envoy_wallet_pair_success_subheading),
      ],
      buttons: [
        OnboardingButton(
            label: S().single_envoy_wallet_pair_success_cta1,
            onTap: () {
              OnboardingPage.goHome(context);
            }),
        OnboardingButton(
            label: S().single_envoy_wallet_pair_success_cta,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return SingleWalletAddressVerifyPage(pairedWallet);
              }));
            }),
      ],
    );
  }
}
