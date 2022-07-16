import 'package:envoy/ui/pages/wallet/single_wallet_address_verify.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/templates/onboarding_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:wallet/wallet.dart';

class SingleWalletPairSuccessPage extends StatelessWidget {
  final Wallet pairedWallet;

  SingleWalletPairSuccessPage(this.pairedWallet);

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    return OnboardingPage(
      key: Key("single_wallet_pair_success"),
      clipArt: Image.asset("assets/circle_ok.png"),
      text: [
        OnboardingText(
            header: loc.single_envoy_wallet_pair_success_heading,
            text: loc.single_envoy_wallet_pair_success_subheading),
      ],
      buttons: [
        OnboardingButton(
            light: true,
            label: loc.single_envoy_wallet_pair_success_cta1,
            onTap: () {
              OnboardingPage.goHome(context);
            }),
        OnboardingButton(
            label: loc.single_envoy_wallet_pair_success_cta,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return SingleWalletAddressVerifyPage(pairedWallet);
              }));
            }),
      ],
    );
  }
}
