// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:animations/animations.dart';
import 'package:envoy/business/account.dart';
import 'package:envoy/business/account_manager.dart';
import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/envoy_dialog.dart';
import 'package:envoy/ui/envoy_icons.dart';
import 'package:envoy/ui/fading_edge_scroll_view.dart';
import 'package:envoy/ui/home/cards/accounts/account_list_tile.dart';
import 'package:envoy/ui/home/cards/accounts/address_card.dart';
import 'package:envoy/ui/home/cards/accounts/descriptor_card.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coin_tags_list_widget.dart';
import 'package:envoy/ui/home/cards/accounts/detail/filter_options.dart';
import 'package:envoy/ui/home/cards/accounts/detail/filter_state.dart';
import 'package:envoy/ui/home/cards/accounts/send_card.dart';
import 'package:envoy/ui/home/cards/envoy_text_button.dart';
import 'package:envoy/ui/home/cards/navigation_card.dart';
import 'package:envoy/ui/home/cards/text_entry.dart';
import 'package:envoy/ui/loader_ghost.dart';
import 'package:envoy/ui/pages/scanner_page.dart';
import 'package:envoy/ui/shield.dart';
import 'package:envoy/ui/state/hide_balance_state.dart';
import 'package:envoy/ui/state/home_page_state.dart';
import 'package:envoy/ui/state/transactions_state.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/util/amount.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeAgo;
import 'package:wallet/wallet.dart';

//ignore: must_be_immutable
class AccountCard extends ConsumerStatefulWidget with NavigationCard {
  final Account account;

  AccountCard(this.account, {CardNavigator? navigationCallback})
      : super(key: UniqueKey()) {
    optionsWidget = AccountOptions(
      account,
      navigator: navigationCallback,
    );
    modal = false;
    title = S().manage_account_address_heading.toUpperCase();
    navigator = navigationCallback;
  }

  @override
  ConsumerState<AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends ConsumerState<AccountCard> {
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
  }

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    super.dispose();
    ExchangeRate().removeListener(_redraw);
  }

  @override
  Widget build(BuildContext context) {
    List<Transaction> transactions =
        ref.watch(transactionsProvider(widget.account.id));
    return Scaffold(
      extendBody: true,
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: AccountListTile(widget.account, onTap: () {
            widget.navigator!.pop();
            ref.read(homePageAccountsProvider.notifier).state =
                HomePageAccountsState(HomePageAccountsNavigationState.list);
          }),
        ),
        AnimatedSwitcher(
          duration: Duration(milliseconds: 200),
          child: transactions.isNotEmpty
              ? Container(
                  padding: EdgeInsets.only(bottom: 0),
                  child: FilterOptions(),
                )
              : SizedBox.shrink(),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
            child: widget.account.dateSynced == null
                ? ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: 4,
                    itemBuilder: (BuildContext context, int index) {
                      return GhostListTile();
                    },
                  )
                : transactions.isNotEmpty
                    ? _getMainWidget(context, transactions)
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GhostListTile(animate: false),
                          Expanded(
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.only(top: 14),
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
        height: 94,
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
        padding: const EdgeInsets.only(
            left: 50.0, right: 50.0, bottom: 24.0, top: 8.0),
        child: Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: EnvoyTextButton(
                    label: S().receive_tx_list_receive,
                    onTap: () {
                      //hide if prompt is not shown
                      EnvoyStorage().addPromptState(
                          DismissiblePrompt.userInteractedWithReceive);
                      widget.navigator!.push(AddressCard(
                        widget.account,
                        navigationCallback: widget.navigator,
                      ));
                    }),
              ),
            ),
            QrShield(
                child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        EnvoyIcons.qr_scan,
                        size: 30,
                        color: EnvoyColors.darkTeal,
                      ),
                      onPressed: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return ScannerPage(
                              [ScannerType.address, ScannerType.azteco],
                              account: widget.account,
                              onAddressValidated: (address, amount) {
                            widget.navigator!.push(SendCard(widget.account,
                                address: address,
                                amountSats: amount,
                                navigationCallback: widget.navigator));
                          });
                        }));
                      },
                    ))),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: EnvoyTextButton(
                  onTap: () {
                    widget.navigator!.push(SendCard(widget.account,
                        navigationCallback: widget.navigator));
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
                  //Accommodate for the FAB options
                  padding: EdgeInsets.only(bottom: 88),
                  controller: _scrollController,
                  itemCount: transactions.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      child: TransactionListTile(
                          transaction: transactions[index],
                          account: widget.account),
                    );
                  },
                );
              }))
          : CoinsList(
              callback: () {},
            ),
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
    return GestureDetector(
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: transaction.txId));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(S().envoy_account_transaction_copied_clipboard),
        ));
      },
      child: ListTile(
        title: transaction.amount < 0
            ? Text(S().envoy_account_sent)
            : Text(S().envoy_account_received),
        subtitle: transaction.type == TransactionType.azteco
            ? Text(S().azteco_account_tx_history_pending_voucher)
            : transaction.isConfirmed
                ? Text(timeAgo.format(transaction.date))
                : Text(S().envoy_account_awaiting_confirmation),
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
                bool hide = ref.watch(balanceHideStateStatusProvider(account));
                if (hide) {
                  return SizedBox(
                      width: 100,
                      height: 15,
                      child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                              color: Color(0xffEEEEEE),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)))));
                } else {
                  return child ?? Container();
                }
              },
              child: Text(
                transaction.type == TransactionType.azteco
                    ? ""
                    : getFormattedAmount(transaction.amount),
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
                      ref.watch(balanceHideStateStatusProvider(account));
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
                                      BorderRadius.all(Radius.circular(20))))),
                    );
                  } else {
                    return child ?? Container();
                  }
                },
                child: Text(
                    transaction.type == TransactionType.azteco
                        ? ""
                        : ExchangeRate().getFormattedAmount(transaction.amount),
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).textTheme.bodySmall!.color)),
              ),
          ],
        ),
      ),
    );
  }
}

class AccountOptions extends ConsumerStatefulWidget {
  final Account account;
  final CardNavigator? navigator;

  AccountOptions(this.account, {this.navigator}) : super(key: UniqueKey());

  @override
  ConsumerState<AccountOptions> createState() => _AccountOptionsState();
}

class _AccountOptionsState extends ConsumerState<AccountOptions> {
  late TextEntry textEntry;
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    textEntry = TextEntry(
      focusNode: focusNode,
      maxLength: 20,
      placeholder: widget.account.name,
    );
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
            S().envoy_account_show_descriptor.toUpperCase(),
            style: TextStyle(color: Colors.white),
          ),
          onTap: () {
            widget.navigator!.push(DescriptorCard(
              widget.account,
              navigationCallback: widget.navigator,
            ));
          },
        ),
        SizedBox(
          height: 10,
        ),
        GestureDetector(
          child: Text(
            S().envoy_account_edit_name.toUpperCase(),
            style: TextStyle(color: Colors.white),
          ),
          onTap: () {
            ref.read(homePageOptionsVisibilityProvider.notifier).state = false;
            bool isKeyboardShown = false;
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
                    title: S().envoy_account_rename,
                    content: textEntry,
                    actions: [
                      EnvoyButton(
                        S().component_save.toUpperCase(),
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
          child: Text(S().component_delete.toUpperCase(),
              style: TextStyle(color: EnvoyColors.lightCopper)),
          onTap: () {
            ref.read(homePageOptionsVisibilityProvider.notifier).state = false;
            if (!widget.account.wallet.hot) {
              showEnvoyDialog(
                  context: context,
                  dialog: EnvoyDialog(
                    title: S().envoy_account_delete_are_you_sure,
                    content: Text(S().envoy_account_delete_explainer),
                    actions: [
                      EnvoyButton(
                        S().component_delete.toUpperCase(),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        onTap: () {
                          AccountManager().deleteAccount(widget.account);
                          widget.navigator!.pop();
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ));
            } else {
              widget.navigator!.pop();
              ref.read(homePageBackgroundProvider.notifier).state =
                  HomePageBackgroundState.backups;
            }
          },
        ),
      ],
    );
  }
}
