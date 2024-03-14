// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:flutter/cupertino.dart';

import '../../theme/envoy_colors.dart';
import '../../theme/envoy_spacing.dart';
import '../../theme/envoy_typography.dart';

class BuyBitcoinCard extends StatefulWidget {
  const BuyBitcoinCard({super.key});

  @override
  State<BuyBitcoinCard> createState() => _BuyBitcoinCardState();
}

class _BuyBitcoinCardState extends State<BuyBitcoinCard> {
  @override
  Widget build(BuildContext context) {
    return Container(color: const Color(0xFFFFE306));
  }
}

class BuyOptionDialog extends StatelessWidget {
  const BuyOptionDialog({
    super.key,
    this.website,
    this.description,
    required this.icon,
    required this.name, required this.poweredByIcons,
  });

  final String name;
  final EnvoyIcons icon;
  final String? website;
  final String? description;

  final List<EnvoyIcons> poweredByIcons;
  final bool emailRequired=false; // nastavit

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: EnvoySpacing.medium3, horizontal: EnvoySpacing.medium2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (description != null)
            Text(
              description!,
              textAlign: TextAlign.center,
            ),
          //if (street != null) Text(street!, textAlign: TextAlign.center),
          if (website != null)
            GestureDetector(
              child: Text(
                website!,
                textAlign: TextAlign.center,
                style: EnvoyTypography.button
                    .copyWith(color: EnvoyColors.accentPrimary),
              ),
              onTap: () {},
            ),
          //if (street == null && description == null && website == null)
            const Text("No extra details available for this atm."),
        ],
      ),
    );
  }
}
