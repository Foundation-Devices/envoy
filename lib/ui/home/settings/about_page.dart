// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 100, left: 40, right: 40),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Image.asset("assets/logo.png", height: 170),
          ),
          const SizedBox(height: EnvoySpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AboutText(S().about_appVersion),
              FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return AboutText(
                        snapshot.data!.version,
                        dark: true,
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  }),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: AboutText(S().about_openSourceLicences)),
              AboutButton(
                S().about_show,
                onTap: () {
                  showLicensePage(
                      context: context,
                      applicationName: "Envoy", // TODO: FIGMA
                      useRootNavigator: true,
                      applicationLegalese:
                          "This program is free software: you can redistribute it and/or modify " // TODO: FIGMA
                          "it under the terms of the GNU General Public License as published by "
                          "the Free Software Foundation, either version 3 of the License, or "
                          "(at your option) any later version. "
                          "This program is distributed in the hope that it will be useful,"
                          "but WITHOUT ANY WARRANTY; without even the implied warranty of "
                          "MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the "
                          "GNU General Public License for more details.");
                },
              )
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AboutText(S().about_termsOfUse),
              AboutButton(
                hasLinkIcon: true,
                S().about_show,
                onTap: () {
                  launchUrlString("https://foundation.xyz/terms/");
                },
              )
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AboutText(S().about_privacyPolicy),
              AboutButton(
                hasLinkIcon: true,
                S().about_show,
                onTap: () {
                  launchUrlString("https://foundation.xyz/privacy/");
                },
              )
            ],
          ),
        ],
      ),
    );
  }
}

class AboutText extends StatelessWidget {
  final String label;
  final bool dark;

  const AboutText(
    this.label, {
    this.dark = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: dark ? Colors.white38 : Colors.white,
          fontSize: 15.0,
          fontWeight: FontWeight.w500,
        ));
  }
}

class AboutButton extends StatelessWidget {
  final String label;
  final Function()? onTap;
  final bool hasLinkIcon;

  const AboutButton(
    this.label, {
    super.key,
    this.onTap,
    this.hasLinkIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
          constraints: const BoxConstraints(
            minWidth: 100,
          ),
          decoration: const BoxDecoration(
              color: EnvoyColors.accentPrimary,
              borderRadius:
                  BorderRadius.all(Radius.circular(EnvoySpacing.small))),
          child: Center(
              child: Padding(
            padding: const EdgeInsets.symmetric(
                vertical: EnvoySpacing.small, horizontal: EnvoySpacing.medium1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                hasLinkIcon
                    ? const Row(
                        children: [
                          EnvoyIcon(
                            EnvoyIcons.externalLink,
                            size: EnvoyIconSize.small,
                            color: EnvoyColors.textPrimaryInverse,
                          ),
                          SizedBox(width: EnvoySpacing.small),
                        ],
                      )
                    : const SizedBox.shrink(),
                Text(
                  label,
                  style: EnvoyTypography.button.copyWith(
                    color: EnvoyColors.textPrimaryInverse,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ))),
    );
  }
}
