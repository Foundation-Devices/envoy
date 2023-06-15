// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/home/cards/learn/videos.dart';
import 'package:envoy/ui/home/cards/tl_navigation_card.dart';
import 'package:flutter/material.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/home/cards/learn/faq.dart';
import 'package:envoy/ui/home/cards/navigation_card.dart';

//ignore: must_be_immutable
class LearnCard extends StatefulWidget with TopLevelNavigationCard {
  @override
  TopLevelNavigationCardState<TopLevelNavigationCard> createState() {
    var state = LearnCardState();
    tlCardState = state;
    return state;
  }
}

class LearnCardState extends State<LearnCard> with TopLevelNavigationCardState {
  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable

    push(DefaultLearnCard());

    return AnimatedSwitcher(
        duration: Duration(milliseconds: 250), child: cardStack.last);
  }
}

//ignore: must_be_immutable
class DefaultLearnCard extends StatelessWidget with NavigationCard {
  DefaultLearnCard() {
    optionsWidget = null;
    modal = false;
    title = "Learn".toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Stack(children: [
          Padding(
              padding: EdgeInsets.only(bottom: 50),
              child: Column(children: [
                Material(
                  color: Colors.transparent,
                  child: TabBar(
                    labelStyle: Theme.of(context).textTheme.titleSmall,
                    indicatorColor: EnvoyColors.darkTeal,
                    labelColor: Colors.black,
                    tabs: [
                      Tab(
                        text: S().envoy_learn_videos,
                      ),
                      Tab(
                        text: S().envoy_learn_faqs,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [Videos(), Faq()],
                  ),
                )
              ])),
          Positioned(
            height: 85,
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                      EnvoyColors.whitePrint,
                      EnvoyColors.transparent
                    ],
                        stops: [
                      0.6,
                      1.0
                    ])),
              ),
            ),
          )
        ]));
  }
}
