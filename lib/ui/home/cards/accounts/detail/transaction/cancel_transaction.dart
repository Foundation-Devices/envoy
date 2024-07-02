// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/account.dart';
import 'package:envoy/business/fees.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/background.dart';
import 'package:envoy/ui/components/amount_widget.dart';
import 'package:envoy/ui/components/button.dart';
import 'package:envoy/ui/home/cards/accounts/accounts_state.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coins_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/psbt_card.dart';
import 'package:envoy/ui/home/cards/accounts/spend/spend_state.dart';
import 'package:envoy/ui/shield.dart';
import 'package:envoy/ui/state/transactions_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/ui/widgets/envoy_amount_widget.dart';
import 'package:envoy/ui/widgets/toast/envoy_toast.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:envoy/util/haptics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart' as rive;

import 'package:url_launcher/url_launcher.dart';
import 'package:wallet/exceptions.dart';
import 'package:wallet/wallet.dart';
import 'package:envoy/util/bug_report_helper.dart';

class RBFState {
  final String originalTxId;
  final String newTxId;
  final String accountId;
  final num oldFee;
  final num newFee;
  final int rbfTimeStamp;
  final int previousTxTimeStamp;

  RBFState({
    required this.originalTxId,
    required this.newTxId,
    required this.oldFee,
    required this.newFee,
    required this.accountId,
    required this.rbfTimeStamp,
    required this.previousTxTimeStamp,
  });

  /// returns json
  Map<String, dynamic> toJson() {
    return {
      "originalTxId": originalTxId,
      "newTxId": newTxId,
      "oldFee": oldFee,
      "newFee": newFee,
      "accountId": accountId,
      "rbfTimeStamp": rbfTimeStamp,
      "previousTxTimeStamp": previousTxTimeStamp
    };
  }

  /// from json
  factory RBFState.fromJson(Map<String, dynamic> json) {
    return RBFState(
      originalTxId: json["originalTxId"],
      newTxId: json["newTxId"],
      oldFee: json["oldFee"],
      newFee: json["newFee"],
      accountId: json["accountId"],
      rbfTimeStamp: json["rbfTimeStamp"] ?? 0,
      previousTxTimeStamp: json["previousTxTimeStamp"] ?? 0,
    );
  }
}

class CancelTxButton extends ConsumerStatefulWidget {
  final Transaction transaction;

  const CancelTxButton({super.key, required this.transaction});

  @override
  ConsumerState<CancelTxButton> createState() => _CancelTxButtonState();
}

class _CancelTxButtonState extends ConsumerState<CancelTxButton> {
  bool _isPressed = false;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(EnvoySpacing.xs),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(),
          GestureDetector(
            onTapDown: (_) {
              setState(() {
                _isPressed = true;
                Haptics.lightImpact();
              });
            },
            onTapUp: (_) {
              checkCancel(context);
              _isPressed = false;
            },
            onTapCancel: () {
              setState(() {
                _isPressed = false;
                Haptics.lightImpact();
              });
            },
            child: Container(
              height: EnvoySpacing.medium2,
              decoration: BoxDecoration(
                  color:
                      EnvoyColors.chilli500.withOpacity(_isPressed ? 0.5 : 1),
                  borderRadius: BorderRadius.circular(EnvoySpacing.small)),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _loading
                      ? const SizedBox.square(
                          dimension: EnvoySpacing.medium1,
                          child: CircularProgressIndicator(
                            strokeWidth: 1,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Row(
                          children: [
                            const Icon(Icons.close,
                                color: Colors.white, size: 18),
                            const SizedBox(width: EnvoySpacing.xs),
                            Text(S().coincontrol_tx_detail_passport_cta2,
                                style: EnvoyTypography.button.copyWith(
                                  color: Colors.white,
                                ))
                          ],
                        )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  checkCancel(BuildContext context) async {
    setState(() {
      _loading = true;
    });
    final selectedAccount = ref.read(selectedAccountProvider);
    if (selectedAccount == null) {
      return;
    }
    final doNotSpend = ref.read(lockedUtxosProvider(selectedAccount.id!));
    final feeRate = Fees().fastRate(selectedAccount.wallet.network);

    try {
      final psbt = await selectedAccount.wallet
          .cancelTx(widget.transaction.txId, doNotSpend, feeRate);

      final rawTx = await selectedAccount.wallet
          .decodeWalletRawTx(psbt.rawTx, selectedAccount.wallet.network);
      final originalTxRawHex = await selectedAccount.wallet
          .getRawTxFromTxId(widget.transaction.txId);

      final originalTxRaw = await selectedAccount.wallet
          .decodeWalletRawTx(originalTxRawHex, selectedAccount.wallet.network);

      if (context.mounted) {
        showEnvoyDialog(
            context: context,
            builder: Builder(
                builder: (context) => TxCancelDialog(
                    originalTx: widget.transaction,
                    cancelRawTx: rawTx,
                    originalRawTx: originalTxRaw,
                    cancelTx: psbt)));
      }
    } catch (e, s) {
      debugPrintStack(stackTrace: s);
      kPrint(e);
      String message = "$e";
      if (e is InsufficientFunds) {
        message = S().send_keyboard_amount_insufficient_funds_info;
      }
      if (context.mounted) {
        EnvoyToast(
          backgroundColor: EnvoyColors.danger,
          replaceExisting: true,
          duration: const Duration(seconds: 4),
          message: message,
          icon: const Icon(
            Icons.info_outline,
            color: EnvoyColors.solidWhite,
          ),
        ).show(context);
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }
}

class TxCancelDialog extends ConsumerStatefulWidget {
  final Transaction originalTx;
  final Psbt cancelTx;
  final RawTransaction cancelRawTx;
  final RawTransaction originalRawTx;

  const TxCancelDialog(
      {super.key,
      required this.originalTx,
      required this.cancelTx,
      required this.cancelRawTx,
      required this.originalRawTx});

  @override
  ConsumerState createState() => _TxCancelDialogState();
}

class _TxCancelDialogState extends ConsumerState<TxCancelDialog> {
  int _totalReturnAmount = 0;
  int _totalFeeAmount = 0;

  @override
  void initState() {
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => _findCancellationFee());
    super.initState();
  }

  _findCancellationFee() {
    int originalSpendAmount = 0;
    for (var element in widget.originalRawTx.outputs) {
      if (element.path == TxOutputPath.NotMine) {
        originalSpendAmount += element.amount;
      }
    }
    _totalFeeAmount = widget.originalTx.fee;

    /// if the amount is 0, check if the tx is a self transfer
    if (originalSpendAmount == 0) {
      for (var element in widget.originalRawTx.outputs) {
        if (element.path == TxOutputPath.External) {
          originalSpendAmount += element.amount;
        }
      }
    }

    setState(() {
      _totalFeeAmount = widget.cancelTx.fee;
      if (originalSpendAmount != 0) {
        _totalReturnAmount = originalSpendAmount - widget.originalTx.fee;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Account? account = ref.read(selectedAccountProvider);
    if (account == null) {
      return const Center(
        child: Text("No account selected"),
      );
    }

    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(EnvoySpacing.medium2),
        ),
        color: EnvoyColors.textPrimaryInverse,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: EnvoySpacing.medium2, horizontal: EnvoySpacing.medium2),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                  padding: const EdgeInsets.only(bottom: EnvoySpacing.small),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Transform.translate(
                        offset: const Offset(
                            -EnvoySpacing.small, -EnvoySpacing.small),
                        child: IconButton(
                          icon: const Icon(Icons.chevron_left,
                              color: EnvoyColors.textPrimary),
                          iconSize: 32,
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ],
                  )),
              const Padding(
                padding: EdgeInsets.only(bottom: EnvoySpacing.medium3),
                child: EnvoyIcon(
                  EnvoyIcons.alert,
                  size: EnvoyIconSize.big,
                  color: EnvoyColors.danger,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: EnvoySpacing.medium1),
                child: Text(
                  S().coincontrol_tx_detail_passport_cta2,
                  style: EnvoyTypography.subheading,
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: EnvoySpacing.medium3),
                child: Text(
                  _totalReturnAmount.isNegative
                      ? S()
                          .replaceByFee_cancelAmountNone_overlay_modal_subheading
                      : S().replaceByFee_cancel_overlay_modal_subheading,
                  style: EnvoyTypography.info,
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: EnvoySpacing.small),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S().replaceByFee_cancel_overlay_modal_cancelationFees,
                          style: EnvoyTypography.body,
                        ),
                        EnvoyAmount(
                            account: account,
                            amountSats: _totalFeeAmount,
                            amountWidgetStyle: AmountWidgetStyle.normal),
                      ],
                    ),
                    const SizedBox(height: EnvoySpacing.medium1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S().replaceByFee_cancel_overlay_modal_receivingAmount,
                          style: EnvoyTypography.body,
                        ),
                        _totalReturnAmount.isNegative
                            ? Text(S().replaceByFee_cancelAmountNone_None,
                                style: EnvoyTypography.body
                                    .copyWith(color: EnvoyColors.danger))
                            : EnvoyAmount(
                                account: account,
                                amountSats: _totalReturnAmount,
                                amountWidgetStyle: AmountWidgetStyle.normal,
                              )
                      ],
                    ),
                    const SizedBox(height: EnvoySpacing.medium1),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: EnvoySpacing.medium2),
                child: TextButton(
                  onPressed: () {
                    launchUrl(Uri.parse(
                        "https://docs.foundation.xyz/envoy/envoy-menu/account/#cancel-a-transaction"));
                  },
                  child: Text(
                    S().component_learnMore,
                    style: EnvoyTypography.button
                        .copyWith(color: EnvoyColors.accentPrimary),
                  ),
                ),
              ),
              EnvoyButton(
                  label: S()
                      .replaceByFee_cancel_overlay_modal_proceedWithCancelation,
                  type: ButtonType.danger,

                  ///wrap to the text and padding...
                  height: 0,
                  state: ButtonState.defaultState,
                  onTap: () async {
                    final navigator =
                        Navigator.of(context, rootNavigator: true);
                    if (widget.originalTx.isConfirmed) {
                      EnvoyToast(
                        backgroundColor: EnvoyColors.danger,
                        replaceExisting: true,
                        duration: const Duration(seconds: 4),
                        message: "Error: Transaction Confirmed",
                        // TODO: Figma
                        icon: const Icon(
                          Icons.info_outline,
                          color: EnvoyColors.solidWhite,
                        ),
                      ).show(context);
                      return;
                    } else {
                      if (account.wallet.hot == false) {
                        await navigator.push(MaterialPageRoute(
                            builder: (context) => Builder(builder: (context) {
                                  return background(
                                      child: PsbtCard(
                                        widget.cancelTx,
                                        account,
                                        onSignedPsbtScanned: (psbt) async {
                                          navigator.pop();
                                          navigator.pop();
                                          //wait for route to pop
                                          await Future.delayed(const Duration(
                                              milliseconds: 100));
                                          navigator.push(MaterialPageRoute(
                                            builder: (context) =>
                                                CancelTransactionProgress(
                                              cancelTx: psbt,
                                              cancelRawTx: widget.cancelRawTx,
                                              originalTx: widget.originalTx,
                                            ),
                                          ));
                                        },
                                      ),
                                      context: context);
                                })));
                      } else {
                        Navigator.pop(context);
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) {
                            return CancelTransactionProgress(
                              cancelTx: widget.cancelTx,
                              cancelRawTx: widget.cancelRawTx,
                              originalTx: widget.originalTx,
                            );
                          },
                        ));
                      }
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}

class CancelTransactionProgress extends ConsumerStatefulWidget {
  final Psbt cancelTx;
  final Transaction originalTx;
  final RawTransaction cancelRawTx;

  const CancelTransactionProgress(
      {super.key,
      required this.cancelTx,
      required this.originalTx,
      required this.cancelRawTx});

  @override
  ConsumerState<CancelTransactionProgress> createState() =>
      _CancelTransactionProgressState();
}

class _CancelTransactionProgressState
    extends ConsumerState<CancelTransactionProgress> {
  rive.StateMachineController? _stateMachineController;
  BroadcastProgress broadcastProgress = BroadcastProgress.staging;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _broadcastTx();
    });
  }

  _broadcastTx() async {
    setState(() {
      broadcastProgress = BroadcastProgress.inProgress;
    });
    _stateMachineController?.findInput<bool>("indeterminate")?.change(true);
    _stateMachineController?.findInput<bool>("happy")?.change(false);
    _stateMachineController?.findInput<bool>("unhappy")?.change(false);
    final account = ref.read(selectedAccountProvider);
    if (account == null) {
      return;
    }
    int port = Settings().getPort(account.wallet.network);
    try {
      await account.wallet.broadcastTx(
          Settings().electrumAddress(account.wallet.network),
          port,
          widget.cancelTx.rawTx);
      await Future.delayed(const Duration(milliseconds: 500));
      await EnvoyStorage().addCancelState(RBFState(
              originalTxId: widget.originalTx.txId,
              newTxId: widget.cancelTx.txid,
              oldFee: widget.originalTx.fee,
              newFee: widget.cancelTx.fee,
              accountId: account.id!,
              rbfTimeStamp: DateTime.now().millisecondsSinceEpoch,
              previousTxTimeStamp:
                  widget.originalTx.date.millisecondsSinceEpoch)
          .toJson());
      await Future.delayed(const Duration(milliseconds: 500));

      ref.read(rbfBroadCastedTxProvider.notifier).state = [
        ...ref.read(rbfBroadCastedTxProvider),
        widget.originalTx.txId
      ];

      Psbt psbt = widget.cancelTx;

      String receiverAddress = "";
      for (var element in widget.cancelRawTx.outputs) {
        if (element.path == TxOutputPath.Internal) {
          receiverAddress = element.address;
        }
      }
      final note = await EnvoyStorage().getTxNote(widget.originalTx.txId);
      if (note != null) {
        try {
          await EnvoyStorage().addTxNote(note: note, key: psbt.txid);
        } catch (e) {
          kPrint("Error adding note to new tx $e");
          EnvoyReport().log("RBF:cancel", e.toString());
        }
      }

      await EnvoyStorage().addPendingTx(
        psbt.txid,
        account.id!,
        DateTime.now(),
        TransactionType.pending,
        psbt.fee,
        psbt.fee,
        receiverAddress,
      );

      _stateMachineController?.findInput<bool>("indeterminate")?.change(false);
      _stateMachineController?.findInput<bool>("happy")?.change(true);
      _stateMachineController?.findInput<bool>("unhappy")?.change(false);
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        broadcastProgress = BroadcastProgress.success;
      });
    } catch (e) {
      EnvoyReport().log("RBF:Cancel", e.toString());
      _stateMachineController?.findInput<bool>("indeterminate")?.change(false);
      _stateMachineController?.findInput<bool>("happy")?.change(false);
      _stateMachineController?.findInput<bool>("unhappy")?.change(true);
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        broadcastProgress = BroadcastProgress.failed;
      });
      kPrint(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: broadcastProgress != BroadcastProgress.inProgress,
      onPopInvoked: (didPop) {
        clearSpendState(ProviderScope.containerOf(context));
      },
      child: background(
        child: MediaQuery.removePadding(
          removeTop: true,
          removeBottom: true,
          context: context,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            child: Padding(
              key: const Key("progress"),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 260,
                        child: rive.RiveAnimation.asset(
                          "assets/envoy_loader.riv",
                          fit: BoxFit.contain,
                          onInit: (artboard) {
                            _stateMachineController =
                                rive.StateMachineController.fromArtboard(
                                    artboard, 'STM');
                            artboard.addController(_stateMachineController!);
                            _stateMachineController
                                ?.findInput<bool>("indeterminate")
                                ?.change(true);
                          },
                        ),
                      ),
                    ),
                    const SliverPadding(padding: EdgeInsets.all(28)),
                    SliverToBoxAdapter(
                      child: Builder(
                        builder: (context) {
                          String title =
                              S().replaceByFee_cancel_confirm_heading;
                          String subTitle =
                              S().stalls_before_sending_tx_scanning_subheading;
                          if (broadcastProgress !=
                              BroadcastProgress.inProgress) {
                            if (broadcastProgress ==
                                BroadcastProgress.success) {
                              title = S().replaceByFee_cancel_success_heading;
                              subTitle =
                                  S().replaceByFee_cancel_success_subheading;
                            } else {
                              title = S().replaceByFee_cancel_fail_heading;
                              subTitle = S()
                                  .stalls_before_sending_tx_scanning_broadcasting_fail_subheading;
                            }
                          }
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  title,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const Padding(padding: EdgeInsets.all(18)),
                                Text(subTitle,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                            fontWeight: FontWeight.w500)),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    SliverFillRemaining(
                        hasScrollBody: false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 44),
                          child: _ctaButtons(context),
                        ))
                  ],
                ),
              ),
            ),
          ),
        ),
        context: context,
      ),
    );
  }

  Widget _ctaButtons(BuildContext context) {
    if (broadcastProgress == BroadcastProgress.inProgress ||
        broadcastProgress == BroadcastProgress.staging) {
      return const SizedBox();
    }
    if (broadcastProgress == BroadcastProgress.success) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        children: [
          EnvoyButton(
            label: S().component_continue,
            onTap: () async {
              Navigator.of(context).popUntil((route) {
                return route.settings is MaterialPage;
              });
            },
            type: ButtonType.primary,
            state: ButtonState.defaultState,
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        children: [
          EnvoyButton(
            label: S().component_back,
            onTap: () async {
              Navigator.pop(context);
            },
            type: ButtonType.secondary,
            state: ButtonState.defaultState,
          ),
        ],
      );
    }
  }
}

Widget background({required Widget child, required BuildContext context}) {
  double appBarHeight = AppBar().preferredSize.height;
  double topAppBarOffset = appBarHeight + 10;

  return Scaffold(
    resizeToAvoidBottomInset: true,
    body: Stack(
      children: [
        const AppBackground(showRadialGradient: true,),
        Positioned(
          top: topAppBarOffset,
          left: 5,
          bottom: const BottomAppBar().height ?? 20 + 8,
          right: 5,
          child: Shield(child: child),
        )
      ],
    ),
  );
}
