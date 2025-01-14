// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 0, bottom: 50),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: EnvoySpacing.medium3),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(height: EnvoySpacing.medium2),
                    MenuOption(
                      icon: EnvoyIcons.externalLink,
                      label: S().envoy_support_documentation,
                      onTap: () {
                        launchUrl(Uri.parse("https://docs.foundation.xyz"));
                      },
                    ),
                    const SizedBox(height: 0),
                    MenuOption(
                      icon: EnvoyIcons.externalLink,
                      label: S().envoy_support_community,
                      onTap: () {
                        launchUrl(
                            Uri.parse("https://community.foundation.xyz/"),
                            mode: LaunchMode.externalApplication);
                      },
                    ),
                    const SizedBox(height: 0),
                    MenuOption(
                      icon: EnvoyIcons.mail,
                      label: S().envoy_support_email,
                      onTap: () {
                        final Uri emailUri = Uri(
                          scheme: 'mailto',
                          path: 'hello@foundation.xyz',
                        );
                        launchUrl(emailUri);
                      },
                    ),
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuOption extends StatelessWidget {
  final String label;
  final Function() onTap;
  final EnvoyIcons icon;

  const MenuOption({
    super.key,
    required this.label,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: EnvoySpacing.large2, vertical: EnvoySpacing.medium1),
        child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label.toUpperCase(),
                textAlign: TextAlign.center,
                style: EnvoyTypography.subheading
                    .copyWith(
                      color: EnvoyColors.textPrimaryInverse,
                    )
                    .setWeight(FontWeight.w500),
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: EnvoyIcon(
                  icon,
                  size: EnvoyIconSize.extraSmall,
                  color: EnvoyColors.textPrimaryInverse,
                ),
              )
            ]),
      ),
    );
  }
}
