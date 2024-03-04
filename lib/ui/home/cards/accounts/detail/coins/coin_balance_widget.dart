// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/coin_tag.dart';
import 'package:envoy/business/coins.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coins_state.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coins_switch.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/warning_dialogs.dart';
import 'package:envoy/ui/loader_ghost.dart';
import 'package:envoy/ui/state/hide_balance_state.dart';
import 'package:envoy/ui/state/home_page_state.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:envoy/util/haptics.dart';
import 'package:envoy/util/rive_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart' as Rive;
import 'package:rive/rive.dart';
import 'package:envoy/ui/components/amount_widget.dart';
import 'package:envoy/ui/widgets/envoy_amount_widget.dart';
import 'package:envoy/business/account_manager.dart';

//Widget that displays the balance,lock icon etc of a coin

//
class BalanceWidget extends ConsumerWidget {
  final int amount;
  final bool showLock;
  final bool locked;
  final String accountId;
  final GestureTapCallback? onLockTap;
  final Widget? switchWidget;

  const BalanceWidget(
      {super.key,
      required this.amount,
      required this.locked,
      required this.showLock,
      required this.accountId,
      required this.onLockTap,
      this.switchWidget});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hide = ref.watch(balanceHideStateStatusProvider(accountId));
    final account = AccountManager().getAccountById(accountId);

    List<Widget> rowItems = [];
    if (showLock) {
      rowItems.add(FittedBox(
        child: StatefulBuilder(
          builder: (context, setState) {
            return CoinLockButton(
              locked: locked,
              gestureTapCallback: () => onLockTap?.call(),
            );
          },
        ),
      ));
    }
    if (switchWidget != null) {
      rowItems.add(AnimatedOpacity(
          opacity: locked ? 0.2 : 1,
          duration: Duration(milliseconds: 250),
          child: IgnorePointer(
              ignoring: locked, child: switchWidget ?? SizedBox.shrink())));
    }

    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.only(left: EnvoySpacing.xs),
      padding: EdgeInsets.only(left: EnvoySpacing.xs),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
              child: Container(
            child: hide
                ? LoaderGhost(width: 100, height: 20)
                : EnvoyAmount(
                    account: account!,
                    amountSats: amount,
                    amountWidgetStyle: AmountWidgetStyle.singleLine),
          )),
          if (rowItems.isNotEmpty)
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: rowItems,
            )
        ],
      ),
    );
  }
}

class CoinBalanceWidget extends ConsumerStatefulWidget {
  final Coin coin;
  final bool showLock;

  const CoinBalanceWidget({
    super.key,
    required this.coin,
    this.showLock = true,
  });

  @override
  ConsumerState<CoinBalanceWidget> createState() => _CoinBalanceWidgetState();
}

class _CoinBalanceWidgetState extends ConsumerState<CoinBalanceWidget> {
  @override
  Widget build(BuildContext context) {
    final coin = widget.coin;

    return BalanceWidget(
      locked: widget.coin.locked,
      amount: widget.coin.amount,
      accountId: widget.coin.account,
      showLock: widget.showLock,
      onLockTap: () async {
        if (!coin.locked) {
          bool dismissed = await EnvoyStorage()
              .checkPromptDismissed(DismissiblePrompt.coinLockWarning);
          if (!dismissed) {
            showEnvoyDialog(
                context: context,
                alignment: Alignment(0.0, -.6),
                useRootNavigator: true,
                builder: Builder(
                  builder: (context) {
                    return CoinLockWarning(
                      buttonTitle: S().coincontrol_lock_coin_modal_cta1,
                      promptType: DismissiblePrompt.coinLockWarning,
                      warningMessage:
                          S().coincontrol_lock_coin_modal_subheading,
                      onContinue: () async {
                        Navigator.pop(context);
                        //wait for dialog to close so that the lock icon animation is not interrupted
                        await Future.delayed(Duration(milliseconds: 250));
                        _lockUnLockCoin(coin);
                      },
                    );
                  },
                ));
          } else {
            _lockUnLockCoin(coin);
          }
        } else {
          bool dismissed = await EnvoyStorage()
              .checkPromptDismissed(DismissiblePrompt.coinUnlockWarning);
          if (!dismissed) {
            showEnvoyDialog(
                context: context,
                alignment: Alignment(0.0, -.6),
                builder: Builder(
                  builder: (context) {
                    return CoinLockWarning(
                      buttonTitle: S().coincontrol_unlock_coin_modal_cta1,
                      promptType: DismissiblePrompt.coinUnlockWarning,
                      warningMessage:
                          S().coincontrol_unlock_coin_modal_subheading,
                      onContinue: () async {
                        Navigator.pop(context);
                        //wait for dialog to close so that the lock icon animation is not interrupted
                        await Future.delayed(Duration(milliseconds: 250));
                        _lockUnLockCoin(coin);
                      },
                    );
                  },
                ));
          } else {
            _lockUnLockCoin(coin);
          }
        }
      },
      switchWidget: Consumer(
        builder: (context, ref, child) {
          final isSelected = ref.watch(isCoinSelectedProvider(coin.id));
          return CoinTagSwitch(
            value: isSelected ? CoinTagSwitchState.on : CoinTagSwitchState.off,
            onChanged: (value) {
              final selectionState =
                  ref.read(coinSelectionStateProvider.notifier);
              if (value == CoinTagSwitchState.on) {
                selectionState.add(coin.id);
              } else {
                selectionState.remove(coin.id);
              }
            },
          );
        },
      ),
    );
  }

  Future _lockUnLockCoin(Coin coin) async {
    setState(() {
      coin.setLock(!coin.locked);
      //if coin is locked, remove it from selection
      if (coin.locked) {
        ref.read(coinSelectionStateProvider.notifier).remove(coin.id);
      }
    });
    Future.delayed(Duration(milliseconds: 100))
        .then((value) => Haptics.lightImpact());
  }
}

class CoinTagBalanceWidget extends ConsumerWidget {
  final CoinTag coinTag;
  final bool isListScreen;

  const CoinTagBalanceWidget(
      {super.key, required this.coinTag, this.isListScreen = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool locked = ref.watch(coinTagLockStateProvider(coinTag));

    /// hide switch if the tag is empty or all coins are locked
    bool hideSwitch = (coinTag.isAllCoinsLocked && isListScreen) ||
        (coinTag.totalAmount == 0);

    final cardRadius = 26.0;
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(cardRadius))),
      child: BalanceWidget(
        locked: locked,
        amount: coinTag.totalAmount,
        accountId: coinTag.account,
        showLock: coinTag.totalAmount != 0,
        onLockTap: () async {
          if (!coinTag.isAllCoinsLocked) {
            bool dismissed = await EnvoyStorage()
                .checkPromptDismissed(DismissiblePrompt.coinLockWarning);
            if (!dismissed) {
              showEnvoyDialog(
                  context: context,
                  alignment: Alignment(0.0, -.6),
                  useRootNavigator: true,
                  builder: Builder(
                    builder: (context) {
                      return CoinLockWarning(
                        buttonTitle: S().coincontrol_lock_coin_modal_cta1,
                        promptType: DismissiblePrompt.coinLockWarning,
                        warningMessage:
                            S().coincontrol_lock_coin_modal_subheading,
                        onContinue: () async {
                          Navigator.pop(context);
                          //wait for dialog to close so that the lock icon animation is not interrupted
                          await Future.delayed(Duration(milliseconds: 250));
                          coinTag.updateLockState(true);
                        },
                      );
                    },
                  ));
            } else {
              coinTag.updateLockState(true);
            }
          } else {
            bool dismissed = await EnvoyStorage()
                .checkPromptDismissed(DismissiblePrompt.coinUnlockWarning);
            if (!dismissed) {
              showEnvoyDialog(
                  context: context,
                  alignment: Alignment(0.0, -.6),
                  useRootNavigator: true,
                  builder: Builder(
                    builder: (context) {
                      return CoinLockWarning(
                        buttonTitle: S().coincontrol_unlock_coin_modal_cta1,
                        promptType: DismissiblePrompt.coinUnlockWarning,
                        warningMessage:
                            S().coincontrol_unlock_coin_modal_subheading,
                        onContinue: () async {
                          Navigator.pop(context);
                          //wait for dialog to close so that the lock icon animation is not interrupted
                          await Future.delayed(Duration(milliseconds: 250));
                          coinTag.updateLockState(false);
                        },
                      );
                    },
                  ));
            } else {
              coinTag.updateLockState(false);
            }
          }
        },
        switchWidget: hideSwitch
            ? null
            : Consumer(
                builder: (context, ref, child) {
                  final coins = coinTag.coins_id;
                  final selectedItems = ref
                      .watch(coinSelectionStateProvider)
                      .where(
                        (element) => coins.contains(element),
                      )
                      .toList();
                  CoinTagSwitchState coinTagSwitchState =
                      selectedItems.length == 0
                          ? CoinTagSwitchState.off
                          : CoinTagSwitchState.partial;
                  if (selectedItems.length == coinTag.numOfCoins) {
                    coinTagSwitchState = CoinTagSwitchState.on;
                  }
                  if (coinTag.coins.isEmpty) {
                    coinTagSwitchState = CoinTagSwitchState.off;
                  }
                  return CoinTagSwitch(
                    triState: true,
                    value: coinTagSwitchState,
                    onChanged: (value) {
                      final selectionState =
                          ref.read(coinSelectionStateProvider.notifier);

                      bool hasLockedItems = coinTag.numOfLockedCoins != 0;
                      if (hasLockedItems && value == CoinTagSwitchState.on) {
                        final ids = coinTag.coins
                            .where((element) => !element.locked)
                            .map((e) => e.id)
                            .toList();
                        selectionState.removeAll(ids);
                      } else {
                        if (value == CoinTagSwitchState.on ||
                            value == CoinTagSwitchState.partial) {
                          final ids = coinTag.coins
                              .where((element) => !element.locked)
                              .map((e) => e.id)
                              .toList();
                          selectionState.addAll(ids);
                        } else {
                          final ids = coinTag.coins
                              .where((element) => !element.locked)
                              .map((e) => e.id)
                              .toList();
                          selectionState.removeAll(ids);
                        }
                      }
                    },
                  );
                },
              ),
      ),
    );
  }
}

//Lock button with rive animation
class CoinLockButton extends StatefulWidget {
  final bool locked;
  final GestureTapCallback gestureTapCallback;

  const CoinLockButton(
      {super.key, required this.locked, required this.gestureTapCallback});

  @override
  State<CoinLockButton> createState() => _CoinLockButtonState();
}

class _CoinLockButtonState extends State<CoinLockButton> {
  Rive.StateMachineController? _controller;
  late Rive.RiveFile riveFile;

  void _onInit(Artboard art) {
    var ctrl = StateMachineController.fromArtboard(art, 'CoinStateMachine')
        as StateMachineController;
    art.addController(ctrl);
    _controller = ctrl;
    _controller?.findInput<bool>("Lock")?.change(widget.locked);
  }

  @override
  Widget build(BuildContext context) {
    _controller?.findInput<bool>("Lock")?.change(widget.locked);
    return Consumer(builder: (context, ref, child) {
      RiveFile? riveFile = ref.watch(coinLockRiveProvider);
      return GestureDetector(
          onTap: widget.gestureTapCallback,
          behavior: HitTestBehavior.opaque,
          child: Container(
              height: 38,
              width: 50,
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: EnvoySpacing.xs),
                child: riveFile != null
                    ? Rive.RiveAnimation.direct(
                        riveFile,
                        onInit: _onInit,
                      )
                    : SizedBox.shrink(),
              )));
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }
}

//Widget to show coin tag selections and lock states
class CoinSubTitleText extends ConsumerWidget {
  final CoinTag tag;

  CoinSubTitleText(this.tag);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String message = getMessage(tag, ref);
    return Text(
      message,
      style: EnvoyTypography.info.copyWith(color: Colors.white),
    );
  }
}

String getMessage(CoinTag tag, WidgetRef ref) {
  final selections = ref.watch(coinSelectionStateProvider);
  final selectedCoins =
      selections.where((element) => tag.coins_id.contains(element));
  final lockedCoins = tag.coins.where((element) => element.locked);
  final availableCoins = tag.numOfCoins - lockedCoins.length;
  String selectionMessage =
      "${selectedCoins.length} ${S().card_label_of} ${availableCoins} ${S().card_coins_selected}";

  if (availableCoins == 0 || availableCoins == selectedCoins.length) {
    selectionMessage =
        "${selectedCoins.length} ${selectedCoins.length == 1 ? S().card_coin_selected : S().card_coins_selected}";
  }

  String message = "${tag.numOfCoins} ${S().card_coins_unselected}";
  if (selectedCoins.isEmpty) {
    message =
        "${tag.numOfCoins} ${tag.numOfCoins == 1 ? S().card_coin_unselected : S().card_coins_unselected}";
    if (lockedCoins.isNotEmpty) {
      message =
          "$message | ${lockedCoins.length} ${lockedCoins.length == 1 ? S().card_coin_locked : S().card_coins_locked} ";
    }
  } else {
    message = "${selectionMessage}";
    if (lockedCoins.isNotEmpty) {
      message =
          "$message | ${lockedCoins.length} ${lockedCoins.length == 1 ? S().card_coin_locked : S().card_coins_locked} ";
    }
  }
  if (tag.numOfCoins == lockedCoins.length) {
    message =
        "${tag.numOfCoins} ${tag.numOfCoins == 1 ? S().card_coin_locked : S().card_coins_locked} ";
  }
  if (tag.numOfCoins == 0) {
    message = "0 ${S().card_coins_unselected}";
  }
  return message;
}
