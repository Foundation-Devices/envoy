// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:ui';

import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/amount_entry.dart';
import 'package:envoy/ui/components/amount_widget.dart';
import 'package:envoy/ui/components/envoy_info_card.dart';
import 'package:envoy/ui/components/envoy_tag_list_item.dart';
import 'package:envoy/ui/home/cards/accounts/accounts_state.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coins_state.dart';
import 'package:envoy/ui/home/cards/accounts/detail/filter_state.dart';
import 'package:envoy/ui/home/cards/accounts/detail/transaction/transactions_details.dart';
import 'package:envoy/ui/home/cards/accounts/detail/transaction/tx_note_dialog_widget.dart';
import 'package:envoy/ui/home/cards/accounts/spend/staging_tx_tagging.dart';
import 'package:envoy/ui/home/cards/accounts/spend/state/spend_state.dart';
import 'package:envoy/ui/indicator_shield.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/state/send_screen_state.dart';
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
import 'package:url_launcher/url_launcher_string.dart';

class StagingTxDetails extends ConsumerStatefulWidget {
  final bool isRBFSpend;
  final DraftTransaction draftTransaction;
  final Function? onTagUpdate;
  final Function? onTxNoteUpdated;

  ///for rbf staging transaction details
  final BitcoinTransaction? previousTransaction;

  const StagingTxDetails(
      {super.key,
      required this.draftTransaction,
      this.previousTransaction,
      this.onTagUpdate,
      this.onTxNoteUpdated,
      this.isRBFSpend = false});

  @override
  ConsumerState createState() => _SpendTxDetailsState();
}

class _SpendTxDetailsState extends ConsumerState<StagingTxDetails> {
  final GlobalKey _key = GlobalKey();

  bool loading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    EnvoyAccount? account = ref.watch(selectedAccountProvider);
    if (account == null) {
      return Container();
    }
    final accountAccentColor = fromHex(account.color);
    DraftTransaction draftTransaction = widget.draftTransaction;
    final stagedTransaction = draftTransaction.transaction;

    String note = ref.watch(stagingTxNoteProvider) ?? "";
    String changeOutputTag = ref.watch(stagingTxChangeOutPutTagProvider) ?? "";

    if (changeOutputTag.isEmpty) {
      changeOutputTag = S().account_details_untagged_card;
    }

    final totalInputAmount = (stagedTransaction.inputs)
        .map((e) => e.amount.toInt())
        .fold(0, (int sum, element) => sum + element);

    final totalReceiveAmount = (stagedTransaction.amount.toInt());

    final inputs = stagedTransaction.inputs.map((e) => "${e.txId}:${e.vout}");
    final inputTags = stagedTransaction.inputs.map((e) => e.tag);

    final totalChangeAmount = (stagedTransaction.outputs.firstWhereOrNull(
          (outPut) => outPut.keychain == KeyChain.internal,
        ))?.amount.toInt() ??
        0;

    // final String? userChosenTag = ref.watch(stagingTxChangeOutPutTagProvider);

    double? displayFiatSendAmount = ref.watch(displayFiatSendAmountProvider);
    double? displayFiatTotalChangeAmount =
        ExchangeRate().convertSatsToFiat(totalChangeAmount);
    double? displayFiatTotalInputAmount =
        displayFiatSendAmount! + displayFiatTotalChangeAmount;

    final sendScreenUnit = ref.watch(sendScreenUnitProvider);
    final uneconomicSpends = ref.watch(uneconomicSpendsProvider);

    /// if user selected unit from the form screen then use that, otherwise use the default
    DisplayUnit unit = sendScreenUnit == AmountDisplayUnit.btc
        ? DisplayUnit.btc
        : DisplayUnit.sat;

    AmountDisplayUnit formatUnit =
        unit == DisplayUnit.btc ? AmountDisplayUnit.btc : AmountDisplayUnit.sat;

    if (sendScreenUnit == AmountDisplayUnit.fiat) {
      unit = Settings().displayUnit;
    }

    return Stack(
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black,
                    Colors.black,
                    Colors.transparent,
                  ]),
            ),
          ),
        ),
        Positioned.fill(
          child: GestureDetector(
            onTapDown: (details) {
              final height = MediaQuery.of(context).size.height;

              /// if user taps on the bottom 60% of the screen, close the dialog
              if (details.localPosition.dy / height >= .5) {
                Navigator.pop(context);
              }
            },
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                leading: const SizedBox.shrink(),
                actions: [
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: EnvoyColors.textPrimaryInverse,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
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
                        style:
                            Theme.of(context).textTheme.displayMedium?.copyWith(
                                  color: EnvoyColors.textPrimaryInverse,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ],
                  ),
                ),
              ),
              body: Column(
                key: _key,
                children: [
                  EnvoyInfoCard(
                      backgroundColor: accountAccentColor,
                      topWidget: EnvoyAmount(
                          unit: formatUnit,
                          account: account,
                          displayFiatAmount: displayFiatSendAmount,
                          amountSats: totalReceiveAmount.abs(),
                          millionaireMode: false,
                          amountWidgetStyle: AmountWidgetStyle.singleLine),
                      bottomWidgets: [
                        EnvoyInfoCardListItem(
                          spacingPriority: FlexPriority.trailing,
                          title:
                              "${S().coincontrol_tx_detail_expand_spentFrom} ${inputs.toSet().length} ${inputs.toSet().length == 1 ? S().coincontrol_tx_detail_expand_coin : S().coincontrol_tx_detail_expand_coins}",
                          icon: const EnvoyIcon(EnvoyIcons.utxo,
                              color: EnvoyColors.textPrimary,
                              size: EnvoyIconSize.small),
                          trailing: EnvoyAmount(
                              unit: formatUnit,
                              account: account,
                              amountSats: totalInputAmount,
                              displayFiatAmount: displayFiatTotalInputAmount,
                              millionaireMode: false,
                              amountWidgetStyle: AmountWidgetStyle.normal),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(left: EnvoySpacing.small),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: EnvoySpacing.medium2),
                              child: Wrap(
                                spacing: EnvoySpacing.small,
                                runSpacing: EnvoySpacing.small,
                                children: inputTags
                                    .map((e) => e ?? "")
                                    .map((e) => (e.isEmpty)
                                        ? S().account_details_untagged_card
                                        : e)
                                    .toSet()
                                    .map((e) {
                                  return _coinTag(e);
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: EnvoySpacing.medium2,
                        ),
                        EnvoyInfoCardListItem(
                            spacingPriority: FlexPriority.trailing,
                            title:
                                S().coincontrol_tx_detail_expand_changeReceived,
                            icon: const EnvoyIcon(EnvoyIcons.transfer,
                                color: EnvoyColors.textPrimary,
                                size: EnvoyIconSize.extraSmall),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                loading
                                    ? const Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: EnvoySpacing.xs),
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
                                                    .copyWith(
                                                        color: EnvoyColors
                                                            .textTertiary),
                                              )
                                            : EnvoyAmount(
                                                unit: formatUnit,
                                                account: account,
                                                amountSats: totalChangeAmount,
                                                millionaireMode: false,
                                                amountWidgetStyle:
                                                    AmountWidgetStyle.normal),
                                      ),
                              ],
                            )),
                        Padding(
                          padding:
                              const EdgeInsets.only(left: EnvoySpacing.small),
                          child: Container(
                            height: 24,
                            margin: const EdgeInsets.only(
                                left: EnvoySpacing.medium2),
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                if (totalChangeAmount != 0)
                                  GestureDetector(
                                      onTap: () {
                                        showEnvoyDialog(
                                            context: context,
                                            builder: Builder(
                                              builder: (_) =>
                                                  ChooseTagForStagingTx(
                                                accountId: account.id,
                                                onEditTransaction: () =>
                                                    _onEditTransaction(context),
                                                onTagUpdate: () {
                                                  widget.onTagUpdate?.call();
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ),
                                            alignment:
                                                const Alignment(0.0, -.6));
                                      },
                                      child: _coinTag(changeOutputTag)),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height:
                              totalChangeAmount != 0 ? EnvoySpacing.medium2 : 0,
                        ),
                        EnvoyInfoCardListItem(
                          title: S().coincontrol_tx_history_tx_detail_note,
                          icon: const EnvoyIcon(EnvoyIcons.note,
                              color: EnvoyColors.textPrimary,
                              size: EnvoyIconSize.small),
                          trailing: GestureDetector(
                              child: NoteDisplay(note: note),
                              onTap: () {
                                showEnvoyDialog(
                                  context: context,
                                  dialog: TxNoteDialog(
                                    onAdd: (noteText) {
                                      ref
                                          .read(stagingTxNoteProvider.notifier)
                                          .state = noteText;
                                      widget.onTxNoteUpdated?.call();
                                      Navigator.pop(context);
                                    },
                                    txId: "UpcomingTx",
                                    noteHintText: "i.e. Bought P2P Bitcoin",
                                    noteSubTitle:
                                        S().coincontrol_tx_add_note_subheading,
                                    noteTitle: S().add_note_modal_heading,
                                    value: note,
                                  ),
                                  alignment: const Alignment(0.0, -0.5),
                                );
                              }),
                        ),
                      ]),
                  if (uneconomicSpends) ...[
                    const EnvoyIcon(
                      EnvoyIcons.alert,
                      size: EnvoyIconSize.medium,
                      color: EnvoyColors.solidWhite,
                    ),
                    const SizedBox(height: EnvoySpacing.xs),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: EnvoySpacing.large1),
                      child: Text(
                        S().coincontrol_tx_detail_high_fee_info_overlay_subheading,
                        textAlign: TextAlign.center,
                        style: EnvoyTypography.info
                            .copyWith(color: EnvoyColors.solidWhite),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(EnvoySpacing.medium1),
                      child: SizedBox(
                        height: 40,
                        width: 200,
                        child: LinkText(
                          text: S()
                              .coincontrol_tx_detail_high_fee_info_overlay_learnMore,
                          textAlign: TextAlign.center,
                          linkStyle: EnvoyTypography.button
                              .copyWith(color: EnvoyColors.solidWhite),
                          onTap: () {
                            launchUrlString(
                                "https://docs.foundation.xyz/troubleshooting/envoy/#boosting-or-canceling-transactions");
                          },
                        ),
                      ),
                    )
                  ]
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _coinTag(String title) {
    TextStyle titleStyle = Theme.of(context).textTheme.titleSmall!.copyWith(
          color: EnvoyColors.accentPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const EnvoyIcon(EnvoyIcons.tag,
            color: EnvoyColors.accentPrimary, size: EnvoyIconSize.superSmall),
        const Padding(padding: EdgeInsets.only(left: EnvoySpacing.xs)),
        Text(
          title,
          style: titleStyle,
        )
      ],
    );
  }

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
