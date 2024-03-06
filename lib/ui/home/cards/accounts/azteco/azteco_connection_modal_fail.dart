// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/material.dart';

class AztecoConnectionModalFail extends StatefulWidget {
  final PageController controller;

  const AztecoConnectionModalFail({super.key, required this.controller});

  @override
  State<AztecoConnectionModalFail> createState() => _AztecoRedeemModalFail();
}

class _AztecoRedeemModalFail extends State<AztecoConnectionModalFail> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: EnvoySpacing.medium1,
                  vertical: EnvoySpacing.medium1),
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: EnvoySpacing.medium2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset("assets/exclamation_triangle.png",
                    scale: 1.0, width: 70, height: 70, fit: BoxFit.contain),
                Padding(
                  padding: const EdgeInsets.only(top: EnvoySpacing.medium1),
                  child: Text(
                    "Unable to Connect", // TODO: FIGMA
                    //S().azteco_connection_modal_fail_heading,
                    textAlign: TextAlign.center,
                    style: EnvoyTypography.heading,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: EnvoySpacing.medium1),
                  child: Text(
                    "Envoy is unable to connect with Azteco. Please contact support@azte.co or try again later.",
                    // TODO: FIGMA
                    //S().azteco_connection_modal_fail_subheading,
                    textAlign: TextAlign.center,
                    style: EnvoyTypography.info,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: EnvoySpacing.medium1,
                vertical: EnvoySpacing.medium2),
            child: EnvoyButton(
              "Continue", // TODO: FIGMA
              //S().azteco_connection_modal_fail_cta,
              type: EnvoyButtonTypes.primaryModal,
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}
