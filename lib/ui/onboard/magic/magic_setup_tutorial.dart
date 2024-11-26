// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/envoy_scaffold.dart';
import 'package:envoy/ui/embedded_video.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/onboard/magic/wallet_security/wallet_security_modal.dart';
import 'package:envoy/ui/onboard/onboard_page_wrapper.dart';
import 'package:envoy/ui/onboard/onboard_welcome.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/onboard/routes/onboard_routes.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/util/build_context_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MagicSetupTutorial extends StatefulWidget {
  const MagicSetupTutorial({super.key});

  @override
  State<MagicSetupTutorial> createState() => _MagicSetupTutorialState();
}

class _MagicSetupTutorialState extends State<MagicSetupTutorial> {
  final GlobalKey<EmbeddedVideoState> _playerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return OnboardPageBackground(
        child: EnvoyScaffold(
      removeAppBarPadding: true,
      topBarLeading: CupertinoNavigationBarBackButton(
        color: Colors.black,
        onPressed: () => context.pop(),
      ),
      topBarActions: [
        TextButton(
          child: Text(S().component_skip,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.black)),
          onPressed: () {
            context.go("/");
          },
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: EnvoySpacing.xs),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: EnvoySpacing.medium2),
              child: Container(
                padding: const EdgeInsets.only(top: 5),
                child: Column(
                  children: [
                    !Platform.isLinux
                        ? EmbeddedVideo(
                            path: "assets/videos/magic_backups.m4v",
                            key: _playerKey,
                          )
                        : Container(),
                  ],
                ),
              ),
            ),
            const Padding(padding: EdgeInsets.only(bottom: 6)),
            Text(
              S().magic_setup_tutorial_heading,
              textAlign: TextAlign.center,
              style: EnvoyTypography.heading,
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: EnvoySpacing.medium2),
              child: LinkText(
                text: Platform.isAndroid
                    ? S().magic_setup_tutorial_android_subheading
                    : S().magic_setup_tutorial_ios_subheading,
                linkStyle: EnvoyTypography.button
                    .copyWith(color: EnvoyColors.accentPrimary),
                onTap: () {
                  _playerKey.currentState?.pause();
                  showEnvoyDialog(
                      context: context,
                      dialog: WalletSecurityModal(
                        onLastStep: () {
                          Navigator.pop(context);
                        },
                      ));
                },
              ),
            ),
            Column(
              children: [
                Consumer(
                  builder: (context, ref, child) {
                    return OnboardingButton(
                        fontWeight: FontWeight.w600,
                        type: EnvoyButtonTypes.secondary,
                        label: S().magic_setup_tutorial_ios_CTA2,
                        textStyle: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                                color: EnvoyColors.accentPrimary,
                                fontWeight: FontWeight.w600),
                        onTap: () {
                          _playerKey.currentState?.pause();
                          //reset flags since the user manually trying to recover
                          ref.read(triedAutomaticRecovery.notifier).state =
                              false;
                          ref.read(successfulManualRecovery.notifier).state =
                              false;
                          ref.read(successfulSetupWallet.notifier).state =
                              false;
                          context.pushNamed(ONBOARD_ENVOY_MAGIC_RECOVER_SETUP);
                        });
                  },
                ),
                OnboardingButton(
                    fontWeight: FontWeight.w600,
                    textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: EnvoyColors.surface2,
                        fontWeight: FontWeight.w600),
                    label: S().magic_setup_tutorial_ios_CTA1,
                    onTap: () {
                      _playerKey.currentState?.pause();
                      context.pushNamed(ONBOARD_ENVOY_MAGIC_GENERATE_SETUP);
                    }),
                const SizedBox(height: EnvoySpacing.xs),
                SizedBox(
                    height: context.isSmallScreen
                        ? EnvoySpacing.medium1
                        : EnvoySpacing.medium2),
              ],
            )
          ],
        ),
      ),
    ));
  }

// void showCreateWarning(BuildContext context) {
//   showEnvoyDialog(
//     context: context,
//     dismissible: true,
//     builder: Builder(builder: (context) {
//       return Container(
//         width: MediaQuery.of(context).size.width * 0.8,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Padding(padding: EdgeInsets.all(24)),
//               Column(
//                 children: [
//                   Icon(EnvoyIcons.exclamation_warning,
//                       color: EnvoyColors.darkCopper, size: 56),
//                   Padding(padding: EdgeInsets.all(12)),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 8),
//                     child: Text(
//                       Platform.isAndroid
//                           ? S()
//                               .magic_setup_generate_wallet_modal_android_subheading
//                           : S()
//                               .magic_setup_generate_wallet_modal_ios_subheading,
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                 ],
//               ),
//               OnboardingButton(
//                   label: Platform.isAndroid
//                       ? S().magic_setup_generate_wallet_modal_android_CTA
//                       : S().component_continue,
//                   onTap: () async {
//                     Navigator.pop(context);
//                     Navigator.of(context)
//                         .push(MaterialPageRoute(builder: (context) {
//                       return MagicSetupGenerate();
//                     }));
//                   }),
//               Padding(padding: EdgeInsets.all(12)),
//             ],
//           ),
//         ),
//       );
//     }),
//   );
// }
}
