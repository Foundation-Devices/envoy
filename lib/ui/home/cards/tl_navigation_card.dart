// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter_neumorphic/flutter_neumorphic.dart';

import 'package:envoy/ui/home/home_page.dart';
import 'package:envoy/ui/home/cards/navigation_card.dart';

mixin TopLevelNavigationCard on StatefulWidget {
  TopLevelNavigationCardState? tlCardState;
}

mixin TopLevelNavigationCardState<T extends TopLevelNavigationCard>
    on State<T> {
  List<NavigationCard> cardStack = [];

  void push(NavigationCard card, {bool modal = false}) {
    setState(() {
      cardStack.add(card);
    });
    notifyHomePage();
  }

  void pop({int depth = 1}) {
    setState(() {
      if (depth == -1) {
        cardStack.clear();
      } else {
        cardStack.removeRange(cardStack.length - depth, cardStack.length);
      }
    });
    notifyHomePage();
  }

  void hideOptions() {
    notifyHomePage();
  }

  void notifyHomePage() {
    if (cardStack.isNotEmpty) {
      try {
        NavigationCard currentCard = cardStack.last;
        HomePageNotification(
            modal: currentCard.modal,
            optionsWidget: currentCard.optionsWidget,
            title: currentCard.title,
            rightFunctionIcon:
                cardStack.length > 1 ? Icons.more_horiz : Icons.add,
            rightFunction: currentCard.rightFunction,
            leftFunction: cardStack.length > 1
                ? () {
                    pop();
                  }
                : null)
          ..dispatch(context);
      } catch (e) {
        // ignore
      }
    }
  }
}
