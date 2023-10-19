// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:animations/animations.dart';
import 'package:envoy/business/account.dart';
import 'package:envoy/business/account_manager.dart';
import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/pop_up.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/envoy_dialog.dart';
import 'package:envoy/ui/envoy_icons.dart' as oldIcons;
import 'package:envoy/ui/fading_edge_scroll_view.dart';
import 'package:envoy/ui/home/cards/accounts/account_list_tile.dart';
import 'package:envoy/ui/home/cards/accounts/accounts_state.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coin_tag_list_screen.dart';
import 'package:envoy/ui/home/cards/accounts/detail/filter_options.dart';
import 'package:envoy/ui/home/cards/accounts/detail/filter_state.dart';
import 'package:envoy/ui/home/cards/accounts/detail/transaction/transactions_details.dart';
import 'package:envoy/ui/home/cards/accounts/spend/spend_requirement_overlay.dart';
import 'package:envoy/ui/home/cards/accounts/spend/spend_state.dart';
import 'package:envoy/ui/home/cards/envoy_text_button.dart';
import 'package:envoy/ui/home/cards/text_entry.dart';
import 'package:envoy/ui/home/home_page.dart';
import 'package:envoy/ui/home/home_state.dart';
import 'package:envoy/ui/loader_ghost.dart';
import 'package:envoy/ui/pages/scanner_page.dart';
import 'package:envoy/ui/routes/accounts_router.dart';
import 'package:envoy/ui/routes/route_state.dart';
import 'package:envoy/ui/shield.dart';
import 'package:envoy/ui/state/hide_balance_state.dart';
import 'package:envoy/ui/state/home_page_state.dart';
import 'package:envoy/ui/state/transactions_state.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/util/amount.dart';
import 'package:envoy/util/blur_container_transform.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:wallet/wallet.dart';

//ignore: must_be_immutable
class AccountCard extends ConsumerStatefulWidget {
  final bool showUtxoPage;

  AccountCard({this.showUtxoPage = false}) : super(key: UniqueKey()) {}

  // @override
  // String? title = S().manage_account_address_heading.toUpperCase();

  @override
  ConsumerState<AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends ConsumerState<AccountCard>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Account account;
  late Animation<Alignment> animation;

  TextStyle _explainerTextStyleWallet = TextStyle(
      height: 2.0,
      fontFamily: 'Montserrat',
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w400,
      color: EnvoyColors.grey);

  _redraw() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    // Redraw when we fetch exchange rate
    ExchangeRate().addListener(_redraw);
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    animation = Tween(begin: Alignment(0.0, 1.0), end: Alignment(0.0, 0.65))
        .animate(CurvedAnimation(
            parent: animationController, curve: Curves.easeInOut));

    Future.delayed(Duration()).then((value) {
      account =
          ref.read(selectedAccountProvider) ?? AccountManager().accounts[0];
      ref.read(homePageTitleProvider.notifier).state =
          S().manage_account_address_heading;

      ref.read(homeShellOptionsProvider.notifier).state = HomeShellOptions(
          optionsWidget: AccountOptions(account),
          rightAction: Consumer(
            builder: (context, ref, child) {
              bool menuVisible = ref.watch(homePageOptionsVisibilityProvider);
              return IconButton(
                  onPressed: () {
                    HomePageState.of(context)?.toggleOptions();
                  },
                  icon: Icon(
                      menuVisible ? Icons.close : Icons.more_horiz_outlined));
            },
          ));

      bool showOverlay = ref.read(showSpendRequirementOverlayProvider);
      bool isInEditMode = ref.read(spendEditModeProvider);
      String path = ref.read(routePathProvider);
      if ((showOverlay || isInEditMode) && path == ROUTE_ACCOUNT_DETAIL) {
        showSpendRequirementOverlay(context, account);
        ref.read(hideBottomNavProvider.notifier).state = true;
      }
    });
  }

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    hideSpendRequirementOverlay();
    super.dispose();
    ExchangeRate().removeListener(_redraw);
  }

  @override
  Widget build(BuildContext context) {
    account = ref.read(selectedAccountProvider) ?? AccountManager().accounts[0];

    ref.listen(showSpendRequirementOverlayProvider, (previous, next) {
      print("Overlay state changed to $next $previous");
      if (next) {
        showSpendRequirementOverlay(context, account);
      } else {
        hideSpendRequirementOverlay();
      }
    });
    List<Transaction> transactions =
        ref.watch(transactionsProvider(account.id));

    bool txFiltersEnabled = ref.watch(isTransactionFiltersEnabled);

    return Scaffold(
      extendBody: true,
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 20,
            bottom: 0,
            left: 20,
            right: 20,
          ),
          child: AccountListTile(account, onTap: () {
            Navigator.pop(context);
            ref.read(homePageAccountsProvider.notifier).state =
                HomePageAccountsState(HomePageAccountsNavigationState.list);
          }),
        ),
        AnimatedSwitcher(
          duration: Duration(milliseconds: 200),
          child: (transactions.isNotEmpty || txFiltersEnabled)
              ? Container(
                  padding: EdgeInsets.only(
                      top: EnvoySpacing.medium2, bottom: EnvoySpacing.small),
                  child: FilterOptions(),
                )
              : SizedBox.shrink(),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: EnvoySpacing.medium1, vertical: EnvoySpacing.small),
            child: account.dateSynced == null
                ? ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: 4,
                    itemBuilder: (BuildContext context, int index) {
                      return GhostListTile();
                    },
                  )
                : (transactions.isNotEmpty)
                    ? _getMainWidget(context, transactions)
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GhostListTile(animate: false),
                          Expanded(
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 128),
                                child: Text(
                                  S().account_empty_tx_history_text_explainer,
                                  style: _explainerTextStyleWallet.copyWith(),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
          ),
        ),
      ]),
      bottomNavigationBar: Container(
        height: 100,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: EnvoyColors.white100,
              spreadRadius: 0,
              blurRadius: 24,
              offset: Offset(0, -8), // changes position of shadow
            ),
            BoxShadow(
              color: EnvoyColors.white100,
              spreadRadius: 12,
              blurRadius: 24,
            ),
          ],
        ),
        padding: const EdgeInsets.only(left: 50.0, right: 50.0, bottom: 35.0),
        child: Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: EnvoyTextButton(
                    label: S().receive_tx_list_receive,
                    onTap: () {
                      context.go(ROUTE_ACCOUNT_RECEIVE, extra: account);
                    }),
              ),
            ),
            QrShield(
                child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        oldIcons.EnvoyIcons.qr_scan,
                        size: 30,
                        color: EnvoyColors.darkTeal,
                      ),
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true)
                            .push(MaterialPageRoute(builder: (context) {
                          return MediaQuery.removePadding(
                            context: context,
                            child: ScannerPage(
                                [ScannerType.address, ScannerType.azteco],
                                account: account,
                                onAddressValidated: (address, amount) {
                              // Navigator.pop(context);
                              ref.read(spendAddressProvider.notifier).state =
                                  address;
                              ref.read(spendAmountProvider.notifier).state =
                                  amount;
                              context.go(ROUTE_ACCOUNT_SEND, extra: {
                                "account": account,
                                "address": address,
                                "amount": amount
                              });
                            }),
                          );
                        }));
                      },
                    ))),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: EnvoyTextButton(
                  onTap: () {
                    context.go(ROUTE_ACCOUNT_SEND);
                    return;
                    // widget.navigator!.push(
                    //     SendCard(widget.account, navigator: widget.navigator));
                  },
                  label: S().receive_tx_list_send,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getMainWidget(BuildContext context, List<Transaction> transactions) {
    AccountToggleState accountToggleState =
        ref.watch(accountToggleStateProvider);
    return PageTransitionSwitcher(
      reverse: accountToggleState == AccountToggleState.Tx,
      transitionBuilder: (
        Widget child,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
      ) {
        return SharedAxisTransition(
          animation: animation,
          fillColor: Colors.transparent,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.vertical,
          child: child,
        );
      },
      child: accountToggleState == AccountToggleState.Tx
          ? FadingEdgeScrollView.fromScrollView(
              gradientFractionOnEnd: 0.1,
              gradientFractionOnStart: 0.1,
              scrollController: _scrollController,
              child: StatefulBuilder(builder: (c, s) {
                return ListView.builder(
                  //Space for the white gradient shadow at the bottom
                  padding: EdgeInsets.only(bottom: 120),
                  physics: BouncingScrollPhysics(),
                  controller: _scrollController,
                  itemCount: transactions.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      child: TransactionListTile(
                          transaction: transactions[index], account: account),
                    );
                  },
                );
              }))
          : CoinsList(account: account),
    );
  }
}

class GhostListTile extends StatelessWidget {
  final bool animate;

  const GhostListTile({
    this.animate = true,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Padding(
        padding: const EdgeInsets.only(top: 2, right: 50),
        child: LoaderGhost(
          width: 10,
          height: 15,
          animate: animate,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 3.0, right: 80),
        child: LoaderGhost(
          width: 30,
          height: 15,
          animate: animate,
        ),
      ),
      leading: LoaderGhost(
        width: 50,
        height: 50,
        diagonal: true,
        animate: animate,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          LoaderGhost(
            width: 50,
            height: 15,
            animate: animate,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 3.0),
            child: LoaderGhost(
              width: 40,
              height: 15,
              animate: animate,
            ),
          )
        ],
      ),
    );
  }
}

class TransactionListTile extends StatelessWidget {
  const TransactionListTile({
    Key? key,
    required this.transaction,
    required this.account,
  }) : super(key: key);

  final Transaction transaction;
  final Account account;

  @override
  Widget build(BuildContext context) {
    return BlurContainerTransform(
      useRootNavigator: true,
      closedBuilder: (context, action) {
        return GestureDetector(
          onTap: () {
            action();
          },
          onLongPress: () async {
            bool dismissed = await EnvoyStorage()
                .checkPromptDismissed(DismissiblePrompt.copyTxId);
            if (!dismissed) {
              showEnvoyPopUp(
                  context,
                  S().coincontrol_coin_change_spendable_tate_modal_subheading,
                  S().coincontrol_coin_change_spendable_tate_modal_cta1,
                  () {
                    Clipboard.setData(
                        ClipboardData(text: transaction.txId)); // here
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          "Transaction ID copied to clipboard!"), //TODO: FIGMA
                    ));
                  },
                  icon: EnvoyIcons.info,
                  secondaryButtonLabel:
                      S().coincontrol_coin_change_spendable_state_modal_cta2,
                  onSecondaryButtonTap: () {
                    Navigator.pop(context);
                  },
                  checkBoxText: "Don’t show again",
                  // TODO: FIGMA
                  checkedValue: dismissed,
                  onCheckBoxChanged: (checkedValue) {
                    if (!checkedValue) {
                      EnvoyStorage().addPromptState(DismissiblePrompt.copyTxId);
                    } else if (checkedValue) {
                      EnvoyStorage()
                          .removePromptState(DismissiblePrompt.copyTxId);
                    }
                  });
            } else {
              Clipboard.setData(ClipboardData(text: transaction.txId)); // here
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content:
                    Text("Transaction ID copied to clipboard!"), //TODO: FIGMA
              ));
            }
          },
          child: ListTile(
            title: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: transaction.amount < 0
                  ? Text(S().Sent)
                  : Text(S().activity_received),
            ),
            subtitle: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: transaction.type == TransactionType.azteco
                  ? Text(S().azteco_account_tx_history_pending_voucher)
                  : transaction.isConfirmed
                      ? Text(timeago.format(transaction.date))
                      : Text(S().receive_tx_list_awaitingConfirmation),
            ),
            leading: transaction.amount < 0
                ? Icon(Icons.call_made)
                : Icon(Icons.call_received),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: Settings().selectedFiat == null
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.end,
              children: [
                // Styled as ListTile.title and ListTile.subtitle respectively
                Consumer(
                  builder: (context, ref, child) {
                    bool hide =
                        ref.watch(balanceHideStateStatusProvider(account.id));
                    if (hide) {
                      return SizedBox(
                        width: 100,
                        height: 15,
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            color: Color(0xffEEEEEE),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                        ),
                      );
                    } else {
                      return child ?? Container();
                    }
                  },
                  child: Text(
                    transaction.type == TransactionType.azteco
                        ? ""
                        : getFormattedAmount(transaction.amount,
                            trailingZeroes: true),
                    style: Settings().selectedFiat == null
                        ? Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontSize: 20.0)
                        : Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (Settings().selectedFiat != null)
                  Consumer(
                    builder: (context, ref, child) {
                      bool hide =
                          ref.watch(balanceHideStateStatusProvider(account.id));
                      if (hide) {
                        return Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: SizedBox(
                            width: 64,
                            height: 15,
                            child: Container(
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                color: Color(0xffEEEEEE),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                              ),
                            ),
                          ),
                        );
                      } else {
                        return child ?? Container();
                      }
                    },
                    child: Text(
                        transaction.type == TransactionType.azteco
                            ? ""
                            : ExchangeRate().getFormattedAmount(
                                transaction.amount,
                                wallet: account.wallet),
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color:
                                Theme.of(context).textTheme.bodySmall!.color)),
                  ),
              ],
            ),
          ),
        );
      },
      openBuilder: (context, action) {
        return TransactionsDetailsWidget(
          account: account,
          tx: transaction,
        );
      },
    );
  }
}

class AccountOptions extends ConsumerStatefulWidget {
  final Account account;

  AccountOptions(
    this.account,
  ) : super(key: UniqueKey());

  @override
  ConsumerState<AccountOptions> createState() => _AccountOptionsState();
}

class _AccountOptionsState extends ConsumerState<AccountOptions> {
  late TextEntry textEntry;
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Divider(),
        SizedBox(
          height: 10,
        ),
        GestureDetector(
          child: Text(
            S().manage_account_menu_showDescriptor.toUpperCase(),
            style: TextStyle(color: Colors.white),
          ),
          onTap: () {
            HomePageState.of(context)?.toggleOptions();
            context.go(ROUTE_ACCOUNT_DESCRIPTOR, extra: widget.account);
          },
        ),
        SizedBox(
          height: 10,
        ),
        GestureDetector(
          child: Text(
            S().manage_account_menu_editAccountName.toUpperCase(),
            style: TextStyle(color: Colors.white),
          ),
          onTap: () {
            ref.read(homePageOptionsVisibilityProvider.notifier).state = false;
            bool isKeyboardShown = false;
            textEntry = TextEntry(
              focusNode: focusNode,
              maxLength: 20,
              placeholder: widget.account.name,
            );
            showEnvoyDialog(
              context: context,
              dialog: Builder(
                builder: (context) {
                  if (!isKeyboardShown) {
                    Future.delayed(Duration(milliseconds: 200)).then((value) {
                      FocusScope.of(context).requestFocus(focusNode);
                    });
                    isKeyboardShown = true;
                  }
                  return EnvoyDialog(
                    title: S().manage_account_rename_heading,
                    content: textEntry,
                    actions: [
                      EnvoyButton(
                        S().manage_account_rename_cta.toUpperCase(),
                        onTap: () {
                          AccountManager().renameAccount(
                              widget.account, textEntry.enteredText);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
        SizedBox(
          height: 10,
        ),
        GestureDetector(
          child: Text(S().delete.toUpperCase(),
              style: TextStyle(color: EnvoyColors.lightCopper)),
          onTap: () {
            ref.read(homePageOptionsVisibilityProvider.notifier).state = false;
            if (!widget.account.wallet.hot) {
              showEnvoyDialog(
                  context: context,
                  dialog: EnvoyDialog(
                    title: S().manage_account_remove_heading,
                    content: Text(S().manage_account_remove_subheading),
                    actions: [
                      EnvoyButton(
                        S().manage_account_remove_cta.toUpperCase(),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        onTap: () {
                          AccountManager().deleteAccount(widget.account);
                          // widget.navigator!.pop();
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ));
            } else {
              ref.read(homePageBackgroundProvider.notifier).state =
                  HomePageBackgroundState.backups;
              GoRouter.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}

abstract class VisibilityAwareState<T extends StatefulWidget>
    extends State<T> // ignore: prefer_mixin
    with
        WidgetsBindingObserver,
        _StackChangedListener {
  VisibilityAwareState({this.debugPrintsEnabled = false});

  static final Set<String> _widgetStack = {};
  static final Map<String, int> _widgetStackTimestamps = {};

  static final Set<_StackChangedListener> _listeners = {};

  bool debugPrintsEnabled;

  bool _isWidgetRemoved = false;

  WidgetVisibility? _widgetVisibility;

  /// Adds [widgetName] to the set.
  ///
  /// Returns `true` if [widgetName] was not yet in the set.
  /// Otherwise returns `false` and the set is not changed.
  static bool _addToStack(String widgetName) {
    final bool result = _widgetStack.add(widgetName);
    if (result) {
      _widgetStackTimestamps[widgetName] =
          DateTime.now().millisecondsSinceEpoch;
      for (final listener in _listeners) {
        listener._onAddToStack(widgetName);
      }
      //debugPrint('_addToStack($widgetName) returns true, $_widgetStack');
    }
    return result;
  }

  /// Removes [widgetName] from the set.
  ///
  /// Returns `true` if [widgetName] was in the set, and `false` if not.
  /// The method has no effect if [widgetName] was not in the set.
  static bool _removeFromStack(String widgetName) {
    final bool result = _widgetStack.remove(widgetName);
    if (result) {
      _widgetStackTimestamps.remove(widgetName);
      //debugPrint('_removeFromStack($widgetName) returns true, $_widgetStack');
      for (final listener in _listeners) {
        listener._onRemoveFromStack();
      }
    }
    return result;
  }

  @override
  void _onAddToStack(String widgetName) {
    if (_widgetVisibility != WidgetVisibility.INVISIBLE &&
        runtimeType.toString() != widgetName &&
        !_wasAddedTogetherWith(widgetName)) {
      _onVisibilityChanged(WidgetVisibility.INVISIBLE);
    }
  }

  @override
  void _onRemoveFromStack() {
    if (_widgetStack.isNotEmpty &&
        (runtimeType.toString() == _widgetStack.last ||
            _wasAddedTogetherWith(_widgetStack.last))) {
      _onVisibilityChanged(WidgetVisibility.VISIBLE);
    }
  }

  @override
  void initState() {
    super.initState();
    //debugPrint('$runtimeType.initState()');
    WidgetsBinding.instance.addPostFrameCallback(_onWidgetLoaded);
    WidgetsBinding.instance.addObserver(this);
  }

  void _onWidgetLoaded(_) {
    //debugPrint('$runtimeType.onWidgetLoaded()');
    _listeners.add(this);
    WidgetsBinding.instance.addPersistentFrameCallback((timeStamp) {
      //print(runtimeType);
      if (!_isWidgetRemoved && _addToStack(runtimeType.toString())) {
        //debugPrint('Adding $runtimeType to stack. widgetStack = $_widgetStack');
        _onVisibilityChanged(WidgetVisibility.VISIBLE);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    //debugPrint('$runtimeType.dispose()');
    _isWidgetRemoved = true;
    _listeners.remove(this);
    _removeFromStack(runtimeType.toString());
    //print('Removing $runtimeType from stack. widgetStack = $_widgetStack');
    _onVisibilityChanged(WidgetVisibility.GONE);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // move app to background: inactive -> paused
    // open app from background: resumed
    if (debugPrintsEnabled) {
      debugPrint('$runtimeType.didChangeAppLifecycleState($state)');
    }
    if (state == AppLifecycleState.inactive) {
      // app is inactive (called on iOS if app overview is shown)
      _onVisibilityChanged(WidgetVisibility.INVISIBLE);
    } else if (state == AppLifecycleState.paused) {
      // user is about quit our app temporally
      // (called on iOS if the app is in background and overview was closed)
      _onVisibilityChanged(WidgetVisibility.INVISIBLE);
    } else if (state == AppLifecycleState.resumed) {
      // user returned to our app
      if (_widgetStack.isNotEmpty &&
          (runtimeType.toString() == _widgetStack.last ||
              _wasAddedTogetherWith(_widgetStack.last))) {
        _onVisibilityChanged(WidgetVisibility.VISIBLE);
      }
    } else if (state == AppLifecycleState.detached) {
      // still hosted on a flutter engine but is detached from any host views
    }
  }

  bool _wasAddedTogetherWith(String otherWidgetsName) {
    final int? timeOtherWasAdded = _widgetStackTimestamps[otherWidgetsName];
    final int? timeAdded = _widgetStackTimestamps[runtimeType.toString()];
    if (timeOtherWasAdded == null || timeAdded == null) {
      return false;
    }

    final int diff = (timeAdded > timeOtherWasAdded)
        ? timeAdded - timeOtherWasAdded
        : timeOtherWasAdded - timeAdded;

    if (diff < 50) {
      if (debugPrintsEnabled) {
        debugPrint(
            'diff of $otherWidgetsName and ${runtimeType.toString()}: $diff');
      }
      return true;
    }
    return false;
  }

  void _onVisibilityChanged(WidgetVisibility visibility) {
    if (_widgetVisibility != visibility) {
      _widgetVisibility = visibility;
      onVisibilityChanged(visibility);

      if (debugPrintsEnabled) {}
    }
  }

  void onVisibilityChanged(WidgetVisibility visibility) {}

  bool isVisible() {
    return _widgetVisibility == WidgetVisibility.VISIBLE;
  }

  void finish() {
    // close the whole screen
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      SystemNavigator.pop();
    }
  }
}

enum WidgetVisibility { VISIBLE, INVISIBLE, GONE }

mixin _StackChangedListener {
  void _onAddToStack(String widgetName);

  void _onRemoveFromStack();
}
