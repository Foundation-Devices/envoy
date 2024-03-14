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
import 'package:envoy/ui/home/cards/accounts/spend/fee_slider.dart';
import 'package:envoy/ui/home/cards/accounts/spend/psbt_card.dart';
import 'package:envoy/ui/home/cards/accounts/spend/rbf/rbf_button.dart';
import 'package:envoy/ui/home/cards/accounts/spend/spend_fee_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/spend_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/staging_tx_details.dart';
import 'package:envoy/ui/home/cards/accounts/spend/transaction_review_card.dart';
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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart' as rive;
import 'package:url_launcher/url_launcher.dart';
import 'package:wallet/exceptions.dart';
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
  bool warningShown = false;
  late Transaction _originalTx;

  @override
  void initState() {
    _psbt = widget.rbfSpendState.psbt;
    _originalTx = widget.rbfSpendState.originalTx;
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      //add the note as staging note
      EnvoyStorage().getTxNote(widget.rbfSpendState.originalTx.txId).then(
          (value) => ref.read(stagingTxNoteProvider.notifier).state = value);
      _checkInputsChanged();
      ref
          .read(spendTransactionProvider.notifier)
          .setAmount(widget.rbfSpendState.originalAmount);
    });
  }

  @override
  Widget build(BuildContext context) {
    Psbt psbt = _psbt;
    bool showProgress = broadcastProgress == BroadcastProgress.inProgress ||
        broadcastProgress == BroadcastProgress.success ||
        broadcastProgress == BroadcastProgress.failed;

    Account? account = ref.watch(selectedAccountProvider);
    TransactionModel transactionModel = ref.watch(spendTransactionProvider);

    String subHeading =
        (account!.wallet.hot || transactionModel.isPSBTFinalized)
            ? S().coincontrol_tx_detail_subheading
            : S().coincontrol_txDetail_subheading_passport;

    bool canPop =
        !(broadcastProgress == BroadcastProgress.inProgress) && !_rebuildingTx;
    ProviderContainer scope = ProviderScope.containerOf(context);

    return PopScope(
      canPop: canPop,
      onPopInvoked: (didPop) {
        ref.read(stagingTxNoteProvider.notifier).state = null;
        clearSpendState(scope);
      },
      child: background(
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
                                      horizontal: 12, vertical: EnvoySpacing.xs)
                                  .add(const EdgeInsets.only(
                                      bottom: EnvoySpacing.large1)),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Opacity(
                                    opacity: _rebuildingTx ? 0.3 : 1,
                                    child: EnvoyButton(
                                      label: S()
                                          .replaceByFee_coindetails_overlay_modal_heading,
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
                                              psbt: _psbt,
                                              previousTransaction: widget
                                                  .rbfSpendState.originalTx,
                                            );
                                          },
                                          transitionDuration:
                                              const Duration(milliseconds: 100),
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
                    ),
            ),
          ),
        ),
        context: context,
      ),
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
                  if (broadcastProgress != BroadcastProgress.inProgress) {
                    if (broadcastProgress == BroadcastProgress.success) {
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
              Navigator.pop(context);
              Navigator.pop(context);
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
                broadcastProgress = BroadcastProgress.staging;
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
    if (warningShown) {
      return;
    }

    Account? account = ref.read(selectedAccountProvider);
    if (account == null) {
      return;
    }

    final rawTx =
        await ref.read(rawWalletTransactionProvider(_psbt.rawTx).future);

    if (rawTx != null &&
        rawTx.inputs.length != _originalTx.inputs?.length &&
        mounted) {
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
                              "https://docs.foundationdevices.com/en/troubleshooting#why-is-envoy-adding-more-coins-to-my-boost-or-cancel-transaction";
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
                          warningShown = true;
                          Navigator.pop(context);
                        }),
                  ],
                ),
              ),
            );
          }));
    }
  }

  _boostTx(BuildContext context) async {
    Account? account = ref.read(selectedAccountProvider);
    if (account == null) {
      return;
    }
    if (account.wallet.hot) {
      broadcastTx(account, _psbt, context);
    } else {
      await Navigator.of(context, rootNavigator: false).push(MaterialPageRoute(
          builder: (context) => background(
              child: PsbtCard(
                _psbt,
                account,
                onSignedPsbtScanned: (psbt) {
                  Navigator.pop(context);
                  broadcastTx(account, psbt, context);
                },
              ),
              context: context)));
    }
  }

  Future broadcastTx(Account account, Psbt psbt, BuildContext context) async {
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

      try {
        /// get the raw transaction from the database
        final rawTx =
            await ref.read(rawWalletTransactionProvider(_psbt.rawTx).future);

        Transaction originalTx = widget.rbfSpendState.originalTx;

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
          await EnvoyStorage().addTxNote(updatedNote, txid);
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
              if (existingId.contains(widget.rbfSpendState.originalTx.txId)) {
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

      String receiverAddress = widget.rbfSpendState.receiveAddress;

      await EnvoyStorage().addPendingTx(
        psbt.txid,
        account.id!,
        DateTime.now(),
        TransactionType.pending,
        (_originalTx.amount.abs() - _originalTx.fee) + psbt.fee,
        psbt.fee,
        receiverAddress,
      );
      _stateMachineController?.findInput<bool>("indeterminate")?.change(false);
      _stateMachineController?.findInput<bool>("happy")?.change(true);
      _stateMachineController?.findInput<bool>("unhappy")?.change(false);
      addHapticFeedback();
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() {
        broadcastProgress = BroadcastProgress.success;
      });
    } catch (e) {
      _stateMachineController?.findInput<bool>("indeterminate")?.change(false);
      _stateMachineController?.findInput<bool>("happy")?.change(false);
      _stateMachineController?.findInput<bool>("unhappy")?.change(true);
      await Future.delayed(const Duration(milliseconds: 800));
      setState(() {
        broadcastProgress = BroadcastProgress.failed;
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
      final psbt = await account.wallet
          .getBumpedPSBT(_originalTx.txId, convertToFeeRate(fee), lockedUtXOs);
      setState(() {
        _psbt = psbt;
      });
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
}
