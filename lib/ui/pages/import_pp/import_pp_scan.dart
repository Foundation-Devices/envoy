import 'package:envoy/ui/pages/scanner_page.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/templates/onboarding_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ImportPpScanPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    return OnboardingPage(
      key: Key("import_pp_scan"),
      text: [
        OnboardingText(
            header: loc.envoy_import_pp_scan_heading,
            text: loc.envoy_import_pp_scan_subheading),
      ],
      navigationDots: 2,
      navigationDotsIndex: 1,
      buttons: [
        OnboardingButton(
            label: loc.envoy_import_pp_scan_cta,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return ScannerPage(ScannerType.pair);
              }));
            }),
      ],
    );
  }
}
