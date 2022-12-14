// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/templates/onboarding_page.dart';
import 'package:envoy/ui/pages/fw/fw_microsd.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:envoy/business/updates_manager.dart';
import 'package:envoy/ui/fw_warning.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/ui/pages/pp/pp_setup_intro.dart';

//ignore: must_be_immutable
class FwIntroPage extends StatelessWidget {
  bool onboarding;

  FwIntroPage({this.onboarding: true});

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(
      key: Key("fw_intro"),
      clipArt: Image.asset("assets/fw_intro.png"),
      text: [
        OnboardingText(header: S().envoy_fw_intro_heading),
        OnboardingHelperText(
            text: S().envoy_fw_intro_subheading,
            onTap: () {
              launchUrlString(
                  "https://github.com/Foundation-Devices/passport-firmware/releases");
            })
      ],
      navigationDots: 3,
      navigationDotsIndex: 0,
      buttons: [
        OnboardingButton(
            label: "Continue",
            onTap: () {
              if (UpdatesManager().getStoredFwVersion() == null) {
                showEnvoyDialog(
                    dialog: FwWarning(
                      tryNow: () {
                        // TODO: some kind of spinner here?
                      },
                      tryLater: () {
                        if (onboarding) {
                          Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                            return PpSetupIntroPage();
                          }));
                        } else {
                          OnboardingPage.goHome(context);
                        }
                      },
                    ),
                    context: context);
              } else {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return FwMicrosdPage(
                    onboarding: onboarding,
                  );
                }));
              }
            }),
      ],
    );
  }
}
