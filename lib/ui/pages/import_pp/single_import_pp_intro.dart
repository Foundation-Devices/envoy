import 'package:envoy/ui/pages/import_pp/single_import_pp_scan.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/templates/onboarding_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SingleImportPpIntroPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    return OnboardingPage(
      key: Key("single_import_pp_intro"),
      clipArt: Image.asset("assets/import_pp_intro.png"),
      text: [
        OnboardingText(
            header: loc.single_envoy_import_pp_intro_card1_heading,
            text: loc.single_envoy_import_pp_intro_card1_subheading),
        OnboardingText(
          text: loc.single_envoy_import_pp_intro_card2_subheading,
        )
      ],
      navigationDots: 2,
      navigationDotsIndex: 0,
      buttons: [
        OnboardingButton(
            label: loc.single_envoy_import_pp_intro_cta,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return SingleImportPpScanPage();
              }));
            }),
      ],
    );
  }
}
