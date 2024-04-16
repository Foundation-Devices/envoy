// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/connectivity_manager.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';

class TorWarning extends StatefulWidget {
  const TorWarning({super.key});

  @override
  State<TorWarning> createState() => _TorWarningState();
}

class _TorWarningState extends State<TorWarning> {
  @override
  Widget build(BuildContext context) {
    var textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        );

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.85,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(EnvoyIcons.exclamationWarning,
                    color: EnvoyColors.accentSecondary, size: 84),
                Padding(
                    padding: const EdgeInsets.only(top: 18.0),
                    child: LinkText(
                      text: S().torToast_learnMore_warningBody,
                      textStyle: textStyle,
                      linkStyle: EnvoyTypography.button
                          .copyWith(color: EnvoyColors.accentPrimary),
                      onTap: () {
                        launchUrl(
                            Uri.parse("https://docs.foundation.xyz/envoy/tor"),
                            mode: LaunchMode.externalApplication);
                      },
                    )),
                const Padding(padding: EdgeInsets.all(4)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 28),
            child: Column(
              //Temporarily Disable Tor
              children: [
                EnvoyButton(
                  S().torToast_learnMore_temporarilyDisableTor,
                  type: EnvoyButtonTypes.secondary,
                  onTap: () {
                    ConnectivityManager().torTemporarilyDisabled = true;
                    Navigator.of(context).pop();
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: EnvoyButton(
                    S().torToast_learnMore_retryTorConnection,
                    onTap: () {
                      // We are continually retrying anyway
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
