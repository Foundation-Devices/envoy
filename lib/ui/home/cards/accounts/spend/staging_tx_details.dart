// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:ui';

import 'package:envoy/business/account.dart';
import 'package:envoy/business/coin_tag.dart';
import 'package:envoy/business/coins.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/amount_entry.dart';
import 'package:envoy/ui/background.dart';
import 'package:envoy/ui/components/amount_widget.dart';
import 'package:envoy/ui/home/cards/accounts/accounts_state.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coins_state.dart';
import 'package:envoy/ui/home/cards/accounts/detail/filter_state.dart';
import 'package:envoy/ui/home/cards/accounts/detail/transaction/tx_note_dialog_widget.dart';
import 'package:envoy/ui/home/cards/accounts/spend/spend_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/staging_tx_tagging.dart';
import 'package:envoy/ui/indicator_shield.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/state/send_screen_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/ui/widgets/envoy_amount_widget.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:envoy/util/list_utils.dart';
import 'package:envoy/util/tuple.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:wallet/wallet.dart';

class StagingTxDetails extends ConsumerStatefulWidget {
  final Psbt psbt;

  ///for rbf staging transaction details
  final Transaction? previousTransaction;

  const StagingTxDetails(
      {super.key, required this.psbt, this.previousTransaction});

  @override
  ConsumerState createState() => _SpendTxDetailsState();
}

class _SpendTxDetailsState extends ConsumerState<StagingTxDetails> {
  final GlobalKey _key = GlobalKey();

  bool loading = true;
  int totalReceiveAmount = 0;
  int totalChangeAmount = 0;
  List<Tuple<CoinTag, Coin>> inputs = [];
  List<Tuple<String, int>> inputTagData = [];
  CoinTag? changeOutputTag;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => loadStagingTx());
  }

  /// find tags and change tags belongs to the provided transaction
  Future loadStagingTx() async {
    final account = ref.read(selectedAccountProvider);
    if (account == null) {
      return;
    }
    setState(() {
      loading = true;
    });

    /// if the user is in RBF tx we need to load note from the previous transaction
    if (widget.previousTransaction != null) {
      final note =
          await EnvoyStorage().getTxNote(widget.previousTransaction!.txId);
      ref.read(stagingTxNoteProvider.notifier).state = note;
    }

    final RawTransaction? rawTransaction =
        await ref.read(rawWalletTransactionProvider(widget.psbt.rawTx).future);

    if (rawTransaction != null) {
      RawTransactionOutput receiveOutPut =
          rawTransaction.outputs.firstWhere((element) {
        return (element.path == TxOutputPath.NotMine ||
            element.path == TxOutputPath.External);
      }, orElse: () => rawTransaction.outputs.first);

      /// find change output
      RawTransactionOutput? changeOutPut =
          rawTransaction.outputs.firstWhereOrNull((element) {
        return (element.path == TxOutputPath.Internal);
      });

      List<CoinTag> tags = ref.read(coinsTagProvider(account.id!));

      /// if the user is in RBF tx we need to load the tags from the previous transaction
      if (widget.previousTransaction != null) {
        final coinHistory = await EnvoyStorage()
            .getCoinHistoryByTransactionId(widget.previousTransaction!.txId);
        coinHistory?.forEach((element) {
          for (var input in rawTransaction.inputs) {
            if (input.id == element.coin.id) {
              inputTagData.add(Tuple(element.tagName, element.coin.amount));
            }
          }
        });

        /// if the RBF tx include any other inputs, then find tags belongs to that inputs
        for (var input in rawTransaction.inputs) {
          final id = input.id;
          final tag = tags.firstWhereOrNull((tag) => tag.coinsId.contains(id));
          if (tag != null) {
            final coin = tag.coins.firstWhereOrNull((coin) => coin.id == id);
            if (coin != null) inputTagData.add(Tuple(tag.name, coin.amount));
          }
        }
      } else {
        /// find inputs that belongs to the tags
        for (var input in rawTransaction.inputs) {
          final id = input.id;
          final tag = tags.firstWhereOrNull((tag) => tag.coinsId.contains(id));
          if (tag != null) {
            final coin = tag.coins.firstWhereOrNull((coin) => coin.id == id);
            inputTagData.add(Tuple(tag.name, coin?.amount ?? 0));
          }
        }
      }

      /// find change output tag
      for (var tag in tags) {
        String id = "";
        if (widget.previousTransaction != null) {
          id = widget.previousTransaction!.txId;
          for (var element in tag.coinsId) {
            if (element.contains(id)) {
              changeOutputTag = tag;
            }
          }
        } else {
          id =
              "${widget.psbt.txid}:${rawTransaction.outputs.indexOf(receiveOutPut)}";
          if (tag.coinsId.contains(id)) {
            changeOutputTag = tag;
          }
        }
      }

      final userSelectedCoins = ref.read(getSelectedCoinsProvider(account.id!));
      if (userSelectedCoins.isNotEmpty) {}
      setState(() {
        totalReceiveAmount = receiveOutPut.amount;
        totalChangeAmount = changeOutPut?.amount ?? 0;
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Account? account = ref.watch(selectedAccountProvider);
    if (account == null) {
      return Container();
    }
    final CoinTag? userChosenTag = ref.watch(stagingTxChangeOutPutTagProvider);

    if (userChosenTag != null) {
      changeOutputTag = userChosenTag;
    }

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

    int totalInputAmount = inputTagData
        .map((e) => e.item2)
        .fold(0, (previousValue, element) => previousValue + element);

    final accountAccentColor = account.color;

    Set<String> spendTags = inputTagData.map((e) => e.item1).toSet();

    final note = ref.watch(stagingTxNoteProvider) ?? "";

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
              body: SingleChildScrollView(
                key: _key,
                child: Padding(
                  padding: const EdgeInsets.all(EnvoySpacing.small),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(EnvoySpacing.small),
                        child: AnimatedContainer(
                          height: 275,
                          duration: const Duration(milliseconds: 250),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(
                                Radius.circular(EnvoySpacing.medium2)),
                            border: Border.all(
                                color: EnvoyColors.textPrimary,
                                width: 2,
                                style: BorderStyle.solid),
                            gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  accountAccentColor,
                                  EnvoyColors.textPrimary,
                                ]),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(EnvoySpacing.medium2)),
                                border: Border.all(
                                    color: accountAccentColor,
                                    width: 2,
                                    style: BorderStyle.solid)),
                            child: ClipRRect(
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(EnvoySpacing.medium2)),
                                child: StripesBackground(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        height: 36,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: EnvoySpacing.small),
                                        margin: const EdgeInsets.symmetric(
                                            vertical: EnvoySpacing.xs,
                                            horizontal: EnvoySpacing.xs),
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(
                                                  EnvoySpacing.medium2)),
                                          color: EnvoyColors.textPrimaryInverse,
                                        ),
                                        child: EnvoyAmount(
                                            unit: formatUnit,
                                            account: account,
                                            amountSats: totalReceiveAmount,
                                            amountWidgetStyle:
                                                AmountWidgetStyle.singleLine),
                                      ),
                                      Expanded(
                                          child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: EnvoySpacing.xs,
                                            horizontal: EnvoySpacing.xs),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: EnvoySpacing.small,
                                            vertical: EnvoySpacing.small),
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(
                                                  EnvoySpacing.medium1)),
                                          color: EnvoyColors.textPrimaryInverse,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    SvgPicture.asset(
                                                      "assets/icons/ic_utxos.svg",
                                                      width: 16,
                                                      height: 16,
                                                    ),
                                                    const Padding(
                                                        padding: EdgeInsets.only(
                                                            left: EnvoySpacing
                                                                .small)),
                                                    Text(
                                                        "${S().coincontrol_tx_detail_expand_spentFrom} ${inputTagData.length} ${inputTagData.length == 1 ? S().coincontrol_tx_detail_expand_coin : S().coincontrol_tx_detail_expand_coins}")
                                                  ],
                                                ),
                                                Expanded(child:
                                                    Builder(builder: (context) {
                                                  return Row(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      EnvoyAmount(
                                                          unit: formatUnit,
                                                          account: account,
                                                          amountSats:
                                                              totalInputAmount,
                                                          amountWidgetStyle:
                                                              AmountWidgetStyle
                                                                  .normal),
                                                    ],
                                                  );
                                                }))
                                              ],
                                            ),
                                            const Padding(
                                                padding: EdgeInsets.all(
                                                    EnvoySpacing.xs)),
                                            Container(
                                              height: 24,
                                              margin: const EdgeInsets.only(
                                                  left: EnvoySpacing.medium2),
                                              child: ListView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                children: spendTags.map((e) {
                                                  return _coinTag(e);
                                                }).toList(),
                                              ),
                                            ),
                                            const Padding(
                                                padding: EdgeInsets.all(
                                                    EnvoySpacing.xs)),
                                            Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.compare_arrows,
                                                        size: 16,
                                                      ),
                                                      const Padding(
                                                          padding: EdgeInsets.only(
                                                              left: EnvoySpacing
                                                                  .small)),
                                                      Text(S()
                                                          .coincontrol_tx_detail_expand_changeReceived)
                                                    ],
                                                  ),
                                                  Expanded(
                                                    child: Builder(
                                                        builder: (context) {
                                                      return Row(
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          loading
                                                              ? const Padding(
                                                                  padding: EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          EnvoySpacing
                                                                              .xs),
                                                                  child: SizedBox
                                                                      .square(
                                                                    dimension:
                                                                        12,
                                                                    child:
                                                                        CircularProgressIndicator(
                                                                      strokeWidth:
                                                                          1,
                                                                    ),
                                                                  ),
                                                                )
                                                              : Container(
                                                                  alignment:
                                                                      Alignment
                                                                          .centerRight,
                                                                  child: totalChangeAmount ==
                                                                          0
                                                                      ? Text(
                                                                          S().coincontrol_tx_detail_no_change,
                                                                          style: EnvoyTypography
                                                                              .body
                                                                              .copyWith(color: EnvoyColors.textTertiary),
                                                                        )
                                                                      : EnvoyAmount(
                                                                          unit:
                                                                              formatUnit,
                                                                          account:
                                                                              account,
                                                                          amountSats:
                                                                              totalChangeAmount,
                                                                          amountWidgetStyle:
                                                                              AmountWidgetStyle.normal),
                                                                ),
                                                        ],
                                                      );
                                                    }),
                                                  )
                                                ]),
                                            const Padding(
                                                padding: EdgeInsets.all(
                                                    EnvoySpacing.xs)),
                                            Container(
                                              height: 24,
                                              margin: const EdgeInsets.only(
                                                  left: EnvoySpacing.medium2),
                                              child: ListView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                children: [
                                                  GestureDetector(
                                                      onTap: () {
                                                        showEnvoyDialog(
                                                            context: context,
                                                            builder: Builder(
                                                              builder: (context) =>
                                                                  ChooseTagForStagingTx(
                                                                accountId:
                                                                    account.id!,
                                                                onEditTransaction:
                                                                    () async {
                                                                  Navigator.pop(
                                                                      context);

                                                                  final router =
                                                                      GoRouter.of(
                                                                          context);

                                                                  ///indicating that we are in edit mode
                                                                  ref
                                                                      .read(spendEditModeProvider
                                                                          .notifier)
                                                                      .state = true;

                                                                  /// The user has is in edit mode and if the psbt
                                                                  /// has inputs then use them to populate the coin selection state
                                                                  if (ref.read(
                                                                          rawTransactionProvider) !=
                                                                      null) {
                                                                    List<String> inputs = ref
                                                                        .read(
                                                                            rawTransactionProvider)!
                                                                        .inputs
                                                                        .map((e) =>
                                                                            "${e.previousOutputHash}:${e.previousOutputIndex}")
                                                                        .toList();

                                                                    if (ref
                                                                        .read(
                                                                            coinSelectionStateProvider)
                                                                        .isEmpty) {
                                                                      ref
                                                                          .read(coinSelectionStateProvider
                                                                              .notifier)
                                                                          .addAll(
                                                                              inputs);
                                                                    }
                                                                  }

                                                                  ///toggle to coins view for coin control
                                                                  ref
                                                                          .read(accountToggleStateProvider
                                                                              .notifier)
                                                                          .state =
                                                                      AccountToggleState
                                                                          .coins;

                                                                  ///pop review
                                                                  router.pop();
                                                                  await Future.delayed(
                                                                      const Duration(
                                                                          milliseconds:
                                                                              100));

                                                                  ///pop spend form
                                                                  router.pop();
                                                                },
                                                                onTagUpdate:
                                                                    () {
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                              ),
                                                            ),
                                                            alignment:
                                                                const Alignment(
                                                                    0.0, -.6));
                                                      },
                                                      child: _coinTag(
                                                          changeOutputTag == null
                                                              ? S()
                                                                  .account_details_untagged_card
                                                              : changeOutputTag!
                                                                  .name)),
                                                ],
                                              ),
                                            ),
                                            const Padding(
                                                padding: EdgeInsets.all(
                                                    EnvoySpacing.small)),
                                            GestureDetector(
                                              onTap: () {
                                                showEnvoyDialog(
                                                    context: context,
                                                    dialog: TxNoteDialog(
                                                      onAdd: (note) {
                                                        ref
                                                            .read(
                                                                stagingTxNoteProvider
                                                                    .notifier)
                                                            .state = note;
                                                        Navigator.pop(context);
                                                      },
                                                      txId: "UpcomingTx",
                                                      noteHintText:
                                                          "i.e. Bought P2P Bitcoin",
                                                      noteSubTitle: S()
                                                          .coincontrol_tx_add_note_subheading,
                                                      noteTitle: S()
                                                          .add_note_modal_heading,
                                                      value: ref.read(
                                                          stagingTxNoteProvider),
                                                    ),
                                                    alignment: const Alignment(
                                                        0.0, -0.5));
                                              },
                                              child: Container(
                                                color: Colors.transparent,
                                                padding: const EdgeInsets.all(
                                                    EnvoySpacing.xs),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Flexible(
                                                      flex: 1,
                                                      child: Row(
                                                        children: [
                                                          Padding(
                                                            padding: const EdgeInsets
                                                                .only(
                                                                left:
                                                                    EnvoySpacing
                                                                        .xs),
                                                            child: SvgPicture
                                                                .asset(
                                                              "assets/icons/ic_notes.svg",
                                                              color: EnvoyColors
                                                                  .textPrimary,
                                                              height: 14,
                                                            ),
                                                          ),
                                                          const Padding(
                                                              padding:
                                                                  EdgeInsets.all(
                                                                      EnvoySpacing
                                                                          .xs)),
                                                          Text(
                                                            S().coincontrol_tx_history_tx_detail_note,
                                                            style: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodySmall
                                                                ?.copyWith(
                                                                    color: EnvoyColors
                                                                        .textPrimary,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Expanded(
                                                        child: Container(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          Expanded(
                                                            child: Text(note,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                maxLines: 2,
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodySmall
                                                                    ?.copyWith(
                                                                        color: EnvoyColors
                                                                            .textPrimary,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w600,
                                                                        fontSize:
                                                                            12),
                                                                textAlign:
                                                                    TextAlign
                                                                        .end),
                                                          ),
                                                          const Padding(
                                                              padding:
                                                                  EdgeInsets.all(
                                                                      EnvoySpacing
                                                                          .xs)),
                                                          note.trim().isNotEmpty
                                                              ? SvgPicture
                                                                  .asset(
                                                                  note
                                                                          .trim()
                                                                          .isNotEmpty
                                                                      ? "assets/icons/ic_edit_note.svg"
                                                                      : "assets/icons/ic_notes.svg",
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColor,
                                                                  height: 14,
                                                                )
                                                              : const Icon(
                                                                  Icons
                                                                      .add_circle_rounded,
                                                                  color: EnvoyColors
                                                                      .accentPrimary,
                                                                  size: 16),
                                                        ],
                                                      ),
                                                    )),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const Padding(
                                                padding: EdgeInsets.all(
                                                    EnvoySpacing.xs)),
                                          ],
                                        ),
                                      )),
                                    ],
                                  ),
                                )),
                          ),
                        ),
                      ),
                      if (uneconomicSpends) ...[
                        const Padding(
                          padding: EdgeInsets.all(EnvoySpacing.medium1),
                          child: EnvoyIcon(
                            EnvoyIcons.info,
                            size: EnvoyIconSize.big,
                            color: EnvoyColors.solidWhite,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: EnvoySpacing.medium3),
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
                                    "https://docs.foundationdevices.com/troubleshooting#envoy-is-excluding-small-coins-from-my-transaction");
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
    return Container(
      margin: const EdgeInsets.only(right: EnvoySpacing.small),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            "assets/icons/ic_tag.svg",
            color: EnvoyColors.accentPrimary,
            height: 12,
          ),
          const Padding(padding: EdgeInsets.only(left: EnvoySpacing.xs)),
          Text(
            title,
            style: titleStyle,
          )
        ],
      ),
    );
  }
}
