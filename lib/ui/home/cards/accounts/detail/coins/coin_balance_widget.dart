// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/account_manager.dart';
import 'package:envoy/business/coin_tag.dart';
import 'package:envoy/business/coins.dart';
import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coins_state.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coins_switch.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/warning_dialogs.dart';
import 'package:envoy/ui/loader_ghost.dart';
import 'package:envoy/ui/state/hide_balance_state.dart';
import 'package:envoy/ui/state/home_page_state.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/util/amount.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:envoy/util/haptics.dart';
import 'package:envoy/util/rive_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rive/rive.dart' as Rive;
import 'package:rive/rive.dart';

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
    bool hideFiat = AccountManager().isAccountTestnet(accountId);

    TextStyle _textStyleFiat = Theme.of(context).textTheme.titleSmall!.copyWith(
          color: EnvoyColors.grey,
          fontSize: 11,
          fontWeight: FontWeight.w400,
        );

    TextStyle _textStyleAmountSatBtc =
        Theme.of(context).textTheme.headlineSmall!.copyWith(
              color: EnvoyColors.grey,
              fontSize: 15,
              fontWeight: FontWeight.w400,
            );

    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(horizontal: 4),
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
              flex: 3,
              child: Container(
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: Settings().displayUnit == DisplayUnit.btc
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      alignment: Alignment(0, 0),
                      child: SizedBox.square(
                          dimension: 12,
                          child: SvgPicture.asset(
                            Settings().displayUnit == DisplayUnit.btc
                                ? "assets/icons/ic_bitcoin_straight.svg"
                                : "assets/icons/ic_sats.svg",
                            color: Color(0xff808080),
                          )),
                    ),
                    Container(
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(
                          left:
                              Settings().displayUnit == DisplayUnit.btc ? 4 : 0,
                          right: Settings().displayUnit == DisplayUnit.btc
                              ? 0
                              : 8),
                      child: hide
                          ? LoaderGhost(width: 100, height: 20)
                          : Text(
                              "${getFormattedAmount(amount, trailingZeroes: true)}",
                              textAlign:
                                  Settings().displayUnit == DisplayUnit.btc
                                      ? TextAlign.start
                                      : TextAlign.end,
                              style: _textStyleAmountSatBtc,
                            ),
                    ),
                  ],
                ),
              )),
          Flexible(
            flex: 4,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  constraints: BoxConstraints(minWidth: 80),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 12.0),
                  child: hide
                      ? LoaderGhost(
                          width: 40,
                          height: 20,
                          animate: false,
                        )
                      : Text(
                          hideFiat
                              ? ""
                              : ExchangeRate().getFormattedAmount(amount),
                          style: _textStyleFiat,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                        ),
                ),
                showLock
                    ? FittedBox(
                        child: StatefulBuilder(
                          builder: (context, setState) {
                            return CoinLockButton(
                              locked: locked,
                              gestureTapCallback: () => onLockTap?.call(),
                            );
                          },
                        ),
                      )
                    : SizedBox.shrink(),
                Flexible(
                    child: AnimatedOpacity(
                        opacity: locked ? 0.0 : 1,
                        duration: Duration(milliseconds: 250),
                        child: IgnorePointer(
                            ignoring: locked,
                            child: switchWidget ?? SizedBox.shrink()))),
              ],
            ),
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
                      buttonTitle: "Lock Coins", // TODO: FIGMA
                      promptType: DismissiblePrompt.coinLockWarning,
                      warningMessage:
                          "You’re about to lock coins.\nThis will prevent them from being used in transactions.", // TODO: FIGMA
                      onContinue: () {
                        Navigator.pop(context);
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
                      buttonTitle: "Unlock coins", // TODO: FIGMA
                      promptType: DismissiblePrompt.coinUnlockWarning,
                      warningMessage:
                          "Unlocking coins will make them available for use in transactions.", // TODO: FIGMA
                      onContinue: () {
                        Navigator.pop(context);
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

  const CoinTagBalanceWidget({super.key, required this.coinTag});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool locked = ref.watch(coinTagLockStateProvider(coinTag));

    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(16))),
      child: BalanceWidget(
        locked: locked,
        amount: coinTag.totalAmount,
        accountId: coinTag.account,
        showLock: true,
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
                        buttonTitle: "Lock Coins", // TODO: FIGMA
                        promptType: DismissiblePrompt.coinLockWarning,
                        warningMessage:
                            "You’re about to lock coins.\nThis will prevent them from being used in transactions.", // TODO: FIGMA
                        onContinue: () {
                          Navigator.pop(context);
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
                        buttonTitle: "Unlock coins", // TODO: FIGMA
                        promptType: DismissiblePrompt.coinUnlockWarning,
                        warningMessage:
                            "Unlocking coins will make them available for use in transactions.", // TODO: FIGMA
                        onContinue: () {
                          Navigator.pop(context);
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
        switchWidget: Consumer(
          builder: (context, ref, child) {
            final coins = coinTag.coins_id;
            final selectedItems = ref
                .watch(coinSelectionStateProvider)
                .where(
                  (element) => coins.contains(element),
                )
                .toList();
            CoinTagSwitchState coinTagSwitchState = selectedItems.length == 0
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
          child: Container(
              child: SizedBox(
                  height: 30,
                  width: 30,
                  child: riveFile != null
                      ? Rive.RiveAnimation.direct(
                          riveFile,
                          onInit: _onInit,
                        )
                      : SizedBox.shrink())));
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
    TextStyle _textStyleTagSubtitle =
        Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            );
    final selections = ref.watch(coinSelectionStateProvider);
    ref.watch(coinsProvider(tag.account));
    final selectedCoins =
        selections.where((element) => tag.coins_id.contains(element));
    final lockedCoins = tag.coins.where((element) => element.locked);
    final availableCoins = tag.numOfCoins - lockedCoins.length;
    String selectionMessage =
        "${selectedCoins.length} of ${availableCoins} Coins Selected"; // TODO: FIGMA

    if (availableCoins == 0 || availableCoins == selectedCoins.length) {
      selectionMessage =
          "${selectedCoins.length} ${selectedCoins.length == 1 ? 'Coin' : 'Coins'} Selected"; // TODO: FIGMA
    }

    String message = "${tag.numOfCoins} Coins"; // TODO: FIGMA
    if (selectedCoins.isEmpty) {
      message =
          "${tag.numOfCoins} ${tag.numOfCoins == 1 ? 'Coin' : 'Coins'}"; // TODO: FIGMA
      if (lockedCoins.isNotEmpty) {
        message =
            "$message | ${lockedCoins.length} ${lockedCoins.length == 1 ? 'Coin' : 'Coins'} Locked"; // TODO: FIGMA
      }
    } else {
      message = "${selectionMessage}";
      if (lockedCoins.isNotEmpty) {
        message =
            "$message | ${lockedCoins.length} ${lockedCoins.length == 1 ? 'Coin' : 'Coins'} Locked"; // TODO: FIGMA
      }
    }
    if (tag.numOfCoins == lockedCoins.length) {
      message =
          "${tag.numOfCoins} ${tag.numOfCoins == 1 ? 'Coin' : 'Coins'} Locked"; // TODO: FIGMA
    }
    if (tag.numOfCoins == 0) {
      message = "0 Coins"; // TODO: FIGMA
    }
    return Text(
      message,
      style: _textStyleTagSubtitle,
    );
  }
}
