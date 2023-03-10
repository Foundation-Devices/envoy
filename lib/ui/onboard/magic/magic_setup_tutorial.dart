// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/onboard/magic/magic_recover_wallet.dart';
import 'package:envoy/ui/onboard/magic/wallet_security/wallet_security_modal.dart';
import 'package:envoy/ui/onboard/onboard_page_wrapper.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:envoy/generated/l10n.dart';
import 'dart:io';
import 'package:envoy/ui/onboard/magic/magic_setup_generate.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/ui/envoy_icons.dart';

class MagicSetupTutorial extends StatefulWidget {
  const MagicSetupTutorial({Key? key}) : super(key: key);

  @override
  State<MagicSetupTutorial> createState() => _MagicSetupTutorialState();
}

class _MagicSetupTutorialState extends State<MagicSetupTutorial> {
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
              child: Text(S().magic_setup_tutorial_ios_skip,
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
                        S().magic_setup_tutorial_ios_heading,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      Padding(padding: EdgeInsets.all(24)),
                      OnboardingHelperText(
                        text: Platform.isAndroid
                            ? S().magic_setup_tutorial_android_subheading
                            : S().magic_setup_tutorial_ios_subheading,
                        onTap: () {
                          showEnvoyDialog(
                              context: context,
                              dialog: WalletSecurityModal(
                                onLastStep: () {
                                  Navigator.pop(context);
                                },
                              ));
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
                      child: OnboardingButton(
                          fontWeight: FontWeight.w600,
                          type: EnvoyButtonTypes.SECONDARY,
                          label: S().magic_setup_tutorial_ios_CTA2,
                          textStyle: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                  color: EnvoyColors.darkTeal,
                                  fontWeight: FontWeight.w600),
                          onTap: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return MagicRecoverWallet();
                            }));
                          }),
                    ),
                    OnboardingButton(
                        fontWeight: FontWeight.w600,
                        textStyle: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                                color: EnvoyColors.white100,
                                fontWeight: FontWeight.w600),
                        label: S().magic_setup_tutorial_ios_CTA1,
                        onTap: () {
                          showCreateWarning(context);
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

  void showCreateWarning(BuildContext context) {
    showEnvoyDialog(
      context: context,
      dismissible: true,
      builder: Builder(builder: (context) {
        return Container(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(padding: EdgeInsets.all(24)),
                Column(
                  children: [
                    Icon(EnvoyIcons.exclamation_warning,
                        color: EnvoyColors.darkCopper, size: 56),
                    Padding(padding: EdgeInsets.all(12)),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        Platform.isAndroid
                            ? S()
                                .magic_setup_generate_wallet_modal_android_subheading
                            : S()
                                .magic_setup_generate_wallet_modal_ios_subheading,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                OnboardingButton(
                    label: Platform.isAndroid
                        ? S().magic_setup_generate_wallet_modal_android_CTA
                        : S().magic_setup_generate_wallet_modal_ios_CTA,
                    onTap: () async {
                      Navigator.pop(context);
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return MagicSetupGenerate();
                      }));
                    }),
                Padding(padding: EdgeInsets.all(12)),
              ],
            ),
          ),
        );
      }),
    );
  }
}
