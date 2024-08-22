// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:animations/animations.dart';
import 'package:envoy/business/account.dart';
import 'package:envoy/business/account_manager.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/amount_widget.dart';
import 'package:envoy/ui/components/pop_up.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/envoy_dialog.dart';
import 'package:envoy/ui/envoy_icons.dart' as old_icons;
import 'package:envoy/ui/fading_edge_scroll_view.dart';
import 'package:envoy/ui/home/cards/accounts/account_list_tile.dart';
import 'package:envoy/ui/home/cards/accounts/accounts_state.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coin_tag_list_screen.dart';
import 'package:envoy/ui/home/cards/accounts/detail/filter_options.dart';
import 'package:envoy/ui/home/cards/accounts/detail/filter_state.dart';
import 'package:envoy/ui/home/cards/accounts/detail/transaction/cancel_transaction.dart';
import 'package:envoy/ui/home/cards/accounts/detail/transaction/transactions_details.dart';
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
import 'package:envoy/ui/state/accounts_state.dart';
import 'package:envoy/ui/state/hide_balance_state.dart';
import 'package:envoy/ui/state/home_page_state.dart';
import 'package:envoy/ui/state/transactions_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/ui/widgets/envoy_amount_widget.dart';
import 'package:envoy/util/blur_container_transform.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:envoy/util/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:wallet/wallet.dart';
import 'package:envoy/business/exchange_rate.dart';

//ignore: must_be_immutable
class AccountCard extends ConsumerStatefulWidget {
  final bool showUtxoPage;

  AccountCard({this.showUtxoPage = false}) : super(key: UniqueKey());

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

  _redraw() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    // Redraw when we fetch exchange rate
    ExchangeRate().addListener(_redraw);
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    animation =
        Tween(begin: const Alignment(0.0, 1.0), end: const Alignment(0.0, 0.65))
            .animate(CurvedAnimation(
                parent: animationController, curve: Curves.easeInOut));

    Future.delayed(const Duration()).then((value) {
      account =
          ref.read(selectedAccountProvider) ?? AccountManager().accounts[0];
      ref.read(homePageTitleProvider.notifier).state = "";

      ref.read(homeShellOptionsProvider.notifier).state = HomeShellOptions(
          optionsWidget: AccountOptions(account),
          rightAction: Consumer(
            builder: (context, ref, child) {
              bool menuVisible = ref.watch(homePageOptionsVisibilityProvider);
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HomePageState.of(context)?.toggleOptions();
                },
                child: Container(
                  height: 55,
                  width: 55,
                  color: Colors.transparent,
                  child: Icon(
                    menuVisible ? Icons.close : Icons.more_horiz_outlined,
                  ),
                ),
              );
            },
          ));

      bool showOverlay = ref.read(showSpendRequirementOverlayProvider);
      bool isInEditMode =
          ref.read(spendEditModeProvider) != SpendOverlayContext.hidden;
      String path = ref.read(routePathProvider);
      if ((showOverlay || isInEditMode) && path == ROUTE_ACCOUNT_DETAIL) {
        ref.read(hideBottomNavProvider.notifier).state = true;
      }
    });
  }

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    super.dispose();
    ExchangeRate().removeListener(_redraw);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(settingsProvider);
    account = ref.read(selectedAccountProvider) ?? AccountManager().accounts[0];

    List<Transaction> transactions =
        ref.watch(filteredTransactionsProvider(account.id));

    bool txFiltersEnabled = ref.watch(isTransactionFiltersEnabled);
    bool isMenuOpen = ref.watch(homePageOptionsVisibilityProvider);

    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      removeBottom: true,
      removeLeft: true,
      removeRight: true,
      child: Scaffold(
        body: PopScope(
          canPop: !isMenuOpen,
          onPopInvoked: (bool didPop) async {
            if (!didPop) {
              HomePageState.of(context)?.toggleOptions();
            }
          },
          child: Column(
            children: [
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
                      HomePageAccountsState(
                          HomePageAccountsNavigationState.list);
                }),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: (transactions.isNotEmpty || txFiltersEnabled)
                    ? Container(
                        padding: const EdgeInsets.only(
                            top: EnvoySpacing.medium2,
                            bottom: EnvoySpacing.small),
                        child: const FilterOptions(),
                      )
                    : const SizedBox.shrink(),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(

                      ///proper padding to align with top sections, based on UI design
                      left: 20,
                      right: 20,
                      top: EnvoySpacing.small),
                  child: account.dateSynced == null
                      ? ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: 4,
                          itemBuilder: (BuildContext context, int index) {
                            return const GhostListTile();
                          },
                        )
                      : _getMainWidget(context, transactions, txFiltersEnabled),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Consumer(
          builder: (context, ref, child) {
            bool hide = ref.watch(showSpendRequirementOverlayProvider);
            bool isInEditMode =
                ref.watch(spendEditModeProvider) != SpendOverlayContext.hidden;
            return IgnorePointer(
              ignoring: (hide || isInEditMode),
              child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: (hide || isInEditMode) ? 0 : 1,
                  child: child),
            );
          },
          child: Container(
            height: 100,
            decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: EnvoyColors.textPrimaryInverse,
                  spreadRadius: 0,
                  blurRadius: 24,
                  offset: Offset(0, -8), // changes position of shadow
                ),
                BoxShadow(
                  color: EnvoyColors.textPrimaryInverse,
                  spreadRadius: 12,
                  blurRadius: 24,
                ),
              ],
            ),
            padding: const EdgeInsets.only(
                left: EnvoySpacing.large1,
                right: EnvoySpacing.large1,
                bottom: EnvoySpacing.medium3),
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
                      icon: const Icon(
                        old_icons.EnvoyIcons.qrScan,
                        size: 30,
                        color: EnvoyColors.accentPrimary,
                      ),
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute(builder: (context) {
                            return MediaQuery.removePadding(
                              context: context,
                              child: ScannerPage(
                                const [
                                  ScannerType.address,
                                  ScannerType.azteco,
                                  ScannerType.btcPay
                                ],
                                account: account,
                                onAddressValidated: (address, amount, message) {
                                  // Navigator.pop(context);
                                  ref
                                      .read(spendAddressProvider.notifier)
                                      .state = address;
                                  ref.read(spendAmountProvider.notifier).state =
                                      amount;
                                  ref
                                      .read(stagingTxNoteProvider.notifier)
                                      .state = message;
                                  context.go(ROUTE_ACCOUNT_SEND, extra: {
                                    "account": account,
                                    "address": address,
                                    "amount": amount
                                  });
                                },
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  ),
                ),
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
        ),
      ),
    );
  }

  Widget _getMainWidget(BuildContext context, List<Transaction> transactions,
      bool txFiltersEnabled) {
    AccountToggleState accountToggleState =
        ref.watch(accountToggleStateProvider);
    return PageTransitionSwitcher(
      reverse: accountToggleState == AccountToggleState.tx,
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
      child: accountToggleState == AccountToggleState.tx
          ? _buildTransactionListWidget(transactions, txFiltersEnabled)
          : CoinsList(account: account),
    );
  }

  Widget _buildTransactionListWidget(
      List<Transaction> transactions, bool txFiltersEnabled) {
    if (transactions.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const GhostListTile(animate: false),
          Expanded(
            child: Center(
              child: Text(
                txFiltersEnabled
                    ? S().account_emptyTxHistoryTextExplainer_FilteredView
                    : S().account_empty_tx_history_text_explainer,
                style: EnvoyTypography.body
                    .copyWith(color: EnvoyColors.textTertiary),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      );
    } else {
      return FadingEdgeScrollView.fromScrollView(
          gradientFractionOnEnd: 0.1,
          gradientFractionOnStart: 0.1,
          scrollController: _scrollController,
          child: StatefulBuilder(builder: (c, s) {
            return ListView.builder(
              //Space for the white gradient shadow at the bottom
              padding: const EdgeInsets.only(bottom: EnvoySpacing.medium3),
              physics: const BouncingScrollPhysics(),
              controller: _scrollController,
              itemCount: transactions.length,
              itemBuilder: (BuildContext context, int index) {
                return TransactionListTile(
                    transaction: transactions[index], account: account);
              },
            );
          }));
    }
  }
}

class GhostListTile extends StatelessWidget {
  final bool animate;

  const GhostListTile({
    this.animate = true,
    super.key,
  });

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
  TransactionListTile({
    super.key,
    required this.transaction,
    required this.account,
  });

  final Transaction transaction;
  final Account account;

  final TextStyle _transactionTextStyleInfo = EnvoyTypography.body.copyWith(
    fontWeight: FontWeight.w400,
    color: EnvoyColors.txInfo,
  );

  final Color _detailsColor = EnvoyColors.textPrimaryInverse;

  final TextStyle _detailsHeadingStyle = EnvoyTypography.subheading
      .copyWith(color: EnvoyColors.textPrimaryInverse);

  @override
  Widget build(BuildContext context) {
    final Locale activeLocale = Localizations.localeOf(context);

    return BlurContainerTransform(
      useRootNavigator: true,
      closedBuilder: (context, action) {
        return GestureDetector(
          onTap: () {
            action();
          },
          onLongPress: () async {
            await copyTxId(context, transaction.txId, transaction.type);
          },
          onDoubleTap: () {},
          // Avoids unintended behavior, prevents list item disappearance
          child: Row(
            children: [
              transactionIcon(context),
              Expanded(
                child: ListTile(
                  minLeadingWidth: 0,
                  horizontalTitleGap: EnvoySpacing.small,
                  title: transactionTitle(context),
                  subtitle: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: txSubtitle(activeLocale),
                  ),
                  contentPadding: const EdgeInsets.all(0),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: Settings().selectedFiat == null
                        ? CrossAxisAlignment.center
                        : CrossAxisAlignment.end,
                    children: [
                      // Styled as ListTile.title and ListTile.subtitle respectively
                      Consumer(
                        builder: (context, ref, child) {
                          bool hide = ref.watch(
                              balanceHideStateStatusProvider(account.id));
                          if (hide) {
                            return const LoaderGhost(
                              width: 100,
                              height: 15,
                              animate: false,
                            );
                          } else {
                            return child ?? Container();
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            (transaction.amount == 0 &&
                                    transaction.currency != null &&
                                    transaction.currencyAmount != null)
                                ? Text(
                                    "${transaction.currencyAmount!} ${transaction.currency!}",
                                    style: EnvoyTypography.body.copyWith(
                                      color: EnvoyColors.textPrimary,
                                    ),
                                  )
                                : EnvoyAmount(
                                    account: account,
                                    amountSats: transaction.amount,
                                    amountWidgetStyle:
                                        AmountWidgetStyle.normal),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      openBuilder: (context, action) {
        return TransactionsDetailsWidget(
            account: account,
            tx: transaction,
            iconTitleWidget: transactionIcon(context, iconColor: _detailsColor),
            titleWidget: transactionTitle(
              context,
              txTitleStyle: _detailsHeadingStyle,
            ));
      },
    );
  }

  Widget txSubtitle(Locale activeLocale) {
    if (transaction.type == TransactionType.azteco) {
      return Text(
        S().azteco_account_tx_history_pending_voucher,
        style: _transactionTextStyleInfo,
      );
    }

    if (transaction.type == TransactionType.btcPay) {
      return Text(
        S().btcpay_pendingVoucher,
        style: _transactionTextStyleInfo,
      );
    }
    if (transaction.type == TransactionType.ramp) {
      return Text(
        S().activity_pending,
        style: _transactionTextStyleInfo,
      );
    }

    if (transaction.type == TransactionType.normal && transaction.isConfirmed) {
      return Builder(builder: (context) {
        String time = timeago
            .format(transaction.date, locale: activeLocale.languageCode)
            .capitalize();
        return Text(
          time,
          style: _transactionTextStyleInfo,
        );
      });
    } else {
      return Text(
        S().receive_tx_list_awaitingConfirmation,
        style: _transactionTextStyleInfo,
      );
    }
  }

  Widget transactionIcon(
    BuildContext context, {
    Color iconColor = EnvoyColors.textTertiary,
  }) {
    return FittedBox(
      alignment: Alignment.centerLeft,
      fit: BoxFit.scaleDown,
      child: Consumer(
        builder: (context, ref, child) {
          bool? isBoosted = ref.watch(isTxBoostedProvider(transaction.txId));
          final cancelState =
              ref.watch(cancelTxStateProvider(transaction.txId));
          EnvoyIcons txIcon =
              transaction.amount < 0 ? EnvoyIcons.spend : EnvoyIcons.receive;
          if (cancelState != null) {
            if (!transaction.isConfirmed) {
              txIcon = EnvoyIcons.alert;
            } else if (cancelState.newTxId == transaction.txId) {
              txIcon = EnvoyIcons.close;
            } else {
              txIcon = transaction.amount < 0
                  ? EnvoyIcons.spend
                  : EnvoyIcons.receive;
            }
          } else if (isBoosted == true) {
            txIcon = EnvoyIcons.rbf_boost;
          }
          return Container(
            padding: const EdgeInsets.only(
              top: EnvoySpacing.small,
              bottom: EnvoySpacing.small,
              right: EnvoySpacing.xs,
              left: EnvoySpacing.xs,
            ),
            child: Transform.scale(
              scale: 1.1,
              child: EnvoyIcon(
                txIcon,
                color: iconColor,
                size: EnvoyIconSize.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget transactionTitle(BuildContext context, {TextStyle? txTitleStyle}) {
    final TextStyle? defaultStyle = Theme.of(context)
        .textTheme
        .bodyLarge
        ?.copyWith(fontWeight: FontWeight.w500, fontSize: 14);

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Consumer(
        builder: (context, ref, child) {
          bool? isBoosted = ref.watch(isTxBoostedProvider(transaction.txId));
          String txTitle = transaction.type == TransactionType.ramp
              ? S().activity_incomingPurchase
              : (transaction.amount < 0
                  ? S().activity_sent
                  : S().activity_received);
          RBFState? cancelState =
              ref.watch(cancelTxStateProvider(transaction.txId));
          if (cancelState != null) {
            if (cancelState.originalTxId == transaction.txId) {
              if (!transaction.isConfirmed) {
                txTitle = S().activity_canceling;
              }
            }
            if (cancelState.newTxId == transaction.txId) {
              if (transaction.isConfirmed) {
                txTitle = S().activity_sent_canceled;
              } else {
                txTitle = S().activity_canceling;
              }
            }
          } else {
            if (isBoosted == true) {
              if (transaction.isConfirmed) {
                txTitle = S().activity_sent_boosted;
              }
              txTitle = S().activity_boosted;
            }
          }
          return Text(
            txTitle,
            style: txTitleStyle ?? defaultStyle,
          );
        },
      ),
    );
  }
}

Future<void> copyTxId(
    BuildContext context, String txId, TransactionType txType) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  bool dismissed =
      await EnvoyStorage().checkPromptDismissed(DismissiblePrompt.copyTxId);
  if (!dismissed && context.mounted) {
    showWarningOnTxIdCopy(context, txId);
  } else {
    Clipboard.setData(ClipboardData(text: txId));
    String message;
    switch (txType) {
      case TransactionType.ramp:
        message = "Ramp ID copied to clipboard!";
        break;
      case TransactionType.btcPay:
        message = "Payment ID copied to clipboard!";
        break;
      default:
        message = "Transaction ID copied to clipboard!"; //TODO: FIGMA
    }
    scaffoldMessenger.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }
}

void showWarningOnTxIdCopy(BuildContext context, String txId) {
  showEnvoyPopUp(
      context,
      S().coincontrol_coin_change_spendable_tate_modal_subheading,
      S().component_continue,
      (BuildContext context) {
        Clipboard.setData(ClipboardData(text: txId)); // here
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Transaction ID copied to clipboard!"), //TODO: FIGMA
        ));
        Navigator.pop(context);
      },
      icon: EnvoyIcons.info,
      secondaryButtonLabel: S().component_cancel,
      onSecondaryButtonTap: (BuildContext context) {
        Navigator.pop(context);
      },
      checkBoxText: S().component_dontShowAgain,
      checkedValue: false,
      onCheckBoxChanged: (checkedValue) {
        if (!checkedValue) {
          EnvoyStorage().addPromptState(DismissiblePrompt.copyTxId);
        } else if (checkedValue) {
          EnvoyStorage().removePromptState(DismissiblePrompt.copyTxId);
        }
      });
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
    final account = ref.watch(accountStateProvider(widget.account.id!));
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(
          height: 10,
        ),
        GestureDetector(
          child: Text(
            S().manage_account_menu_showDescriptor.toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
          onTap: () {
            HomePageState.of(context)?.toggleOptions();
            context.go(ROUTE_ACCOUNT_DESCRIPTOR, extra: widget.account);
          },
        ),
        const SizedBox(
          height: 10,
        ),
        GestureDetector(
          child: Text(
            S().manage_account_menu_editAccountName.toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
          onTap: () {
            ref.read(homePageOptionsVisibilityProvider.notifier).state = false;
            bool isKeyboardShown = false;
            textEntry = TextEntry(
              focusNode: focusNode,
              maxLength: 20,
              placeholder: account?.name ?? "",
            );
            showEnvoyDialog(
              context: context,
              dialog: Builder(
                builder: (context) {
                  if (!isKeyboardShown) {
                    Future.delayed(const Duration(milliseconds: 200))
                        .then((value) {
                      FocusScope.of(context).requestFocus(focusNode);
                    });
                    isKeyboardShown = true;
                  }
                  return EnvoyDialog(
                    title: S().manage_account_rename_heading,
                    content: textEntry,
                    actions: [
                      EnvoyButton(
                        S().component_save,
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
        const SizedBox(
          height: 10,
        ),
        GestureDetector(
          child: Text(S().component_delete.toUpperCase(),
              style: const TextStyle(color: EnvoyColors.accentSecondary)),
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
                        S().component_delete,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                        onTap: () async {
                          Navigator.pop(context);
                          GoRouter.of(context).pop();
                          await Future.delayed(
                              const Duration(milliseconds: 50));
                          AccountManager().deleteAccount(widget.account);
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
