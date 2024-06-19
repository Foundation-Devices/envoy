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
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'fw_intro.dart';
import 'package:envoy/ui/home/cards/devices/device_list_tile.dart';

class FwAndroidProgressPage extends ConsumerStatefulWidget {
  final bool onboarding;
  final int deviceId;

  const FwAndroidProgressPage(this.deviceId,
      {super.key, this.onboarding = true});

  @override
  ConsumerState<FwAndroidProgressPage> createState() =>
      _FwAndroidProgressPageState();
}

class _FwAndroidProgressPageState extends ConsumerState<FwAndroidProgressPage> {
  bool? done;
  int currentDotIndex = 3;
  int navigationDots = 6;

  final PageController _instructionPageController = PageController();

  void refreshFirmwareUpdateDot() {
    final device = Devices().getDeviceById(widget.deviceId);
    if (device != null) {
      ref.invalidate(shouldUpdateProvider(device));
    }
  }

  @override
  Widget build(BuildContext context) {
    final fwInfo = ref.watch(firmwareStreamProvider(widget.deviceId));
    ref.listen<bool?>(
      sdFwUploadProgressProvider,
      (previous, next) async {
        if (next is bool) {
          if (next) {
            await Future.delayed(const Duration(seconds: 5));
            _instructionPageController.animateToPage(1,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut);
          } else {
            _instructionPageController.animateToPage(2,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut);
          }
          setState(() {
            done = next;
            if (done!) {
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
      key: const Key("fw_progress"),
      text: [
        Expanded(
          child: PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _instructionPageController,
              onPageChanged: (index) {
                setState(() {
                  currentDotIndex = index == 3 ? 3 : 4;
                  navigationDots = index == 2 ? 0 : 6;
                });
              },
              children: [
                SingleChildScrollView(
                  child: OnboardingText(
                    header: S().envoy_fw_progress_heading,
                    text: S().envoy_fw_progress_subheading,
                  ),
                ),
                SingleChildScrollView(
                  child: OnboardingText(
                    header: S().envoy_fw_success_heading,
                    text: S().envoy_fw_success_subheading,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            OnboardingText(
                              header: S().envoy_fw_fail_heading,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 32.0),
                              child: LinkText(
                                  text: S().envoy_fw_fail_subheading,
                                  linkStyle: EnvoyTypography.button.copyWith(
                                      color: EnvoyColors.accentPrimary),
                                  onTap: () {
                                    launchUrlString(
                                        "https://github.com/Foundation-Devices/passport2/releases/tag/${fwInfo.value!.storedVersion}");
                                  }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ]),
        ),
      ],
      clipArt: const SdCardSpinner(),
      navigationDots: navigationDots,
      navigationDotsIndex: currentDotIndex,
      buttons: [
        if (done != null)
          Padding(
            padding: const EdgeInsets.only(bottom: EnvoySpacing.medium2),
            child: OnboardingButton(
                label: done! ? S().component_continue : S().component_tryAgain,
                onTap: () {
                  Navigator.of(context)
                      .pushReplacement(MaterialPageRoute(builder: (context) {
                    if (done!) {
                      refreshFirmwareUpdateDot();
                      return FwPassportPage(
                        onboarding: widget.onboarding,
                      );
                    } else {
                      return FwIntroPage(
                        deviceId: widget.deviceId,
                        onboarding: widget.onboarding,
                      );
                    }
                  }));
                }),
          )
      ],
    );
  }
}
