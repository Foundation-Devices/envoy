import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/templates/onboarding_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class SingleWalletAddressVerifyConfirmPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    return OnboardingPage(
      key: Key("single_wallet_verify_confirm"),
      clipArt: Image.asset("assets/shield_info.png"),
      text: [
        OnboardingText(
            header: loc.single_envoy_wallet_address_verify_confirm_heading,
            text: loc.single_envoy_wallet_address_verify_confirm_subheading),
      ],
      buttons: [
        OnboardingButton(
          label: loc.single_envoy_wallet_address_verify_confirm_cta1,
          onTap: () {
            launchUrl(Uri.parse("mailto:hello@foundationdevices.com"));
          },
          light: true,
        ),
        OnboardingButton(
            label: loc.single_envoy_wallet_address_verify_confirm_cta,
            onTap: () {
              OnboardingPage.goHome(context);
            }),
      ],
    );
  }
}
