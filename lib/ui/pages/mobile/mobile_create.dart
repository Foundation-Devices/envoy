import 'package:envoy/ui/pages/mobile/mobile_backup_intro.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/templates/onboarding_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MobileCreatePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    return OnboardingPage(
      key: Key("mobile_create"),
      text: [
        OnboardingText(header: loc.envoy_mobile_create_heading),
      ],
      buttons: [
        OnboardingButton(
            label: loc.envoy_mobile_intro_cta,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return MobileBackupIntroPage();
              }));
            }),
      ],
    );
  }
}
