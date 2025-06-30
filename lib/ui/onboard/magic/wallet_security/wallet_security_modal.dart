// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/onboard/manual/widgets/mnemonic_grid_widget.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:collection/collection.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';

class WalletSecurityModal extends StatefulWidget {
  final Function onLastStep;
  final Function? onConfirmBackup;
  final Function? onDenyBackup;

  const WalletSecurityModal({
    super.key,
    required this.onLastStep,
    this.onDenyBackup,
    this.onConfirmBackup,
  });

  @override
  State<WalletSecurityModal> createState() => _WalletSecurityModalState();
}

class _WalletSecurityModalState extends State<WalletSecurityModal> {
  final PageController _pageController = PageController();

  List<Widget> stepIllustration = [
    Image.asset(
      Platform.isAndroid
          ? "assets/data_secured_1_android.png"
          : "assets/data_secured_1_ios.png",
      height: 180,
    ),
    Image.asset(
      "assets/data_secured_2.png",
      height: 82,
      width: 230,
    ),
    Image.asset(
      Platform.isAndroid
          ? "assets/data_secured_3_android.png"
          : "assets/data_secured_3_ios.png",
      height: 180,
    ),
    Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          "assets/exclamation_icon.png",
          height: 120,
        ),
      ],
    ),
  ];

  List<String> stepHeadings = [
    S().wallet_security_modal_HowYourWalletIsSecured,
    S().wallet_security_modal_HowYourWalletIsSecured,
    S().wallet_security_modal_4_4_heading,
    S().wallet_security_modal_4_4_heading,
  ];

  late List<String> stepSubHeadings;

  @override
  void initState() {
    super.initState();

    stepSubHeadings = [
      Platform.isAndroid
          ? S().wallet_security_modal_1_4_android_subheading
          : S().wallet_security_modal_1_4_ios_subheading,
      S().wallet_security_modal_2_4_subheading,
      Platform.isAndroid
          ? S().wallet_security_modal_3_4_android_subheading
          : S().wallet_security_modal_3_4_ios_subheading,
      S().wallet_security_modal_4_4_subheading,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.85,
      height: 600,
      child: PageView(
        controller: _pageController,
        children: [
          ...stepHeadings.mapIndexed((i, _) {
            return Padding(
              padding: const EdgeInsets.only(
                  left: EnvoySpacing.medium3,
                  right: EnvoySpacing.medium3,
                  top: EnvoySpacing.medium3,
                  bottom: EnvoySpacing.medium2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  Center(
                      child: SizedBox(
                    height: 150,
                    child: stepIllustration[i],
                  )),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(stepHeadings[i],
                              textAlign: TextAlign.center,
                              style: EnvoyTypography.heading),
                          const SizedBox(height: EnvoySpacing.medium2),
                          LinkText(
                            text: stepSubHeadings[i],
                            linkStyle: EnvoyTypography.button.copyWith(
                              color: EnvoyColors.accentPrimary,
                            ),
                            onTap: () => launchUrl(
                              Uri.parse(
                                Platform.isAndroid
                                    ? "https://developer.android.com/guide/topics/data/autobackup"
                                    : "https://support.apple.com/en-us/HT202303",
                              ),
                            ),
                          ),
                          const SizedBox(height: EnvoySpacing.medium2),
                          DotsIndicator(
                            totalPages: stepHeadings.length,
                            pageController: _pageController,
                          ),
                          const SizedBox(height: EnvoySpacing.medium2),
                          AnimatedCrossFade(
                            firstChild: EnvoyButton(
                              (_pageController.hasClients
                                          ? _pageController.page?.toInt()
                                          : 0) ==
                                      stepHeadings.length
                                  ? S()
                                      .manual_setup_create_and_store_backup_modal_CTA
                                  : S().component_continue,
                              type: EnvoyButtonTypes.primaryModal,
                              onTap: () {
                                int currentPage =
                                    _pageController.page?.toInt() ?? 0;
                                if (stepHeadings.length == currentPage + 1) {
                                  widget.onLastStep();
                                } else {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 600),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                            ),
                            secondChild: const SizedBox(),
                            crossFadeState: CrossFadeState.showFirst,
                            duration: const Duration(milliseconds: 400),
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
