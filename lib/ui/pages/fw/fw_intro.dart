// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/updates_manager.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/pages/fw/fw_routes.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher_string.dart';

class FwIntroPage extends StatefulWidget {
  final FwPagePayload fwPagePayload;

  const FwIntroPage({super.key, required this.fwPagePayload});

  @override
  State<FwIntroPage> createState() => _FwIntroPageState();
}

class _FwIntroPageState extends State<FwIntroPage> {
  bool _downloading = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.fwPagePayload.onboarding,
      child: CustomOnboardingPage(
        key: const Key("fw_intro"),
        showBackArrow: !widget.fwPagePayload.onboarding,
        mainWidget: _downloading
            ? const SizedBox(
                height: 184,
                width: 184,
                child: CircularProgressIndicator(
                  color: EnvoyColors.tealLight,
                  backgroundColor: EnvoyColors.surface4,
                  strokeWidth: EnvoySpacing.small,
                ),
              )
            : Image.asset("assets/fw_download.png", height: 184),
        title: _downloading ? "" : S().envoy_fw_intro_heading,
        subheading: _downloading ? "" : S().envoy_fw_intro_subheading,
        onLinkTextTap: () {
          launchUrlString(
              "https://github.com/Foundation-Devices/passport2/releases");
        },
        buttons: [
          if (!_downloading)
            EnvoyButton(S().envoy_fw_intro_cta,
                borderRadius:
                    BorderRadius.all(Radius.circular(EnvoySpacing.medium1)),
                onTap: () async {
              // make sure it is downloaded
              if (!await UpdatesManager()
                  .isFirmwareDownloaded(widget.fwPagePayload.deviceId)) {
                setState(() {
                  _downloading = true;
                });
                await UpdatesManager().fetchAndDownloadFirmwareUpdate(
                    widget.fwPagePayload.deviceId);
              }
              setState(() {
                _downloading = false;
              });

              if (context.mounted) {
                context.pushNamed(PASSPORT_UPDATE_SD_CARD,
                    extra: widget.fwPagePayload);
              }
            }),
        ],
      ),
    );
  }
}
