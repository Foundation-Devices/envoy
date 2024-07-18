// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/envoy_pattern_scaffold.dart';
import 'package:envoy/ui/onboard/onboard_privacy_setup.dart';
import 'package:envoy/ui/prime/onboard_prime_connect.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/util/build_context_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OnboardPrimeQuantumLink extends StatefulWidget {
  const OnboardPrimeQuantumLink({super.key});

  @override
  State<OnboardPrimeQuantumLink> createState() =>
      _OnboardPrimeQuantumLinkState();
}

class _OnboardPrimeQuantumLinkState extends State<OnboardPrimeQuantumLink> {
  @override
  Widget build(BuildContext context) {
    return EnvoyPatternScaffold(
      heroTag: "shield",
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: const CupertinoNavigationBarBackButton(
          color: Colors.white,
        ),
        actions: const [],
      ),
      header: const PrivacyShieldAnimated(),
      shield: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Flexible(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: EnvoySpacing.medium1),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
                    Text(
                      "Secure Bluetooth with\nQuantumLink",
                      textAlign: TextAlign.center,
                      style: EnvoyTypography.heading,
                    ),
                    const Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
                    ConstrainedBox(
                      constraints: BoxConstraints.tightFor(
                          width: MediaQuery.sizeOf(context).width * 0.75),
                      child: Text(
                        "QuantumLink creates an end-to-end encrypted Bluetooth tunnel using post-quantum encryption technology.\n\nPassport Prime’s Bluetooth chip only relays already encrypted data, ensuring private and secure communications.",
                        style: EnvoyTypography.body
                            .copyWith(color: const Color(0xff808080)),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                left: EnvoySpacing.medium2,
                right: EnvoySpacing.medium2,
                top: EnvoySpacing.xs,
                bottom: context.isSmallScreen
                    ? EnvoySpacing.xs
                    : EnvoySpacing.medium1),
            child: EnvoyButton(
              "Establish QuantumLink",
              onTap: () async {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return const OnboardPrime();
                  },
                ));
              },
            ),
          ),
        ],
      ),
    );
  }
}
