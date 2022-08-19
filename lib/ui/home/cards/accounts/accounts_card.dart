// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/account_manager.dart';
import 'package:envoy/ui/home/cards/indexed_transition_switcher.dart';
import 'package:envoy/ui/home/cards/tl_navigation_card.dart';
import 'package:envoy/ui/pages/import_pp/single_import_pp_intro.dart';
import 'package:envoy/ui/pages/legal/passport_tou.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/ui/templates/empty_card.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/home/cards/accounts/account_card.dart';
import 'package:envoy/ui/home/cards/accounts/account_list_tile.dart';
import 'package:envoy/ui/home/cards/navigation_card.dart';
import 'package:animations/animations.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';

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
      return SingleImportPpIntroPage();
    }));
  }

  _redraw() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    // Redraw when we there are changes in accounts
    AccountManager().addListener(_redraw);
  }

  @override
  void dispose() {
    super.dispose();
    AccountManager().removeListener(_redraw);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // ignore: unused_local_variable

    final navigator = CardNavigator(push, pop, hideOptions);

    if (cardStack.isEmpty) {
      navigator.push(AccountsList(navigator, _showAddAccountPage));
    }

    return IndexedTransitionSwitcher(
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
    );
  }

  @override
  bool get wantKeepAlive => false;
}

//ignore: must_be_immutable
class AccountsList extends StatefulWidget with NavigationCard {
  AccountsList(CardNavigator? navigationCallback, Function() addAccountFunction)
      : super(key: UniqueKey()) {
    optionsWidget = null;
    modal = false;
    title = S().envoy_home_accounts.toUpperCase();
    navigator = navigationCallback;
    rightFunction = addAccountFunction;
  }

  @override
  State<AccountsList> createState() => _AccountsListState();
}

class _AccountsListState extends State<AccountsList> {
  _redraw() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    // Redraw when we there are changes in devices
    AccountManager().addListener(_redraw);
  }

  @override
  void dispose() {
    super.dispose();
    AccountManager().removeListener(_redraw);
  }

  @override
  Widget build(BuildContext context) {
    return AccountManager().accounts.isEmpty
        ? EmptyCard(widget.rightFunction!,
            buttons: [
              EnvoyButton(
                S().envoy_accounts_new_passport,
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return TouPage();
                  }));
                },
              ),
              EnvoyButton(
                S().envoy_accounts_existing_passport,
                onTap: widget.rightFunction!,
                light: true,
              )
            ],
            helperText: EmptyCardHelperText(
                text: S().envoy_accounts_no_devices,
                onTap: () {
                  launchUrl(
                      Uri.parse("https://foundationdevices.com/passport"));
                }))
        : Padding(
            padding: const EdgeInsets.all(20),
            child: DragAndDropLists(
              constrainDraggingAxis: false,
              removeTopPadding: true,
              children: [
                DragAndDropList(
                    children: AccountManager()
                        .accounts
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
                setState(() {
                  AccountManager().moveAccount(oldItemIndex, newItemIndex);
                });
              },
            ),
          );
  }
}
