import 'package:envoy/ui/pages/pp/pp_new_seed_backup.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/templates/onboarding_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PpNewSeedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    return OnboardingPage(
      key: Key("pp_new_seed"),
      clipArt: Image.asset("assets/pp_new_seed.png"),
      text: [
        OnboardingText(
            header: loc.envoy_pp_new_seed_heading,
            text: loc.envoy_pp_new_seed_subheading),
      ],
      navigationDots: 3,
      navigationDotsIndex: 0,
      buttons: [
        OnboardingButton(
            label: loc.envoy_pp_new_seed_cta,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return PpNewSeedBackupPage();
              }));
            }),
      ],
    );
  }
}
