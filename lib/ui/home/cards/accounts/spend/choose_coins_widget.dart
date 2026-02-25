// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/pop_up.dart';
import 'package:envoy/ui/home/cards/accounts/account_list_tile.dart';
import 'package:envoy/ui/home/cards/accounts/accounts_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/spend_fee_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/staging_tx_details.dart';
import 'package:envoy/ui/home/cards/accounts/spend/state/spend_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/color_util.dart';
import 'package:envoy/ui/widgets/envoy_amount_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ngwallet/ngwallet.dart';
import 'package:envoy/business/devices.dart';
import 'package:envoy/business/fees.dart';
import 'package:envoy/ui/components/amount_widget.dart';
import 'package:envoy/ui/components/draggable_overlay.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coin_balance_widget.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coins_state.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:envoy/ui/state/home_page_state.dart';

class ChooseCoinsWidget extends ConsumerStatefulWidget {
  const ChooseCoinsWidget({super.key});

  @override
  ConsumerState createState() => _ChooseCoinsWidget();
}

class _ChooseCoinsWidget extends ConsumerState<ChooseCoinsWidget> {
  bool _coinsOpen = false;

  @override
  Widget build(BuildContext context) {
    EnvoyAccount? account = ref.watch(selectedAccountProvider);

    final selectedChangeOutput = ref.watch(rbfChangeOutputProvider);
    int totalSelectedAmount =
        ref.watch(getTotalSelectedAmount(account?.id ?? ""));

    ref.listen(coinSelectionStateProvider, (previous, next) {
      if (!setEquals(previous, next)) {
        ref.read(userSelectedCoinsThisSessionProvider.notifier).state = true;
      }
    });

    final spendEditMode = ref.watch(spendEditModeProvider);
    final requiredAmount = ref.watch(spendAmountProvider);

    if (spendEditMode == SpendOverlayContext.rbfSelection) {
      totalSelectedAmount += selectedChangeOutput?.amount.toInt() ?? 0;
    }

    bool valid =
        (totalSelectedAmount != 0 && totalSelectedAmount >= requiredAmount);

    Set<String> walletSelection = ref.watch(coinSelectionFromWallet);
    Set<String> coinSelection = ref.watch(coinSelectionStateProvider);
    Set coinSelectionDiff1 = walletSelection.difference(coinSelection);
    Set coinSelectionDiff2 = coinSelection.difference(walletSelection);
    Set coinSelectionDiff = coinSelectionDiff1
        .union(coinSelectionDiff2); // all the diff (excluding all duplicates)

    if (account == null) {
      return Container();
    }

    return DraggableOverlay(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        if (!_coinsOpen)
          Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: EnvoyIcon(
                    EnvoyIcons.chevron_left,
                    size: EnvoyIconSize.extraSmall,
                  ),
                ),
                const SizedBox(width: EnvoySpacing.small),
                Text(
                  S().send_editTxDetails_spendingFromAccount,
                  style: EnvoyTypography.subheading
                      .copyWith(color: EnvoyColors.textPrimary),
                )
              ]),
        if (!_coinsOpen)
          Padding(
            padding: const EdgeInsets.only(top: EnvoySpacing.small),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black,
                    border: Border.all(
                      color: fromHex(account.color),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: Padding(
                      padding: const EdgeInsets.all(EnvoySpacing.small),
                      child: BadgeIcon(
                        account: account,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: EnvoySpacing.small),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.name,
                      style: EnvoyTypography.subheading
                          .copyWith(color: EnvoyColors.textPrimary),
                    ),
                    if (account.deviceSerial != null)
                      Text(
                        Devices()
                                .getDeviceBySerial(
                                  account.deviceSerial!,
                                )
                                ?.name ??
                            "",
                        style: EnvoyTypography.info
                            .copyWith(color: EnvoyColors.textPrimary),
                      )
                  ],
                )
              ],
            ),
          ),
        if (!_coinsOpen)
          Padding(
            padding: const EdgeInsets.only(
                top: EnvoySpacing.small, bottom: EnvoySpacing.medium1),
            child: EnvoyAmount(
                amountSats: account.balance.toInt(),
                amountWidgetStyle: AmountWidgetStyle.singleLine,
                account: account),
          ),
        CoinsListSpendState(
          account: account,
          onOpenChanged: (isOpen) {
            setState(() {
              _coinsOpen = isOpen;
            });
          },
        ),
        Divider(
          height: 1,
        ),
        SizedBox(
          height: EnvoySpacing.medium1,
        ),
        Row(
          children: [
            Text(
              S().coincontrol_edit_transaction_requiredAmount,
              style: EnvoyTypography.body
                  .copyWith(color: EnvoyColors.textTertiary),
            ),
            const Spacer(),
            EnvoyAmount(
                amountSats: requiredAmount,
                amountWidgetStyle: AmountWidgetStyle.sendScreen,
                account: account)
          ],
        ),
        const Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
        Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              S().coincontrol_edit_transaction_selectedAmount,
              style:
                  EnvoyTypography.body.copyWith(color: EnvoyColors.textPrimary),
            ),
            const Spacer(),
            EnvoyAmount(
                amountSats: totalSelectedAmount,
                amountWidgetStyle: AmountWidgetStyle.sendScreen,
                account: account)
          ],
        ),
        if (coinSelectionDiff.isNotEmpty)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: EnvoySpacing.medium1,
              ),
              EnvoyButton(
                S().tagged_coin_details_inputs_fails_cta2,
                type: EnvoyButtonTypes.secondary,
                onTap: () async {
                  bool isDismissed = ref.watch(arePromptsDismissedProvider(
                      DismissiblePrompt.txDiscardWarning));

                  if (isDismissed) {
                    ref.read(coinSelectionStateProvider.notifier).reset();
                    ref
                        .read(coinSelectionStateProvider.notifier)
                        .addAll(walletSelection.toList());
                    return;
                  }
                  showEnvoyPopUp(
                    context,
                    S().manual_coin_preselection_dialog_description,
                    S().component_yes,
                    (context) {
                      ref.read(coinSelectionStateProvider.notifier).reset();
                      ref
                          .read(coinSelectionStateProvider.notifier)
                          .addAll(walletSelection.toList());
                      Navigator.of(context).pop();
                    },
                    onCheckBoxChanged: (checkedValue) async {
                      if (checkedValue) {
                        await EnvoyStorage()
                            .addPromptState(DismissiblePrompt.txDiscardWarning);
                      } else {
                        await EnvoyStorage().removePromptState(
                            DismissiblePrompt.txDiscardWarning);
                      }
                    },
                    secondaryButtonLabel: S().component_no,
                    onSecondaryButtonTap: (context) {
                      Navigator.of(context).pop();
                    },
                    checkBoxText: S().component_dontShowAgain,
                    showCloseButton: false,
                    checkedValue: isDismissed,
                    title: S().tagged_coin_details_inputs_fails_cta2,
                    typeOfMessage: PopUpState.warning,
                    icon: EnvoyIcons.alert,
                  );

                  return;
                },
              ),
              SizedBox(
                height: EnvoySpacing.medium1,
              ),
              EnvoyButton(S().send_editTxDetails_applyChanges, enabled: valid,
                  onTap: () async {
                final scope = ProviderScope.containerOf(context);
                final navigator = Navigator.of(context);
                final account = ref.read(selectedAccountProvider);

                ///reset fees if coin selection changed
                ref.read(spendFeeRateProvider.notifier).state =
                    Fees().slowRate(account!.network);
                ref.read(spendTransactionProvider.notifier).validate(scope);

                await Future.delayed(const Duration(milliseconds: 120));
                navigator.pop();
              }),
            ],
          ),
        const SizedBox(height: EnvoySpacing.medium1),
      ]),
    );
  }
}

class CoinsListSpendState extends ConsumerStatefulWidget {
  final EnvoyAccount account;
  final ValueChanged<bool>? onOpenChanged;

  const CoinsListSpendState({
    super.key,
    required this.account,
    this.onOpenChanged,
  });

  @override
  ConsumerState<CoinsListSpendState> createState() => _CoinsListState();
}

class _CoinsListState extends ConsumerState<CoinsListSpendState> {
  Tag? _openTag;

  void _setOpenTag(Tag? tag) {
    setState(() {
      _openTag = tag;
    });
    widget.onOpenChanged?.call(_openTag != null);
  }

  @override
  Widget build(BuildContext context) {
    final tags = ref.watch(tagsProvider(widget.account.id));

    // When no tag is selected -> show list
    if (_openTag == null) {
      return Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.4,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              for (final tag in tags)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Divider(),
                    SizedBox(height: EnvoySpacing.medium1),
                    CoinItemSpendWidget(
                      tag: tag,
                      onTap: () {
                        _setOpenTag(tag);
                      },
                    ),
                  ],
                ),
            ],
          ),
        ),
      );
    }

    // When a tag is selected -> show only that tag's coins
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Optional back row to go back to list
        Row(
          children: [
            GestureDetector(
              child: EnvoyIcon(EnvoyIcons.chevron_left),
              onTap: () => _setOpenTag(null),
            ),
            SizedBox(width: EnvoySpacing.small),
            Text(S().send_editTxDetails_tagDetails),
          ],
        ),
        SizedBox(height: EnvoySpacing.small),
        ChooseCoinsFromTagWidget(_openTag!),
      ],
    );
  }
}

class CoinItemSpendWidget extends ConsumerWidget {
  final Tag tag;
  final VoidCallback? onTap;

  const CoinItemSpendWidget({
    super.key,
    required this.tag,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tag = ref.watch(tagProvider(this.tag.name)) ?? this.tag;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                EnvoyIcon(EnvoyIcons.tag, size: EnvoyIconSize.small),
                SizedBox(width: EnvoySpacing.xs),
                coinTagPill(tag.name),
              ],
            ),
            GestureDetector(
              onTap: onTap,
              child: EnvoyIcon(
                EnvoyIcons.chevron_right,
                size: EnvoyIconSize.small,
              ),
            ),
          ],
        ),
        CoinSubTitleText(tag, textColor: EnvoyColors.textPrimary),
        CoinTagBalanceWidget(coinTag: tag),
      ],
    );
  }
}

class ChooseCoinsFromTagWidget extends ConsumerStatefulWidget {
  final Tag tag;

  const ChooseCoinsFromTagWidget(this.tag, {super.key});

  @override
  ConsumerState createState() => _ChooseCoinsFromTagWidget();
}

class _ChooseCoinsFromTagWidget
    extends ConsumerState<ChooseCoinsFromTagWidget> {
  @override
  Widget build(BuildContext context) {
    EnvoyAccount? account = ref.watch(selectedAccountProvider);

    ref.listen(coinSelectionStateProvider, (previous, next) {
      if (!setEquals(previous, next)) {
        ref.read(userSelectedCoinsThisSessionProvider.notifier).state = true;
      }
    });

    if (account == null) {
      return Container();
    }

    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: EnvoySpacing.small,
          ),
          Row(
            children: [
              EnvoyIcon(
                EnvoyIcons.tag,
                size: EnvoyIconSize.small,
              ),
              SizedBox(width: EnvoySpacing.xs),
              coinTagPill(widget.tag.name)
            ],
          ),
          SizedBox(
            height: EnvoySpacing.xs,
          ),
          CoinSubTitleText(
            widget.tag,
            textColor: EnvoyColors.textPrimary,
          ),
          SizedBox(
            height: EnvoySpacing.xs,
          ),
          CoinTagBalanceWidget(coinTag: widget.tag),
          SizedBox(
            height: EnvoySpacing.small,
          ),
          if (widget.tag.utxo.length >= 2)
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.4,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Divider(),
                    for (final coin in widget.tag.utxo)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CoinBalanceWidget(
                            output: coin,
                            coinTag: widget.tag,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
        ]);
  }
}
