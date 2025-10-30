// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/devices.dart';
import 'package:envoy/business/fw_uploader.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/home/cards/devices/device_list_tile.dart';
import 'package:envoy/ui/onboard/onboard_page_wrapper.dart';
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
import 'package:envoy/ui/theme/envoy_spacing.dart';

class FwAndroidProgressPage extends ConsumerStatefulWidget {
  final FwPagePayload payload;

  const FwAndroidProgressPage({super.key, required this.payload});

  @override
  ConsumerState<FwAndroidProgressPage> createState() =>
      _FwAndroidProgressPageState();
}

class _FwAndroidProgressPageState extends ConsumerState<FwAndroidProgressPage> {
  bool? done;

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

    return OnboardPageBackground(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.only(
              left: EnvoySpacing.medium1,
              right: EnvoySpacing.medium1,
              bottom: EnvoySpacing.medium2),
          child: Column(
            key: const Key("fw_progress"),
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  const SdCardSpinner(),
                  Transform.translate(
                    offset: const Offset(0, -EnvoySpacing.medium2),
                    child: ExpandablePageView(
                        physics: const NeverScrollableScrollPhysics(),
                        controller: _instructionPageController,
                        children: [
                          SingleChildScrollView(
                              child: Column(
                            children: [
                              Text(
                                S().envoy_fw_progress_heading,
                                style: EnvoyTypography.heading,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: EnvoySpacing.medium3),
                              Text(
                                S().envoy_fw_progress_subheading,
                                style: EnvoyTypography.body
                                    .copyWith(color: EnvoyColors.textSecondary),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          )),
                          SingleChildScrollView(
                              child: Column(
                            children: [
                              Text(
                                S().envoy_fw_success_heading,
                                style: EnvoyTypography.heading,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: EnvoySpacing.medium3),
                              Text(
                                S().envoy_fw_success_subheading,
                                style: EnvoyTypography.body
                                    .copyWith(color: EnvoyColors.textSecondary),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          )),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      Text(
                                        S().envoy_fw_fail_heading,
                                        style: EnvoyTypography.heading,
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(
                                          height: EnvoySpacing.medium3),
                                      LinkText(
                                          text: S().envoy_fw_fail_subheading,
                                          linkStyle: EnvoyTypography.button
                                              .copyWith(
                                                  color: EnvoyColors
                                                      .accentPrimary),
                                          onTap: () {
                                            launchUrlString(
                                                "https://github.com/Foundation-Devices/passport2/releases/tag/${fwInfo.value!.storedVersion}");
                                          }),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ]),
                  ),
                ],
              ),
              if (done != null)
                EnvoyButton(
                    done! ? S().component_continue : S().component_tryAgain,
                    borderRadius:
                        BorderRadius.all(Radius.circular(EnvoySpacing.medium1)),
                    onTap: () {
                  if (done!) {
                    context.pushNamed(PASSPORT_UPDATE_PASSPORT,
                        extra: widget.payload);
                    return;
                  } else {
                    context.pushNamed(PASSPORT_UPDATE, extra: widget.payload);
                  }
                })
            ],
          ),
        ),
      ),
    );
  }
}
