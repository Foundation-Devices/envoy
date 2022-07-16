import 'package:envoy/ui/pages/pp/pp_new_seed_success.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/templates/onboarding_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PpNewSeedBackupPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    return OnboardingPage(
      key: Key("pp_new_seed_backup"),
      text: [
        OnboardingText(
            header: loc.envoy_pp_new_seed_backup_heading,
            text: loc.envoy_pp_new_seed_backup_subheading),
      ],
      navigationDots: 3,
      navigationDotsIndex: 1,
      buttons: [
        OnboardingButton(
            label: loc.envoy_pp_new_seed_backup_cta,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return PpNewSeedSuccessPage();
              }));
            }),
      ],
    );
  }
}
