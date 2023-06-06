// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/fw_uploader.dart';
import 'package:envoy/ui/onboard/sd_card_spinner.dart';
import 'package:envoy/ui/pages/fw/fw_passport.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:envoy/generated/l10n.dart';

import 'fw_microsd.dart';

//ignore: must_be_immutable
class FwProgressPage extends ConsumerStatefulWidget {
  final bool onboarding;

  FwProgressPage({this.onboarding = true});

  @override
  ConsumerState<FwProgressPage> createState() => _FwProgressPageState();
}

class _FwProgressPageState extends ConsumerState<FwProgressPage> {
  bool done = false;
  int currentDotIndex = 3;
  int navigationDots = 6;

  PageController _instructionPageController = PageController();

  @override
  Widget build(BuildContext context) {
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
          });
        }
      },
    );

    return OnboardingPage(
      leftFunction: (context) {
        Navigator.of(context).pop();
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
                ActionText(
                  header:
                      "Envoy failed to copy the firmware onto the microSD card",
                  text: "Try again.",
                  action: () {
                    Navigator.of(context)
                        .pushReplacement(MaterialPageRoute(builder: (context) {
                      return FwMicrosdPage(onboarding: widget.onboarding);
                    }));
                  },
                ),
              ]),
        ),
      ],
      clipArt: SdCardSpinner(),
      navigationDots: navigationDots,
      navigationDotsIndex: currentDotIndex,
      buttons: [
        IgnorePointer(
          ignoring: !done,
          child: AnimatedOpacity(
            opacity: done ? 1.0 : 0.4,
            duration: Duration(milliseconds: 500),
            child: OnboardingButton(
                label: S().envoy_fw_success_cta,
                onTap: () {
                  Navigator.of(context)
                      .pushReplacement(MaterialPageRoute(builder: (context) {
                    return FwPassportPage(
                      onboarding: widget.onboarding,
                    );
                  }));
                }),
          ),
        )
      ],
    );
  }
}
