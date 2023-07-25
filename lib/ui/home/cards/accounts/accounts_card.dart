// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:ui';
import 'package:animations/animations.dart';
import 'package:envoy/business/account_manager.dart';
import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/fading_edge_scroll_view.dart';
import 'package:envoy/ui/home/cards/accounts/account_card.dart';
import 'package:envoy/ui/home/cards/accounts/account_list_tile.dart';
import 'package:envoy/ui/home/cards/accounts/empty_accounts_card.dart';
import 'package:envoy/ui/home/cards/indexed_transition_switcher.dart';
import 'package:envoy/ui/home/cards/navigation_card.dart';
import 'package:envoy/ui/home/cards/tl_navigation_card.dart';
import 'package:envoy/ui/onboard/onboard_welcome_envoy.dart';
import 'package:envoy/ui/onboard/onboard_welcome_passport.dart';
import 'package:envoy/ui/state/accounts_state.dart';
import 'package:envoy/ui/state/home_page_state.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/ui/home/cards/devices/devices_card.dart';

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
        return OnboardEnvoyWelcomeScreen();
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

  bool _onReOrderStart = false;

  @override
  void initState() {
    super.initState();

    // Redraw when we fetch exchange rate
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountsProvider);
    return accounts.isEmpty
        ? Padding(
            padding: const EdgeInsets.all(6 * 4),
            child: EmptyAccountsCard(),
          )
        : Padding(
            padding:
                const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 60),
            child: FadingEdgeScrollView.fromScrollView(
              scrollController: _scrollController,
              child: ReorderableListView(
                  footer: Opacity(
                    child: AccountPrompts(),
                    opacity: _onReOrderStart ? 0.0 : 1.0,
                  ),
                  shrinkWrap: true,
                  scrollController: _scrollController,
                  //proxyDecorator is the widget that is shown when dragging
                  proxyDecorator: (widget, index, animation) {
                    return FadeTransition(
                      opacity:
                          animation.drive(Tween<double>(begin: 1.0, end: 0.5)),
                      child: ScaleTransition(
                        scale: animation
                            .drive(Tween<double>(begin: 0.95, end: 1.02)),
                        child: widget,
                      ),
                    );
                  },
                  onReorderEnd: (index) {
                    setState(() {
                      _onReOrderStart = false;
                    });
                  },
                  onReorderStart: (index) {
                    setState(() {
                      _onReOrderStart = true;
                    });
                  },
                  onReorder: (oldIndex, newIndex) async {
                    await AccountManager()
                        .moveAccount(oldIndex, newIndex, accounts);
                  },
                  children: [
                    for (final account in accounts)
                      SizedBox(
                          key: ValueKey(account.id),
                          height: 124,
                          child: AccountListTile(
                            account,
                            onTap: () {
                              ref
                                      .read(homePageAccountsProvider.notifier)
                                      .state =
                                  HomePageAccountsState(
                                      HomePageAccountsNavigationState.details,
                                      currentAccount: account);
                              widget.navigator!.push(AccountCard(account,
                                  navigationCallback: widget.navigator));
                            },
                          ))
                  ]),
            ),
          );
  }
}

class AccountPrompts extends ConsumerWidget {
  const AccountPrompts();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TextStyle _explainerTextStyle = TextStyle(
        fontFamily: 'Montserrat',
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w400,
        color: EnvoyColors.grey);
    var isHideAmountDismissed =
        ref.watch(arePromptsDismissedProvider(DismissiblePrompt.hideAmount));

    var isDragAndDropDismissed =
        ref.watch(arePromptsDismissedProvider(DismissiblePrompt.dragAndDrop));

    var userInteractedWithReceive = ref.watch(arePromptsDismissedProvider(
        DismissiblePrompt.userInteractedWithReceive));
    var accounts = ref.watch(accountsProvider);
    var accountsHaveZeroBalance = ref.watch(accountsZeroBalanceProvider);

    //Show if the user never tried receive screen and has no balance
    if (!userInteractedWithReceive && accountsHaveZeroBalance) {
      return Center(
          child: Padding(
        padding: const EdgeInsets.only(top: 0.0),
        child: Text(
          accounts.length == 1
              ? S().hot_wallet_accounts_creation_done_text_explainer
              : S()
                  .hot_wallet_accounts_creation_done_text_explainer_more_than_1_accnt,
          style: _explainerTextStyle,
        ),
      ));
    } else {
      if (!isHideAmountDismissed && !accountsHaveZeroBalance) {
        return Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 5,
            children: [
              Text(
                S().hide_amount_first_time_text,
                style: _explainerTextStyle,
              ),
              GestureDetector(
                child: Text(
                  S().hide_amount_first_time_text_button,
                  style: _explainerTextStyle.copyWith(color: EnvoyColors.teal),
                ),
                onTap: () {
                  EnvoyStorage().addPromptState(DismissiblePrompt.hideAmount);
                },
              ),
            ],
          ),
        );
      }

      if (!isDragAndDropDismissed && accounts.length > 1) {
        return Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 5,
            children: [
              Text(
                S().tap_and_drag_first_time_text,
                style: _explainerTextStyle,
              ),
              GestureDetector(
                child: Text(
                  S().tap_and_drag_first_time_text_button,
                  style: _explainerTextStyle.copyWith(color: EnvoyColors.teal),
                ),
                onTap: () {
                  EnvoyStorage().addPromptState(DismissiblePrompt.dragAndDrop);
                },
              ),
            ],
          ),
        );
      }
    }
    return SizedBox.square();
  }
}

void showSecurityDialog(BuildContext context) {
  EnvoyStorage().addPromptState(DismissiblePrompt.secureWallet);
  showEnvoyDialog(
      context: context,
      dismissible: false,
      dialog: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.all(16)),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/exclamation_icon.png",
                    height: 60,
                    width: 60,
                  ),
                  Padding(padding: EdgeInsets.all(16)),
                  Container(
                    constraints: BoxConstraints(maxWidth: 200),
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    child: Text(S().wallet_security_modal__heading,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    child: Text(
                      S().wallet_security_modal_subheading,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              OnboardingButton(
                  type: EnvoyButtonTypes.tertiary,
                  label: S().wallet_security_modal_cta2,
                  onTap: () {
                    Navigator.of(context).pop();
                  }),
              OnboardingButton(
                  type: EnvoyButtonTypes.primaryModal,
                  label: S().wallet_security_modal_cta1,
                  onTap: () {
                    Navigator.of(context).pop();
                    showDialog(
                      context: context,
                      builder: (context) {
                        return BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: Material(child: DeviceEmptyVideo()));
                      },
                    );
                  }),
              Padding(padding: EdgeInsets.all(12)),
            ],
          ),
        ),
      ));
}
