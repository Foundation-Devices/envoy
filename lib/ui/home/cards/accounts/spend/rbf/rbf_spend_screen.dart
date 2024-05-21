// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:envoy/business/account.dart';
import 'package:envoy/business/coin_tag.dart';
import 'package:envoy/business/coins.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/background.dart';
import 'package:envoy/ui/components/button.dart';
import 'package:envoy/ui/components/envoy_scaffold.dart';
import 'package:envoy/ui/home/cards/accounts/accounts_state.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coins_state.dart';
import 'package:envoy/ui/home/cards/accounts/detail/transaction/cancel_transaction.dart';
import 'package:envoy/ui/home/cards/accounts/spend/choose_coins_widget.dart';
import 'package:envoy/ui/home/cards/accounts/spend/fee_slider.dart';
import 'package:envoy/ui/home/cards/accounts/spend/psbt_card.dart';
import 'package:envoy/ui/home/cards/accounts/spend/rbf/rbf_button.dart';
import 'package:envoy/ui/home/cards/accounts/spend/spend_fee_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/coin_selection_overlay.dart';
import 'package:envoy/ui/home/cards/accounts/spend/spend_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/staging_tx_details.dart';
import 'package:envoy/ui/home/cards/accounts/spend/transaction_review_card.dart';
import 'package:envoy/ui/routes/accounts_router.dart';
import 'package:envoy/ui/shield.dart';
import 'package:envoy/ui/state/accounts_state.dart';
import 'package:envoy/ui/state/transactions_state.dart';
import 'package:envoy/ui/storage/coins_repository.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/ui/widgets/toast/envoy_toast.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rive/rive.dart' as rive;
import 'package:url_launcher/url_launcher.dart';
import 'package:wallet/exceptions.dart';
import 'package:wallet/generated_bindings.dart' as rust;
import 'package:wallet/wallet.dart';
import 'package:envoy/util/bug_report_helper.dart';

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
  RawTransaction? _rawTransaction;
  Psbt? finalizedPsbt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final rbfSpendState = ref.read(rbfSpendStateProvider);
      if (rbfSpendState == null) {
        return;
      }
      //add the note as staging note
      EnvoyStorage().getTxNote(rbfSpendState.originalTx.txId).then(
          (value) => ref.read(stagingTxNoteProvider.notifier).state = value);
      _checkInputsChanged();
      ref
          .read(spendTransactionProvider.notifier)
          .setAmount(rbfSpendState.originalAmount);
    });
  }

  @override
  Widget build(BuildContext context) {
    final rbfState = ref.watch(rbfSpendStateProvider);
    if (rbfState == null) {
      return const SizedBox();
    }

    Psbt psbt = rbfState.psbt;
    bool showProgress = _broadcastProgress == BroadcastProgress.inProgress ||
        _broadcastProgress == BroadcastProgress.success ||
        _broadcastProgress == BroadcastProgress.failed;

    Account? account = ref.watch(selectedAccountProvider);
    TransactionModel transactionModel = ref.watch(spendTransactionProvider);

    String subHeading =
        (account!.wallet.hot || transactionModel.isPSBTFinalized)
            ? S().coincontrol_tx_detail_subheading
            : S().coincontrol_txDetail_subheading_passport;

    bool canPop =
        !(_broadcastProgress == BroadcastProgress.inProgress) && !_rebuildingTx;
    ProviderContainer scope = ProviderScope.containerOf(context);

    return CoinSelectionOverlay(
      child: Builder(builder: (context) {
        return PopScope(
          canPop: canPop,
          onPopInvoked: (didPop) {
            clearSpendState(scope);
            kPrint("RBF Spend Screen Pop Invoked: $didPop");
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
                                      Opacity(
                                        opacity: _inputsChanged ? 1 : 0,
                                        child: EnvoyButton(
                                          label: S().coincontrol_tx_detail_cta2,
                                          state: ButtonState.defaultState,
                                          onTap: _inputsChanged
                                              ? () => _editCoins(context)
                                              : null,
                                          type: ButtonType.secondary,
                                        ),
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
                                              S().replaceByFee_boost_tx_heading,
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
                              ),
                              SliverToBoxAdapter(
                                child: Consumer(builder: (context, ref, child) {
                                  return TransactionReviewCard(
                                    psbt: psbt,
                                    onTxDetailTap: () {
                                      Navigator.of(context, rootNavigator: true)
                                          .push(PageRouteBuilder(
                                              pageBuilder: (context, animation,
                                                  secondaryAnimation) {
                                                return StagingTxDetails(
                                                  psbt: psbt,
                                                  previousTransaction:
                                                      rbfState.originalTx,
                                                );
                                              },
                                              transitionDuration:
                                                  const Duration(
                                                      milliseconds: 100),
                                              transitionsBuilder: (context,
                                                  animation,
                                                  secondaryAnimation,
                                                  child) {
                                                return FadeTransition(
                                                  opacity: animation,
                                                  child: child,
                                                );
                                              },
                                              opaque: false,
                                              fullscreenDialog: true));
                                    },
                                    psbtFinalized: false,
                                    hideTxDetailsDialog: true,
                                    loading: _rebuildingTx,
                                    feeTitle:
                                        S().replaceByFee_boost_tx_boostFee,
                                    address: rbfState.receiveAddress,
                                    feeChooserWidget: FeeChooser(
                                      onFeeSelect: (int fee,
                                          BuildContext context,
                                          bool customFee) {
                                        _setFee(fee, context, customFee);
                                      },
                                    ),
                                  );
                                }),
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

  rive.StateMachineController? _stateMachineController;

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
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Padding(padding: EdgeInsets.all(18)),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 44),
                  child: _ctaButtons(context),
                ))
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
        ],
      );
    }
  }

  /// if the newly created RBF tx has more inputs
  /// than the original tx, show a warning
  _checkInputsChanged() async {
    Account? account = ref.read(selectedAccountProvider);
    RBFSpendState? rbfSpendState = ref.read(rbfSpendStateProvider);
    if (account == null || rbfSpendState == null) {
      return;
    }
    if (_broadcastProgress != BroadcastProgress.staging) {
      return;
    }
    Psbt psbt = rbfSpendState.psbt;
    Transaction originalTx = rbfSpendState.originalTx;

    final rawTx =
        await ref.read(rawWalletTransactionProvider(psbt.rawTx).future);

    if (rawTx != null &&
        rawTx.inputs.length != originalTx.inputs?.length &&
        mounted) {
      setState(() {
        _inputsChanged = true;
        _rawTransaction = rawTx;
      });
      if (_warningShown) {
        return;
      }
      showEnvoyDialog(
          context: context,
          dialog: Builder(builder: (context) {
            return Container(
              width: MediaQuery.of(context).size.width * 0.75,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(EnvoySpacing.medium2),
                ),
                color: EnvoyColors.textPrimaryInverse,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: EnvoySpacing.medium3,
                    horizontal: EnvoySpacing.medium2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.only(bottom: EnvoySpacing.medium3),
                      child: EnvoyIcon(
                        EnvoyIcons.alert,
                        size: EnvoyIconSize.big,
                        color: EnvoyColors.danger,
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(bottom: EnvoySpacing.medium1),
                      child: Text(
                        S().component_warning,
                        style: EnvoyTypography.subheading,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: EnvoySpacing.xs),
                      child: Text(
                        S().replaceByFee_warning_extraUTXO_overlay_modal_subheading,
                        style: EnvoyTypography.info,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    GestureDetector(
                        onTap: () async {
                          const link =
                              "https://docs.foundation.xyz/en/troubleshooting#why-is-envoy-adding-more-coins-to-my-boost-or-cancel-transaction";
                          launchUrl(Uri.parse(link));
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: EnvoySpacing.medium1),
                          child: Text(
                            S().component_learnMore,
                            style: EnvoyTypography.baseFont.copyWith(
                                color: EnvoyColors.accentPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                          ),
                        )),
                    Padding(
                      padding:
                          const EdgeInsets.only(bottom: EnvoySpacing.medium1),
                      child: EnvoyButton(
                          label: S().component_back,
                          type: ButtonType.secondary,
                          state: ButtonState.defaultState,
                          onTap: () {
                            //hide dialog
                            Navigator.pop(context);
                            //hide RBF screen
                            Navigator.pop(context);
                          }),
                    ),
                    EnvoyButton(
                        label: S().component_continue,
                        type: ButtonType.primary,
                        state: ButtonState.defaultState,
                        onTap: () {
                          _warningShown = true;
                          Navigator.pop(context);
                        }),
                  ],
                ),
              ),
            );
          }));
    } else {
      setState(() {
        _inputsChanged = false;
      });
    }
  }

  _boostTx(BuildContext context) async {
    Account? account = ref.read(selectedAccountProvider);
    RBFSpendState? rbfSpendState = ref.read(rbfSpendStateProvider);
    if (account == null || rbfSpendState == null) {
      return;
    }
    final psbt = rbfSpendState.psbt;

    if (account.wallet.hot) {
      broadcastTx(account, psbt, context);
    } else {
      if (finalizedPsbt != null) {
        broadcastTx(account, psbt, context);
        return;
      }
      await Navigator.of(context, rootNavigator: false).push(MaterialPageRoute(
          builder: (context) => background(
              child: PsbtCard(
                psbt,
                account,
                onSignedPsbtScanned: (psbt) {
                  Navigator.pop(context);
                  if (mounted) {
                    setState(() {
                      finalizedPsbt = psbt;
                    });
                  }
                },
              ),
              context: context)));
    }
  }

  Future broadcastTx(Account account, Psbt psbt, BuildContext context) async {
    final rbfState = ref.read(rbfSpendStateProvider);
    if (rbfState == null) {
      return;
    }
    Psbt psbt = rbfState.psbt;
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
      _stateMachineController?.findInput<bool>("indeterminate")?.change(true);
      _stateMachineController?.findInput<bool>("happy")?.change(false);
      _stateMachineController?.findInput<bool>("unhappy")?.change(false);

      int port = Settings().getPort(account.wallet.network);
      final txid = await account.wallet.broadcastTx(
          Settings().electrumAddress(account.wallet.network), port, psbt.rawTx);
      //wait for BDK to broadcast the transaction
      await Future.delayed(const Duration(seconds: 5));
      //
      try {
        /// get the raw transaction from the database
        final rawTx =
            await ref.read(rawWalletTransactionProvider(psbt.rawTx).future);

        Transaction originalTx = rbfState.originalTx;

        await EnvoyStorage().addRBFBoost(
          psbt.txid,
          RBFState(
            originalTxId: originalTx.txId,
            newTxId: psbt.txid,
            accountId: account.id ?? "",
            newFee: psbt.fee,
            oldFee: originalTx.fee,
            previousTxTimeStamp: originalTx.date.millisecondsSinceEpoch,
            rbfTimeStamp: DateTime.now().millisecondsSinceEpoch,
          ),
        );
        ref.read(rbfBroadCastedTxProvider.notifier).state = [
          ...ref.read(rbfBroadCastedTxProvider),
          originalTx.txId
        ];

        ///Copy existing or updated note to the new transaction id
        final updatedNote = ref.read(stagingTxNoteProvider);
        if (updatedNote != null) {
          await EnvoyStorage().addTxNote(note: updatedNote, key: txid);
        }

        /// get all the tags for searching change output tag in the original transaction
        final tags = ref.read(coinsTagProvider(account.id!));

        CoinTag? tag = ref.read(stagingTxChangeOutPutTagProvider);

        if (tag != null) {
          ///add change tag if its new and if it is not already added to the database
          if (tags.map((e) => e.id).contains(tag.id) == false &&
              tag.untagged == false) {
            await CoinRepository().addCoinTag(tag);
            await Future.delayed(const Duration(milliseconds: 100));
          }
        } else {
          ///if user already selected a change output tag to original transaction then find it and add it to the new transaction
          CoinTag? foundAnExistingChangeTag;

          /// Find any change tag present in the original transaction
          for (var tag in tags) {
            for (var existingId in tag.coinsId) {
              /// check with original tx to see if any change output tag is present
              if (existingId.contains(rbfState.originalTx.txId)) {
                foundAnExistingChangeTag = tag;
              }
            }
          }
          tag = foundAnExistingChangeTag;
        }

        ///move new change output to tags based on user selection or from the original selection
        if (rawTx != null && tag != null) {
          for (var output in rawTx.outputs) {
            if (output.path == TxOutputPath.Internal) {
              final coin = Coin(
                  Utxo(
                      txid: psbt.txid,
                      vout: rawTx.outputs.indexOf(output),
                      value: output.amount),
                  account: account.id!);
              tag.coinsId.add(coin.id);
              await CoinRepository().updateCoinTag(tag);
              // ignore: unused_result
              ref.refresh(accountsProvider);
              await Future.delayed(const Duration(seconds: 1));
              final _ = ref.refresh(coinsTagProvider(account.id!));
            }
          }
        }
      } catch (e) {
        kPrint(e);
      }
      if (context.mounted) {
        clearSpendState(ProviderScope.containerOf(context));
      }

      String receiverAddress = rbfState.receiveAddress;

      final originalTx = rbfState.originalTx;
      await EnvoyStorage().addPendingTx(
        psbt.txid,
        account.id!,
        DateTime.now(),
        TransactionType.pending,
        (originalTx.amount.abs() - originalTx.fee) + psbt.fee,
        psbt.fee,
        receiverAddress,
      );
      _stateMachineController?.findInput<bool>("indeterminate")?.change(false);
      _stateMachineController?.findInput<bool>("happy")?.change(true);
      _stateMachineController?.findInput<bool>("unhappy")?.change(false);
      addHapticFeedback();
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() {
        _broadcastProgress = BroadcastProgress.success;
      });
    } catch (e) {
      EnvoyReport().log("RBF Boost", " $e");
      _stateMachineController?.findInput<bool>("indeterminate")?.change(false);
      _stateMachineController?.findInput<bool>("happy")?.change(false);
      _stateMachineController?.findInput<bool>("unhappy")?.change(true);
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

  Future _setFee(int fee, BuildContext context, bool customFee) async {
    kPrint("Setting fee to $fee");
    Account? account = ref.read(selectedAccountProvider);
    num? existingFeeRate = ref.read(spendFeeRateProvider);
    setState(() {
      _rebuildingTx = true;
    });
    try {
      if (account == null) {
        return;
      }
      ref.read(spendFeeProcessing.notifier).state = true;
      ref.read(spendFeeRateProvider.notifier).state = fee;
      final lockedUtXOs = ref.read(lockedUtxosProvider(account.id!));
      final rbfState = ref.read(rbfSpendStateProvider);
      if (rbfState == null) {
        return;
      }
      final originalTx = rbfState.originalTx;
      final psbt = await account.wallet
          .getBumpedPSBT(originalTx.txId, convertToFeeRate(fee), lockedUtXOs);
      ref.read(rbfSpendStateProvider.notifier).state =
          rbfState.copyWith(psbt: psbt, feeRate: fee, receiveAmount: psbt.fee);
      if (customFee && context.mounted) {
        /// hide the fee slider
        Navigator.of(context, rootNavigator: false).pop();
      }
      _checkInputsChanged();
    } catch (e) {
      String message = "$e";
      if (e is InsufficientFunds) {
        message = S().send_keyboard_amount_insufficient_funds_info;
      }
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
    } finally {
      setState(() {
        _rebuildingTx = false;
      });
      ref.read(spendFeeProcessing.notifier).state = false;
    }
  }

  Widget background({required Widget child, required BuildContext context}) {
    double appBarHeight = AppBar().preferredSize.height;
    double topAppBarOffset = appBarHeight + 10;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const AppBackground(),
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

  //show edit coins screen,
  //if the user changed coin selection, recalculate the fee boundaries and rebuild the boosted tx
  _editCoins(BuildContext context) async {
    final rbfState = ref.read(rbfSpendStateProvider);
    final router = Navigator.of(context, rootNavigator: true);
    if (rbfState == null) {
      return;
    }

    /// The user has is in edit mode and if the psbt
    /// has inputs then use them to populate the coin selection state
    if (_rawTransaction != null) {
      List<String> inputs = _rawTransaction!.inputs
          .map((e) => "${e.previousOutputHash}:${e.previousOutputIndex}")
          .toList();

      ref.read(coinSelectionStateProvider.notifier).reset();
      ref.read(coinSelectionStateProvider.notifier).addAll(inputs);

      ///make a copy of wallet selected coins so that we can backtrack to it
      ref.read(coinSelectionFromWallet.notifier).reset();
      ref.read(coinSelectionFromWallet.notifier).addAll(inputs);
    }

    if (ref.read(selectedAccountProvider) != null) {
      CoinSelectionOverlay.of(context)?.show(SpendOverlayContext.rbfSelection);
    }
    dynamic refresh = await router.push(CupertinoPageRoute(
        builder: (context) => const ChooseCoinsWidget(),
        fullscreenDialog: true));

    if (refresh == true) {
      final account = ref.read(selectedAccountProvider);
      if (account == null) {
        return;
      }
      setState(() {
        _rebuildingTx = true;
      });

      final lockedUtxos = ref.read(lockedUtxosProvider(account.id!));
      final originalTx = rbfState.originalTx;
      final selected = ref.read(coinSelectionStateProvider);
      final coins = ref.read(coinsProvider(account.id!));

      if (selected.isNotEmpty) {
        for (var element in coins) {
          if (!selected.contains(element.id)) {
            lockedUtxos.add(element.utxo);
          }
        }

        try {
          rust.RBFfeeRates rates = await account.wallet
              .getBumpedPSBTMaxFeeRate(originalTx.txId, lockedUtxos);

          if (rates.min_fee_rate > 0) {
            double minFeeRate = rates.min_fee_rate.ceil().toDouble();
            Psbt? psbt = await account.wallet.getBumpedPSBT(
                rbfState.originalTx.txId,
                convertToFeeRate(minFeeRate),
                lockedUtxos);
            final rawTxx = await account.wallet
                .decodeWalletRawTx(psbt.rawTx, account.wallet.network);

            RawTransactionOutput receiveOutPut =
                rawTxx.outputs.firstWhere((element) {
              return (element.path == TxOutputPath.NotMine ||
                  element.path == TxOutputPath.External);
            }, orElse: () => rawTxx.outputs.first);

            RBFSpendState rbfSpendState = RBFSpendState(
                psbt: psbt,
                rbfFeeRates: rates,
                receiveAddress: receiveOutPut.address,
                receiveAmount: 0,
                originalAmount: rbfState.originalTx.amount,
                feeRate: minFeeRate.toInt(),
                originalTx: rbfState.originalTx);

            ref.read(spendAddressProvider.notifier).state =
                receiveOutPut.address;
            ref.read(spendAmountProvider.notifier).state = receiveOutPut.amount;

            int minRate = minFeeRate.toInt();
            int maxRate = rates.max_fee_rate.toInt();
            int fasterFeeRate = minRate + 1;

            if (minRate == maxRate) {
              fasterFeeRate = maxRate;
            } else {
              if (minRate < maxRate) {
                fasterFeeRate = (minRate + 1).clamp(minRate, maxRate);
              }
            }

            ref.read(feeChooserStateProvider.notifier).state = FeeChooserState(
              standardFeeRate: minFeeRate,
              fasterFeeRate: fasterFeeRate,
              minFeeRate: rates.min_fee_rate.ceil().toInt(),
              maxFeeRate: rates.max_fee_rate.floor().toInt(),
            );
            ref.read(rbfSpendStateProvider.notifier).state = rbfSpendState;
            setState(() {
              _rebuildingTx = false;
            });
            return;
          }
        } on InsufficientFunds {
          setState(() {
            _rebuildingTx = false;
          });
          if (context.mounted) {
            EnvoyToast(
              backgroundColor: EnvoyColors.danger,
              replaceExisting: true,
              duration: const Duration(seconds: 4),
              message: S().send_keyboard_amount_insufficient_funds_info,
              icon: const Icon(
                Icons.info_outline,
                color: EnvoyColors.solidWhite,
              ),
            ).show(context);
          }
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
            if (context.mounted) {
              EnvoyToast(
                backgroundColor: EnvoyColors.danger,
                replaceExisting: true,
                duration: const Duration(seconds: 4),
                message: "Error: Unable to construct transaction.",
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
    Account? account = ref.read(selectedAccountProvider);
    if (account != null && !account.wallet.hot) {
      if (finalizedPsbt == null) {
        return S().coincontrol_txDetail_cta1_passport;
      }
    }
    return S().replaceByFee_coindetails_overlay_modal_heading;
  }
}
