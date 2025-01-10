// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/home/home_state.dart';
import 'package:envoy/ui/pages/wallet/single_wallet_address_verify.dart';
import 'package:envoy/ui/state/home_page_state.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wallet/wallet.dart';

class SingleWalletPairSuccessPage extends StatelessWidget {
  final Wallet pairedWallet;

  const SingleWalletPairSuccessPage(this.pairedWallet, {super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      key: const Key("single_wallet_pair_success"),
      clipArt: Padding(
        padding: const EdgeInsets.only(top: 50.0),
        child: Image.asset(
          "assets/circle_ok.png",
          height: 150,
        ),
      ),
      text: [
        Align(
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: OnboardingText(
                header: S().pair_new_device_success_heading,
                text: S().pair_new_device_success_subheading),
          ),
        ),
      ],
      buttons: [
        OnboardingButton(
            type: EnvoyButtonTypes.secondary,
            label: S().pair_new_device_success_cta2,
            onTap: () {
              ProviderScope.containerOf(context)
                  .read(homePageBackgroundProvider.notifier)
                  .state = HomePageBackgroundState.hidden;
              ProviderScope.containerOf(context)
                  .read(homePageTitleProvider.notifier)
                  .state = "";
              context.go("/");
            }),
        OnboardingButton(
            label: S().pair_new_device_success_cta1,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return SingleWalletAddressVerifyPage(pairedWallet);
              }));
            }),
      ],
    );
  }
}
