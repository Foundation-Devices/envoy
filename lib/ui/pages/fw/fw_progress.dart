// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:envoy/ui/onboard/sd_card_spinner.dart';
import 'package:envoy/ui/pages/fw/fw_passport.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/templates/onboarding_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//ignore: must_be_immutable
class FwProgressPage extends ConsumerStatefulWidget {
  bool onboarding;

  FwProgressPage({this.onboarding: true});

  @override
  ConsumerState<FwProgressPage> createState() => _FwProgressPageState();
}

class _FwProgressPageState extends ConsumerState<FwProgressPage> {
  Timer? _uploadTimer;
  bool done = false;
  final sdCardUploadSuccessProvider = StateProvider<bool>((ref) => false);

  @override
  void initState() {
    _uploadTimer = Timer(Duration(seconds: 10), () {
      setState(() {
        done = true;
      });

      ref.read(sdCardUploadSuccessProvider.notifier).state = true;
    });

    super.initState();
  }

  @override
  void dispose() {
    if (_uploadTimer != null) {
      _uploadTimer!.cancel();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      leftFunction: (context) {
        Navigator.of(context).pop();
      },
      key: Key("fw_progress"),
      clipArt: SdCardSpinner(sdCardUploadSuccessProvider),
      text: [
        AnimatedSwitcher(
            duration: Duration(milliseconds: 250),
            child: OnboardingText(
                key: UniqueKey(),
                header: done
                    ? "Firmware was successfully copied onto the microSD card"
                    : "Envoy is now copying the firmware onto the microSD card",
                text: done
                    ? "Make sure to \"safely remove\" from your file manager or notification bar before removing your microSD card from your phone."
                    : "This might take few seconds. Please do not remove the microSD card."))
      ],
      buttons: [
        OnboardingButton(
            label: "Continue",
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return FwPassportPage(
                  onboarding: widget.onboarding,
                );
              }));
            })
      ],
    );
  }
}
