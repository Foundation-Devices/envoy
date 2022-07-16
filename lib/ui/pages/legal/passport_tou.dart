import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/templates/onboarding_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:envoy/ui/pages/scv/scv_intro.dart';
import 'package:flutter_html/flutter_html.dart';

class TouPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //ignore:unused_local_variable
    var loc = AppLocalizations.of(context)!;
    return OnboardingPage(
      key: Key("tos"),
      text: [
        OnboardingText(
            header: "Please review and accept the Passport Terms of Use"),
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(4.0),
            scrollDirection: Axis.vertical,
            child: FutureBuilder<String>(
                future: rootBundle.loadString('assets/passport_tou.html'),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Html(
                      data: snapshot.data,
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                }),
          ),
        )
      ],
      buttons: [
        OnboardingButton(
            label: "I Accept",
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return ScvIntroPage();
              }));
            }),
      ],
    );
  }
}
