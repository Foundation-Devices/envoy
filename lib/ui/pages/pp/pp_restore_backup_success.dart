import 'package:envoy/ui/pages/import_pp/single_import_pp_intro.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/templates/onboarding_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PpRestoreBackupSuccessPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    return OnboardingPage(
      key: Key("pp_restore_backup_success"),
      clipArt: Image.asset("assets/circle_ok.png"),
      text: [
        OnboardingText(
            header: loc.envoy_pp_restore_backup_success_heading,
            text: loc.envoy_pp_restore_backup_success_subheading),
      ],
      navigationDots: 3,
      navigationDotsIndex: 2,
      buttons: [
        OnboardingButton(
            label: loc.envoy_pp_restore_backup_success_cta,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return SingleImportPpIntroPage();
              }));
            }),
      ],
    );
  }
}
