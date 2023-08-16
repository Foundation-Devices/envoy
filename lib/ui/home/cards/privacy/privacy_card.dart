// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/home/cards/tl_navigation_card.dart';
import 'package:flutter/material.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/home/cards/navigation_card.dart';

//ignore: must_be_immutable
class PrivacyCard extends StatefulWidget with TopLevelNavigationCard {
  @override
  TopLevelNavigationCardState<TopLevelNavigationCard> createState() {
    var state = PrivacyCardState();
    tlCardState = state;
    return state;
  }
}

class PrivacyCardState extends State<PrivacyCard>
    with TopLevelNavigationCardState {
  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable

    push(TopLevelPrivacyCard());
    return AnimatedSwitcher(
        duration: Duration(milliseconds: 250), child: cardStack.last);
  }
}

//ignore: must_be_immutable
class TopLevelPrivacyCard extends StatelessWidget with NavigationCard {
  TopLevelPrivacyCard() {
    optionsWidget = null;
    modal = false;
    title = S().bottomNav_activity.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
    );
  }
}
