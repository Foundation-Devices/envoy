import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/templates/onboarding_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:envoy/ui/pages/fw/fw_intro.dart';

class PinIntroPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    return OnboardingPage(
      key: Key("pin_intro"),
      clipArt: Image.asset("assets/pin_intro.png"),
      text: [
        OnboardingText(
            header: loc.envoy_pin_intro_heading,
            text: loc.envoy_pin_intro_subheading),
      ],
      buttons: [
        OnboardingButton(
            label: loc.envoy_pin_intro_cta,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return FwIntroPage();
              }));
            }),
      ],
    );
  }
}
