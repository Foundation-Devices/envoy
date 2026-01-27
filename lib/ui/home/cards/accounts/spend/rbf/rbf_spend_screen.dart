// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:envoy/account/accounts_manager.dart';
import 'package:envoy/account/envoy_transaction.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/business/uniform_resource.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/background.dart';
import 'package:envoy/ui/components/button.dart';
import 'package:envoy/ui/components/envoy_scaffold.dart';
import 'package:envoy/ui/components/pop_up.dart';
import 'package:envoy/ui/home/cards/accounts/accounts_state.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coins_state.dart';
import 'package:envoy/ui/home/cards/accounts/detail/transaction/cancel_transaction.dart';
import 'package:envoy/ui/home/cards/accounts/spend/choose_coins_widget.dart';
import 'package:envoy/ui/home/cards/accounts/spend/coin_selection_overlay.dart';
import 'package:envoy/ui/home/cards/accounts/spend/fee_slider.dart';
import 'package:envoy/ui/home/cards/accounts/spend/rbf/rbf_button.dart';
import 'package:envoy/ui/home/cards/accounts/spend/spend_fee_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/staging_tx_details.dart';
import 'package:envoy/ui/home/cards/accounts/spend/state/spend_notifier.dart';
import 'package:envoy/ui/home/cards/accounts/spend/state/spend_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/transaction_review_card.dart';
import 'package:envoy/ui/routes/accounts_router.dart';
import 'package:envoy/ui/routes/routes.dart';
import 'package:envoy/ui/shield.dart';
import 'package:envoy/ui/state/transactions_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/ui/widgets/toast/envoy_toast.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:envoy/util/list_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ngwallet/ngwallet.dart';
import 'package:rive/rive.dart' as rive;
import 'package:url_launcher/url_launcher.dart';

final rbfSpendStateProvider = StateProvider<RBFSpendState?>((ref) => null);

class RBFSpendScreen extends ConsumerStatefulWidget {
  const RBFSpendScreen({super.key});

  @override
  ConsumerState createState() => _RBFSpendScreenState();
}

class _RBFSpendScreenState extends ConsumerState<RBFSpendScreen> {
  bool _rebuildingTx = false;
  BroadcastProgress _broadcastProgress = BroadcastProgress.staging;
  bool _warningShown = false;
  bool _inputsChanged = false;

  rive.File? _riveFile;
  rive.RiveWidgetController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initRive();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final rbfSpendState = ref.read(rbfSpendStateProvider);
      if (rbfSpendState == null) {
        return;
      }
      _checkInputsChanged();
    });
  }

  void _initRive() async {
    _riveFile = await rive.File.asset("assets/envoy_loader.riv",
        riveFactory: rive.Factory.rive);
    _controller = rive.RiveWidgetController(
      _riveFile!,
      stateMachineSelector: rive.StateMachineSelector.byName('STM'),
    );

    //TODO: fix rive with databindings.
    // ignore: deprecated_member_use
    _controller?.stateMachine.boolean("indeterminate")?.value = true;

    setState(() => _isInitialized = true);
  }

  void _setAnimState(BroadcastProgress progress) {
    if (_controller?.stateMachine == null) return;

    bool happy = progress == BroadcastProgress.success;
    bool unhappy = progress == BroadcastProgress.failed;
    bool indeterminate = progress == BroadcastProgress.inProgress;

    final stateMachine = _controller!.stateMachine;
    //TODO: fix rive with databindings.
    // ignore: deprecated_member_use
    stateMachine.boolean("indeterminate")?.value = indeterminate;
    //TODO: fix rive with databindings.
    // ignore: deprecated_member_use
    stateMachine.boolean("happy")?.value = happy;
    //TODO: fix rive with databindings.
    // ignore: deprecated_member_use
    stateMachine.boolean("unhappy")?.value = unhappy;
  }

  @override
  Widget build(BuildContext context) {
    final rbfState = ref.watch(rbfSpendStateProvider);
    if (rbfState == null) {
      return const SizedBox();
    }

    bool showProgress = _broadcastProgress == BroadcastProgress.inProgress ||
        _broadcastProgress == BroadcastProgress.success ||
        _broadcastProgress == BroadcastProgress.failed;

    EnvoyAccount? account = ref.watch(selectedAccountProvider);
    TransactionModel transactionModel = ref.watch(spendTransactionProvider);

    String subHeading = (account!.isHot || rbfState.draftTx.isFinalized)
        ? S().coincontrol_tx_detail_subheading
        : S().coincontrol_txDetail_subheading_passport;

    bool showReviewCoin = true;
    //if the tx finalized and if its a passport tx,no need to show review coin
    if (rbfState.draftTx.isFinalized && !account.isHot) {
      showReviewCoin = false;
    }

    bool canPop =
        !(_broadcastProgress == BroadcastProgress.inProgress) && !_rebuildingTx;
    ProviderContainer scope = ProviderScope.containerOf(context);

    return CoinSelectionOverlay(
      child: Builder(builder: (context) {
        return PopScope(
          canPop: canPop,
          onPopInvokedWithResult: (didPop, _) {
            //clear coins selection when exiting RBF screen
            ref.read(coinSelectionFromWallet.notifier).reset();
            ref.read(coinSelectionStateProvider.notifier).reset();
            clearSpendState(scope);
          },
          child: background(
            child: MediaQuery.removePadding(
              removeTop: true,
              removeBottom: true,
              context: context,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                child: PageTransitionSwitcher(
                  transitionBuilder:
                      (child, primaryAnimation, secondaryAnimation) {
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
                          bottom: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(7),
                            ),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                              child: Container(
                                color: Colors.white12,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: EnvoySpacing.xs)
                                      .add(const EdgeInsets.only(
                                          bottom: EnvoySpacing.large1)),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (showReviewCoin)
                                        EnvoyButton(
                                          label: S()
                                              .replaceByFee_boost_reviewCoinSelection,
                                          state: ButtonState.defaultState,
                                          onTap: () => _editCoins(context),
                                          type: ButtonType.secondary,
                                        ),
                                      const Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: EnvoySpacing.small)),
                                      Opacity(
                                        opacity: _rebuildingTx ? 0.3 : 1,
                                        child: EnvoyButton(
                                          label: getButtonText(context),
                                          state: ButtonState.defaultState,
                                          onTap: !_rebuildingTx
                                              ? () => _boostTx(context)
                                              : null,
                                          type: ButtonType.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: EnvoySpacing.small),
                                  child: AppBar(
                                    backgroundColor: Colors.transparent,
                                    automaticallyImplyLeading: false,
                                    titleSpacing:
                                        0, // Don't show the leading button
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        IconButton(
                                          icon: const EnvoyIcon(
                                            EnvoyIcons.chevron_left,
                                            color: EnvoyColors.textPrimary,
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                        Expanded(
                                          child: Text(
                                            S().replaceByFee_boost_tx_heading,
                                            textAlign: TextAlign.center,
                                            style: EnvoyTypography.subheading
                                                .copyWith(
                                                    color: EnvoyColors
                                                        .textPrimary),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: EnvoySpacing.medium2,
                                        )
                                      ],
                                    ),
                                  )),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: EnvoySpacing.small,
                                    horizontal: EnvoySpacing.medium1),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: EnvoySpacing.small),
                                  child: Text(
                                    subHeading,
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
                              Flexible(
                                child: SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 160),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Consumer(
                                            builder: (context, ref, child) {
                                          return TransactionReviewCard(
                                            account: account,
                                            transaction:
                                                rbfState.draftTx.transaction,
                                            amountToSend:
                                                rbfState.originalAmount.abs(),
                                            onTxDetailTap: () {
                                              _showTxDetailsPage(context);
                                            },
                                            canModifyPsbt:
                                                transactionModel.canModify,
                                            loading: transactionModel.loading,
                                            address: rbfState.receiveAddress,
                                            onFeeTap:
                                                (transactionModel.isFinalized &&
                                                        !account.isHot)
                                                    ? null
                                                    : () {
                                                        _showFeeChooser(
                                                          context,
                                                          ref,
                                                          rbfState.draftTx
                                                              .transaction,
                                                        );
                                                      },
                                          );
                                        }),
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
            context: context,
          ),
        );
      }),
    );
  }

  void _showFeeChooser(
    BuildContext context,
    WidgetRef ref,
    BitcoinTransaction transaction,
  ) {
    Navigator.of(context, rootNavigator: true).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return FeeChooser(
            transaction,
            onFeeSelect: (fee, context, bool customFee) {
              _setFee(fee, context, customFee);
              ref.read(userHasChangedFeesProvider.notifier).state = true;
            },
          );
        },
        transitionDuration: const Duration(milliseconds: 100),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        opaque: false,
        fullscreenDialog: true));
  }

  Widget _buildBroadcastProgress() {
    return Padding(
      key: const Key("progress"),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(
                height: 260,
                child: _isInitialized && _controller != null
                    ? rive.RiveWidget(
                        controller: _controller!,
                        fit: rive.Fit.contain,
                      )
                    : const SizedBox(),
              ),
            ),
            const SliverPadding(padding: EdgeInsets.all(28)),
            SliverToBoxAdapter(
              child: Builder(
                builder: (context) {
                  String title = S().replaceByFee_boost_confirm_heading;
                  String subTitle =
                      S().stalls_before_sending_tx_scanning_subheading;
                  if (_broadcastProgress != BroadcastProgress.inProgress) {
                    if (_broadcastProgress == BroadcastProgress.success) {
                      title = S().replaceByFee_boost_success_header;
                      subTitle = S()
                          .stalls_before_sending_tx_scanning_broadcasting_success_subheading;
                    } else {
                      title = S().replaceByFee_boost_fail_header;
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
                        Text(
                          subTitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 44),
                child: _ctaButtons(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ctaButtons(BuildContext context) {
    if (_broadcastProgress == BroadcastProgress.inProgress ||
        _broadcastProgress == BroadcastProgress.staging) {
      return const SizedBox();
    }
    if (_broadcastProgress == BroadcastProgress.success) {
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
              final providerScope = ProviderScope.containerOf(context);
              clearSpendState(providerScope);
              providerScope.read(coinSelectionStateProvider.notifier).reset();
              GoRouter.of(context).go(ROUTE_ACCOUNT_DETAIL);
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
            label: S().coincontrol_txDetail_ReviewTransaction,
            onTap: () async {
              setState(() {
                _broadcastProgress = BroadcastProgress.staging;
              });
            },
            type: ButtonType.secondary,
            state: ButtonState.defaultState,
          ),
          const Padding(padding: EdgeInsets.all(6)),
          EnvoyButton(
            label: S().component_tryAgain,
            type: ButtonType.primary,
            onTap: () {
              _boostTx(context);
            },
          ),
        ],
      );
    }
  }

  /// if the newly created RBF tx has more inputs
  /// than the original tx, show a warning
  Future<void> _checkInputsChanged() async {
    EnvoyAccount? account = ref.read(selectedAccountProvider);
    RBFSpendState? rbfSpendState = ref.read(rbfSpendStateProvider);
    if (account == null || rbfSpendState == null) {
      return;
    }
    if (_broadcastProgress != BroadcastProgress.staging) {
      return;
    }

    BitcoinTransaction originalTx = rbfSpendState.originalTx;
    BitcoinTransaction draftRbfTx = rbfSpendState.draftTx.transaction;
    List<Input> originalInputs = originalTx.inputs;
    List<Input> draftInputs = draftRbfTx.inputs;
    ref.read(stagingTxNoteProvider.notifier).state = originalTx.note;
    if (originalInputs.length != draftInputs.length) {
      setState(() {
        _inputsChanged = true;
        _rebuildingTx = false;
      });
      if (_warningShown) {
        return;
      }
      if (_inputsChanged) {
        showEnvoyDialog(
            context: context,
            dialog: Builder(builder: (context) {
              return EnvoyPopUp(
                icon: EnvoyIcons.alert,
                typeOfMessage: PopUpState.warning,
                title: S().component_warning,
                showCloseButton: false,
                content:
                    S().replaceByFee_warning_extraUTXO_overlay_modal_subheading,
                onLearnMore: () {
                  launchUrl(Uri.parse(
                      "https://docs.foundation.xyz/troubleshooting/envoy/#boosting-or-canceling-transactions"));
                },
                primaryButtonLabel: S().component_continue,
                onPrimaryButtonTap: (context) {
                  _warningShown = true;
                  Navigator.pop(context);
                },
                secondaryButtonLabel: S().component_back,
                onSecondaryButtonTap: (context) {
                  //hide dialog
                  Navigator.pop(context);
                  //hide RBF screen
                  Navigator.pop(context);
                },
              );
            }));
      }
    }
  }

  Future<void> _boostTx(BuildContext context) async {
    EnvoyAccount? account = ref.read(selectedAccountProvider);
    RBFSpendState? rbfSpendState = ref.read(rbfSpendStateProvider);
    if (account == null || rbfSpendState == null) {
      return;
    }

    if (account.isHot) {
      broadcastTx(account, rbfSpendState.draftTx, context);
    } else {
      if (rbfSpendState.draftTx.isFinalized) {
        broadcastTx(account, rbfSpendState.draftTx, context);
        return;
      }
      _handleQRExchange(rbfSpendState, context);
    }
  }

  void _handleQRExchange(RBFSpendState rbfState, BuildContext context) async {
    bool received = false;
    final cryptoPsbt = await GoRouter.of(context)
        .pushNamed(PSBT_QR_EXCHANGE_STANDALONE, extra: rbfState.draftTx);
    if (cryptoPsbt is CryptoPsbt && received == false) {
      final preparedTx = await EnvoyAccountHandler.decodePsbt(
          draftTransaction: rbfState.draftTx, psbt: cryptoPsbt.decoded);
      await Future.delayed(const Duration(milliseconds: 50));
      ref.read(rbfSpendStateProvider.notifier).state = rbfState.copyWith(
          feeRate: preparedTx.transaction.feeRate.toInt(),
          preparedTx: preparedTx);
      received = true;
    }
  }

  Future broadcastTx(EnvoyAccount account, DraftTransaction draft,
      BuildContext context) async {
    final rbfState = ref.read(rbfSpendStateProvider);
    final stagingTxNote = ref.read(stagingTxNoteProvider);
    final changeOutputTag = ref.read(stagingTxChangeOutPutTagProvider);
    final handler = account.handler;
    if (rbfState == null || handler == null) {
      return;
    }
    try {
      setState(() {
        _broadcastProgress = BroadcastProgress.inProgress;
      });
      if (ref
              .read(getTransactionProvider(rbfState.originalTx.txId))
              ?.isConfirmed ==
          true) {
        setState(() {
          _broadcastProgress = BroadcastProgress.staging;
        });
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
      }
      _setAnimState(BroadcastProgress.inProgress);

      final server = Settings().electrumAddress(account.network);
      int? port = Settings().getTorPort(account.network, server);

      //update draft transaction with latest note and change output tag
      final draftTransaction = DraftTransaction(
          transaction: draft.transaction.copyWith(
            note: stagingTxNote,
          ),
          psbt: draft.psbt,
          inputTags: draft.inputTags,
          isFinalized: draft.isFinalized,
          changeOutPutTag: changeOutputTag);

      /// get the raw transaction from the database
      await EnvoyAccountHandler.broadcast(
        draftTransaction: draftTransaction,
        electrumServer: server,
        torPort: port,
      );
      await handler.updateBroadcastState(draftTransaction: draftTransaction);

      BitcoinTransaction originalTx = rbfState.originalTx;
      BitcoinTransaction bumpedTx = rbfState.getBumpedTransaction;
      await EnvoyStorage().addRBFBoost(
        bumpedTx.txId,
        RBFState(
          originalTxId: originalTx.txId,
          newTxId: bumpedTx.txId,
          accountId: account.id,
          newFee: bumpedTx.fee.toInt(),
          oldFee: originalTx.fee.toInt(),
          previousTxTimeStamp: originalTx.date?.toInt() ?? 0,
          rbfTimeStamp: DateTime.now().millisecondsSinceEpoch,
        ),
      );
      ref.read(rbfBroadCastedTxProvider.notifier).state = [
        ...ref.read(rbfBroadCastedTxProvider),
        originalTx.txId
      ];
      await Future.delayed(const Duration(milliseconds: 200));
      final _ = ref.refresh(rbfTxStateProvider(bumpedTx.txId));
      await Future.delayed(const Duration(milliseconds: 100));
      if (context.mounted) {
        clearSpendState(ProviderScope.containerOf(context));
      }
      _setAnimState(BroadcastProgress.success);
      addHapticFeedback();
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() {
        _broadcastProgress = BroadcastProgress.success;
      });
    } catch (e) {
      EnvoyReport().log("RBF Boost", " $e");
      _setAnimState(BroadcastProgress.failed);
      await Future.delayed(const Duration(milliseconds: 800));
      setState(() {
        _broadcastProgress = BroadcastProgress.failed;
      });
    }
  }

  bool hapticCalled = false;

  void addHapticFeedback() async {
    if (hapticCalled) return;
    hapticCalled = true;
    await Future.delayed(const Duration(milliseconds: 700));
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    HapticFeedback.mediumImpact();
  }

  Future _setFee(double fee, BuildContext context, bool customFee) async {
    EnvoyAccount? account = ref.read(selectedAccountProvider);
    num? existingFeeRate = ref.read(spendFeeRateProvider);
    setState(() {
      _rebuildingTx = false;
    });
    try {
      if (account == null) {
        return;
      }
      ref.read(spendFeeProcessing.notifier).state = true;
      ref.read(spendFeeRateProvider.notifier).state = fee;
      final rbfState = ref.read(rbfSpendStateProvider);
      final selectedOutputs =
          ref.read(getSelectedCoinsProvider(account.id)).toList();
      if (rbfState == null) {
        return;
      }
      final originalTx = rbfState.originalTx;

      final transaction = await account.handler?.composeRbfPsbt(
          selectedOutputs: selectedOutputs,
          feeRate: BigInt.from(fee),
          bitcoinTransaction: originalTx);

      if (transaction == null) {
        return;
      }

      ref.read(rbfSpendStateProvider.notifier).state = rbfState.copyWith(
          feeRate: transaction.transaction.feeRate.toInt(),
          preparedTx: transaction);

      if (customFee && context.mounted) {
        /// hide the fee slider
        Navigator.of(context, rootNavigator: false).pop();
      }
      _checkInputsChanged();
    } catch (e, stack) {
      //TODO: handle error
      String message = "$e";
      message = S().send_keyboard_amount_insufficient_funds_info;
      if (context.mounted) {
        EnvoyToast(
          replaceExisting: true,
          duration: const Duration(seconds: 4),
          message: message,
          icon: const Icon(
            Icons.info_outline,
            color: EnvoyColors.solidWhite,
          ),
        ).show(context);
      }
      if (existingFeeRate != null) {
        ref.read(spendFeeRateProvider.notifier).state = existingFeeRate;
      }
      EnvoyReport().log("RBF", "Rbf set-fee failed : ${stack.toString()}");
    } finally {
      if (context.mounted) {
        setState(() {
          _rebuildingTx = false;
        });
        ref.read(spendFeeProcessing.notifier).state = false;
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

  void _updateMeta() async {
    String? note = ref.read(stagingTxNoteProvider);
    final rbfState = ref.read(rbfSpendStateProvider);
    String? changeOutputTag = ref.read(stagingTxChangeOutPutTagProvider);
    String? existingTag = rbfState?.draftTx.changeOutPutTag;
    if (existingTag != null && existingTag.isNotEmpty) {
      changeOutputTag = rbfState?.draftTx.changeOutPutTag;
    }
    EnvoyAccount? account = ref.read(selectedAccountProvider);
    if (account == null) {
      return;
    }
    final selectedOutputs =
        ref.read(getSelectedCoinsProvider(account.id)).toList();
    if (rbfState == null) {
      return;
    }
    try {
      final transaction = await account.handler?.composeRbfPsbt(
          selectedOutputs: selectedOutputs,
          feeRate: BigInt.from(rbfState.feeRate),
          note: note,
          tag: changeOutputTag,
          bitcoinTransaction: rbfState.originalTx);
      if (transaction == null) {
        return;
      }
      ref.read(rbfSpendStateProvider.notifier).state = rbfState.copyWith(
          feeRate: transaction.transaction.feeRate.toInt(),
          preparedTx: transaction);
    } catch (e) {
      EnvoyReport().log("RBF:Unable to update Note/Tag", " $e");
    }
  }

  //show edit coins screen,
  //if the user changed coin selection, recalculate the fee boundaries and rebuild the boosted tx
  Future<void> _editCoins(BuildContext context) async {
    // nešto ovde
    final selectedAccount = ref.read(selectedAccountProvider);

    final account = ref.read(selectedAccountProvider);
    final handler = account?.handler;
    if (account == null || handler == null) {
      return;
    }
    if (selectedAccount == null) {
      return;
    }
    final rbfState = ref.read(rbfSpendStateProvider);
    if (rbfState == null) {
      return;
    }

    /// The user has is in edit mode and if the psbt
    /// has inputs then use them to populate the coin selection state
    List<String> inputs = rbfState.draftTx.transaction.inputs
        .map((e) => "${e.txId}:${e.vout}")
        .toList();

    //any output that are part of original tx will not be available RBF selection
    Output? changeOutput = rbfState.originalTx.outputs.firstWhereOrNull(
      (element) => element.keychain == KeyChain.internal,
    );

    ref.read(rbfChangeOutputProvider.notifier).state = changeOutput;
    ref.read(coinSelectionStateProvider.notifier).reset();
    ref.read(coinSelectionStateProvider.notifier).addAll(inputs);

    ///make a copy of wallet selected coins so that we can backtrack to
    ///this point if the user cancels/failed
    ref.read(coinSelectionFromWallet.notifier).reset();
    ref.read(coinSelectionFromWallet.notifier).addAll(inputs);

    ref.read(spendAmountProvider.notifier).state =
        rbfState.draftTx.transaction.amount;

    dynamic newSelection = Navigator.of(context, rootNavigator: true).push(
        PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              return ChooseCoinsWidget();
            },
            transitionDuration: const Duration(milliseconds: 100),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            opaque: false,
            fullscreenDialog: true));

    ref.read(rbfChangeOutputProvider.notifier).state = null;
    ref.read(coinSelectionStateProvider.notifier).reset();

    if (newSelection != null && newSelection is Set<String>) {
      final account = ref.read(selectedAccountProvider);
      if (account == null) {
        return;
      }
      setState(() {
        _rebuildingTx = true;
      });

      List<Output> outputs = ref.read(outputsProvider(selectedAccount.id));
      final selectedOutputs = outputs
          .where((element) => newSelection.contains(element.getId()))
          .toList();

      if (selectedOutputs.isNotEmpty) {
        try {
          BitcoinTransaction originalTx = rbfState.originalTx;
          TransactionFeeResult result = await handler.getMaxBumpFeeRates(
              selectedOutputs: selectedOutputs, bitcoinTransaction: originalTx);

          setState(() {
            _rebuildingTx = false;
          });
          int minRate = result.minFeeRate.toInt();
          int maxRate = result.maxFeeRate.toInt();
          int fasterFeeRate = minRate + 1;
          kPrint("RBF: minRate: $minRate, maxRate: $maxRate");
          if (minRate == maxRate) {
            fasterFeeRate = maxRate;
          } else {
            if (minRate < maxRate) {
              fasterFeeRate = (minRate + 1).clamp(minRate, maxRate);
            }
          }
          ref.read(feeChooserStateProvider.notifier).state = FeeChooserState(
            standardFeeRate: minRate,
            fasterFeeRate: fasterFeeRate,
            minFeeRate: minRate,
            maxFeeRate: maxRate,
          );
          ref.read(rbfSpendStateProvider.notifier).state = RBFSpendState(
            receiveAddress: result.draftTransaction.transaction.address,
            receiveAmount: originalTx.amount,
            feeRate: minRate,
            originalTx: originalTx,
            originalAmount: originalTx.amount,
            draftTx: result.draftTransaction,
          );
        } catch (e) {
          setState(() {
            _rebuildingTx = false;
          });
          final originalTx = rbfState.originalTx;
          if (ref.read(getTransactionProvider(originalTx.txId))?.isConfirmed ==
                  true &&
              context.mounted) {
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
            EnvoyReport().log("RBF", "Coin Selection Failure : $e");
            if (context.mounted) {
              EnvoyToast(
                backgroundColor: EnvoyColors.danger,
                replaceExisting: true,
                duration: const Duration(seconds: 4),
                message: e.toString().replaceAll(":Exception", ""),
                overflow: TextOverflow.visible,
                // TODO: Figma
                icon: const Icon(
                  Icons.info_outline,
                  color: EnvoyColors.solidWhite,
                ),
              ).show(context);
            }
          }
        }
      }
    }
  }

  String getButtonText(BuildContext context) {
    EnvoyAccount? account = ref.read(selectedAccountProvider);
    RBFSpendState? rbfSpendState = ref.read(rbfSpendStateProvider);
    if (account != null && !account.isHot && rbfSpendState != null) {
      if (!rbfSpendState.draftTx.isFinalized) {
        return S().coincontrol_txDetail_cta1_passport;
      } else {
        return S().replaceByFee_coindetails_overlay_modal_heading;
      }
    }
    return S().replaceByFee_coindetails_overlay_modal_heading;
  }

  void _showTxDetailsPage(BuildContext context) {
    final rbfState = ref.read(rbfSpendStateProvider);
    if (rbfState == null) {
      return;
    }
    Navigator.of(context, rootNavigator: true).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return StagingTxDetails(
            isRBFSpend: true,
            draftTransaction: rbfState.draftTx,
            previousTransaction: rbfState.originalTx,
            onTagUpdate: () {
              _updateMeta();
            },
            onTxNoteUpdated: () {
              _updateMeta();
            },
          );
        },
        transitionDuration: const Duration(milliseconds: 100),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        opaque: false,
        fullscreenDialog: true));
  }

  @override
  void dispose() {
    _controller?.dispose();
    _riveFile?.dispose();
    super.dispose();
  }
}
