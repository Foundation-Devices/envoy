// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/fw_uploader.dart';
import 'package:envoy/ui/onboard/sd_card_spinner.dart';
import 'package:envoy/ui/pages/fw/fw_passport.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//ignore: must_be_immutable
class FwProgressPage extends ConsumerStatefulWidget {
  bool onboarding;

  FwProgressPage({this.onboarding = true});

  @override
  ConsumerState<FwProgressPage> createState() => _FwProgressPageState();
}

class _FwProgressPageState extends ConsumerState<FwProgressPage> {
  bool done = false;
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
              children: [
                OnboardingText(
                  header:
                      "Envoy is now copying the firmware onto the microSD card",
                  text:
                      "This might take few seconds. Please do not remove the microSD card.",
                ),
                OnboardingText(
                  header:
                      "Firmware was successfully copied onto the microSD card",
                  text:
                      "Make sure to \"safely remove\" from your file manager or notification bar before removing your microSD card from your phone.",
                ),
                OnboardingText(
                  header:
                      "Envoy failed to copy the firmware onto the microSD card",
                  text: "Try again.",
                )
              ]),
        ),
      ],
      clipArt: SdCardSpinner(),
      buttons: [
        IgnorePointer(
          ignoring: !done,
          child: Opacity(
            opacity: done ? 1.0 : 0.4,
            child: OnboardingButton(
                label: "Continue",
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
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
