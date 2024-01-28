// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:envoy/business/account.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/background.dart';
import 'package:envoy/ui/components/button.dart';
import 'package:envoy/ui/components/envoy_scaffold.dart';
import 'package:envoy/ui/home/cards/accounts/accounts_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/fee_slider.dart';
import 'package:envoy/ui/home/cards/accounts/spend/psbt_card.dart';
import 'package:envoy/ui/home/cards/accounts/spend/rbf/rbf_button.dart';
import 'package:envoy/ui/home/cards/accounts/spend/spend_fee_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/spend_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/transaction_review_card.dart';
import 'package:envoy/ui/shield.dart';
import 'package:envoy/ui/state/transactions_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/toast/envoy_toast.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart' as Rive;
import 'package:tor/tor.dart';
import 'package:wallet/wallet.dart';

class RBFSpendScreen extends ConsumerStatefulWidget {
  final RBFSpendState rbfSpendState;

  const RBFSpendScreen({super.key, required this.rbfSpendState});

  @override
  ConsumerState createState() => _RBFSpendScreenState();
}

class _RBFSpendScreenState extends ConsumerState<RBFSpendScreen> {
  bool _rebuildingTx = false;
  BroadcastProgress broadcastProgress = BroadcastProgress.staging;
  late Psbt _psbt;
  late Transaction _originalTx;

  @override
  void initState() {
    _psbt = widget.rbfSpendState.psbt;
    _originalTx = widget.rbfSpendState.originalTx;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Psbt psbt = _psbt;
    bool showProgress = broadcastProgress == BroadcastProgress.inProgress ||
        broadcastProgress == BroadcastProgress.success ||
        broadcastProgress == BroadcastProgress.failed;
    return PopScope(
      canPop:
          broadcastProgress == BroadcastProgress.inProgress || _rebuildingTx,
      onPopInvoked: (didPop) {
        clearSpendState(ProviderScope.containerOf(context));
      },
      child: Background(
        child: MediaQuery.removePadding(
          removeTop: true,
          removeBottom: true,
          context: context,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            child: PageTransitionSwitcher(
              transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
                return SharedAxisTransition(
                  animation: primaryAnimation,
                  secondaryAnimation: secondaryAnimation,
                  fillColor: Colors.transparent,
                  transitionType: SharedAxisTransitionType.vertical,
                  child: child,
                );
              },
              child: showProgress
                  ? _buildBroadcastProgress()
                  : EnvoyScaffold(
                      backgroundColor: Colors.transparent,
                      hasScrollBody: true,
                      extendBody: true,
                      extendBodyBehindAppBar: true,
                      removeAppBarPadding: true,
                      child: CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Flexible(
                                    flex: 1,
                                    child: BackButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      color: Colors.black,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                          "Your transaction is ready\nto be boosted",
                                          textAlign: TextAlign.center,
                                          style: EnvoyTypography.heading),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: EnvoySpacing.small,
                                  horizontal: EnvoySpacing.medium1),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: EnvoySpacing.small),
                                child: Text(
                                  "Choose a new fee below to boost your transaction.",
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400),
                                ),
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: Consumer(builder: (context, ref, child) {
                              return TransactionReviewCard(
                                psbt: psbt,
                                psbtFinalized: false,
                                hideTxDetailsDialog: true,
                                loading: false,
                                feeTitle: S().replaceByFee_boost_tx_boostFee,
                                address: widget.rbfSpendState.receiveAddress,
                                feeChooserWidget: FeeChooser(
                                  onFeeSelect: (int fee, BuildContext context,
                                      bool customFee) {
                                    _setFee(fee, context, customFee);
                                  },
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                      bottom: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(7),
                        ),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            color: Colors.white12,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: EnvoySpacing.xs)
                                  .add(EdgeInsets.only(
                                      bottom: EnvoySpacing.large1)),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  EnvoyButton(
                                    label: S()
                                        .replaceByFee_coindetails_overlay_modal_heading,
                                    state: ButtonState.default_state,
                                    onTap: () => _boostTx(context),
                                    type: ButtonType.primary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ),
        context: context,
      ),
    );
  }

  Rive.StateMachineController? _stateMachineController;

  Widget _buildBroadcastProgress() {
    return Padding(
      key: Key("progress"),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                height: 260,
                child: Rive.RiveAnimation.asset(
                  "assets/envoy_loader.riv",
                  fit: BoxFit.contain,
                  onInit: (artboard) {
                    _stateMachineController =
                        Rive.StateMachineController.fromArtboard(
                            artboard, 'STM');
                    artboard.addController(_stateMachineController!);
                    _stateMachineController
                        ?.findInput<bool>("indeterminate")
                        ?.change(true);
                  },
                ),
              ),
            ),
            SliverPadding(padding: EdgeInsets.all(28)),
            SliverToBoxAdapter(
              child: Builder(
                builder: (context) {
                  String title = S().replaceByFee_boost_confirm_heading;
                  String subTitle =
                      S().stalls_before_sending_tx_scanning_subheading;
                  if (broadcastProgress != BroadcastProgress.inProgress) {
                    if (broadcastProgress == BroadcastProgress.success) {
                      title = S()
                          .stalls_before_sending_tx_scanning_broadcasting_success_heading;
                      subTitle = S()
                          .stalls_before_sending_tx_scanning_broadcasting_success_subheading;
                    } else {
                      title = S()
                          .stalls_before_sending_tx_scanning_broadcasting_fail_heading;
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
                        Padding(padding: EdgeInsets.all(18)),
                        Text(subTitle,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(fontWeight: FontWeight.w500)),
                      ],
                    ),
                  );
                },
              ),
            ),
            SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 44),
                  child: _ctaButtons(context),
                ))
          ],
        ),
      ),
    );
  }

  Widget _ctaButtons(BuildContext context) {
    if (broadcastProgress == BroadcastProgress.inProgress ||
        broadcastProgress == BroadcastProgress.staging) {
      return SizedBox();
    }
    if (broadcastProgress == BroadcastProgress.success) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        children: [
          EnvoyButton(
            label: S().component_continue,
            onTap: () async {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            type: ButtonType.primary,
            state: ButtonState.default_state,
          ),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        children: [
          EnvoyButton(
            label: S().coincontrol_txDetail_ReviewTransaction,
            onTap: () async {
              setState(() {
                broadcastProgress = BroadcastProgress.staging;
              });
            },
            type: ButtonType.secondary,
            state: ButtonState.default_state,
          ),
        ],
      );
    }
  }

  _boostTx(BuildContext context) async {
    Account? account = ref.read(selectedAccountProvider);
    if (account == null) {
      return;
    }
    if (account.wallet.hot) {
      broadcastTx(account, _psbt);
    } else {
      final psbt = await Navigator.of(context, rootNavigator: false).push(
          MaterialPageRoute(
              builder: (context) => Background(
                  child: PsbtCard(_psbt, account), context: context)));
      broadcastTx(account, psbt);
    }
  }

  Future broadcastTx(Account account, Psbt psbt) async {
    try {
      setState(() {
        broadcastProgress = BroadcastProgress.inProgress;
      });
      if (ref
              .read(
                  getTransactionProvider(widget.rbfSpendState.originalTx.txId))
              ?.isConfirmed ==
          true) {
        setState(() {
          broadcastProgress = BroadcastProgress.staging;
        });
        EnvoyToast(
          backgroundColor: EnvoyColors.danger,
          replaceExisting: true,
          duration: Duration(seconds: 4),
          message: "Error: Transaction Confirmed",
          icon: Icon(
            Icons.info_outline,
            color: EnvoyColors.solidWhite,
          ),
        ).show(context);
        return;
      }
      _stateMachineController?.findInput<bool>("indeterminate")?.change(true);
      _stateMachineController?.findInput<bool>("happy")?.change(false);
      _stateMachineController?.findInput<bool>("unhappy")?.change(false);
      await Future.delayed(Duration(seconds: 4));

      final txid = await account.wallet.broadcastTx(
          Settings().electrumAddress(account.wallet.network),
          Tor.instance.port,
          psbt.rawTx);

      try {
        // RawTransaction rawTx = await account.wallet
        //     .decodeWalletRawTx(psbt.rawTx, account.wallet.network);

        Transaction originalTx = widget.rbfSpendState.originalTx;
        await EnvoyStorage().addRBFBoost(txid, {
          "originalTxId": originalTx.txId,
          "account_id": account.id,
          "previousFee": originalTx.fee,
          "rbfFee": psbt.fee,
          "rbfTimeStamp": DateTime.now().millisecondsSinceEpoch,
          "previousTxTimeStamp": originalTx.date.millisecondsSinceEpoch,
        });

        String? note = await EnvoyStorage().getTxNote(originalTx.txId);

        if (note != null) {
          //update note with new TxID
          await EnvoyStorage().addTxNote(psbt.txid, note);
        }
        //TODO: Move changeTag to new txID
      } catch (e) {}
      clearSpendState(ProviderScope.containerOf(context));
      _stateMachineController?.findInput<bool>("indeterminate")?.change(false);
      _stateMachineController?.findInput<bool>("happy")?.change(true);
      _stateMachineController?.findInput<bool>("unhappy")?.change(false);
      await Future.delayed(Duration(milliseconds: 300));
      setState(() {
        broadcastProgress = BroadcastProgress.success;
      });
    } catch (e) {
      _stateMachineController?.findInput<bool>("indeterminate")?.change(false);
      _stateMachineController?.findInput<bool>("happy")?.change(false);
      _stateMachineController?.findInput<bool>("unhappy")?.change(true);
      await Future.delayed(Duration(milliseconds: 800));
      EnvoyReport().log("RBF", "${e.toString()}");
      setState(() {
        broadcastProgress = BroadcastProgress.failed;
      });
    }
  }

  Future _setFee(int fee, BuildContext context, bool customFee) async {
    Account? account = ref.read(selectedAccountProvider);
    setState(() {
      _rebuildingTx = true;
    });
    try {
      ref.read(spendFeeProcessing.notifier).state = true;
      ref.read(spendFeeRateProvider.notifier).state = fee;
      final psbt = await account?.wallet
          .getBumpedPSBT(_originalTx.txId, convertToFeeRate(fee));
      setState(() {
        if (psbt != null) _psbt = psbt;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
    } finally {
      setState(() {
        _rebuildingTx = false;
      });
      ref.read(spendFeeProcessing.notifier).state = false;
    }
    if (customFee) {
      /// hide the fee slider
      Navigator.pop(context);
    }
  }

  Widget Background({required Widget child, required BuildContext context}) {
    double _appBarHeight = AppBar().preferredSize.height;
    double _topAppBarOffset = _appBarHeight + 10;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          AppBackground(),
          Positioned(
            top: _topAppBarOffset,
            left: 5,
            bottom: BottomAppBar().height ?? 20 + 8,
            right: 5,
            child: Shield(child: child),
          )
        ],
      ),
    );
  }
}
