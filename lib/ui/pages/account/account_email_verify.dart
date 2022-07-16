import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/templates/onboarding_page.dart';
import 'package:envoy/ui/pages/fw/fw_microsd.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AccountEmailVerifyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    return OnboardingPage(
      key: Key("account_email_verify"),
      text: [
        OnboardingText(
            header: loc.envoy_account_intro_heading,
            text: loc.envoy_account_intro_cta2)
      ],
      buttons: [
        OnboardingButton(
            label: loc.envoy_account_intro_cta,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return FwMicrosdPage();
              }));
            }),
        OnboardingButton(
            label: loc.envoy_account_intro_cta1,
            onTap: () {
              OnboardingPage.goHome(context);
            }),
      ],
    );
  }
}
