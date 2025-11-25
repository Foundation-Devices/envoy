// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:animations/animations.dart';
import 'package:envoy/account/accounts_manager.dart';
import 'package:envoy/account/envoy_transaction.dart';
import 'package:envoy/ble/bluetooth_manager.dart';
import 'package:envoy/business/devices.dart';
import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/amount_widget.dart';
import 'package:envoy/ui/components/envoy_bar.dart';
import 'package:envoy/ui/components/pop_up.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/envoy_dialog.dart';
import 'package:envoy/ui/fading_edge_scroll_view.dart';
import 'package:envoy/ui/home/cards/accounts/account_list_tile.dart';
import 'package:envoy/ui/home/cards/accounts/accounts_state.dart';
import 'package:envoy/ui/home/cards/accounts/azteco/azteco_dialog.dart';
import 'package:envoy/ui/home/cards/accounts/btcPay/btcpay_dialog.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coin_tag_list_screen.dart';
import 'package:envoy/ui/home/cards/accounts/detail/filter_options.dart';
import 'package:envoy/ui/home/cards/accounts/detail/filter_state.dart';
import 'package:envoy/ui/home/cards/accounts/detail/transaction/cancel_transaction.dart';
import 'package:envoy/ui/home/cards/accounts/detail/transaction/transactions_details.dart';
import 'package:envoy/ui/home/cards/accounts/spend/state/spend_state.dart';
import 'package:envoy/ui/home/cards/text_entry.dart';
import 'package:envoy/ui/home/home_page.dart';
import 'package:envoy/ui/home/home_state.dart';
import 'package:envoy/ui/home/setup_overlay.dart';
import 'package:envoy/ui/loader_ghost.dart';
import 'package:envoy/ui/routes/accounts_router.dart';
import 'package:envoy/ui/routes/route_state.dart';
import 'package:envoy/ui/state/accounts_state.dart';
import 'package:envoy/ui/state/hide_balance_state.dart';
import 'package:envoy/ui/state/home_page_state.dart';
import 'package:envoy/ui/state/transactions_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/tx_utils.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/ui/widgets/color_util.dart';
import 'package:envoy/ui/widgets/envoy_amount_widget.dart';
import 'package:envoy/ui/widgets/scanner/decoders/payment_qr_decoder.dart';
import 'package:envoy/ui/widgets/scanner/qr_scanner.dart';
import 'package:envoy/util/blur_container_transform.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_api/foundation_api.dart' as api;
import 'package:go_router/go_router.dart';
import 'package:ngwallet/ngwallet.dart' as ngwallet;
import 'package:ngwallet/ngwallet.dart';
import 'package:flutter/cupertino.dart';

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
  late EnvoyAccount account;
  late Animation<Alignment> animation;

  void _redraw() {
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
      if (!ref.context.mounted) {
        return;
      }
      account =
          ref.read(selectedAccountProvider) ?? NgAccountManager().accounts[0];
      ref.read(homePageTitleProvider.notifier).state = "";

      ref.read(homeShellOptionsProvider.notifier).state = HomeShellOptions(
          optionsWidget: Container(),
          rightAction: Consumer(
            builder: (context, ref, child) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      opaque: false,
                      pageBuilder: (_, __, ___) => AccountOptions(account),
                    ),
                  );
                },
                child: Container(
                  height: 55,
                  width: 55,
                  color: Colors.transparent,
                  child: Icon(
                    Icons.more_horiz_outlined,
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
    account =
        ref.read(selectedAccountProvider) ?? NgAccountManager().accounts[0];

    List<EnvoyTransaction> transactions =
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
            onPopInvokedWithResult: (bool didPop, _) async {
              if (!didPop) {
                HomePageState.of(context)?.toggleOptions();
              }
            },
            child: EnvoyPullToRefresh(
              onRefresh: () async {
                // TODO: implement refresh here, ref's and so on!!!
                await Future.delayed(const Duration(seconds: 2));
              },
              pullIndicator: (progress) {
                return Column(
                  key: ValueKey("pull"),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    EnvoyIcon(
                      EnvoyIcons.refresh,
                      color: EnvoyColors.textTertiary,
                    ),
                    const SizedBox(height: EnvoySpacing.small),
                    Opacity(
                      opacity: progress,
                      child: Text(
                        S().rescanAccount_pullToSync_pullToSync,
                        style: TextStyle(color: EnvoyColors.textTertiary),
                      ),
                    ),
                  ],
                );
              },
              refreshIndicator: const CupertinoActivityIndicator(
                key: ValueKey("refresh"),
                color: Colors.black,
                radius: 12,
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                width: double.infinity,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 20,
                        bottom: 0,
                        left: 20,
                        right: 20,
                      ),
                      child: AccountListTile(
                        account,
                        onTap: () {
                          Navigator.pop(context);
                          ref.read(homePageAccountsProvider.notifier).state =
                              HomePageAccountsState(
                                  HomePageAccountsNavigationState.list);
                        },
                      ),
                    ),

                    // TODO: add "show" logic here
                    RescanningIndicator(),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: (transactions.isNotEmpty || txFiltersEnabled)
                          ? Container(
                              padding: const EdgeInsets.only(
                                top: EnvoySpacing.medium2,
                                bottom: EnvoySpacing.small,
                              ),
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
                          top: EnvoySpacing.small,
                        ),
                        child: account.dateSynced == null
                            ? ListView.builder(
                                padding: EdgeInsets.zero,
                                itemCount: 4,
                                itemBuilder: (_, __) => const GhostListTile(),
                              )
                            : _getMainWidget(
                                context,
                                // TODO: fix transactions can be seen under EnvoyBar while scrolling
                                transactions,
                                txFiltersEnabled,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            )),
        bottomNavigationBar: Consumer(
            builder: (context, ref, child) {
              bool hide = ref.watch(showSpendRequirementOverlayProvider);
              bool isInEditMode = ref.watch(spendEditModeProvider) !=
                  SpendOverlayContext.hidden;
              return IgnorePointer(
                ignoring: (hide || isInEditMode),
                child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: (hide || isInEditMode) ? 0 : 1,
                    child: child),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(top: EnvoySpacing.xs),
              child: EnvoyBar(
                showDividers: true,
                // enabled: , TODO: disable if rescanning !!!!
                bottomPadding: EnvoySpacing.large1,
                items: [
                  EnvoyBarItem(
                    icon: EnvoyIcons.transfer,
                    text: S().receive_tx_list_transfer,
                    onTap: () {
                      // TODO: add "Transfer" code
                    },
                  ),
                  EnvoyBarItem(
                    icon: EnvoyIcons.receive,
                    text: S().receive_tx_list_receive,
                    onTap: () {
                      if (accountHasNoTaprootXpub(account) &&
                          Settings().taprootEnabled()) {
                        showEnvoyPopUp(
                          context,
                          icon: EnvoyIcons.info,
                          showCloseButton: true,
                          title: S().taproot_passport_dialog_heading,
                          S().taproot_passport_dialog_subheading,
                          S().taproot_passport_dialog_reconnect,
                          (BuildContext modalContext) {
                            Navigator.pop(modalContext);
                            scanForDevice(context);
                          },
                          secondaryButtonLabel:
                              S().taproot_passport_dialog_later,
                          onSecondaryButtonTap: (BuildContext context) {
                            Navigator.pop(context);
                            context.go(ROUTE_ACCOUNT_RECEIVE,
                                extra: account.id);
                          },
                        );
                      } else {
                        context.go(ROUTE_ACCOUNT_RECEIVE, extra: account.id);
                      }
                    },
                  ),
                  EnvoyBarItem(
                    icon: EnvoyIcons.send,
                    text: S().receive_tx_list_send,
                    onTap: () async {
                      clearSpendState(ProviderScope.containerOf(context));
                      await Future.delayed(const Duration(milliseconds: 50));
                      if (context.mounted) {
                        context.go(ROUTE_ACCOUNT_SEND);
                      }
                      return;
                      // widget.navigator!.push(
                      //     SendCard(widget.account, navigator: widget.navigator));
                    },
                  ),
                  EnvoyBarItem(
                    icon: EnvoyIcons.externalLink,
                    text: S().receive_tx_list_scan,
                    onTap: () {
                      final navigator =
                          Navigator.of(context, rootNavigator: true);
                      final goRouter = GoRouter.of(context);
                      showScannerDialog(
                          context: context,
                          onBackPressed: (context) {
                            Navigator.of(context).pop();
                          },
                          decoder: PaymentQrDecoder(
                              account: account,
                              onAztecoScan: (aztecoVoucher) {
                                navigator.pop();
                                showEnvoyDialog(
                                    context: context,
                                    useRootNavigator: true,
                                    dialog:
                                        AztecoDialog(aztecoVoucher, account));
                              },
                              btcPayVoucherScan: (voucher) {
                                navigator.pop();
                                showEnvoyDialog(
                                    context: context,
                                    useRootNavigator: true,
                                    dialog: BtcPayDialog(voucher, account));
                              },
                              onAddressValidated:
                                  (address, amount, message) async {
                                if (navigator.canPop()) {
                                  navigator.pop();
                                }
                                //wait for the dialog to close,200ms based on material bottom_sheet.dart
                                await Future.delayed(
                                    const Duration(milliseconds: 200));
                                if (!ref.context.mounted) {
                                  return;
                                }
                                ref.read(spendAddressProvider.notifier).state =
                                    address;
                                ref.read(spendAmountProvider.notifier).state =
                                    amount;
                                ref.read(stagingTxNoteProvider.notifier).state =
                                    message;
                                goRouter.go(ROUTE_ACCOUNT_SEND, extra: {
                                  "address": address,
                                  "amount": amount
                                });
                              }));
                    },
                  ),
                ],
              ),
            )),
      ),
    );
  }

  Widget _getMainWidget(BuildContext context,
      List<EnvoyTransaction> transactions, bool txFiltersEnabled) {
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
      List<EnvoyTransaction> transactions, bool txFiltersEnabled) {
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
  final bool diagonal;
  final double leadingHeight;
  final double minLeadingWidth;
  final double titleRightPadding;
  final double subtitleRightPadding;

  const GhostListTile({
    this.animate = true,
    this.diagonal = true,
    this.leadingHeight = 50.0,
    this.minLeadingWidth = 40.0,
    this.titleRightPadding = 50.0,
    this.subtitleRightPadding = 80.0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      titleAlignment: ListTileTitleAlignment.center,
      minLeadingWidth: minLeadingWidth,
      title: Padding(
        padding: EdgeInsets.only(top: 2, right: titleRightPadding),
        child: LoaderGhost(
          width: 10,
          height: 15,
          animate: animate,
        ),
      ),
      subtitle: Padding(
        padding: EdgeInsets.only(top: 3.0, right: subtitleRightPadding),
        child: LoaderGhost(
          width: 30,
          height: 15,
          animate: animate,
        ),
      ),
      leading: LoaderGhost(
        width: leadingHeight,
        height: leadingHeight,
        diagonal: diagonal,
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

class TransactionListTile extends ConsumerWidget {
  TransactionListTile({
    super.key,
    required this.transaction,
    required this.account,
  });

  final EnvoyTransaction transaction;
  final EnvoyAccount account;

  final TextStyle _transactionTextStyleInfo = EnvoyTypography.body.copyWith(
    fontWeight: FontWeight.w400,
    color: EnvoyColors.txInfo,
  );

  final Color _detailsColor = EnvoyColors.textPrimaryInverse;

  final TextStyle _detailsHeadingStyle = EnvoyTypography.subheading
      .copyWith(color: EnvoyColors.textPrimaryInverse);

  final Settings s = Settings();

  @override
  Widget build(BuildContext context, ref) {
    final Locale activeLocale = Localizations.localeOf(context);

    ref.watch(isTxBoostedProvider(transaction.txId));

    String? currencyAmount;
    String? currency;
    if (transaction is BtcPayTransaction) {
      currencyAmount = (transaction as BtcPayTransaction).currencyAmount;
      currency = (transaction as BtcPayTransaction).currency;
    }
    return BlurContainerTransform(
      // TODO: fix blur moving while refresh
      useRootNavigator: true,
      closedBuilder: (context, action) {
        return GestureDetector(
          onTap: () {
            if (!ref.read(transactionDetailsOpen.notifier).state) {
              ref.read(transactionDetailsOpen.notifier).state = true;
              action();
            }
          },
          onLongPress: () async {
            await copyTxId(context, transaction.txId, transaction);
          },
          onDoubleTap: () {},
          // Avoids unintended behavior, prevents list item disappearance
          child: Row(
            children: [
              transactionIcon(context, transaction),
              Expanded(
                child: ListTile(
                  minLeadingWidth: 0,
                  horizontalTitleGap: EnvoySpacing.small,
                  title: transactionTitle(context, transaction),
                  subtitle: txSubtitle(activeLocale),
                  contentPadding: const EdgeInsets.all(0),
                  trailing: Column(
                    mainAxisAlignment: s.displayFiat() == null ||
                            (kDebugMode &&
                                account.network != ngwallet.Network.bitcoin)
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.center,
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
                            ((!transaction.isOnChain()) &&
                                    currency != null &&
                                    currencyAmount != null)
                                ? Text(
                                    "$currencyAmount $currency",
                                    style: EnvoyTypography.body.copyWith(
                                      color: EnvoyColors.textPrimary,
                                    ),
                                  )
                                : Padding(
                                    padding: EdgeInsets.only(
                                        top: s.displayFiat() == null ||
                                                (kDebugMode &&
                                                    account.network !=
                                                        ngwallet
                                                            .Network.bitcoin)
                                            ? EnvoySpacing.small
                                            : 0),
                                    child: EnvoyAmount(
                                        account: account,
                                        amountSats: transaction.amount,
                                        amountWidgetStyle:
                                            AmountWidgetStyle.normal),
                                  ),
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
            iconTitleWidget:
                transactionIcon(context, transaction, iconColor: _detailsColor),
            titleWidget: transactionTitle(
              context,
              transaction,
              txTitleStyle: _detailsHeadingStyle,
            ));
      },
    );
  }

  Widget txSubtitle(Locale activeLocale) {
    return Text(
      getTransactionSubtitleText(transaction, activeLocale),
      style: _transactionTextStyleInfo,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}

Widget transactionTitle(BuildContext context, EnvoyTransaction transaction,
    {TextStyle? txTitleStyle}) {
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
        RBFState? cancelState =
            ref.watch(cancelTxStateProvider(transaction.txId));
        return Text(
          getTransactionTitleText(transaction, cancelState, isBoosted),
          style: txTitleStyle ?? defaultStyle,
        );
      },
    ),
  );
}

Widget transactionIcon(
  BuildContext context,
  EnvoyTransaction transaction, {
  Color iconColor = EnvoyColors.textTertiary,
}) {
  return FittedBox(
    alignment: Alignment.centerLeft,
    fit: BoxFit.scaleDown,
    child: Consumer(
      builder: (context, ref, child) {
        bool? isBoosted = ref.watch(isTxBoostedProvider(transaction.txId));
        final cancelState = ref.watch(cancelTxStateProvider(transaction.txId));
        return Container(
          padding: const EdgeInsets.only(
            top: EnvoySpacing.small,
            bottom: EnvoySpacing.small,
            right: EnvoySpacing.xs,
            left: EnvoySpacing.xs,
          ),
          child: Transform.scale(
            scale: cancelState?.newTxId == transaction.txId ? 0.95 : 1.1,
            child: EnvoyIcon(
              getTransactionIcon(transaction, cancelState, isBoosted)!,
              color: iconColor,
              size: EnvoyIconSize.normal,
            ),
          ),
        );
      },
    ),
  );
}

Future<void> copyTxId(
    BuildContext context, String txId, EnvoyTransaction? tx) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  bool dismissed =
      await EnvoyStorage().checkPromptDismissed(DismissiblePrompt.copyTxId);
  if (!dismissed && context.mounted) {
    showWarningOnTxIdCopy(context, txId);
  } else {
    Clipboard.setData(ClipboardData(text: txId));
    String message;
    if (tx is RampTransaction) {
      message = "Ramp ID copied to clipboard!";
    } else if (tx is BtcPayTransaction) {
      message = "Payment ID copied to clipboard!";
    } else {
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
  final EnvoyAccount account;

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
    final account = ref.watch(accountStateProvider(widget.account.id));
    final navigator = Navigator.of(context);

    return Stack(children: [
      GestureDetector(
        onTap: () => navigator.pop(),
        // close when tapping outside
        child: Container(
          color: Colors.black.applyOpacity(0.4),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 80, right: EnvoySpacing.xs),
        child: Align(
          alignment: Alignment.topRight,
          child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(EnvoySpacing.medium1),
              ),
              width: 250,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: EnvoySpacing.xs),
                  _MenuItem(
                    label: S().exploreAdresses_activityOptions_showDescriptor,
                    icon: EnvoyIcons.info,
                    onTap: () {
                      navigator.pop();
                      if (accountHasNoTaprootXpub(widget.account) &&
                          Settings().taprootEnabled()) {
                        showEnvoyPopUp(
                          context,
                          icon: EnvoyIcons.info,
                          showCloseButton: true,
                          title: S().taproot_passport_dialog_heading,
                          S().taproot_passport_dialog_subheading,
                          S().taproot_passport_dialog_reconnect,
                          (modalContext) {
                            Navigator.pop(modalContext);
                            HomePageState.of(context)?.toggleOptions();
                            scanForDevice(context);
                          },
                          secondaryButtonLabel:
                              S().taproot_passport_dialog_later,
                          onSecondaryButtonTap: (modalContext) {
                            Navigator.pop(modalContext);
                            HomePageState.of(context)?.toggleOptions();
                            context.go(ROUTE_ACCOUNT_DESCRIPTOR,
                                extra: widget.account.id);
                          },
                        );
                      } else {
                        HomePageState.of(context)?.toggleOptions();
                        context.go(ROUTE_ACCOUNT_DESCRIPTOR,
                            extra: widget.account.id);
                      }
                    },
                  ),
                  _MenuItem(
                    label: S().exploreAdresses_activityOptions_editAccountName,
                    icon: EnvoyIcons.edit,
                    onTap: () {
                      navigator.pop();
                      ref
                          .read(homePageOptionsVisibilityProvider.notifier)
                          .state = false;

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
                                  .then((_) {
                                if (context.mounted) {
                                  FocusScope.of(context)
                                      .requestFocus(focusNode);
                                }
                              });
                              isKeyboardShown = true;
                            }
                            return EnvoyDialog(
                              title: S().manage_account_rename_heading,
                              content: textEntry,
                              actions: [
                                EnvoyButton(
                                  S().component_save,
                                  onTap: () async {
                                    navigator.pop();
                                    Device? device = Devices()
                                        .getDeviceBySerial(
                                            widget.account.deviceSerial ?? "");
                                    final handler = account?.handler;
                                    if (handler == null) return;

                                    await handler.renameAccount(
                                        name: textEntry.enteredText);

                                    if (device != null &&
                                        device.type ==
                                            DeviceType.passportPrime &&
                                        account?.id != null) {
                                      BluetoothManager().sendAccountUpdate(
                                        api.AccountUpdate(
                                          accountId: account!.id,
                                          update:
                                              await handler.toRemoteUpdate(),
                                        ),
                                      );
                                    }
                                    navigator.pop();
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      );
                    },
                  ),
                  _MenuItem(
                    label: S().exploreAdresses_activityOptions_exploreAddresses,
                    icon: EnvoyIcons.list,
                    onTap: () {
                      navigator.pop();
                      // TODO
                    },
                  ),
                  _MenuItem(
                    label: S().receive_qr_signMessage,
                    icon: EnvoyIcons.envelope,
                    onTap: () {
                      navigator.pop();
                      // TODO
                    },
                  ),
                  _MenuItem(
                    label: S().receive_qr_rescanAccount,
                    icon: EnvoyIcons.refresh,
                    onTap: () {
                      navigator.pop();
                      showEnvoyDialog(
                          context: context,
                          dialog: const RescanAccountDialog());
                    },
                  ),
                  _MenuItem(
                    label: S().exploreAdresses_activityOptions_deleteAccount,
                    icon: EnvoyIcons.close,
                    color: EnvoyColors.accentSecondary,
                    useDivider: false,
                    onTap: () {
                      navigator.pop();
                      ref
                          .read(homePageOptionsVisibilityProvider.notifier)
                          .state = false;

                      if (!widget.account.isHot) {
                        showEnvoyDialog(
                          context: context,
                          dialog: EnvoyPopUp(
                            icon: EnvoyIcons.alert,
                            typeOfMessage: PopUpState.warning,
                            showCloseButton: true,
                            customWidget: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  S().manage_account_remove_heading,
                                  style: EnvoyTypography.info,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: EnvoySpacing.medium1),
                                Text(
                                  S().manage_account_remove_subheading,
                                  style: EnvoyTypography.info,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: EnvoySpacing.medium1),
                              ],
                            ),
                            primaryButtonLabel: S().component_delete,
                            onPrimaryButtonTap: (context) async {
                              Navigator.pop(context);
                              GoRouter.of(context).pop();
                              await Future.delayed(
                                  const Duration(milliseconds: 50));
                              await NgAccountManager()
                                  .deleteAccount(widget.account);
                            },
                          ),
                        );
                      } else {
                        ref.read(homePageBackgroundProvider.notifier).state =
                            HomePageBackgroundState.backups;
                        navigator.pop();
                      }
                    },
                  ),
                  const SizedBox(height: EnvoySpacing.xs),
                ],
              )),
        ),
      ),
    ]);
  }
}

class _MenuItem extends StatelessWidget {
  final String label;
  final EnvoyIcons icon;
  final Color color;
  final VoidCallback onTap;
  final bool useDivider;

  const _MenuItem(
      {required this.label,
      required this.icon,
      required this.onTap,
      this.color = EnvoyColors.textPrimary,
      this.useDivider = true});

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: EnvoySpacing.medium1,
                vertical: 12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: EnvoyTypography.body.copyWith(color: color),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(width: EnvoySpacing.xs),
                  EnvoyIcon(icon, color: color),
                ],
              ),
            ),
          ),
          useDivider ? const Divider(height: 0) : const SizedBox()
        ],
      ),
    );
  }
}

class RescanAccountDialog extends ConsumerStatefulWidget {
  const RescanAccountDialog({super.key});

  @override
  ConsumerState<RescanAccountDialog> createState() =>
      _RescanAccountDialogState();
}

class _RescanAccountDialogState extends ConsumerState<RescanAccountDialog> {
  @override
  Widget build(BuildContext context) {
    return EnvoyPopUp(
      icon: EnvoyIcons.info,
      typeOfMessage: PopUpState.deafult,
      showCloseButton: false,
      customWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            S().rescanAccount_sizeModal_header,
            style: EnvoyTypography.heading,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: EnvoySpacing.medium1),
          Text(
            S().rescanAccount_sizeModal_content,
            style: EnvoyTypography.info,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: EnvoySpacing.medium1),

          // TODO: learn more link/button
          // onLearnMore: () {
          //   launchUrl(Uri.parse(
          //       "https://docs.foundation.xyz/troubleshooting/envoy/#boosting-or-canceling-transactions"));
          // },

          EnvoyButton(
            S().rescanAccount_sizeModal_1000Addresses,
            type: EnvoyButtonTypes.secondary,
            onTap: () {
              Navigator.pop(context);
              // TODO: 1000
            },
          ),
        ],
      ),
      secondaryButtonLabel: S().rescanAccount_sizeModal_500Addresses,
      onSecondaryButtonTap: (context) async {
        Navigator.pop(context);
        // TODO: 500
      },
      primaryButtonLabel: S().rescanAccount_sizeModal_300Addresses,
      onPrimaryButtonTap: (context) async {
        Navigator.pop(context);
        // TODO: 300
      },
    );
  }
}

class RescanningIndicator extends StatelessWidget {
  const RescanningIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: EnvoySpacing.medium1),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: EnvoySpacing.medium1),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.40),
                  blurRadius: 8,
                  offset: Offset(0, 0),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: const SizedBox(
                height: 3,
                child: LinearProgressIndicator(
                  backgroundColor: EnvoyColors.textPrimaryInverse,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    EnvoyColors.textTertiary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: EnvoySpacing.small),
          Text(
            S().rescanAccount_rescanning_rescanningAccount,
            textAlign: TextAlign.center,
            style: EnvoyTypography.info.copyWith(
              color: EnvoyColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class EnvoyPullToRefresh extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  /// shown during pull (receives progress 0-1)
  final Widget Function(double progress) pullIndicator;

  /// shown when refreshing begins
  final Widget refreshIndicator;

  const EnvoyPullToRefresh({
    super.key,
    required this.child,
    required this.onRefresh,
    required this.pullIndicator,
    required this.refreshIndicator,
  });

  @override
  State<EnvoyPullToRefresh> createState() => _EnvoyPullToRefreshState();
}

class _EnvoyPullToRefreshState extends State<EnvoyPullToRefresh>
    with TickerProviderStateMixin {
  double _dragOffset = 0;
  bool _refreshing = false;

  static const double triggerDistance = 100;
  static const double maxIndicatorPull = 80;

  late AnimationController _springController;
  late Animation<double> _springAnimation;

  @override
  void initState() {
    super.initState();
    _springController = AnimationController(vsync: this);
    _springController.addListener(() {
      setState(() {
        _dragOffset = _springAnimation.value;
      });
    });
  }

  @override
  void dispose() {
    _springController.dispose();
    super.dispose();
  }

  double get _progress => (_dragOffset / triggerDistance).clamp(0, 1);

  void _animateBack({double to = 0}) {
    _springAnimation = Tween<double>(
      begin: _dragOffset,
      end: to,
    ).animate(
      CurvedAnimation(
        parent: _springController,
        curve: Curves.easeOutBack,
      ),
    );

    _springController.duration = const Duration(milliseconds: 350);
    _springController.forward(from: 0);
  }

  Future<void> _triggerRefresh() async {
    setState(() => _refreshing = true);

    _animateBack(to: maxIndicatorPull);

    await widget.onRefresh();

    setState(() => _refreshing = false);
    _animateBack(to: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // INDICATOR
        Positioned(
          top: -maxIndicatorPull + _dragOffset.clamp(0, maxIndicatorPull),
          left: 0,
          right: 0,
          height: 95,
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: _refreshing
                  ? widget.refreshIndicator
                  : widget.pullIndicator(_progress),
            ),
          ),
        ),

        // CONTENT
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragStart: (_) {
            if (_refreshing) return;
            _springController.stop();
          },
          onVerticalDragUpdate: (details) {
            if (_refreshing) return;
            if (details.delta.dy < 0) return; // only downward pull

            setState(() {
              _dragOffset += details.delta.dy / 2;
              if (_dragOffset > triggerDistance) {
                _dragOffset = triggerDistance;
              }
            });
          },
          onVerticalDragEnd: (_) {
            if (_dragOffset >= triggerDistance && !_refreshing) {
              _triggerRefresh();
            } else {
              _animateBack(to: 0);
            }
          },
          child: Transform.translate(
            offset: Offset(0, _dragOffset),
            child: widget.child,
          ),
        ),
      ],
    );
  }
}

bool accountHasNoTaprootXpub(EnvoyAccount account) {
  final hasTaproot = account.externalPublicDescriptors.any(
    (pair) => pair.$1 == AddressType.p2Tr && pair.$2.isNotEmpty,
  );
  return !hasTaproot;
}
