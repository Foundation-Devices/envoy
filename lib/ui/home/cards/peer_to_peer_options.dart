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
import 'package:url_launcher/url_launcher.dart';

enum PeerToPeerState { none, hodl, bisq, robosats, peach }

class PeerToPeerCard extends StatefulWidget {
  const PeerToPeerCard({super.key});

  @override
  State<PeerToPeerCard> createState() => _PeerToPeerCardState();
}

class _PeerToPeerCardState extends State<PeerToPeerCard> {
  PeerToPeerState currentState = PeerToPeerState.none;

  void _updateState(PeerToPeerState newState) {
    setState(() {
      currentState = newState;
    });
  }

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
                    isSelected: currentState == PeerToPeerState.hodl,
                    onSelect: (selected) {
                      _updateState(PeerToPeerState.hodl);
                    },
                  ),
                  const SizedBox(
                    height: EnvoySpacing.medium1,
                  ),
                  BuyOptionCard(
                    icon: EnvoyIcons.bisq,
                    label: S().buy_bitcoin_buyOptions_peerToPeer_options_bisq,
                    description: S()
                        .buy_bitcoin_buyOptions_peerToPeer_options_bisq_subheading,
                    isSelected: currentState == PeerToPeerState.bisq,
                    onSelect: (selected) {
                      _updateState(PeerToPeerState.bisq);
                    },
                  ),
                  const SizedBox(
                    height: EnvoySpacing.medium1,
                  ),
                  BuyOptionCard(
                    icon: EnvoyIcons.robosats,
                    label:
                        S().buy_bitcoin_buyOptions_peerToPeer_options_robosats,
                    description: S()
                        .buy_bitcoin_buyOptions_peerToPeer_options_robosats_subheading,
                    isSelected: currentState == PeerToPeerState.robosats,
                    onSelect: (selected) {
                      _updateState(PeerToPeerState.robosats);
                    },
                  ),
                  const SizedBox(
                    height: EnvoySpacing.medium1,
                  ),
                  BuyOptionCard(
                    icon: EnvoyIcons.peach,
                    label: S().buy_bitcoin_buyOptions_peerToPeer_options_peach,
                    description: S()
                        .buy_bitcoin_buyOptions_peerToPeer_options_peach_subheading,
                    isSelected: currentState == PeerToPeerState.peach,
                    onSelect: (selected) {
                      _updateState(PeerToPeerState.peach);
                    },
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: EnvoySpacing.large1),
            child: EnvoyButton(
              label: "Open",
              //TODO: figma
              type: ButtonType.primary,
              state: currentState == PeerToPeerState.none
                  ? ButtonState.disabled
                  : ButtonState.defaultState,
              icon: EnvoyIcons.externalLink,
              onTap: () {
                launchPeerToPeerPage(currentState);
              },
            ),
          )
        ],
      ),
    );
  }
}

void launchPeerToPeerPage(PeerToPeerState state) {
  String url;
  switch (state) {
    case PeerToPeerState.none:
      url = "";
      break;
    case PeerToPeerState.hodl:
      url = "https://hodlhodl.com";
      break;
    case PeerToPeerState.bisq:
      url = "https://bisq.network/";
      break;
    case PeerToPeerState.robosats:
      url = "https://learn.robosats.com";
      break;
    case PeerToPeerState.peach:
      url = "https://peachbitcoin.com/";
      break;
  }
  launchUrl(Uri.parse(url));
}
