// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/pages/scv/scv_intro.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:envoy/ui/onboard/onboard_page_wrapper.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';

class TouPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //ignore:unused_local_variable

    return OnboardPageBackground(
      key: Key("tou"),
      child: Material(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: EnvoySpacing.medium1),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(Icons.arrow_back_ios_rounded, size: 20),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: EnvoySpacing.xs),
                    child: IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
            Text(
              S().envoy_account_tos_heading,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(4.0),
                scrollDirection: Axis.vertical,
                child: FutureBuilder<String>(
                  future: rootBundle.loadString('assets/passport_tou.html'),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return DefaultTextStyle(
                        style: Theme.of(context).textTheme.bodySmall!,
                        child: Html(
                          data: snapshot.data,
                        ),
                      );
                    } else {
                      return SizedBox.shrink();
                    }
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: EnvoySpacing.small,
                  bottom: EnvoySpacing.medium1,
                  left: EnvoySpacing.small,
                  right: EnvoySpacing.small),
              child: OnboardingButton(
                label: S().envoy_account_tos_cta,
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return ScvIntroPage();
                  }));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
