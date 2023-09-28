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

class WalletSecurityModal extends StatefulWidget {
  final Function onLastStep;
  final Function? onConfirmBackup;
  final Function? onDenyBackup;

  const WalletSecurityModal({
    Key? key,
    required this.onLastStep,
    this.onDenyBackup,
    this.onConfirmBackup,
  }) : super(key: key);

  @override
  State<WalletSecurityModal> createState() => _WalletSecurityModalState();
}

class _WalletSecurityModalState extends State<WalletSecurityModal> {
  PageController _pageController = PageController();

  List<Widget> stepIllustration = [
    Image.asset(
      "assets/data_secured_1.png",
      height: 180,
    ),
    Image.asset(
      "assets/data_secured_2.png",
      height: 180,
    ),
    Image.asset(
      "assets/data_secured_3.png",
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
    S().wallet_security_modal_1_4_ios_heading,
    S().wallet_security_modal_2_4_heading,
    S().wallet_security_modal_3_4_ios_heading,
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
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      height: MediaQuery.of(context).size.height * 0.75,
      child: Scrollbar(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            height: MediaQuery.of(context).size.height * 0.75,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: PageView(
                          controller: _pageController,
                          children: [
                            ...stepHeadings.mapIndexed((i, e) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 22),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 180,
                                      child: stepIllustration[i],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 22, vertical: 12),
                                      child: Text(
                                        stepHeadings[i],
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 22, vertical: 14),
                                      child: AnimatedSwitcher(
                                        duration: Duration(milliseconds: 400),
                                        child: LinkText(
                                          text: stepSubHeadings[i],
                                          onTap: () {
                                            launchUrl(Uri.parse(Platform
                                                    .isAndroid
                                                ? "https://developer.android.com/guide/topics/data/autobackup"
                                                : "https://support.apple.com/en-us/HT202303"));
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList()
                          ],
                        ),
                      ),
                      DotsIndicator(
                        totalPages: stepHeadings.length,
                        pageController: _pageController,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 48, vertical: 12),
                  child: Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 14),
                      child: Column(
                        children: [
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
                                        duration: Duration(milliseconds: 600),
                                        curve: Curves.easeInOut);
                                  }
                                },
                              ),
                              secondChild: SizedBox(),
                              crossFadeState: CrossFadeState.showFirst,
                              duration: Duration(milliseconds: 400))
                        ],
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
