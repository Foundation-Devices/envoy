import 'package:envoy/ui/pages/wallet/single_wallet_address_verify_confirm.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/templates/onboarding_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:wallet/wallet.dart';

class SingleWalletAddressVerifyPage extends StatelessWidget {
  final Wallet pairedWallet;
  SingleWalletAddressVerifyPage(this.pairedWallet);

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    return OnboardingPage(
      key: Key("single_wallet_address_verify"),
      clipArt: Image.asset("assets/address_verify.png"),
      qrCode: pairedWallet.getAddress(),
      text: [
        OnboardingText(
            header: loc.single_envoy_wallet_address_verify_heading,
            text: loc.single_envoy_wallet_address_verify_subheading),
      ],
      buttons: [
        OnboardingButton(
            label: loc.single_envoy_wallet_address_verify_cta,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return SingleWalletAddressVerifyConfirmPage();
              }));
            }),
      ],
    );
  }
}
