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
  int _currentPage = 0;

  List<Widget> stepIllustration = [
    Image.asset(
      Platform.isAndroid
          ? "assets/data_secured_1_android.png"
          : "assets/data_secured_1_ios.png",
      height: 110,
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
      height: 110,
    ),
    Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          "assets/exclamation_icon.png",
          height: 64,
        ),
      ],
    ),
  ];

  List<String> stepHeadings = [
    S().wallet_security_modal_HowYourSeedIsSecured,
    S().wallet_security_modal_HowYourDatatIsSecured,
    S().wallet_security_modal_HowToRecoverYourWallet,
    S().wallet_security_modal_WantToOptOut,
  ];

  late List<String> stepSubHeadings;

  @override
  void initState() {
    super.initState();

    _pageController.addListener(() {
      final newPage = _pageController.page?.round() ?? 0;
      if (newPage != _currentPage) {
        setState(() {
          _currentPage = newPage;
        });
      }
    });

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
      width: MediaQuery.of(context).size.width * 0.9,
      height: 520,
      child: Padding(
        padding: const EdgeInsets.all(EnvoySpacing.medium2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Flexible(
              child: PageView(
                controller: _pageController,
                children: [
                  ...stepHeadings.mapIndexed((i, _) {
                    return SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: EnvoySpacing.xs),
                          Center(
                              child: SizedBox(
                            height: 110,
                            child: stepIllustration[i],
                          )),
                          SizedBox(height: EnvoySpacing.medium3),
                          Text(stepHeadings[i],
                              textAlign: TextAlign.center,
                              style: EnvoyTypography.heading),
                          const SizedBox(height: EnvoySpacing.medium1),
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
                          const SizedBox(height: EnvoySpacing.medium3)
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            DotsIndicator(
              totalPages: stepHeadings.length,
              pageController: _pageController,
            ),
            const SizedBox(height: EnvoySpacing.medium3),
            EnvoyButton(
              _currentPage == stepHeadings.length - 1
                  ? S().component_continue
                  : S().component_next,
              type: EnvoyButtonTypes.primaryModal,
              onTap: () {
                if (_currentPage == stepHeadings.length - 1) {
                  widget.onLastStep();
                } else {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeInOut,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
