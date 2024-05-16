// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/scv_server.dart';
import 'package:envoy/business/uniform_resource.dart';
import 'package:envoy/ui/pages/scv/scv_scan_qr.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/generated/l10n.dart';

//ignore:must_be_immutable
class ScvShowQrPage extends StatelessWidget {
  Challenge? _challenge;

  ScvShowQrPage({super.key});

  @override
  Widget build(BuildContext context) {
    Future<CryptoRequest> cryptoRequest =
        ScvServer().getChallenge().then((challenge) {
      _challenge = challenge;
      var request = CryptoRequest();
      request.objects.add(ScvChallengeRequest.fromServer(challenge));
      return request;
    });

    return OnboardingPage(
      key: const Key("scv_show_qr"),
      qrCodeUrCryptoRequest: cryptoRequest,
      text: [
        Expanded(
          child: PageView(
            children: [
              SingleChildScrollView(
                child: OnboardingText(
                    header: S().envoy_scv_show_qr_heading,
                    text: S().envoy_scv_show_qr_subheading),
              ),
            ],
          ),
        )
      ],
      navigationDots: 3,
      navigationDotsIndex: 1,
      buttons: [
        OnboardingButton(
            label: S().component_next,
            onTap: () {
              if (_challenge != null) {
                // ENV-216: remove ScvShowQrPage off navigation stack so it doesn't animate in background
                Navigator.of(context)
                    .pushReplacement(MaterialPageRoute(builder: (context) {
                  return ScvScanQrPage(_challenge!);
                }));
              }
            }),
      ],
    );
  }
}
