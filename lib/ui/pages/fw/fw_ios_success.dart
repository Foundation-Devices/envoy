// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/pages/fw/fw_routes.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:go_router/go_router.dart';
import 'package:rive/rive.dart';

class FwIosSuccessPage extends StatefulWidget {
  final FwPagePayload fwPagePayload;

  const FwIosSuccessPage({super.key, required this.fwPagePayload});

  @override
  State<FwIosSuccessPage> createState() => _FwIosSuccessPageState();
}

class _FwIosSuccessPageState extends State<FwIosSuccessPage> {
  File? file;
  RiveWidgetController? controller;

  @override
  void initState() {
    super.initState();
    initRive();
  }

  void initRive() async {
    file = (await File.asset('assets/envoy_loader.riv',
        riveFactory: Factory.rive))!;
    controller = RiveWidgetController(file!);
    controller?.artboard.animationNamed("happy");
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      leftFunction: (context) {
        Navigator.of(context).pop();
      },
      rightFunction: null,
      key: const Key("fw_ios_success"),
      text: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                child: OnboardingText(
                  header: S().envoy_fw_success_heading,
                  text: S().envoy_fw_success_subheading_ios,
                ),
              ),
            ),
          ],
        ),
      ],
      clipArt: RiveWidget(
        controller: controller!,
        fit: Fit.contain,
      ),
      navigationDots: 6,
      navigationDotsIndex: 4,
      buttons: [
        OnboardingButton(
            label: S().component_continue,
            onTap: () {
              context.pushNamed(PASSPORT_UPDATE_PASSPORT,
                  extra: widget.fwPagePayload);
              return;
            })
      ],
    );
  }
}
