import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/templates/onboarding_page.dart';
import 'package:envoy/ui/pages/fw/fw_microsd.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher_string.dart';

class FwIntroPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    return OnboardingPage(
      key: Key("fw_intro"),
      clipArt: Image.asset("assets/fw_intro.png"),
      text: [
        OnboardingText(header: loc.envoy_fw_intro_heading),
        OnboardingHelperText(
            text: loc.envoy_fw_intro_subheading,
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
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return FwMicrosdPage();
              }));
            }),
      ],
    );
  }
}
