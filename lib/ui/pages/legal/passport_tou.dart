// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/pages/scv/scv_intro.dart';
import 'package:envoy/ui/routes/accounts_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:envoy/ui/onboard/onboard_page_wrapper.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:go_router/go_router.dart';

class TouPage extends StatefulWidget {
  final bool fromExternal;

  const TouPage({super.key, this.fromExternal = false});

  @override
  State<TouPage> createState() => _TouPageState();
}

class _TouPageState extends State<TouPage> {
  String? _htmlContent;

  @override
  void initState() {
    super.initState();
    _loadHtml();
  }

  void _loadHtml() async {
    String data = await rootBundle.loadString('assets/passport_tou.html');
    setState(() {
      _htmlContent = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return OnboardPageBackground(
      key: const Key("tou"),
      child: Material(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: _htmlContent != null
              ? MainAxisAlignment.start
              : MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: EnvoySpacing.medium1),
                        child: GestureDetector(
                          onTap: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            } else {
                              context.go(ROUTE_ACCOUNTS_HOME);
                            }
                          },
                          child: const Icon(Icons.arrow_back_ios_rounded,
                              size: 20),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: EnvoySpacing.xs),
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            context.go(ROUTE_ACCOUNTS_HOME);
                          },
                        ),
                      ),
                    ],
                  ),
                  Text(
                    S().envoy_account_tos_heading,
                    textAlign: TextAlign.center,
                    style: EnvoyTypography.heading,
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(EnvoySpacing.xs),
                scrollDirection: Axis.vertical,
                child: DefaultTextStyle(
                  style: Theme.of(context).textTheme.bodySmall!,
                  child: _htmlContent != null
                      ? Html(data: _htmlContent)
                      : CircularProgressIndicator(),
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
