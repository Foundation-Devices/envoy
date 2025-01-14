// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/devices.dart';
import 'package:envoy/business/fw_uploader.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/home/cards/devices/device_list_tile.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/onboard/sd_card_spinner.dart';
import 'package:envoy/ui/pages/fw/fw_routes.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/expandable_page_view.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher_string.dart';

class FwAndroidProgressPage extends ConsumerStatefulWidget {
  final FwPagePayload payload;

  const FwAndroidProgressPage({super.key, required this.payload});

  @override
  ConsumerState<FwAndroidProgressPage> createState() =>
      _FwAndroidProgressPageState();
}

class _FwAndroidProgressPageState extends ConsumerState<FwAndroidProgressPage> {
  bool? done;
  int currentDotIndex = 3;
  int navigationDots = 6;
  late int deviceId = widget.payload.deviceId;
  late bool onboarding = widget.payload.onboarding;

  final PageController _instructionPageController = PageController();

  void refreshFirmwareUpdateDot() {
    final device = Devices().getDeviceById(deviceId);
    if (device != null) {
      ref.invalidate(shouldUpdateProvider(device));
    }
  }

  @override
  Widget build(BuildContext context) {
    final fwInfo = ref.watch(firmwareStreamProvider(deviceId));
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
              Devices()
                  .markDeviceUpdated(deviceId, fwInfo.value!.storedVersion);
              refreshFirmwareUpdateDot();
            }
          });
        }
      },
    );

    return OnboardingPage(
      leftFunction: (context) {
        context.pop();
      },
      key: const Key("fw_progress"),
      text: [
        ExpandablePageView(
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
                                linkStyle: EnvoyTypography.button
                                    .copyWith(color: EnvoyColors.accentPrimary),
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
      ],
      clipArt: const SdCardSpinner(),
      navigationDots: navigationDots,
      navigationDotsIndex: currentDotIndex,
      buttons: [
        if (done != null)
          OnboardingButton(
              label: done! ? S().component_continue : S().component_tryAgain,
              onTap: () {
                if (done!) {
                  context.goNamed(PASSPORT_UPDATE_PASSPORT,
                      extra: widget.payload);
                  return;
                } else {
                  context.goNamed(PASSPORT_UPDATE, extra: widget.payload);
                }
              })
      ],
    );
  }
}
