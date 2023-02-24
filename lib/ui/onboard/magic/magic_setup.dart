// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/onboard/magic/magic_recover_wallet.dart';
import 'package:envoy/ui/onboard/onboard_page_wrapper.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:flutter/material.dart';

class MagicSetup extends StatefulWidget {
  const MagicSetup({Key? key}) : super(key: key);

  @override
  State<MagicSetup> createState() => _MagicSetupState();
}

class _MagicSetupState extends State<MagicSetup> {
  @override
  Widget build(BuildContext context) {
    return OnboardPageBackground(
        child: Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: TextButton(
              child: Text("MISSING", //S().magic_setup_generate_wallet_skip,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.black)),
              onPressed: () {
                OnboardingPage.goHome(context);
              },
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                    child: Container(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "MISSING", //S().magic_setup_flow_tutorial_heading,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      Padding(padding: EdgeInsets.all(24)),
                      OnboardingHelperText(
                        text:
                            "MISSING", //S().magic_setup_flow_tutorial_subheading,
                        onTap: () {
                          // Surface the explainers
                        },
                      ),
                    ],
                  ),
                )),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox.shrink(),
                ),
                Flexible(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: double.infinity,
                      child: TextButton(
                          child: Text(
                              "MISSING", //S().magic_setup_flow_tutorial_CTA_2,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2
                                  ?.copyWith(color: EnvoyColors.teal)),
                          onPressed: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return MagicRecoverWallet();
                            }));
                          }),
                    ),
                    OnboardingButton(
                        light: false,
                        label: "MISSING", //S().magic_setup_flow_tutorial_CTA_1,
                        onTap: () {
                          //showCreateWarning(context);
                        }),
                  ],
                ))
              ],
            ),
          ),
        ),
      ],
    ));
  }
}
