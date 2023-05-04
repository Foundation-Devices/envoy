// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/account_manager.dart';
import 'package:envoy/ui/fading_edge_scroll_view.dart';
import 'package:envoy/ui/home/cards/indexed_transition_switcher.dart';
import 'package:envoy/ui/home/cards/tl_navigation_card.dart';
import 'package:envoy/ui/onboard/magic/magic_setup_tutorial.dart';
import 'package:envoy/ui/onboard/manual/manual_setup.dart';
import 'package:envoy/ui/onboard/onboard_welcome_passport.dart';
import 'package:envoy/ui/state/accounts_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/templates/empty_card.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/home/cards/accounts/account_card.dart';
import 'package:envoy/ui/home/cards/accounts/account_list_tile.dart';
import 'package:envoy/ui/home/cards/navigation_card.dart';
import 'package:animations/animations.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/business/envoy_seed.dart';

//ignore: must_be_immutable
class AccountsCard extends StatefulWidget with TopLevelNavigationCard {
  AccountsCard({
    Key? key,
  }) : super(key: key);

  @override
  TopLevelNavigationCardState<TopLevelNavigationCard> createState() {
    var state = AccountsCardState();
    tlCardState = state;
    return state;
  }
}

// The keep alive mixin is necessary to maintain state when widget is not visible
// Unfortunately it seems to only work with TabView
class AccountsCardState extends State<AccountsCard>
    with AutomaticKeepAliveClientMixin, TopLevelNavigationCardState {
  void _showAddAccountPage() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      if (EnvoySeed().walletDerived()) {
        return OnboardPassportWelcomeScreen();
      } else {
        return MagicSetupTutorial();
      }
    }));
  }

  _redraw() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    // Redraw when we fetch exchange rate
    ExchangeRate().addListener(_redraw);
  }

  @override
  void dispose() {
    super.dispose();
    ExchangeRate().removeListener(_redraw);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // ignore: unused_local_variable

    final navigator = CardNavigator(push, pop, hideOptions);

    if (cardStack.isEmpty) {
      navigator.push(AccountsList(navigator, _showAddAccountPage));
    }

    return WillPopScope(
      onWillPop: () async {
        if (cardStack.length > 1) {
          pop();
          return false;
        }
        return true;
      },
      child: IndexedTransitionSwitcher(
        children: cardStack,
        index: cardStack.length - 1,
        transitionBuilder: (
          Widget child,
          Animation<double> primaryAnimation,
          Animation<double> secondaryAnimation,
        ) {
          return FadeThroughTransition(
            animation: primaryAnimation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => false;
}

//ignore: must_be_immutable
class AccountsList extends ConsumerStatefulWidget with NavigationCard {
  AccountsList(CardNavigator? navigationCallback, Function() addAccountFunction)
      : super(key: UniqueKey()) {
    optionsWidget = null;
    modal = false;
    title = S().envoy_home_accounts.toUpperCase();
    navigator = navigationCallback;
    rightFunction = addAccountFunction;
  }

  @override
  ConsumerState<AccountsList> createState() => _AccountsListState();
}

class _AccountsListState extends ConsumerState<AccountsList> {
  final ScrollController _scrollController = ScrollController();

  _redraw() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    // Redraw when we fetch exchange rate
    ExchangeRate().addListener(_redraw);
  }

  @override
  void dispose() {
    super.dispose();
    ExchangeRate().removeListener(_redraw);
  }

  @override
  Widget build(BuildContext context) {
    var accounts = ref.watch(accountsProvider);
    return accounts.isEmpty
        ? EmptyCard(widget.rightFunction!,
            buttons: [
              EnvoyButton(
                "Set up Envoy Wallet",
                onTap: widget.rightFunction!,
                type: EnvoyButtonTypes.primary,
              ),
              EnvoyButton(
                S().envoy_welcome_screen_cta2,
                type: EnvoyButtonTypes.secondary,
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return ManualSetup();
                  }));
                },
              ),
            ],
            helperText: EmptyCardHelperText(
                text: "No accounts are set up.\n"
                    "Create a new wallet below.",
                onTap: () {
                  launchUrl(
                      Uri.parse("https://foundationdevices.com/passport"));
                }))
        : Padding(
            padding:
                const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 60),
            child: FadingEdgeScrollView.fromScrollView(
              scrollController: _scrollController,
              child: DragAndDropLists(
                constrainDraggingAxis: false,
                removeTopPadding: true,
                scrollController: _scrollController,
                children: [
                  DragAndDropList(
                      children: accounts
                          .map((e) => DragAndDropItem(
                                  child: Padding(
                                padding: const EdgeInsets.only(bottom: 15),
                                child: AccountListTile(
                                  e,
                                  onTap: () {
                                    widget.navigator!.push(AccountCard(e,
                                        navigationCallback: widget.navigator));
                                  },
                                ),
                              )))
                          .toList())
                ],
                onListReorder: (int oldListIndex, int newListIndex) {},
                onItemReorder: (int oldItemIndex, int oldListIndex,
                    int newItemIndex, int newListIndex) {
                  AccountManager().moveAccount(oldItemIndex, newItemIndex);
                },
              ),
            ),
          );
  }
}
