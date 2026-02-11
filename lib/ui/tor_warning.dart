// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/connectivity_manager.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/components/pop_up.dart';

class TorWarning extends StatefulWidget {
  const TorWarning({super.key});

  @override
  State<TorWarning> createState() => _TorWarningState();
}

class _TorWarningState extends State<TorWarning> {
  @override
  Widget build(BuildContext context) {
    var textStyle = Theme.of(
      context,
    ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500);

    return EnvoyPopUp(
      icon: EnvoyIcons.alert,
      typeOfMessage: PopUpState.warning,
      showCloseButton: true,
      customWidget: LinkText(
        text: S().torToast_learnMore_warningBody,
        textStyle: textStyle,
        linkStyle: EnvoyTypography.button.copyWith(
          color: EnvoyColors.accentPrimary,
        ),
        onTap: () {
          launchUrl(
            Uri.parse("https://docs.foundation.xyz/envoy/tor"),
            mode: LaunchMode.externalApplication,
          );
        },
      ),
      primaryButtonLabel: S().torToast_learnMore_retryTorConnection,
      onPrimaryButtonTap: (context) {
        // We are continually retrying anyway
        Navigator.of(context).pop();
      },
      secondaryButtonLabel: S().torToast_learnMore_temporarilyDisableTor,
      onSecondaryButtonTap: (context) {
        ConnectivityManager().torTemporarilyDisabled = true;
        Navigator.of(context).pop();
      },
    );
  }
}
