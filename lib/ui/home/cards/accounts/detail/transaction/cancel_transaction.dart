// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/account/accounts_manager.dart';
import 'package:envoy/account/envoy_transaction.dart';
import 'package:envoy/account/sync_manager.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/business/uniform_resource.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/background.dart';
import 'package:envoy/ui/components/amount_widget.dart';
import 'package:envoy/ui/components/button.dart';
import 'package:envoy/ui/components/pop_up.dart';
import 'package:envoy/ui/home/cards/accounts/accounts_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/rbf/rbf_spend_screen.dart';
import 'package:envoy/ui/home/cards/accounts/spend/state/spend_state.dart';
import 'package:envoy/ui/routes/routes.dart';
import 'package:envoy/ui/shield.dart';
import 'package:envoy/ui/state/transactions_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/ui/widgets/color_util.dart';
import 'package:envoy/ui/widgets/envoy_amount_widget.dart';
import 'package:envoy/ui/widgets/toast/envoy_toast.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:envoy/util/haptics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ngwallet/ngwallet.dart';
import 'package:rive/rive.dart' as rive;
import 'package:url_launcher/url_launcher.dart';

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
  final EnvoyTransaction transaction;
  final DraftTransaction? draftTransaction;
  final bool loading;

  const CancelTxButton(
      {super.key,
      required this.transaction,
      required this.draftTransaction,
      this.loading = false});

  @override
  ConsumerState<CancelTxButton> createState() => _CancelTxButtonState();
}

class _CancelTxButtonState extends ConsumerState<CancelTxButton> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool canCancel = widget.draftTransaction != null && widget.loading == false;
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
                Haptics.lightImpact();
              });
            },
            onTapUp: (_) {
              ref.watch(rbfSpendStateProvider) != null && canCancel
                  ? showEnvoyDialog(
                      context: context,
                      useRootNavigator: true,
                      builder: Builder(
                          builder: (context) => TxCancelDialog(
                              originalTx: widget.transaction,
                              cancelTx: widget.draftTransaction!)))
                  : showNoCancelNoFundsDialog(context);
            },
            child: Container(
              height: EnvoySpacing.medium2,
              decoration: BoxDecoration(
                  color: EnvoyColors.chilli500.applyOpacity(widget.loading
                      ? 1
                      : (ref.watch(rbfSpendStateProvider) != null && canCancel
                          ? 1
                          : 0.5)),
                  borderRadius: BorderRadius.circular(EnvoySpacing.small)),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  widget.loading
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

  void showNoCancelNoFundsDialog(BuildContext context) {
    if (widget.loading) {
      return;
    }

    showEnvoyPopUp(
      context,
      title: S().coindetails_overlay_noCancelNoFunds_heading,
      S().coindetails_overlay_noCanceltNoFunds_subheading,
      S().component_continue,
      onLearnMore: () {
        launchUrl(Uri.parse(
            "https://docs.foundation.xyz/troubleshooting/envoy/#boosting-or-canceling-transactions"));
      },
      (BuildContext context) {
        Navigator.pop(context);
      },
      icon: EnvoyIcons.alert,
      typeOfMessage: PopUpState.warning,
    );
  }
}

class TxCancelDialog extends ConsumerStatefulWidget {
  final EnvoyTransaction originalTx;
  final DraftTransaction cancelTx;

  const TxCancelDialog({
    super.key,
    required this.originalTx,
    required this.cancelTx,
  });

  @override
  ConsumerState createState() => _TxCancelDialogState();
}

class _TxCancelDialogState extends ConsumerState<TxCancelDialog> {
  int _totalReturnAmount = 0;
  int _totalFeeAmount = 0;
  late DraftTransaction draftTransaction = widget.cancelTx;
  late EnvoyTransaction originalTransaction = widget.originalTx;

  @override
  void initState() {
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => _findCancellationFee());
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
  }

  _findCancellationFee() {
    int originalSpendAmount = 0;
    for (var element in originalTransaction.outputs) {
      if (element.keychain == null) {
        originalSpendAmount += element.amount.toInt();
      }
    }
    //if the amount is 0, check if the tx is a self transfer
    if (originalSpendAmount == 0) {
      for (var element in originalTransaction.outputs) {
        if (element.keychain == KeyChain.external_) {
          originalSpendAmount += element.amount.toInt();
        }
      }
    }
    _totalFeeAmount = originalTransaction.fee.toInt();
    setState(() {
      _totalFeeAmount = draftTransaction.transaction.fee.toInt();
      if (originalSpendAmount != 0) {
        _totalReturnAmount =
            originalSpendAmount - originalTransaction.fee.toInt();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    EnvoyAccount? account = ref.read(selectedAccountProvider);
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
                    _broadcast(context);
                  }),
            ],
          ),
        ),
      ),
    );
  }

  void _broadcast(BuildContext context) async {
    EnvoyAccount? account = ref.read(selectedAccountProvider);
    if (account == null) {
      return;
    }
    if (originalTransaction.isConfirmed) {
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
      if (account.isHot == false) {
        _handleQRExchange();
      } else {
        Navigator.pop(context);
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) {
            return CancelTransactionProgress(
              cancelTx: draftTransaction,
              originalTx: originalTransaction,
            );
          },
        ));
      }
    }
  }

  void _handleQRExchange() async {
    final navigator = Navigator.of(context);
    bool received = false;
    final cryptoPsbt = await GoRouter.of(context)
        .pushNamed(PSBT_QR_EXCHANGE_STANDALONE, extra: widget.cancelTx);
    if (cryptoPsbt is CryptoPsbt && received == false) {
      try {
        final preparedTx = await EnvoyAccountHandler.decodePsbt(
            draftTransaction: draftTransaction, psbt: cryptoPsbt.decoded);
        draftTransaction = preparedTx;
        await Future.delayed(const Duration(milliseconds: 50));
        //pop dialog
        navigator.pop();
        navigator.push(MaterialPageRoute(
          builder: (context) {
            return CancelTransactionProgress(
              cancelTx: draftTransaction,
              originalTx: originalTransaction,
            );
          },
        ));
        received = true;
      } catch (e) {
        EnvoyReport().log("RBF:Cancel", e.toString());
      }
    }
  }
}

class CancelTransactionProgress extends ConsumerStatefulWidget {
  final DraftTransaction cancelTx;
  final EnvoyTransaction originalTx;

  const CancelTransactionProgress({
    super.key,
    required this.cancelTx,
    required this.originalTx,
  });

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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await Future.delayed(const Duration(milliseconds: 100));
      _broadcastTx();
    });
  }

  _broadcastTx() async {
    final originalTx =
        ref.read(getTransactionProvider(widget.originalTx.txId)) ??
            widget.originalTx;
    setState(() {
      broadcastProgress = BroadcastProgress.inProgress;
    });
    _stateMachineController?.findInput<bool>("indeterminate")?.change(true);
    _stateMachineController?.findInput<bool>("happy")?.change(false);
    _stateMachineController?.findInput<bool>("unhappy")?.change(false);
    final account = ref.read(selectedAccountProvider);
    final handler = account?.handler;
    if (handler == null || account == null) {
      return;
    }

    try {
      final server = SyncManager.getElectrumServer(account.network);
      int? port = Settings().getPort(account.network);
      if (port == -1) {
        port = null;
      }
      //update draft transaction with updated tx state
      DraftTransaction cancelTx = DraftTransaction(
          transaction: BitcoinTransaction(
            txId: widget.cancelTx.transaction.txId,
            blockHeight: widget.cancelTx.transaction.blockHeight,
            confirmations: widget.cancelTx.transaction.confirmations,
            isConfirmed: widget.cancelTx.transaction.isConfirmed,
            fee: widget.cancelTx.transaction.fee,
            feeRate: widget.cancelTx.transaction.feeRate,
            amount: widget.cancelTx.transaction.amount,
            inputs: widget.cancelTx.transaction.inputs,
            address: widget.cancelTx.transaction.address,
            outputs: widget.cancelTx.transaction.outputs,
            vsize: widget.cancelTx.transaction.vsize,
            accountId: widget.cancelTx.transaction.accountId,
            note: originalTx.note,
          ),
          psbt: widget.cancelTx.psbt,
          inputTags: widget.cancelTx.inputTags,
          isFinalized: widget.cancelTx.isFinalized);

      /// get the raw transaction from the database
      await EnvoyAccountHandler.broadcast(
        draftTransaction: cancelTx,
        electrumServer: server,
        torPort: port,
      );
      await handler.updateBroadcastState(draftTransaction: cancelTx);
      await EnvoyStorage().addCancelState(RBFState(
              originalTxId: widget.originalTx.txId,
              newTxId: cancelTx.transaction.txId,
              oldFee: widget.originalTx.fee.toInt(),
              newFee: cancelTx.transaction.fee.toInt(),
              accountId: account.id,
              rbfTimeStamp: DateTime.now().millisecondsSinceEpoch,
              previousTxTimeStamp: widget.originalTx.date?.toInt() ??
                  DateTime.now().millisecondsSinceEpoch)
          .toJson());
      await Future.delayed(const Duration(milliseconds: 100));
      final _ = ref.refresh(cancelTxStateProvider(cancelTx.transaction.txId));
      await Future.delayed(const Duration(milliseconds: 200));
      ref.read(rbfBroadCastedTxProvider.notifier).state = [
        ...ref.read(rbfBroadCastedTxProvider),
        widget.originalTx.txId
      ];
      _stateMachineController?.findInput<bool>("indeterminate")?.change(false);
      _stateMachineController?.findInput<bool>("happy")?.change(true);
      _stateMachineController?.findInput<bool>("unhappy")?.change(false);
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        broadcastProgress = BroadcastProgress.success;
      });
    } catch (e) {
      kPrint("RBF:Cancel: $e");
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
      onPopInvokedWithResult: (didPop, _) {
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
                                  style: EnvoyTypography.heading,
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
        const AppBackground(
          showRadialGradient: true,
        ),
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
