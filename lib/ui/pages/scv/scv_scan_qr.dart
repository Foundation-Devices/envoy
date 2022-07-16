import 'package:envoy/ui/pages/scanner_page.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/templates/onboarding_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:envoy/business/scv_server.dart';

class ScvScanQrPage extends StatelessWidget {
  final Challenge challenge;

  ScvScanQrPage(this.challenge);

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    return OnboardingPage(
      key: Key("scv_scan_qr"),
      clipArt: Image.asset("assets/scv_scan_qr.png"),
      text: [
        OnboardingText(
            header: loc.envoy_scv_scan_qr_heading,
            text: loc.envoy_scv_scan_qr_subheading)
      ],
      navigationDots: 3,
      navigationDotsIndex: 2,
      buttons: [
        OnboardingButton(
            label: loc.envoy_scv_scan_qr_cta,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return ScannerPage.scv(challenge);
              }));
            }),
      ],
    );
  }
}
