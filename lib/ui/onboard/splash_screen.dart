// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/onboard/expert/manual_setup.dart';
import 'package:envoy/ui/pages/import_pp/single_import_pp_intro.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/business/local_storage.dart';
import 'package:envoy/ui/envoy_icons.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'dart:io';
import 'magic/magic_create_wallet.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Only onboard once
    LocalStorage().prefs.setBool("onboarded", true);
    return OnboardingPage(
      key: Key("splash_screen"),
      leftFunction: null,
      clipArt: Image.asset("assets/envoy.png"),
      text: [
        OnboardingText(
            header: S().splash_screen_heading,
            text: S().splash_screen_subheading)
      ],
      buttons: [
        TextButton(
            child: Text(S().splash_screen_CTA3,
                style: Theme.of(context)
                    .textTheme
                    .bodyText2
                    ?.copyWith(color: EnvoyColors.teal)),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return SingleImportPpIntroPage();
              }));
            }),
        OnboardingButton(
            light: true,
            label: S().splash_screen_CTA2,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return ManualSetup();
              }));
            }),
        OnboardingButton(
            label: S().splash_screen_CTA1,
            onTap: () {
              showCreateWarning(context);
            }),
      ],
    );
  }

  void showCreateWarning(BuildContext context) {
    showEnvoyDialog(
      context: context,
      dismissible: true,
      builder: Builder(builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.38,
          width: MediaQuery.of(context).size.width * 0.8,
          constraints: BoxConstraints(maxHeight: 400, maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(padding: EdgeInsets.all(24)),
                Expanded(
                    child: Column(
                  children: [
                    Icon(EnvoyIcons.exclamation_warning,
                        color: EnvoyColors.brown, size: 56),
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
                )),
                OnboardingButton(
                    label: Platform.isAndroid
                        ? S().magic_setup_generate_wallet_modal_android_CTA
                        : S().magic_setup_generate_wallet_modal_ios_CTA,
                    onTap: () async {
                      Navigator.pop(context);
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return MagicCreateWallet();
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
