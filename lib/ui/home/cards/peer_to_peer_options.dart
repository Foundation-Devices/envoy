// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/components/button.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/buy_btc_option_card.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';

enum PeerToPeerState { none, hodl }

class PeerToPeerCard extends StatefulWidget {
  const PeerToPeerCard({super.key});

  @override
  State<PeerToPeerCard> createState() => _PeerToPeerCardState();
}

class _PeerToPeerCardState extends State<PeerToPeerCard> {
  PeerToPeerState currentState = PeerToPeerState.none;

  // void _updateState(PeerToPeerState newState) {
  //   setState(() {
  //     currentState = newState;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: EnvoySpacing.medium1, horizontal: EnvoySpacing.medium2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    S().buy_bitcoin_buyOptions_peerToPeer_options_heading,
                    style: EnvoyTypography.subheading,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: EnvoySpacing.medium2,
                  ),
                  BuyOptionCard(
                    icon: EnvoyIcons.hodlHodl,
                    label: S()
                        .buy_bitcoin_buyOptions_peerToPeer_options_card_hodlHodl,
                    description: S()
                        .buy_bitcoin_buyOptions_peerToPeer_options_card_hodlHodl_subheading,
                    isSelected: false,
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: EnvoySpacing.medium2),
            child: EnvoyButton(
              label: S().component_continue,
              type: ButtonType.primary,
              state: ButtonState.defaultState,
              onTap: () {},
            ),
          )
        ],
      ),
    );
  }
}
