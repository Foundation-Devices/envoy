import 'package:envoy/ui/pages/legal/passport_tou.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/templates/onboarding_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:envoy/business/local_storage.dart';

import 'import_pp/single_import_pp_intro.dart';

class OnboardingWelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Only onboard once
    LocalStorage().prefs.setBool("onboarded", true);

    var loc = AppLocalizations.of(context)!;
    return OnboardingPage(
      key: Key("onboarding_welcome_page"),
      leftFunction: null,
      clipArt: Image.asset("assets/envoy_passport.png"),
      text: [
        OnboardingText(
            header: loc.envoy_welcome_card1_heading,
            text: loc.envoy_welcome_card1_subheading)
      ],
      helperTextAbove: OnboardingHelperText(
          text: loc.envoy_welcome_cta03,
          onTap: () {
            launchUrl(
                Uri.parse("https://foundationdevices.com/product/passport/"));
          }),
      buttons: [
        OnboardingButton(
            light: true,
            label: loc.envoy_welcome_cta01,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return SingleImportPpIntroPage();
              }));
            }),
        OnboardingButton(
            label: loc.envoy_welcome_cta,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return TouPage();
              }));
            }),
      ],
    );
  }
}
