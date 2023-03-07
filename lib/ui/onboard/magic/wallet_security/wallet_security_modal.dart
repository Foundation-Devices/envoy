// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/onboard/expert/widgets/mnemonic_grid_widget.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:collection/collection.dart';

class WalletSecurityModal extends StatefulWidget {
  final Function onLastStep;

  const WalletSecurityModal({Key? key, required this.onLastStep})
      : super(key: key);

  @override
  State<WalletSecurityModal> createState() => _WalletSecurityModalState();
}

class _WalletSecurityModalState extends State<WalletSecurityModal> {
  PageController _pageController = PageController();
  int step = 0;

  List<Widget> stepIllustration = [
    Image.asset("assets/data_secured_1.png"),
    Image.asset("assets/data_secured_2.png"),
    Image.asset("assets/data_secured_3.png"),
    Image.asset(
      "assets/exclamation_icon.png",
      width: 100,
      height: 100,
    ),
  ];

  List<String> stepHeadings = [
    S().wallet_security_modal_1_4_ios_heading,
    S().wallet_security_modal_2_4_heading,
    S().wallet_security_modal_34_ios_heading,
    S().wallet_security_modal_4_4_heading,
  ];

  List<String> stepSubHeadings = [
    Platform.isAndroid
        ? S().wallet_security_modal_1_4_android_subheading
        : S().wallet_security_modal_1_4_ios_subheading,
    S().wallet_security_modal_2_4_subheading,
    Platform.isAndroid
        ? S().wallet_security_modal_3_4_android_subheading
        : S().wallet_security_modal_34_ios_subheading,
    S().wallet_security_modal_4_4_subheading,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      height: MediaQuery.of(context).size.height * 0.9,
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          Flexible(
            child: PageView(
              physics: NeverScrollableScrollPhysics(),
              controller: _pageController,
              children: [
                ...stepHeadings.mapIndexed((i, e) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        stepIllustration[i],
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Text(
                            stepHeadings[i],
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headline6,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          child: AnimatedSwitcher(
                            duration: Duration(milliseconds: 400),
                            child: OnboardingHelperText(
                              text: stepSubHeadings[i],
                              onTap: () {
                                launchUrl(Uri.parse(Platform.isAndroid
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
            totalPages: stepHeadings.length - 1,
            pageController: _pageController,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 48, vertical: 28),
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: EnvoyButton(
                S().wallet_security_modal_4_4_CTA,
                light: false,
                onTap: () {
                  if (step == stepHeadings.length) {
                    widget.onLastStep();
                  } else {
                    _pageController.animateToPage(step++,
                        duration: Duration(milliseconds: 600),
                        curve: Curves.easeInOut);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
