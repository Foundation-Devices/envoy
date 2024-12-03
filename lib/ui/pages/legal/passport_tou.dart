// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/pages/scv/scv_intro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:envoy/ui/onboard/onboard_page_wrapper.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';

class TouPage extends StatelessWidget {
  const TouPage({super.key});

  @override
  Widget build(BuildContext context) {
    //ignore:unused_local_variable

    return OnboardPageBackground(
      key: const Key("tou"),
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
                      child: const Icon(Icons.arrow_back_ios_rounded, size: 20),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: EnvoySpacing.xs),
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
            Text(S().envoy_account_tos_heading,
                textAlign: TextAlign.center, style: EnvoyTypography.heading),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(4.0),
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
                      return const SizedBox.shrink();
                    }
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: EnvoySpacing.small,
                left: EnvoySpacing.xs,
                right: EnvoySpacing.xs,
                bottom: EnvoySpacing.medium2,
              ),
              child: OnboardingButton(
                label: S().envoy_account_tos_cta,
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return const ScvIntroPage();
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
