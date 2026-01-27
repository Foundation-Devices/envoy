// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/amount_entry.dart';
import 'package:envoy/ui/components/amount_widget.dart';
import 'package:envoy/ui/components/draggable_overlay.dart';
import 'package:envoy/ui/components/envoy_tag_list_item.dart';
import 'package:envoy/ui/home/cards/accounts/accounts_state.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coins_state.dart';
import 'package:envoy/ui/home/cards/accounts/detail/filter_state.dart';
import 'package:envoy/ui/home/cards/accounts/detail/transaction/transactions_details.dart';
import 'package:envoy/ui/home/cards/accounts/detail/transaction/tx_note_dialog_widget.dart';
import 'package:envoy/ui/home/cards/accounts/spend/staging_tx_tagging.dart';
import 'package:envoy/ui/home/cards/accounts/spend/state/spend_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/tx_review.dart';
import 'package:envoy/ui/state/send_unit_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/ui/widgets/color_util.dart';
import 'package:envoy/ui/widgets/envoy_amount_widget.dart';
import 'package:envoy/util/list_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ngwallet/ngwallet.dart';
import 'package:envoy/ui/components/address_widget.dart';
import 'package:envoy/ui/home/cards/accounts/spend/choose_coins_widget.dart';

class StagingTxDetails extends ConsumerStatefulWidget {
  final bool isRBFSpend;
  final DraftTransaction draftTransaction;
  final Function? onTagUpdate;
  final Function? onTxNoteUpdated;
  final bool canEdit;

  ///for rbf staging transaction details
  final BitcoinTransaction? previousTransaction;

  const StagingTxDetails(
      {super.key,
      required this.draftTransaction,
      this.previousTransaction,
      this.onTagUpdate,
      this.onTxNoteUpdated,
      this.isRBFSpend = false,
      this.canEdit = true});

  @override
  ConsumerState createState() => _SpendTxDetailsState();
}

class _SpendTxDetailsState extends ConsumerState<StagingTxDetails>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  Widget _divider() {
    return Container(
      height: 1,
      color: EnvoyColors.border2,
    );
  }

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    EnvoyAccount? account = ref.watch(selectedAccountProvider);
    if (account == null) {
      return Container();
    }

    DraftTransaction draftTransaction = widget.draftTransaction;
    final stagedTransaction = draftTransaction.transaction;

    String note = ref.watch(stagingTxNoteProvider) ?? "";
    String changeOutputTag = ref.watch(stagingTxChangeOutPutTagProvider) ?? "";

    final totalInputAmount = (stagedTransaction.inputs)
        .map((e) => e.amount.toInt())
        .fold(0, (int sum, element) => sum + element);

    final inputs = stagedTransaction.inputs.map((e) => "${e.txId}:${e.vout}");

    final inputTags = stagedTransaction.inputs.map((e) => e.tag);

    final changeOutput = stagedTransaction.outputs.firstWhereOrNull(
      (output) => output.keychain == KeyChain.internal,
    );

    final int totalChangeAmount = changeOutput?.amount.toInt() ?? 0;
    final String changeAddress = changeOutput?.address ?? "";

    double? displayFiatSendAmount = ref.watch(displayFiatSendAmountProvider);
    double? displayFiatTotalChangeAmount =
        ExchangeRate().convertSatsToFiat(totalChangeAmount);
    double? displayFiatTotalInputAmount =
        displayFiatSendAmount! + displayFiatTotalChangeAmount;

    final sendScreenUnit = ref.watch(sendUnitProvider);

    /// if user selected unit from the form screen then use that, otherwise use the default
    DisplayUnit unit = sendScreenUnit == AmountDisplayUnit.btc
        ? DisplayUnit.btc
        : DisplayUnit.sat;

    AmountDisplayUnit formatUnit =
        unit == DisplayUnit.btc ? AmountDisplayUnit.btc : AmountDisplayUnit.sat;

    if (sendScreenUnit == AmountDisplayUnit.fiat) {
      unit = Settings().displayUnit;
    }
    return DraggableOverlay(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        EnvoyInfoCardListItem(
          spacingPriority: FlexPriority.trailing,
          title:
              "${S().coincontrol_tx_detail_expand_spentFrom} ${inputs.toSet().length} ${inputs.toSet().length == 1 ? S().coincontrol_tx_detail_expand_coin : S().coincontrol_tx_detail_expand_coins}",
          icon: const EnvoyIcon(EnvoyIcons.utxo,
              color: EnvoyColors.textPrimary, size: EnvoyIconSize.small),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              EnvoyAmount(
                  unit: formatUnit,
                  account: account,
                  amountSats: totalInputAmount,
                  displayFiatAmount: displayFiatTotalInputAmount,
                  millionaireMode: false,
                  amountWidgetStyle: AmountWidgetStyle.normal),
              if (widget.canEdit)
                GestureDetector(
                    onTap: () async {
                      Navigator.of(context).pop();

                      editTransaction(context, ref);
                      Navigator.of(context, rootNavigator: true).push(
                          PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) {
                                return ChooseCoinsWidget();
                              },
                              transitionDuration:
                                  const Duration(milliseconds: 100),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                              opaque: false,
                              fullscreenDialog: true));
                    },
                    child: EnvoyIcon(
                      EnvoyIcons.chevron_right,
                      size: EnvoyIconSize.extraSmall,
                    )),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 12, top: EnvoySpacing.small),
          child: Align(
            alignment: Alignment.topLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const EnvoyIcon(EnvoyIcons.tag,
                    color: EnvoyColors.textPrimary,
                    size: EnvoyIconSize.extraSmall),
                const Padding(padding: EdgeInsets.only(left: EnvoySpacing.xs)),
                Wrap(
                  spacing: EnvoySpacing.xs,
                  runSpacing: EnvoySpacing.small,
                  children: inputTags
                      .map((e) => e ?? "")
                      .map((e) =>
                          (e.isEmpty) ? S().account_details_untagged_card : e)
                      .toSet()
                      .map((e) {
                    return coinTagPill(e);
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: EnvoySpacing.medium2,
          ),
          child: _divider(),
        ),
        EnvoyInfoCardListItem(
            spacingPriority: FlexPriority.trailing,
            title: S().send_editTxDetails_changeAmount,
            icon: const EnvoyIcon(EnvoyIcons.change,
                color: EnvoyColors.textPrimary, size: EnvoyIconSize.extraSmall),
            trailing: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                loading
                    ? const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: EnvoySpacing.xs),
                        child: SizedBox.square(
                          dimension: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 1,
                          ),
                        ),
                      )
                    : Container(
                        alignment: Alignment.centerRight,
                        child: totalChangeAmount == 0
                            ? Text(
                                S().coincontrol_tx_detail_no_change,
                                style: EnvoyTypography.body
                                    .copyWith(color: EnvoyColors.textTertiary),
                              )
                            : EnvoyAmount(
                                unit: formatUnit,
                                account: account,
                                amountSats: totalChangeAmount,
                                millionaireMode: false,
                                amountWidgetStyle: AmountWidgetStyle.normal),
                      ),
              ],
            )),
        if (totalChangeAmount != 0)
          EnvoyInfoCardListItem(
            spacingPriority: FlexPriority.trailing,
            title: S().send_editTxDetails_changeAddress,
            icon: const EnvoyIcon(EnvoyIcons.change,
                color: EnvoyColors.textPrimary, size: EnvoyIconSize.small),
            trailing: Flexible(
              child: AddressWidget(
                address: changeAddress,
                short: false,
                sideChunks: 2 + ((changeAddress.length / 4)).round(),
              ),
            ),
          ),
        if (totalChangeAmount != 0 && inputTags.length >= 2)
          Padding(
            padding: const EdgeInsets.only(top: EnvoySpacing.small),
            child: Container(
              height: 24,
              margin: const EdgeInsets.only(left: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const EnvoyIcon(EnvoyIcons.tag,
                          color: EnvoyColors.textPrimary,
                          size: EnvoyIconSize.extraSmall),
                      const Padding(
                          padding: EdgeInsets.only(left: EnvoySpacing.xs)),
                      if (totalChangeAmount != 0 && changeOutputTag.isNotEmpty)
                        coinTagPill(changeOutputTag),
                      if (changeOutputTag.isEmpty)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Padding(
                                padding:
                                    EdgeInsets.only(left: EnvoySpacing.xs)),
                            Text(S().send_editTxDetails_applyChangeTag,
                                style: EnvoyTypography.body
                                    .copyWith(color: EnvoyColors.textPrimary))
                          ],
                        )
                    ],
                  ),
                  if (widget.canEdit)
                    GestureDetector(
                      onTap: () {
                        showEnvoyDialog(
                            context: context,
                            builder: Builder(
                              builder: (_) => ChooseTagForStagingTx(
                                accountId: account.id,
                                onEditTransaction: () =>
                                    _onEditTransaction(context),
                                onTagUpdate: () {
                                  widget.onTagUpdate?.call();
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                            alignment: const Alignment(0.0, -.6));
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: EnvoySpacing.xs),
                        child: changeOutputTag.isNotEmpty
                            ? EnvoyIcon(
                                EnvoyIcons.edit,
                                color: EnvoyColors.accentPrimary,
                                size: EnvoyIconSize.small,
                              )
                            : Icon(
                                Icons.add_circle_rounded,
                                color: EnvoyColors.accentPrimary,
                                size: EnvoySpacing.medium2,
                              ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: EnvoySpacing.medium2,
          ),
          child: _divider(),
        ),
        EnvoyInfoCardListItem(
          title: S().coincontrol_tx_history_tx_detail_note,
          icon: const EnvoyIcon(EnvoyIcons.note,
              color: EnvoyColors.textPrimary, size: EnvoyIconSize.small),
          trailing: GestureDetector(
              child: NoteDisplay(note: note),
              onTap: () {
                showEnvoyDialog(
                  context: context,
                  dialog: TxNoteDialog(
                    onAdd: (noteText) {
                      ref.read(stagingTxNoteProvider.notifier).state = noteText;
                      widget.onTxNoteUpdated?.call();
                      Navigator.pop(context);
                    },
                    txId: "UpcomingTx",
                    noteHintText: S().send_editTxDetails_addNoteExample,
                    noteSubTitle: S().coincontrol_tx_add_note_subheading,
                    noteTitle: S().add_note_modal_heading,
                    value: note,
                  ),
                  alignment: const Alignment(0.0, -0.5),
                );
              }),
        ),
      ],
    ));
  }

  // @override
  // Widget build(BuildContext context) {
  //   EnvoyAccount? account = ref.watch(selectedAccountProvider);
  //   if (account == null) {
  //     return Container();
  //   }
  //   final accountAccentColor = fromHex(account.color);
  //   DraftTransaction draftTransaction = widget.draftTransaction;
  //   final stagedTransaction = draftTransaction.transaction;
  //
  //   String note = ref.watch(stagingTxNoteProvider) ?? "";
  //   String changeOutputTag = ref.watch(stagingTxChangeOutPutTagProvider) ?? "";
  //
  //   if (changeOutputTag.isEmpty) {
  //     changeOutputTag = S().account_details_untagged_card;
  //   }
  //
  //   final totalInputAmount = (stagedTransaction.inputs)
  //       .map((e) => e.amount.toInt())
  //       .fold(0, (int sum, element) => sum + element);
  //
  //   final totalReceiveAmount = (stagedTransaction.amount.toInt());
  //
  //   final inputs = stagedTransaction.inputs.map((e) => "${e.txId}:${e.vout}");
  //   final inputTags = stagedTransaction.inputs.map((e) => e.tag);
  //
  //   final totalChangeAmount = (stagedTransaction.outputs.firstWhereOrNull(
  //         (outPut) => outPut.keychain == KeyChain.internal,
  //       ))?.amount.toInt() ??
  //       0;
  //
  //   // final String? userChosenTag = ref.watch(stagingTxChangeOutPutTagProvider);
  //
  //   double? displayFiatSendAmount = ref.watch(displayFiatSendAmountProvider);
  //   double? displayFiatTotalChangeAmount =
  //       ExchangeRate().convertSatsToFiat(totalChangeAmount);
  //   double? displayFiatTotalInputAmount =
  //       displayFiatSendAmount! + displayFiatTotalChangeAmount;
  //
  //   final sendScreenUnit = ref.watch(sendUnitProvider);
  //   final uneconomicSpends = ref.watch(uneconomicSpendsProvider);
  //
  //   /// if user selected unit from the form screen then use that, otherwise use the default
  //   DisplayUnit unit = sendScreenUnit == AmountDisplayUnit.btc
  //       ? DisplayUnit.btc
  //       : DisplayUnit.sat;
  //
  //   AmountDisplayUnit formatUnit =
  //       unit == DisplayUnit.btc ? AmountDisplayUnit.btc : AmountDisplayUnit.sat;
  //
  //   if (sendScreenUnit == AmountDisplayUnit.fiat) {
  //     unit = Settings().displayUnit;
  //   }
  //
  //   return Stack(
  //     children: [
  //       BackdropFilter(
  //         filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
  //         child: Container(
  //           decoration: const BoxDecoration(
  //             gradient: LinearGradient(
  //                 begin: Alignment.topCenter,
  //                 end: Alignment.bottomCenter,
  //                 colors: [
  //                   Colors.black,
  //                   Colors.black,
  //                   Colors.transparent,
  //                 ]),
  //           ),
  //         ),
  //       ),
  //       Positioned.fill(
  //         child: GestureDetector(
  //           onTapDown: (details) {
  //             final height = MediaQuery.of(context).size.height;
  //
  //             /// if user taps on the bottom 60% of the screen, close the dialog
  //             if (details.localPosition.dy / height >= .5) {
  //               Navigator.pop(context);
  //             }
  //           },
  //           child: Scaffold(
  //             backgroundColor: Colors.transparent,
  //             appBar: AppBar(
  //               elevation: 0,
  //               backgroundColor: Colors.transparent,
  //               leading: const SizedBox.shrink(),
  //               actions: [
  //                 IconButton(
  //                   icon: const Icon(
  //                     Icons.close,
  //                     color: EnvoyColors.textPrimaryInverse,
  //                   ),
  //                   onPressed: () {
  //                     Navigator.of(context).pop();
  //                   },
  //                 )
  //               ],
  //               flexibleSpace: SafeArea(
  //                 child: Stack(
  //                   alignment: Alignment.center,
  //                   children: [
  //                     const SizedBox(
  //                       height: 100,
  //                       child: IndicatorShield(),
  //                     ),
  //                     Text(
  //                       S().coincontrol_tx_detail_expand_heading.toUpperCase(),
  //                       style:
  //                           Theme.of(context).textTheme.displayMedium?.copyWith(
  //                                 color: EnvoyColors.textPrimaryInverse,
  //                                 fontSize: 18,
  //                                 fontWeight: FontWeight.w600,
  //                               ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //             body: Column(
  //               key: _key,
  //               children: [
  //                 EnvoyInfoCard(
  //                     backgroundColor: accountAccentColor,
  //                     topWidget: EnvoyAmount(
  //                         unit: formatUnit,
  //                         account: account,
  //                         displayFiatAmount: displayFiatSendAmount,
  //                         amountSats: totalReceiveAmount.abs(),
  //                         millionaireMode: false,
  //                         amountWidgetStyle: AmountWidgetStyle.singleLine),
  //                     bottomWidgets: [
  //                       EnvoyInfoCardListItem(
  //                         spacingPriority: FlexPriority.trailing,
  //                         title:
  //                             "${S().coincontrol_tx_detail_expand_spentFrom} ${inputs.toSet().length} ${inputs.toSet().length == 1 ? S().coincontrol_tx_detail_expand_coin : S().coincontrol_tx_detail_expand_coins}",
  //                         icon: const EnvoyIcon(EnvoyIcons.utxo,
  //                             color: EnvoyColors.textPrimary,
  //                             size: EnvoyIconSize.small),
  //                         trailing: EnvoyAmount(
  //                             unit: formatUnit,
  //                             account: account,
  //                             amountSats: totalInputAmount,
  //                             displayFiatAmount: displayFiatTotalInputAmount,
  //                             millionaireMode: false,
  //                             amountWidgetStyle: AmountWidgetStyle.normal),
  //                       ),
  //                       Padding(
  //                         padding:
  //                             const EdgeInsets.only(left: EnvoySpacing.small),
  //                         child: Align(
  //                           alignment: Alignment.topLeft,
  //                           child: Padding(
  //                             padding: const EdgeInsets.symmetric(
  //                                 horizontal: EnvoySpacing.medium2),
  //                             child: Wrap(
  //                               spacing: EnvoySpacing.small,
  //                               runSpacing: EnvoySpacing.small,
  //                               children: inputTags
  //                                   .map((e) => e ?? "")
  //                                   .map((e) => (e.isEmpty)
  //                                       ? S().account_details_untagged_card
  //                                       : e)
  //                                   .toSet()
  //                                   .map((e) {
  //                                 return _coinTag(e);
  //                               }).toList(),
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                       const SizedBox(
  //                         height: EnvoySpacing.medium2,
  //                       ),
  //                       EnvoyInfoCardListItem(
  //                           spacingPriority: FlexPriority.trailing,
  //                           title:
  //                               S().coincontrol_tx_detail_expand_changeReceived,
  //                           icon: const EnvoyIcon(EnvoyIcons.transfer,
  //                               color: EnvoyColors.textPrimary,
  //                               size: EnvoyIconSize.extraSmall),
  //                           trailing: Row(
  //                             mainAxisSize: MainAxisSize.max,
  //                             mainAxisAlignment: MainAxisAlignment.end,
  //                             children: [
  //                               loading
  //                                   ? const Padding(
  //                                       padding: EdgeInsets.symmetric(
  //                                           horizontal: EnvoySpacing.xs),
  //                                       child: SizedBox.square(
  //                                         dimension: 12,
  //                                         child: CircularProgressIndicator(
  //                                           strokeWidth: 1,
  //                                         ),
  //                                       ),
  //                                     )
  //                                   : Container(
  //                                       alignment: Alignment.centerRight,
  //                                       child: totalChangeAmount == 0
  //                                           ? Text(
  //                                               S().coincontrol_tx_detail_no_change,
  //                                               style: EnvoyTypography.body
  //                                                   .copyWith(
  //                                                       color: EnvoyColors
  //                                                           .textTertiary),
  //                                             )
  //                                           : EnvoyAmount(
  //                                               unit: formatUnit,
  //                                               account: account,
  //                                               amountSats: totalChangeAmount,
  //                                               millionaireMode: false,
  //                                               amountWidgetStyle:
  //                                                   AmountWidgetStyle.normal),
  //                                     ),
  //                             ],
  //                           )),
  //                       Padding(
  //                         padding:
  //                             const EdgeInsets.only(left: EnvoySpacing.small),
  //                         child: Container(
  //                           height: 24,
  //                           margin: const EdgeInsets.only(
  //                               left: EnvoySpacing.medium2),
  //                           child: ListView(
  //                             scrollDirection: Axis.horizontal,
  //                             children: [
  //                               if (totalChangeAmount != 0)
  //                                 GestureDetector(
  //                                     onTap: () {
  //                                       showEnvoyDialog(
  //                                           context: context,
  //                                           builder: Builder(
  //                                             builder: (_) =>
  //                                                 ChooseTagForStagingTx(
  //                                               accountId: account.id,
  //                                               onEditTransaction: () =>
  //                                                   _onEditTransaction(context),
  //                                               onTagUpdate: () {
  //                                                 widget.onTagUpdate?.call();
  //                                                 Navigator.pop(context);
  //                                               },
  //                                             ),
  //                                           ),
  //                                           alignment:
  //                                               const Alignment(0.0, -.6));
  //                                     },
  //                                     child: _coinTag(changeOutputTag)),
  //                             ],
  //                           ),
  //                         ),
  //                       ),
  //                       SizedBox(
  //                         height:
  //                             totalChangeAmount != 0 ? EnvoySpacing.medium2 : 0,
  //                       ),
  //                       EnvoyInfoCardListItem(
  //                         title: S().coincontrol_tx_history_tx_detail_note,
  //                         icon: const EnvoyIcon(EnvoyIcons.note,
  //                             color: EnvoyColors.textPrimary,
  //                             size: EnvoyIconSize.small),
  //                         trailing: GestureDetector(
  //                             child: NoteDisplay(note: note),
  //                             onTap: () {
  //                               showEnvoyDialog(
  //                                 context: context,
  //                                 dialog: TxNoteDialog(
  //                                   onAdd: (noteText) {
  //                                     ref
  //                                         .read(stagingTxNoteProvider.notifier)
  //                                         .state = noteText;
  //                                     widget.onTxNoteUpdated?.call();
  //                                     Navigator.pop(context);
  //                                   },
  //                                   txId: "UpcomingTx",
  //                                   noteHintText: "i.e. Bought P2P Bitcoin",
  //                                   noteSubTitle:
  //                                       S().coincontrol_tx_add_note_subheading,
  //                                   noteTitle: S().add_note_modal_heading,
  //                                   value: note,
  //                                 ),
  //                                 alignment: const Alignment(0.0, -0.5),
  //                               );
  //                             }),
  //                       ),
  //                     ]),
  //                 if (uneconomicSpends) ...[
  //                   const EnvoyIcon(
  //                     EnvoyIcons.alert,
  //                     size: EnvoyIconSize.medium,
  //                     color: EnvoyColors.solidWhite,
  //                   ),
  //                   const SizedBox(height: EnvoySpacing.xs),
  //                   Padding(
  //                     padding: const EdgeInsets.symmetric(
  //                         horizontal: EnvoySpacing.large1),
  //                     child: Text(
  //                       S().coincontrol_tx_detail_high_fee_info_overlay_subheading,
  //                       textAlign: TextAlign.center,
  //                       style: EnvoyTypography.info
  //                           .copyWith(color: EnvoyColors.solidWhite),
  //                     ),
  //                   ),
  //                   const SizedBox(height: EnvoySpacing.xs),
  //                   EnvoyButton(
  //                       S().coincontrol_tx_detail_high_fee_info_overlay_learnMore,
  //                       type: EnvoyButtonTypes.tertiary, onTap: () {
  //                     launchUrl(Uri.parse(
  //                         "https://docs.foundation.xyz/troubleshooting/envoy/#boosting-or-canceling-transactions"));
  //                   }),
  //                 ]
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Future<void> _onEditTransaction(BuildContext context) async {
    Navigator.pop(context);

    final router = GoRouter.of(context);

    ///indicating that we are in edit mode
    ref.read(spendEditModeProvider.notifier).state =
        SpendOverlayContext.editCoins;

    /// The user has is in edit mode and if the psbt
    /// has inputs then use them to populate the coin selection state
    if (ref.read(draftTransactionProvider) != null) {
      List<String> inputs = ref
          .read(draftTransactionProvider.select(
            (value) => value?.transaction.inputs ?? [],
          ))
          .map((e) => "${e.txId}:${e.vout}")
          .toList();

      if (ref.read(coinSelectionStateProvider).isEmpty) {
        ref.read(coinSelectionStateProvider.notifier).addAll(inputs);
      }
    }

    ///toggle to coins view for coin control
    ref.read(accountToggleStateProvider.notifier).state =
        AccountToggleState.coins;

    ///pop review
    router.pop();
    await Future.delayed(const Duration(milliseconds: 100));

    ///pop spend form
    router.pop();
  }
}

Widget coinTagPill(String title) {
  TextStyle titleStyle =
      EnvoyTypography.info.copyWith(color: EnvoyColors.solidWhite);
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(EnvoySpacing.medium1),
            color: EnvoyColors.accentPrimary),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              vertical: EnvoySpacing.xs, horizontal: EnvoySpacing.small),
          child: Text(
            title,
            style: titleStyle,
          ),
        ),
      )
    ],
  );
}

class AnimatedBottomTxDetails extends ConsumerStatefulWidget {
  const AnimatedBottomTxDetails({super.key});

  @override
  ConsumerState createState() => _AnimatedBottomOverlayTxDetailsState();
}

class _AnimatedBottomOverlayTxDetailsState
    extends ConsumerState<AnimatedBottomTxDetails>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late double overlayHeight;

  @override
  void initState() {
    super.initState();

    overlayHeight =
        (100 + EnvoySpacing.medium3) * 2 + EnvoySpacing.large2 * 2; // + extra

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0, end: overlayHeight).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward(); // Start animation
  }

  void _closeOverlay() {
    _controller.reverse().then((_) async {
      if (mounted) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        await Future.delayed(const Duration(milliseconds: 100));
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _closeOverlay,
      behavior: HitTestBehavior.opaque, // Close when tapping outside
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {}, // Prevent taps inside the overlay
              onVerticalDragUpdate: (details) {
                _controller.value -= details.primaryDelta! / overlayHeight;
              },
              onVerticalDragEnd: (details) {
                if (_controller.value < 0.5) {
                  _closeOverlay(); // Close if dragged down enough
                } else {
                  _controller.forward(); // Snap back if not enough
                }
              },

              child: Transform.scale(
                scale: 1.0,
                child: SizedBox(
                  height: _animation.value,
                  width: MediaQuery.of(context).size.width,
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.applyOpacity(0.2),
                          spreadRadius: 0,
                          blurRadius: 10,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: EnvoySpacing.xs),
                      child: Card(
                        elevation: 100,
                        margin: EdgeInsets.zero,
                        shadowColor: Colors.black,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(EnvoySpacing.medium2),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                                width: 40,
                                height: 4,
                                margin: const EdgeInsets.only(
                                    top: EnvoySpacing.xs,
                                    bottom: EnvoySpacing.small),
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(2),
                                )),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: EnvoySpacing.medium1),
                                child: SingleChildScrollView(
                                  physics: const NeverScrollableScrollPhysics(),
                                  // this is to remove overflow warning while animating
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [
                                          const SizedBox(
                                              height: EnvoySpacing.medium3),
                                        ],
                                      ),
                                      const SizedBox(
                                          height: EnvoySpacing.medium3),
                                      const SizedBox(
                                          height: EnvoySpacing.medium3),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
