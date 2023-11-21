// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/fw_uploader.dart';
import 'package:envoy/ui/onboard/sd_card_spinner.dart';
import 'package:envoy/ui/pages/fw/fw_passport.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:envoy/business/devices.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'fw_intro.dart';

class FwAndroidProgressPage extends ConsumerStatefulWidget {
  final bool onboarding;
  final int deviceId;

  FwAndroidProgressPage(this.deviceId, {this.onboarding = true});

  @override
  ConsumerState<FwAndroidProgressPage> createState() =>
      _FwAndroidProgressPageState();
}

class _FwAndroidProgressPageState extends ConsumerState<FwAndroidProgressPage> {
  bool done = false;
  int currentDotIndex = 3;
  int navigationDots = 6;

  PageController _instructionPageController = PageController();

  @override
  Widget build(BuildContext context) {
    final fwInfo = ref.watch(firmwareStreamProvider(widget.deviceId));
    ref.listen<bool?>(
      sdFwUploadProgressProvider,
      (previous, next) {
        if (next is bool) {
          if (next) {
            _instructionPageController.animateToPage(1,
                duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
          } else {
            _instructionPageController.animateToPage(2,
                duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
          }
          setState(() {
            done = next;
            if (done) {
              Devices().markDeviceUpdated(
                  widget.deviceId, fwInfo.value!.storedVersion);
            }
          });
        }
      },
    );

    return OnboardingPage(
      leftFunction: (context) {
        Navigator.of(context).pop();
      },
      rightFunction: (_) {
        widget.onboarding
            ? OnboardingPage.popUntilHome(context)
            : OnboardingPage.popUntilGoRoute(context);
      },
      key: Key("fw_progress"),
      text: [
        Expanded(
          child: PageView(
              physics: NeverScrollableScrollPhysics(),
              controller: _instructionPageController,
              onPageChanged: (index) {
                setState(() {
                  currentDotIndex = index == 3 ? 3 : 4;
                  navigationDots = index == 2 ? 0 : 6;
                });
              },
              children: [
                OnboardingText(
                  header: S().envoy_fw_progress_heading,
                  text: S().envoy_fw_progress_subheading,
                ),
                OnboardingText(
                  header: S().envoy_fw_success_heading,
                  text: S().envoy_fw_success_subheading,
                ),
                Column(
                  children: [
                    OnboardingText(
                      header: S().envoy_fw_fail_heading,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: LinkText(
                          text: S().envoy_fw_fail_subheading,
                          linkStyle: EnvoyTypography.button
                              .copyWith(color: EnvoyColors.accentPrimary),
                          onTap: () {
                            launchUrlString(
                                "https://github.com/Foundation-Devices/passport2/releases/tag/${fwInfo.value!.storedVersion}");
                          }),
                    ),
                  ],
                ),
              ]),
        ),
      ],
      clipArt: SdCardSpinner(),
      navigationDots: navigationDots,
      navigationDotsIndex: currentDotIndex,
      buttons: [
        OnboardingButton(
            label: done ? S().envoy_fw_success_cta : S().envoy_fw_fail_cta,
            onTap: () {
              Navigator.of(context)
                  .pushReplacement(MaterialPageRoute(builder: (context) {
                if (done)
                  return FwPassportPage(
                    onboarding: widget.onboarding,
                  );
                else
                  return FwIntroPage(
                    deviceId: widget.deviceId,
                  );
              }));
            })
      ],
    );
  }
}
