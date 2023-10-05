// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:ui';

import 'package:envoy/business/account.dart';
import 'package:envoy/business/account_manager.dart';
import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/fading_edge_scroll_view.dart';
import 'package:envoy/ui/home/cards/accounts/account_list_tile.dart';
import 'package:envoy/ui/home/cards/accounts/empty_accounts_card.dart';
import 'package:envoy/ui/home/cards/devices/devices_card.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/routes/accounts_router.dart';
import 'package:envoy/ui/state/accounts_state.dart';
import 'package:envoy/ui/state/home_page_state.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';

//ignore: must_be_immutable
class AccountsCard extends StatefulWidget {
  AccountsCard({
    Key? key,
  }) : super(key: key);

  @override
  State<AccountsCard> createState() => AccountsCardState();
}

// The keep alive mixin is necessary to maintain state when widget is not visible
// Unfortunately it seems to only work with TabView
class AccountsCardState extends State<AccountsCard>
    with AutomaticKeepAliveClientMixin {
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

    return AccountsList();
    // final navigator = CardNavigator(push, pop, hideOptions);
    //
    // return WillPopScope(
    //   onWillPop: () async {
    //     if (cardStack.length > 1) {
    //       pop();
    //       return false;
    //     }
    //     return true;
    //   },
    //   child: IndexedTransitionSwitcher(
    //     children: cardStack,
    //     index: cardStack.length - 1,
    //     transitionBuilder: (
    //       Widget child,
    //       Animation<double> primaryAnimation,
    //       Animation<double> secondaryAnimation,
    //     ) {
    //       return FadeThroughTransition(
    //         animation: primaryAnimation,
    //         fillColor: Colors.transparent,
    //         secondaryAnimation: secondaryAnimation,
    //         child: child,
    //       );
    //     },
    //   ),
    // );
  }

  @override
  bool get wantKeepAlive => false;
}

//ignore: must_be_immutable
class AccountsList extends ConsumerStatefulWidget {
  final Widget? child;

  AccountsList({this.child}) : super(key: UniqueKey()) {}

  final GlobalKey _listKey = GlobalKey();

  @override
  ConsumerState<AccountsList> createState() => _AccountsListState();
}

class _AccountsListState extends ConsumerState<AccountsList> {
  late FadingEdgeScrollView _scrollView;
  final ScrollController _scrollController = ScrollController();
  double _accountHeight = 124;
  bool _onReOrderStart = false;
  double _listWidgetHeight = 0;

  @override
  void didChangeDependencies() {
    super
        .didChangeDependencies(); //  _screenListHeight will only be accurate once the layout is complete,
    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
  }

  void _afterLayout(_) {
    setState(() {
      _listWidgetHeight = _getListHeight();
    });
  }

  double _getListHeight() {
    if (widget._listKey.currentContext == null) {
      return 0.0;
    }

    final RenderBox listRenderBox =
        widget._listKey.currentContext!.findRenderObject() as RenderBox;
    return listRenderBox.size.height;
  }

  @override
  Widget build(BuildContext context) {
    final _accounts = ref.watch(accountsProvider);
    final _listContentHeight = _accounts.length * _accountHeight;

    final _isFadingEnabled = _listContentHeight > _listWidgetHeight;

    ref.listen(accountsProvider, (List<Account>? previous, List<Account> next) {
      if (previous!.length < next.length) {
        if (_scrollController.hasClients)
          _scrollController.animateTo(
            _listContentHeight, //when new acc, go to bottom to see the acc
            duration: const Duration(milliseconds: 1),
            curve: Curves.ease,
          );
      }

      if (previous.length > next.length) {
        if (_scrollController.hasClients)
          _scrollController.animateTo(
            0, //when delete acc go to top
            duration: const Duration(seconds: 1),
            curve: Curves.ease,
          );
      }
    });

    _scrollView = FadingEdgeScrollView.fromScrollView(
      scrollController: _scrollController,
      gradientFractionOnStart: _isFadingEnabled ? 0.1 : 0.0,
      gradientFractionOnEnd: _isFadingEnabled ? 0.1 : 0.0,
      child: ReorderableListView(
          key: widget._listKey,
          footer: Opacity(
            child: AccountPrompts(),
            opacity: _onReOrderStart ? 0.0 : 1.0,
          ),
          shrinkWrap: true,
          scrollController: _scrollController,
          //proxyDecorator is the widget that is shown when dragging
          proxyDecorator: (widget, index, animation) {
            return FadeTransition(
              opacity: animation.drive(Tween<double>(begin: 1.0, end: 0.5)),
              child: ScaleTransition(
                scale: animation.drive(Tween<double>(begin: 0.95, end: 1.02)),
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
            // SFT-2488: dismiss the drag and drop prompt after dragging
            EnvoyStorage().addPromptState(DismissiblePrompt.dragAndDrop);
            await AccountManager().moveAccount(oldIndex, newIndex, _accounts);
          },
          children: [
            for (final account in _accounts)
              SizedBox(
                  key: ValueKey(account.id),
                  height: _accountHeight,
                  child: AccountListTile(
                    account,
                    onTap: () {
                      context.go(ROUTE_ACCOUNT_DETAIL, extra: account);
                      return;
                      // ref.read(homePageAccountsProvider.notifier).state =
                      //     HomePageAccountsState(HomePageAccountsNavigationState.details, currentAccount: account);
                      // widget.navigator!.push(AccountCard(
                      //     account,
                      //     widget.navigator,
                      //     AccountOptions(
                      //       account,
                      //       navigator: widget.navigator,
                      //     )));
                    },
                  ))
          ]),
    );

    return _accounts.isEmpty
        ? Padding(
            padding: const EdgeInsets.all(24),
            child: EmptyAccountsCard(),
          )
        : Padding(
            padding:
                const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 60),
            child: _scrollView);
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
        color: EnvoyColors.textTertiary);
    var isHideAmountDismissed =
        ref.watch(arePromptsDismissedProvider(DismissiblePrompt.hideAmount));

    var isDragAndDropDismissed =
        ref.watch(arePromptsDismissedProvider(DismissiblePrompt.dragAndDrop));

    var userInteractedWithReceive = ref.watch(arePromptsDismissedProvider(
        DismissiblePrompt.userInteractedWithReceive));
    var accounts = ref.watch(accountsProvider);
    var accountsHaveZeroBalance = ref.watch(accountsZeroBalanceProvider);

    //Show if the user never visited receive screen, has no balance
    // and there is only one account visible
    if (!userInteractedWithReceive &&
        accountsHaveZeroBalance &&
        accounts.length == 1) {
      return Center(
          child: Wrap(alignment: WrapAlignment.center, spacing: 5, children: [
        Text(
          S().hot_wallet_accounts_creation_done_text_explainer,
          style: _explainerTextStyle,
        ),
        GestureDetector(
          child: Text(
            S().hot_wallet_accounts_creation_done_button,
            style:
                _explainerTextStyle.copyWith(color: EnvoyColors.accentPrimary),
          ),
          onTap: () {
            EnvoyStorage()
                .addPromptState(DismissiblePrompt.userInteractedWithReceive);
          },
        ),
      ]));
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
                  style: _explainerTextStyle.copyWith(
                      color: EnvoyColors.accentPrimary),
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
                  style: EnvoyTypography.button
                      .copyWith(color: EnvoyColors.accentPrimary),
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
