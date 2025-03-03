// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/updates_manager.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/pages/fw/fw_routes.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
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
      canPop: false,
      onPopInvokedWithResult: (didPop, result) => context.go("/"),
      child: OnboardingPage(
        key: const Key("fw_intro"),
        rightFunction: (_) {
          context.go("/");
        },
        clipArt: Transform.translate(
            offset: const Offset(0, 75),
            child: _downloading
                ? const SizedBox(
                    height: 150,
                    width: 150,
                    child: CircularProgressIndicator(
                      color: EnvoyColors.tealLight,
                      backgroundColor: EnvoyColors.surface4,
                      strokeWidth: EnvoySpacing.small,
                    ),
                  )
                : Image.asset("assets/fw_download.png", height: 150)),
        text: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  child: _downloading
                      ? const SizedBox.shrink()
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            OnboardingText(header: S().envoy_fw_intro_heading),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: EnvoySpacing.medium2),
                              child: LinkText(
                                  text: S().envoy_fw_intro_subheading,
                                  linkStyle: EnvoyTypography.button.copyWith(
                                      color: EnvoyColors.accentPrimary),
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
          if (!_downloading)
            OnboardingButton(
                label: S().envoy_fw_intro_cta,
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
                    context.goNamed(PASSPORT_UPDATE_SD_CARD,
                        extra: widget.fwPagePayload);
                  }
                }),
        ],
      ),
    );
  }
}
