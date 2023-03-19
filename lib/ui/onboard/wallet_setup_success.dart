// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/onboard/onboard_page_wrapper.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class WalletSetupSuccess extends StatefulWidget {
  const WalletSetupSuccess({Key? key}) : super(key: key);

  @override
  State<WalletSetupSuccess> createState() => _WalletSetupSuccessState();
}

class _WalletSetupSuccessState extends State<WalletSetupSuccess> {
  @override
  Widget build(BuildContext context) {
    return OnboardPageBackground(
      child: Material(
          child: Container(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  width: 240,
                  height: 240,
                  child: RiveAnimation.asset(
                    "assets/envoy_loader.riv",
                    fit: BoxFit.contain,
                    animations: ["happy"],
                  ),
                ),
                Text(
                  S().wallet_setup_success_heading,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  S().wallet_setup_success_subheading,
                  textAlign: TextAlign.center,
                ),
                OnboardingButton(
                    label: S().wallet_setup_success_CTA,
                    onTap: () {
                      Navigator.of(context).popUntil(ModalRoute.withName("/"));
                    }),
              ],
            ),
          ),
          color: Colors.transparent),
    );
  }
}
