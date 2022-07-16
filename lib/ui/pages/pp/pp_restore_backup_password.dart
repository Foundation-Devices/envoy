import 'package:envoy/ui/pages/pp/pp_restore_backup_success.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/templates/onboarding_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PpRestoreBackupPasswordPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    return OnboardingPage(
      key: Key("pp_restore_backup_password"),
      text: [
        OnboardingText(
            header: loc.envoy_pp_restore_backup_password_heading,
            text: loc.envoy_pp_restore_backup_password_subheading),
      ],
      navigationDots: 3,
      navigationDotsIndex: 1,
      buttons: [
        OnboardingButton(
            label: loc.envoy_pp_restore_backup_password_cta,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return PpRestoreBackupSuccessPage();
              }));
            }),
      ],
    );
  }
}
