// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:ui';

import 'package:envoy/account/accounts_manager.dart';
import 'package:envoy/account/envoy_transaction.dart';
import 'package:envoy/business/fees.dart';
import 'package:envoy/business/locale.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/address_widget.dart';
import 'package:envoy/ui/components/amount_widget.dart';
import 'package:envoy/ui/components/button.dart';
import 'package:envoy/ui/components/envoy_info_card.dart';
import 'package:envoy/ui/components/envoy_tag_list_item.dart';
import 'package:envoy/ui/components/pop_up.dart';
import 'package:envoy/ui/home/cards/accounts/accounts_state.dart';
import 'package:envoy/ui/home/cards/accounts/detail/account_card.dart';
import 'package:envoy/ui/home/cards/accounts/detail/transaction/cancel_transaction.dart';
import 'package:envoy/ui/home/cards/accounts/detail/transaction/tx_note_dialog_widget.dart';
import 'package:envoy/ui/home/cards/accounts/spend/rbf/rbf_button.dart';
import 'package:envoy/ui/home/cards/accounts/spend/rbf/rbf_spend_screen.dart';
import 'package:envoy/ui/home/cards/accounts/spend/spend_fee_state.dart';
import 'package:envoy/ui/indicator_shield.dart';
import 'package:envoy/ui/loader_ghost.dart';
import 'package:envoy/ui/state/hide_balance_state.dart';
import 'package:envoy/ui/state/home_page_state.dart';
import 'package:envoy/ui/state/transactions_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/ui/widgets/color_util.dart';
import 'package:envoy/ui/widgets/envoy_amount_widget.dart';
import 'package:envoy/util/amount.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/easing.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:envoy/util/tuple.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:ngwallet/ngwallet.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

final transactionDetailsOpen = StateProvider<bool>((ref) => false);

class TransactionsDetailsWidget extends ConsumerStatefulWidget {
  final EnvoyAccount account;
  final EnvoyTransaction tx;
  final Widget? iconTitleWidget;
  final Widget? titleWidget;

  const TransactionsDetailsWidget({
    super.key,
    required this.account,
    required this.tx,
    this.iconTitleWidget,
    this.titleWidget,
  });

  @override
  ConsumerState<TransactionsDetailsWidget> createState() =>
      _TransactionsDetailsWidgetState();
}

class _TransactionsDetailsWidgetState
    extends ConsumerState<TransactionsDetailsWidget> {
  bool showTxIdExpanded = false;
  bool showAddressExpanded = false;
  bool showPaymentId = false;
  bool _checkingBoost = true;
  bool _checkingCancel = true;
  DraftTransaction? _cancelTx;
  final GlobalKey _detailWidgetKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await Future.delayed(const Duration(milliseconds: 50));
      _fetchFee();
      _checkForRBF();
    });
  }

  Future<void> _fetchFee() async {
    if (widget.tx.fee.toInt() == FEE_UNKNOWN) {
      final server = Settings().electrumAddress(widget.account.network);
      int? port = Settings().getTorPort(widget.account.network, server);
      try {
        final fee = await EnvoyAccountHandler.fetchElectrumFee(
            txid: widget.tx.txId, electrumServer: server, torPort: port);
        if (fee != null) {
          await widget.account.handler
              ?.updateTxFee(transaction: widget.tx, fee: fee);
        }
      } catch (e) {
        EnvoyReport().log("FetchFee", "RBF check failed : $e");
      }
    }
  }

  Future _checkForRBF() async {
    // don't check boost/cancel on received tx's ˇˇˇˇˇ
    if (widget.tx.confirmations == 0 && !(widget.tx.amount > 0)) {
      try {
        await _checkBoost();
      } catch (e) {
        kPrint(e);
      }
      try {
        await _checkCancel();
      } catch (e) {
        kPrint(e);
      }
    }
  }

  Future<void> _checkBoost() async {
    try {
      ref.watch(rbfSpendStateProvider.notifier).state = null;
      final account = ref.read(selectedAccountProvider);
      final handler = account?.handler;
      if (account == null || handler == null) {
        return;
      }
      setState(() {
        _checkingBoost = true;
      });
      BitcoinTransaction originalTx = widget.tx;

      TransactionFeeResult result = await handler.getMaxBumpFeeRates(
          selectedOutputs: [], bitcoinTransaction: originalTx);

      setState(() {
        _checkingBoost = false;
      });
      int minRate = result.minFeeRate.toInt();
      int maxRate = result.maxFeeRate.toInt();
      int fasterFeeRate = minRate + 1;
      if (minRate == maxRate) {
        fasterFeeRate = maxRate;
      } else {
        if (minRate < maxRate) {
          fasterFeeRate = (minRate + 1).clamp(minRate, maxRate);
        }
      }
      ref.read(feeChooserStateProvider.notifier).state = FeeChooserState(
        standardFeeRate: minRate,
        fasterFeeRate: fasterFeeRate,
        minFeeRate: minRate,
        maxFeeRate: maxRate,
      );
      ref.read(rbfSpendStateProvider.notifier).state = RBFSpendState(
        receiveAddress: result.draftTransaction.transaction.address,
        receiveAmount: originalTx.amount,
        feeRate: minRate,
        originalTx: originalTx,
        originalAmount: originalTx.amount,
        draftTx: result.draftTransaction,
      );
    } catch (e) {
      EnvoyReport().log("RBF", "RBF check failed : $e");
    } finally {
      if (mounted) {
        setState(() {
          _checkingBoost = false;
        });
      }
    }
  }

  Future<void> _checkCancel() async {
    if (mounted) {
      setState(() {
        _cancelTx = null;
      });
    }

    final selectedAccount = ref.read(selectedAccountProvider);
    final handler = selectedAccount?.handler;
    if (handler == null) {
      if (mounted) {
        setState(() {
          _checkingCancel = false;
        });
      }
      return;
    }

    try {
      _cancelTx =
          await handler.composeCancellationTx(bitcoinTransaction: widget.tx);
    } catch (e, s) {
      EnvoyReport().log("RBF:cancel", e.toString(), stackTrace: s);
      if (e is RBFBumpFeeError) {
        if (e is InsufficientFunds) {
          if (mounted) {
            setState(() {
              _cancelTx = null;
            });
          }
          return;
        }
      }
      debugPrintStack(stackTrace: s);
      kPrint(e);
      if (mounted) {
        setState(() {
          _cancelTx = null;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _checkingCancel = false;
        });
      }
    }
  }

  String _getConfirmationTimeString(int minutes) {
    String confirmationTime = "";

    if (minutes < 60) {
      confirmationTime = "${minutes}m";
    } else if (minutes >= 60 && minutes < 120) {
      confirmationTime = "1h";
    } else {
      confirmationTime = "1 ${S().coindetails_overlay_confirmationIn_day}";
    }

    return "${S().coindetails_overlay_confirmationIn} ~$confirmationTime";
  }

  @override
  Widget build(BuildContext context) {
    ///watch transaction changes to get real time updates
    final tx = ref.watch(getTransactionProvider(widget.tx.txId)) ?? widget.tx;

    String note = ref.watch(getTransactionProvider(tx.txId).select(
      (value) => value?.note ?? tx.note ?? "",
    ));

    if (!tx.isConfirmed && (tx is RampTransaction)) {
      final noteFromStorage = ref.watch(txNoteFromStorageProvider(tx.txId));

      note = noteFromStorage.maybeWhen(
        data: (value) => value,
        orElse: () => note,
      );
    }

    final onRampSessionInfo =
        ref.watch(onrampSessionStreamProvider(tx.txId)).value;

    final hideBalance =
        ref.watch(balanceHideStateStatusProvider(widget.account.id));
    final accountAccentColor = fromHex(widget.account.color);
    final trailingTextStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: EnvoyColors.textPrimary,
          fontWeight: FontWeight.w600,
        );

    final idTextStyle =
        EnvoyTypography.body.copyWith(color: EnvoyColors.textSecondary);

    bool addressNotAvailable = tx.address.isEmpty;
    final address = tx.address;

    bool rbfPossible =
        (tx.confirmations == 0 && tx.isOnChain() && tx.amount < 0);

    final cancelState = ref.watch(cancelTxStateProvider(tx.txId));

    if (cancelState?.newTxId == tx.txId) {
      rbfPossible = false;
    }

    bool showTxInfo = tx.isOnChain();

    return PopScope(
      onPopInvokedWithResult: (_, __) {
        ref.read(transactionDetailsOpen.notifier).state = false;
      },
      child: GestureDetector(
        onTapUp: (details) {
          final RenderBox box =
              _detailWidgetKey.currentContext?.findRenderObject() as RenderBox;
          final Offset localOffset = box.globalToLocal(details.globalPosition);

          if (!box.paintBounds.contains(localOffset)) {
            Navigator.of(context).pop();
          }
        },
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: CupertinoNavigationBarBackButton(
              color: Colors.white,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            flexibleSpace: SafeArea(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const SizedBox(
                    height: 100,
                    child: IndicatorShield(),
                  ),
                  Text(
                    S().coincontrol_tx_detail_expand_heading.toUpperCase(),
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ),
          body: Column(
            children: [
              EnvoyInfoCard(
                key: _detailWidgetKey,
                backgroundColor: accountAccentColor,
                titleWidget: widget.titleWidget,
                iconTitleWidget: widget.iconTitleWidget,
                topWidget: hideBalance
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // hide placeholder for btc
                          LoaderGhost(
                            width: 110,
                            height: 20,
                            animate: false,
                          ),
                          // hide placeholder for fiat
                          LoaderGhost(
                            width: 80,
                            height: 20,
                            animate: false,
                          ),
                        ],
                      )
                    : (tx is BtcPayTransaction &&
                            tx.currency != null &&
                            tx.currencyAmount != null)
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const LoaderGhost(
                                width: 110,
                                height: 20,
                                animate: false,
                              ),
                              // hide placeholder for fiat
                              Text(
                                "${tx.currencyAmount!} ${tx.currency!}",
                                style: EnvoyTypography.body.copyWith(
                                  color: EnvoyColors.textPrimary,
                                ),
                              ),
                            ],
                          )
                        : EnvoyAmount(
                            account: widget.account,
                            amountSats: tx.amount,
                            amountWidgetStyle: AmountWidgetStyle.singleLine),
                bottomWidgets: [
                  EnvoyInfoCardListItem(
                    title: S().coindetails_overlay_address,
                    icon: const EnvoyIcon(EnvoyIcons.send,
                        color: EnvoyColors.textPrimary,
                        size: EnvoyIconSize.extraSmall),
                    trailing: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        setState(() {
                          showAddressExpanded = !showAddressExpanded;
                          showTxIdExpanded = false;
                          showPaymentId = false;
                        });
                      },
                      child: TweenAnimationBuilder(
                          curve: EnvoyEasing.easeInOut,
                          tween: Tween<double>(
                              begin: 0, end: showAddressExpanded ? 1 : 0),
                          duration: const Duration(milliseconds: 200),
                          builder: (context, value, child) {
                            return addressNotAvailable
                                ? Text("Address not available ",
                                    // TODO: Figma
                                    style: trailingTextStyle)
                                : AddressWidget(
                                    widgetKey:
                                        ValueKey<bool>(showAddressExpanded),
                                    address: address,
                                    short: true,
                                    sideChunks: 2 +
                                        (value * (address.length / 4)).round(),
                                  );
                          }),
                    ),
                  ),
                  EnvoyInfoCardListItem(
                    title: S().coindetails_overlay_transactionID,
                    icon: const EnvoyIcon(EnvoyIcons.compass,
                        color: EnvoyColors.textPrimary,
                        size: EnvoyIconSize.small),
                    trailing: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onLongPress: () {
                        if (showTxInfo) {
                          copyTxId(context, tx.txId, tx);
                        }
                      },
                      onTap: () {
                        if (showTxInfo) {
                          setState(() {
                            showTxIdExpanded = !showTxIdExpanded;
                            showAddressExpanded = false;
                            showPaymentId = false;
                          });
                        }
                      },
                      child: TweenAnimationBuilder(
                        curve: EnvoyEasing.easeInOut,
                        tween: Tween<double>(
                            begin: 0, end: showTxIdExpanded ? 1 : 0),
                        duration: const Duration(milliseconds: 200),
                        builder: (context, value, child) {
                          String txId =
                              showTxInfo ? tx.txId : S().activity_pending;
                          return Container(
                            constraints: const BoxConstraints(
                              maxHeight: 80,
                            ),
                            child: SingleChildScrollView(
                              child: Text(
                                truncateWithEllipsisInCenter(
                                  txId,
                                  lerpDouble(16, txId.length, value)!.toInt(),
                                ),
                                style: showTxInfo
                                    ? idTextStyle
                                    : trailingTextStyle,
                                textAlign: TextAlign.end,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    button: (showTxIdExpanded)
                        ? EnvoyButton(
                            height: EnvoySpacing.medium3,
                            icon: EnvoyIcons.externalLink,
                            label: S().coindetails_overlay_explorer,
                            type: ButtonType.primary,
                            state: ButtonState.defaultState,
                            onTap: () {
                              openTxDetailsInExplorer(
                                  context, tx.txId, widget.account.network);
                            },
                            edgeInsets: const EdgeInsets.symmetric(
                                horizontal: EnvoySpacing.medium1),
                          )
                        : null,
                  ),
                  EnvoyInfoCardListItem(
                    title: S().coindetails_overlay_date,
                    icon: const EnvoyIcon(EnvoyIcons.calendar,
                        color: EnvoyColors.textPrimary,
                        size: EnvoyIconSize.small),
                    trailing: Text(
                        getTransactionDateAndTimeString(
                            tx.date?.toInt(), tx.isConfirmed),
                        textAlign: TextAlign.end,
                        style: trailingTextStyle),
                  ),
                  EnvoyInfoCardListItem(
                    title: S().coindetails_overlay_status,
                    icon: const EnvoyIcon(EnvoyIcons.activity,
                        color: EnvoyColors.textPrimary,
                        size: EnvoyIconSize.small),
                    trailing: Text(getTransactionStatusString(tx),
                        style: trailingTextStyle),
                  ),
                  if (tx is BtcPayTransaction && tx.pullPaymentId != null)
                    EnvoyInfoCardListItem(
                        title: S().coindetails_overlay_paymentID,
                        icon: const EnvoyIcon(EnvoyIcons.btcPay,
                            color: EnvoyColors.textPrimary,
                            size: EnvoyIconSize.small),
                        trailing: GestureDetector(
                          onLongPress: () {
                            Clipboard.setData(
                                ClipboardData(text: tx.pullPaymentId!));
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Payment ID copied to clipboard!'))); //TODO: FIGMA
                          },
                          onTap: () {
                            setState(() {
                              showPaymentId = !showPaymentId;
                              showTxIdExpanded = false;
                              showAddressExpanded = false;
                            });
                          },
                          child: TweenAnimationBuilder(
                            curve: EnvoyEasing.easeInOut,
                            tween: Tween<double>(
                                begin: 0, end: showPaymentId ? 1 : 0),
                            duration: const Duration(milliseconds: 200),
                            builder: (context, value, child) {
                              return Text(
                                  truncateWithEllipsisInCenter(
                                      tx.pullPaymentId!,
                                      lerpDouble(16, tx.pullPaymentId!.length,
                                              value)!
                                          .toInt()),
                                  style: idTextStyle,
                                  textAlign: TextAlign.end,
                                  maxLines: 4);
                            },
                          ),
                        )),
                  if (tx is RampTransaction && tx.rampId != null)
                    EnvoyInfoCardListItem(
                      title: S().coindetails_overlay_rampID,
                      centerSingleLineTitle: true,
                      icon: const EnvoyIcon(
                        EnvoyIcons.ramp_without_name,
                        size: EnvoyIconSize.small,
                        color: EnvoyColors.textPrimary,
                      ),
                      trailing: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onLongPress: () {
                          copyTxId(context, tx.rampId!, tx);
                        },
                        child: Text(
                          tx.rampId!,
                          style: idTextStyle,
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  if (tx is RampTransaction && tx.rampFee != null)
                    EnvoyInfoCardListItem(
                      title: S().coindetails_overlay_rampFee,
                      centerSingleLineTitle: true,
                      icon: const EnvoyIcon(
                        EnvoyIcons.ramp_without_name,
                        size: EnvoyIconSize.small,
                        color: EnvoyColors.textPrimary,
                      ),
                      trailing: hideBalance
                          ? const LoaderGhost(
                              width: 74, animate: false, height: 16)
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                EnvoyAmount(
                                    account: widget.account,
                                    amountSats: tx.rampFee!,
                                    amountWidgetStyle:
                                        AmountWidgetStyle.normal),
                              ],
                            ),
                    ),
                  if (tx is StripeTransaction && tx.stripeId != null)
                    EnvoyInfoCardListItem(
                      title: S().coindetails_overlay_stripeID,
                      centerSingleLineTitle: true,
                      icon: const EnvoyIcon(
                        EnvoyIcons.stripe,
                        size: EnvoyIconSize.small,
                        color: EnvoyColors.textPrimary,
                      ),
                      trailing: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onLongPress: () {
                          copyTxId(context, tx.stripeId!, tx);
                        },
                        child: Text(
                          tx.stripeId!,
                          style: idTextStyle,
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  if (tx is StripeTransaction)
                    EnvoyInfoCardListItem(
                      title: S().coindetails_overlay_stripeFee,
                      centerSingleLineTitle: true,
                      icon: const EnvoyIcon(
                        EnvoyIcons.stripe,
                        size: EnvoyIconSize.small,
                        color: EnvoyColors.textPrimary,
                      ),
                      trailing: hideBalance
                          ? const LoaderGhost(
                              width: 74, animate: false, height: 16)
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (tx.stripeFee != null)
                                  EnvoyAmount(
                                      account: widget.account,
                                      amountSats: tx.stripeFee!,
                                      amountWidgetStyle:
                                          AmountWidgetStyle.normal),
                                if (tx.stripeFee == null)
                                  Text(
                                    "${((onRampSessionInfo?.networkFee ?? 0.0) + (onRampSessionInfo?.transactionFee ?? 0)).toStringAsFixed(2)} ${onRampSessionInfo?.sourceCurrency}",
                                    style: EnvoyTypography.body.copyWith(
                                      color: EnvoyColors.textPrimary,
                                    ),
                                  )
                              ],
                            ),
                    ),
                  rbfPossible && tx.vsize != BigInt.zero
                      ? EnvoyInfoCardListItem(
                          centerSingleLineTitle: true,
                          spacingPriority: FlexPriority.trailing,
                          title: _getConfirmationTimeString(ref.watch(
                              txEstimatedConfirmationTimeProvider(
                                  Tuple(tx, widget.account.network)))),
                          icon: const EnvoyIcon(
                            EnvoyIcons.clock,
                            size: EnvoyIconSize.extraSmall,
                            color: EnvoyColors.textPrimary,
                          ),
                          trailing: rbfPossible
                              ? TxRBFButton(
                                  tx: tx,
                                  loading: _checkingBoost,
                                )
                              : SizedBox.shrink(),
                        )
                      : Container(),
                  if (tx is! RampTransaction && tx is! StripeTransaction)
                    _renderFeeWidget(context, tx),
                  GestureDetector(
                    onTap: () {
                      showEnvoyDialog(
                          context: context,
                          dialog: TxNoteDialog(
                            txId: tx.txId,
                            value: note,
                            noteTitle: S().add_note_modal_heading,
                            noteHintText: S().add_note_modal_ie_text_field,
                            noteSubTitle: S().add_note_modal_subheading,
                            onAdd: (note) async {
                              if (!tx.isConfirmed &&
                                  (tx is RampTransaction ||
                                      tx is BtcPayTransaction ||
                                      tx is AztecoTransaction ||
                                      tx is StripeTransaction)) {
                                EnvoyStorage()
                                    .updatePendingTx(tx.txId, note: note);
                              } else {
                                widget.account.handler?.setNote(
                                  note: note,
                                  txId: tx.txId,
                                );
                              }
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            },
                          ),
                          alignment: const Alignment(0.0, -0.8));
                    },
                    child: EnvoyInfoCardListItem(
                      title: S().coincontrol_tx_history_tx_detail_note,
                      icon: const EnvoyIcon(
                        EnvoyIcons.note,
                        size: EnvoyIconSize.small,
                        color: EnvoyColors.textPrimary,
                      ),
                      trailing: NoteDisplay(
                        note: note,
                      ),
                    ),
                  ),
                  rbfPossible && tx.vsize != BigInt.zero
                      ? CancelTxButton(
                          transaction: tx,
                          draftTransaction: _cancelTx,
                          loading: _checkingCancel,
                        )
                      : const SizedBox.shrink(),
                ],
              ),
              if (tx is RampTransaction) ...[
                const EnvoyIcon(
                  EnvoyIcons.info,
                  color: EnvoyColors.textPrimaryInverse,
                  size: EnvoyIconSize.medium,
                ),
                const SizedBox(height: EnvoySpacing.xs),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: EnvoySpacing.large1),
                  child: Text(
                    S().replaceByFee_ramp_incompleteTransactionAutodeleteWarning,
                    style: EnvoyTypography.info
                        .copyWith(color: EnvoyColors.textPrimaryInverse),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              if (rbfPossible == true && tx.vsize == BigInt.zero) ...[
                const EnvoyIcon(
                  EnvoyIcons.info,
                  color: EnvoyColors.textPrimaryInverse,
                  size: EnvoyIconSize.medium,
                ),
                const SizedBox(height: EnvoySpacing.xs),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: EnvoySpacing.large1),
                  child: Text(
                    S().replaceByFee_coindetails_overlayNotice,
                    style: EnvoyTypography.info
                        .copyWith(color: EnvoyColors.textPrimaryInverse),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _renderFeeWidget(BuildContext context, EnvoyTransaction tx) {
    final isBoosted =
        (ref.watch(isTxBoostedProvider(tx.txId)) ?? false) && tx.amount < 0;
    final cancelState = ref.watch(cancelTxStateProvider(tx.txId));
    final hideBalance =
        ref.watch(balanceHideStateStatusProvider(widget.account.id));

    String feeTitle = isBoosted
        ? S().coindetails_overlay_boostedFees
        : S().coincontrol_tx_detail_fee;

    Widget icon = isBoosted
        ? const EnvoyIcon(
            EnvoyIcons.rbf_boost,
            size: EnvoyIconSize.extraSmall,
          )
        : SvgPicture.asset(
            "assets/icons/ic_bitcoin_straight_circle.svg",
            colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
            height: 18,
          );

    if (cancelState?.newTxId == tx.txId) {
      icon = const Icon(
        Icons.close,
        size: 16,
      );
      feeTitle = S().replaceByFee_cancel_overlay_modal_cancelationFees;
    }
    return EnvoyInfoCardListItem(
      title: feeTitle,
      icon: icon,
      trailing: hideBalance || tx.fee.toInt() == FEE_UNKNOWN
          ? Padding(
              padding: const EdgeInsets.only(top: 6),
              child: const LoaderGhost(width: 74, animate: false, height: 16),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                EnvoyAmount(
                    account: widget.account,
                    amountSats: tx.fee.toInt(),
                    amountWidgetStyle: AmountWidgetStyle.normal),
              ],
            ),
    );
  }
}

String getTransactionDateAndTimeString(int? date, bool isConfirmed) {
  if (date == null) {
    return S().activity_pending;
  } else {
    if (!isConfirmed) {
      return S().receive_tx_list_awaitingConfirmation;
    }
    final timeStamp = date.toInt() * 1000;
    final dateTimeUtc =
        DateTime.fromMillisecondsSinceEpoch(timeStamp, isUtc: true);
    final dateTimeLocal = dateTimeUtc.toLocal();

    final String transactionDateInfo =
        "${DateFormat.yMd().format(dateTimeLocal)} ${S().coindetails_overlay_at} ${DateFormat.Hm(currentLocale).format(dateTimeLocal)}";
    return transactionDateInfo;
  }
}

String getTransactionStatusString(EnvoyTransaction tx) {
  return tx.isOnChain() && tx.isConfirmed
      ? S().coindetails_overlay_status_confirmed
      : S().activity_pending;
}

Future<void> openTxDetailsInExplorer(
    BuildContext context, String txId, Network network) async {
  bool isDismissed = await EnvoyStorage()
      .checkPromptDismissed(DismissiblePrompt.openTxDetailsInExplorer);
  if (!isDismissed && context.mounted) {
    showEnvoyPopUp(
        context,
        S().coindetails_overlay_modal_explorer_subheading,
        S().component_continue,
        (context) {
          Navigator.pop(context);
          openTxDetailPage(network, txId);
        },
        title: S().coindetails_overlay_modal_explorer_heading,
        onLearnMore: () {
          launchUrl(
              Uri.parse("https://docs.foundation.xyz/faq/home/#envoy-privacy"));
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
            EnvoyStorage()
                .addPromptState(DismissiblePrompt.openTxDetailsInExplorer);
          } else if (checkedValue) {
            EnvoyStorage()
                .removePromptState(DismissiblePrompt.openTxDetailsInExplorer);
          }
        });
  } else {
    openTxDetailPage(network, txId);
  }
}

void openTxDetailPage(Network network, String txId) {
  final baseUrl = getBaseUrlForNetwork(network);
  if (baseUrl != null) {
    launchUrlString("$baseUrl/tx/$txId");
  } else {
    kPrint("Regtest not implemented");
  }
}

String? getBaseUrlForNetwork(Network network) {
  switch (network) {
    case Network.bitcoin:
      return Fees.mempoolFoundationInstance;
    case Network.signet:
      return Fees.signetMempoolFoundationInstance;
    case Network.testnet4:
      return Fees.testnet4MempoolFoundationInstance;
    case Network.testnet:
      return Fees.testnet4MempoolFoundationInstance;
    case Network.regtest:
      return null;
  }
}

class NoteDisplay extends StatelessWidget {
  final String note;

  const NoteDisplay({
    super.key,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.end,
      text: TextSpan(
        style: EnvoyTypography.body.copyWith(
          color: EnvoyColors.textPrimary,
        ),
        children: [
          TextSpan(text: note.trim()),
          if (note.trim().isNotEmpty)
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.only(left: EnvoySpacing.xs),
                child: SvgPicture.asset(
                  "assets/icons/ic_edit_note.svg",
                  colorFilter: ColorFilter.mode(
                      Theme.of(context).primaryColor, BlendMode.srcIn),
                  height: 14,
                ),
              ),
            )
          else
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.only(left: EnvoySpacing.xs),
                child: Icon(
                  Icons.add_circle_rounded,
                  color: EnvoyColors.accentPrimary,
                  size: 24,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
