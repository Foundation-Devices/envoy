// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/pages/fw/fw_routes.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher_string.dart';

class FwIntroPage extends StatelessWidget {
  final FwPagePayload fwPagePayload;

  const FwIntroPage({super.key, required this.fwPagePayload});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) => context.go("/"),
      child: OnboardingPage(
        key: const Key("fw_intro"),
        rightFunction: (_) {
          context.go("/");
        },
        clipArt: Transform.translate(
            offset: const Offset(0, 75),
            child: Image.asset("assets/fw_intro.png", height: 150)),
        text: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OnboardingText(header: S().envoy_fw_intro_heading),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: EnvoySpacing.medium2),
                        child: LinkText(
                            text: S().envoy_fw_intro_subheading,
                            linkStyle: EnvoyTypography.button
                                .copyWith(color: EnvoyColors.accentPrimary),
                            onTap: () {
                              launchUrlString(
                                  "https://github.com/Foundation-Devices/passport2/releases");
                            }),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
        navigationDots: 6,
        navigationDotsIndex: 0,
        buttons: [
          OnboardingButton(
              label: S().envoy_fw_intro_cta,
              onTap: () {
                context.goNamed(PASSPORT_UPDATE_SD_CARD, extra: fwPagePayload);
              }),
        ],
      ),
    );
  }
}
