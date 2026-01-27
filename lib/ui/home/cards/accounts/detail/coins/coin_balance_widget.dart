// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'package:envoy/account/accounts_manager.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/amount_widget.dart';
import 'package:envoy/ui/home/cards/accounts/accounts_state.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coins_state.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coins_switch.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/warning_dialogs.dart';
import 'package:envoy/ui/home/cards/accounts/spend/state/spend_state.dart';
import 'package:envoy/ui/loader_ghost.dart';
import 'package:envoy/ui/state/hide_balance_state.dart';
import 'package:envoy/ui/state/home_page_state.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/ui/widgets/envoy_amount_widget.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:envoy/util/haptics.dart';
import 'package:envoy/util/rive_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ngwallet/ngwallet.dart';
import 'package:rive/rive.dart' as rive;
import 'package:envoy/ui/envoy_colors.dart';

//Widget that displays the balance,lock icon etc of a coin

//
class BalanceWidget extends ConsumerWidget {
  final int amount;
  final bool showLock;
  final bool locked;
  final bool rbfChangeOutput;
  final String accountId;
  final GestureTapCallback? onLockTap;
  final Widget? switchWidget;

  const BalanceWidget(
      {super.key,
      required this.amount,
      required this.locked,
      required this.showLock,
      required this.accountId,
      this.rbfChangeOutput = false,
      required this.onLockTap,
      this.switchWidget});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hide = ref.watch(balanceHideStateStatusProvider(accountId));
    final account = NgAccountManager().getAccountById(accountId);

    List<Widget> rowItems = [];
    if (showLock) {
      rowItems.add(FittedBox(
        child: CoinLockButton(
          locked: locked,
          gestureTapCallback: () => onLockTap?.call(),
        ),
      ));
    }
    if (switchWidget != null) {
      rowItems.add(AnimatedOpacity(
          opacity: locked ? 0.2 : 1,
          duration: const Duration(milliseconds: 250),
          child: IgnorePointer(
              ignoring: locked,
              child: switchWidget ?? const SizedBox.shrink())));
    }

    return IgnorePointer(
      ignoring: rbfChangeOutput,
      child: Opacity(
        opacity: rbfChangeOutput ? 0.5 : 1,
        child: Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.symmetric(horizontal: EnvoySpacing.xs),
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                  child: Container(
                child: hide
                    ? LayoutBuilder(
                        builder: (context, constraints) {
                          return LoaderGhost(
                              animate: false,
                              width: constraints.maxWidth,
                              height: 20);
                        },
                      )
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
        ),
      ),
    );
  }
}

class CoinBalanceWidget extends ConsumerStatefulWidget {
  final Output output;
  final bool showLock;
  final Tag coinTag;
  final Function? onEnable;

  const CoinBalanceWidget(
      {super.key,
      required this.output,
      this.showLock = true,
      required this.coinTag,
      this.onEnable});

  @override
  ConsumerState<CoinBalanceWidget> createState() => _CoinBalanceWidgetState();
}

class _CoinBalanceWidgetState extends ConsumerState<CoinBalanceWidget> {
  @override
  Widget build(BuildContext context) {
    final output =
        ref.watch(outputProvider(widget.output.getId())) ?? widget.output;
    final accountId = ref.read(selectedAccountProvider)?.id ?? "";
    bool isRbfChangeOutput = false;
    final rbfChangeOutput = ref.watch(rbfChangeOutputProvider);
    if (rbfChangeOutput != null &&
        rbfChangeOutput.getId() == output.getId() &&
        ref.read(spendEditModeProvider) == SpendOverlayContext.rbfSelection) {
      isRbfChangeOutput = true;
    }
    return BalanceWidget(
      locked: output.doNotSpend,
      amount: output.amount.toInt(),
      accountId: accountId,
      rbfChangeOutput: isRbfChangeOutput,
      showLock: widget.showLock,
      onLockTap: () async {
        if (!output.doNotSpend) {
          bool dismissed = await EnvoyStorage()
              .checkPromptDismissed(DismissiblePrompt.coinLockWarning);
          if (!dismissed && context.mounted) {
            showEnvoyDialog(
                context: context,
                alignment: const Alignment(0.0, -.6),
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
                        await Future.delayed(const Duration(milliseconds: 250));
                        _lockUnLockCoin(output);
                      },
                    );
                  },
                ));
          } else {
            _lockUnLockCoin(output);
          }
        } else {
          bool dismissed = await EnvoyStorage()
              .checkPromptDismissed(DismissiblePrompt.coinUnlockWarning);
          if (!dismissed && context.mounted) {
            showEnvoyDialog(
                context: context,
                alignment: const Alignment(0.0, -.6),
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
                        await Future.delayed(const Duration(milliseconds: 250));
                        _lockUnLockCoin(output);
                      },
                    );
                  },
                ));
          } else {
            _lockUnLockCoin(output);
          }
        }
      },
      switchWidget: Consumer(
        builder: (context, ref, child) {
          bool isSelected = ref.watch(isCoinSelectedProvider(output.getId()));
          if (isRbfChangeOutput) {
            isSelected = isRbfChangeOutput;
          }
          final tag =
              ref.watch(tagProvider(widget.coinTag.name)) ?? widget.coinTag;
          return tag.isAllCoinsLocked
              ? const SizedBox.shrink()
              : CoinTagSwitch(
                  value: isSelected
                      ? CoinTagSwitchState.on
                      : CoinTagSwitchState.off,
                  onChanged: (value) {
                    if (widget.onEnable != null && !isSelected) {
                      widget.onEnable!();
                    }
                    final selectionState =
                        ref.read(coinSelectionStateProvider.notifier);
                    if (value == CoinTagSwitchState.on) {
                      selectionState.add(output.getId());
                    } else {
                      selectionState.remove(output.getId());
                    }
                  },
                );
        },
      ),
    );
  }

  Future _lockUnLockCoin(Output coin) async {
    final account = ref.read(selectedAccountProvider);
    await account?.handler?.setDoNotSpend(
      utxo: coin,
      doNotSpend: !(coin.doNotSpend),
    );
    setState(() {
      if (coin.doNotSpend == false) {
        ref.read(coinSelectionStateProvider.notifier).remove(coin.getId());
      }
    });
    Future.delayed(const Duration(milliseconds: 100))
        .then((value) => Haptics.lightImpact());
  }
}

class CoinTagBalanceWidget extends ConsumerWidget {
  final Tag coinTag;

  const CoinTagBalanceWidget({super.key, required this.coinTag});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tag = ref.watch(tagProvider(coinTag.name)) ?? coinTag;

    bool isRbfChangeOutput = false;
    final rbfChangeOutput = ref.watch(rbfChangeOutputProvider);
    if (ref.read(spendEditModeProvider) == SpendOverlayContext.rbfSelection &&
        tag.utxo.length == 1) {
      isRbfChangeOutput = rbfChangeOutput != null &&
          rbfChangeOutput.getId() == tag.utxo.first.getId();
    }

    /// hide switch if the tag is empty or all coins are locked
    bool hideSwitch = tag.utxo.isEmpty || tag.isAllCoinsLocked;

    final isAllCoinsLocked = tag.isAllCoinsLocked;
    final accountId = ref.read(selectedAccountProvider)?.id ?? "";
    const cardRadius = 26.0;

    return Container(
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(cardRadius))),
      child: BalanceWidget(
        locked: isAllCoinsLocked,
        amount: tag.totalAmount,
        accountId: accountId,
        rbfChangeOutput: isRbfChangeOutput,
        showLock: tag.totalAmount != 0,
        onLockTap: () async {
          if (!isAllCoinsLocked) {
            bool dismissed = await EnvoyStorage()
                .checkPromptDismissed(DismissiblePrompt.coinLockWarning);
            if (!dismissed && context.mounted) {
              showEnvoyDialog(
                  context: context,
                  alignment: const Alignment(0.0, -.6),
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
                          await Future.delayed(
                              const Duration(milliseconds: 250));
                          if (context.mounted) {
                            lockAllCoins(context, coinTag, ref);
                          }
                        },
                      );
                    },
                  ));
            } else {
              if (context.mounted) {
                lockAllCoins(context, coinTag, ref);
              }
            }
          } else {
            bool dismissed = await EnvoyStorage()
                .checkPromptDismissed(DismissiblePrompt.coinUnlockWarning);
            if (!dismissed && context.mounted) {
              showEnvoyDialog(
                  context: context,
                  alignment: const Alignment(0.0, -.6),
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
                          await Future.delayed(
                              const Duration(milliseconds: 250));
                          unLockAllCoins(coinTag, ref);
                        },
                      );
                    },
                  ));
            } else {
              unLockAllCoins(coinTag, ref);
            }
          }
        },
        switchWidget: hideSwitch
            ? const SizedBox.shrink()
            : Consumer(
                builder: (context, ref, child) {
                  final coins = coinTag.utxo;
                  final selectedItems = ref
                      .watch(coinSelectionStateProvider)
                      .where(
                        (element) =>
                            coins.map((e) => e.getId()).contains(element),
                      )
                      .toList();
                  CoinTagSwitchState coinTagSwitchState = selectedItems.isEmpty
                      ? CoinTagSwitchState.off
                      : CoinTagSwitchState.partial;
                  if (selectedItems.length == coinTag.utxo.length) {
                    coinTagSwitchState = CoinTagSwitchState.on;
                  }
                  if (coinTag.utxo.isEmpty) {
                    coinTagSwitchState = CoinTagSwitchState.off;
                  }
                  if (isRbfChangeOutput) {
                    coinTagSwitchState = CoinTagSwitchState.on;
                  }
                  return CoinTagSwitch(
                      triState: true,
                      value: coinTagSwitchState,
                      onChanged: (value) {
                        final selectionState =
                            ref.read(coinSelectionStateProvider.notifier);
                        bool hasLockedItems = coinTag.numOfLockedCoins != 0;
                        if (hasLockedItems && value == CoinTagSwitchState.on) {
                          final ids = coinTag.utxo
                              .where((element) => !element.doNotSpend)
                              .map((e) => e.getId())
                              .toList();
                          selectionState.removeAll(ids);
                        } else {
                          if (value == CoinTagSwitchState.on ||
                              value == CoinTagSwitchState.partial) {
                            final ids = coinTag.utxo
                                .where((element) => !element.doNotSpend)
                                .map((e) => e.getId())
                                .toList();
                            selectionState.addAll(ids);
                          } else {
                            final ids = coinTag.utxo
                                .where((element) => !element.doNotSpend)
                                .map((e) => e.getId())
                                .toList();
                            selectionState.removeAll(ids);
                          }
                        }
                      });
                },
              ),
      ),
    );
  }

  void lockAllCoins(BuildContext context, Tag coinTag, WidgetRef ref) async {
    final account = ref.read(selectedAccountProvider);
    //Check if the user tried to lock coins that are already in a staging transaction.
    ref.read(coinSelectionStateProvider).forEach((element) {
      if (coinTag.utxo.where((e) => e.getId() == element).isNotEmpty) {
        ref.read(coinSelectionStateProvider.notifier).remove(element);
      }
    });
    try {
      Haptics.lightImpact();
      await account?.handler?.setDoNotSpendMultiple(
        utxo: coinTag.utxo.toList(),
        doNotSpend: true,
      );
    } catch (e) {
      kPrint(e);
    }
  }

  void unLockAllCoins(Tag coinTag, WidgetRef ref) async {
    final account = ref.read(selectedAccountProvider);
    try {
      Haptics.lightImpact();
      await account?.handler?.setDoNotSpendMultiple(
        utxo: coinTag.utxo.toList(),
        doNotSpend: false,
      );
    } catch (e) {
      kPrint(e);
    }
  }
}

//Lock button with rive animation
class CoinLockButton extends StatefulWidget {
  final bool locked;
  final GestureTapCallback gestureTapCallback;

  const CoinLockButton(
      {super.key, required this.locked, required this.gestureTapCallback});

  @override
  State<CoinLockButton> createState() => CoinLockButtonState();
}

class CoinLockButtonState extends State<CoinLockButton> {
  bool _isInitialized = false;
  rive.RiveWidgetController? _controller;

  bool _showRive = false;
  Timer? _hideTimer;

  bool get isLocked =>
      //TODO: fix rive with databindings.
      // ignore: deprecated_member_use
      _controller?.stateMachine.boolean("Lock")?.value ?? widget.locked;

  void _initRive(rive.File riveFile) {
    if (_controller != null) return;

    _controller = rive.RiveWidgetController(
      riveFile,
      stateMachineSelector:
          rive.StateMachineSelector.byName('CoinStateMachine'),
    );

    //TODO: fix rive with databindings.
    // ignore: deprecated_member_use
    _controller?.stateMachine.boolean("Lock")?.value = widget.locked;

    setState(() => _isInitialized = true);
  }

  void _playTransitionWindow() {
    _hideTimer?.cancel();
    setState(() => _showRive = true);

    _hideTimer = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _showRive = false);
    });
  }

  @override
  void didUpdateWidget(covariant CoinLockButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.locked != oldWidget.locked) {
      // Update the Rive input only on change.
      //TODO: fix rive with databindings.
      // ignore: deprecated_member_use
      _controller?.stateMachine.boolean("Lock")?.value = widget.locked;

      _playTransitionWindow();
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  Widget _staticIcon() {
    final color = widget.locked ? EnvoyColors.copper : EnvoyColors.darkTeal;
    final borderColor = widget.locked ? EnvoyColors.copper : EnvoyColors.grey85;
    final icon = widget.locked ? "locked" : "unlocked";

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: SvgPicture.asset(
        "assets/components/icons/$icon.svg",
        width: 18.0,
        height: 18.0,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final riveFile = ref.watch(coinLockRiveProvider);

      if (riveFile != null && !_isInitialized) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _initRive(riveFile);
        });
      }

      final canShowRive =
          riveFile != null && _isInitialized && _controller != null;

      return GestureDetector(
        onTap: () {
          _playTransitionWindow();
          widget.gestureTapCallback();
        },
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: 38,
          width: 50,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: EnvoySpacing.xs),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: (_showRive && canShowRive)
                  ? rive.RiveWidget(
                      key: const ValueKey('rive'),
                      controller: _controller!,
                    )
                  : SizedBox(
                      key: const ValueKey('icon'),
                      child: Center(child: _staticIcon()),
                    ),
            ),
          ),
        ),
      );
    });
  }
}

//Widget to show coin tag selections and lock states
class CoinSubTitleText extends ConsumerWidget {
  final Tag tag;

  const CoinSubTitleText(this.tag, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String message = getMessage(tag, ref);
    return Text(
      message,
      style: EnvoyTypography.info.copyWith(color: Colors.white),
    );
  }
}

String getMessage(Tag tag, WidgetRef ref) {
  final selections = ref.watch(coinSelectionStateProvider);
  //TODO: use the actual utxo objects in selection since new api will allow us to send objects to rust
  final selectedCoins = tag.utxo.where((output) {
    final id = '${output.txId}:${output.vout}';
    return selections.contains(id);
  }).toList();
  final lockedCoins = tag.utxo.where((element) => element.doNotSpend);
  final availableCoins = tag.utxo.length - lockedCoins.length;
  String selectionMessage =
      "${selectedCoins.length} ${S().card_label_of} $availableCoins ${S().card_coins_selected}";

  if (availableCoins == 0 || availableCoins == selectedCoins.length) {
    selectionMessage =
        "${selectedCoins.length} ${selectedCoins.length == 1 ? S().card_coin_selected : S().card_coins_selected}";
  }

  String message = "${tag.utxo.length} ${S().card_coins_unselected}";
  if (selectedCoins.isEmpty) {
    message =
        "${tag.utxo.length} ${tag.utxo.length == 1 ? S().card_coin_unselected : S().card_coins_unselected}";
    if (lockedCoins.isNotEmpty) {
      message =
          "$message | ${lockedCoins.length} ${lockedCoins.length == 1 ? S().card_coin_locked : S().card_coins_locked} ";
    }
  } else {
    message = selectionMessage;
    if (lockedCoins.isNotEmpty) {
      message =
          "$message | ${lockedCoins.length} ${lockedCoins.length == 1 ? S().card_coin_locked : S().card_coins_locked} ";
    }
  }
  if (tag.utxo.length == lockedCoins.length) {
    message =
        "${tag.utxo.length} ${tag.utxo.length == 1 ? S().card_coin_locked : S().card_coins_locked} ";
  }
  if (tag.utxo.isEmpty) {
    message = "0 ${S().card_coins_unselected}";
  }
  return message;
}
