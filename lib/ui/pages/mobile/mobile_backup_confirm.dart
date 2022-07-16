import 'package:envoy/ui/pages/pp/pp_setup_intro.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/templates/onboarding_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MobileBackupConfirmPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    return OnboardingPage(
      key: Key("mobile_backup_confirm"),
      text: [
        OnboardingText(
            header: loc.envoy_mobile_backup_confirm_card1_heading,
            text: loc.envoy_mobile_backup_confirm_card1_subheading),
        OnboardingText(
            header: loc.envoy_mobile_backup_confirm_card2_heading,
            text: loc.envoy_mobile_backup_confirm_card2_subheading),
      ],
      buttons: [
        OnboardingButton(
            label: loc.envoy_mobile_backup_confirm_cta,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return PpSetupIntroPage();
              }));
            }),
      ],
    );
  }
}
