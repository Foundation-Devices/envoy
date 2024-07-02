// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:envoy/business/account.dart';
import 'package:envoy/business/coin_tag.dart';
import 'package:envoy/business/coins.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/envoy_checkbox.dart';
import 'package:envoy/ui/components/envoy_scaffold.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/home/cards/accounts/accounts_state.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coins_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/choose_coins_widget.dart';
import 'package:envoy/ui/home/cards/accounts/spend/fee_slider.dart';
import 'package:envoy/ui/home/cards/accounts/spend/psbt_card.dart';
import 'package:envoy/ui/home/cards/accounts/spend/spend_fee_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/coin_selection_overlay.dart';
import 'package:envoy/ui/home/cards/accounts/spend/spend_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/staging_tx_details.dart';
import 'package:envoy/ui/home/cards/accounts/spend/staging_tx_tagging.dart';
import 'package:envoy/ui/home/cards/accounts/spend/transaction_review_card.dart';
import 'package:envoy/ui/routes/accounts_router.dart';
import 'package:envoy/ui/state/home_page_state.dart';
import 'package:envoy/ui/state/transactions_note_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:envoy/util/list_utils.dart';
import 'package:envoy/util/tuple.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rive/rive.dart' as rive;
import 'package:wallet/wallet.dart';

//ignore: must_be_immutable
class TxReview extends ConsumerStatefulWidget {
  TxReview() : super(key: UniqueKey());

  @override
  ConsumerState<TxReview> createState() => _TxReviewState();
}

class _TxReviewState extends ConsumerState<TxReview> {
  //TODO: disable note
  // String _txNote = "";

  @override
  Widget build(BuildContext context) {
    Account? account = ref.watch(selectedAccountProvider);
    TransactionModel transactionModel = ref.watch(spendTransactionProvider);

    if (account == null || transactionModel.psbt == null) {
      return MediaQuery.removePadding(
        removeTop: true,
        context: context,
        child: Scaffold(
            appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: EnvoyColors.textPrimary,
                  ),
                  onPressed: () {
                    GoRouter.of(context).pop();
                  },
                )),
            body: const Center(
              child: Text("Unable to build transaction"), //TODO: figma
            )),
      );
    }
    return PageTransitionSwitcher(
      reverse: transactionModel.broadcastProgress == BroadcastProgress.staging,
      transitionBuilder: (child, animation, secondaryAnimation) {
        return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.vertical,
          child: child,
        );
      },
      child: transactionModel.broadcastProgress == BroadcastProgress.staging
          ? Padding(
              key: const Key("review"),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              child: TransactionReviewScreen(
                onBroadcast: () async {
                  BuildContext rootContext = context;
                  List<Tuple<CoinTag, Coin>>? spendingTagSet =
                      ref.read(spendInputTagsProvider);
                  List<CoinTag> spendingTags = spendingTagSet
                          ?.map((e) => e.item1)
                          .toList()
                          .unique((element) => element.id)
                          .toList() ??
                      [];

                  ///if the user is spending from a single tag and the change output is needs to be tagged to the same tag
                  if (spendingTags.length == 1 &&
                      ref.read(stagingTxChangeOutPutTagProvider) == null) {
                    ref.read(stagingTxChangeOutPutTagProvider.notifier).state =
                        spendingTags[0];
                  }

                  CoinTag? coinTag = ref.read(stagingTxChangeOutPutTagProvider);

                  ///if the the change output is not tagged and there are more input from different tags
                  final tagInputs = ref.read(spendInputTagsProvider);

                  /// if the change output is null or untagged we need to show the tag selection dialog
                  final userChosenTag = coinTag?.untagged == false;

                  final hasManyTagsAsInput = (tagInputs ?? [])
                          .map((e) => e.item1)
                          .map((e) => e.id)
                          .toSet()
                          .length >
                      1;

                  final userNote = ref.read(stagingTxNoteProvider);
                  final dismissedNoteDialog = await EnvoyStorage()
                      .checkPromptDismissed(DismissiblePrompt.addTxNoteWarning);
                  if ((userNote == null || userNote.isEmpty) &&
                      !dismissedNoteDialog &&
                      !ref.read(spendTransactionProvider).isPSBTFinalized &&
                      context.mounted) {
                    await showEnvoyDialog(
                        context: context,
                        useRootNavigator: true,
                        dialog: TxReviewNoteDialog(
                          onAdd: (note) {
                            Navigator.pop(context);
                          },
                          txId: "UpcomingTx",
                          noteSubTitle: S()
                              .stalls_before_sending_tx_add_note_modal_subheading,
                          noteTitle: S().add_note_modal_heading,
                          value: ref.read(stagingTxNoteProvider),
                        ),
                        alignment: const Alignment(0.0, -0.5));

                    ///wait for the dialog to pop
                    await Future.delayed(const Duration(milliseconds: 200));
                  }

                  Tuple<String, int>? changeOutPut =
                      ref.read(changeOutputProvider);
                  bool hasChangeOutPutPresent =
                      changeOutPut != null && changeOutPut.item2 != 0;

                  ///then show the tag selection dialog
                  if (!userChosenTag &&
                      tagInputs != null &&
                      hasManyTagsAsInput &&
                      hasChangeOutPutPresent &&
                      context.mounted) {
                    await showTagDialog(
                        context, account, rootContext, transactionModel);
                  } else {
                    if (account.wallet.hot ||
                        ref.read(spendTransactionProvider).isPSBTFinalized) {
                      if (context.mounted) {
                        broadcastTx(context);
                      }
                    } else {
                      if (rootContext.mounted) {
                        final psbt = await Navigator.of(rootContext,
                                rootNavigator: false)
                            .push(MaterialPageRoute(
                                builder: (context) => Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: PsbtCard(
                                          transactionModel.psbt!, account),
                                    )));
                        ref
                            .read(spendTransactionProvider.notifier)
                            .updateWithFinalPSBT(psbt);
                        await Future.delayed(const Duration(milliseconds: 200));
                      }
                    }
                  }
                },
              ),
            )
          : _buildBroadcastProgress(),
    );
  }

  Future<void> showTagDialog(BuildContext context, Account account,
      BuildContext rootContext, TransactionModel transactionModel) async {
    await showEnvoyDialog(
        useRootNavigator: true,
        context: context,
        builder: Builder(
          builder: (context) => ChooseTagForStagingTx(
            accountId: account.id!,
            onEditTransaction: () {
              Navigator.pop(context);
              editTransaction(context, ref);
            },
            hasMultipleTagsInput: true,
            onTagUpdate: () async {
              Navigator.pop(context);
              if (account.wallet.hot ||
                  ref.read(spendTransactionProvider).isPSBTFinalized) {
                broadcastTx(context);
              } else {
                final psbt = await Navigator.of(rootContext,
                        rootNavigator: false)
                    .push(MaterialPageRoute(
                        builder: (context) => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: PsbtCard(transactionModel.psbt!, account),
                            )));
                ref
                    .read(spendTransactionProvider.notifier)
                    .updateWithFinalPSBT(psbt);
                await Future.delayed(const Duration(milliseconds: 200));
              }
            },
          ),
        ),
        alignment: const Alignment(0.0, -.6));
  }

  rive.StateMachineController? _stateMachineController;

  Widget _buildBroadcastProgress() {
    final spendState = ref.watch(spendTransactionProvider);
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
                    broadcastTx(context);
                  },
                ),
              ),
            ),
            const SliverPadding(padding: EdgeInsets.all(28)),
            SliverToBoxAdapter(
              child: Builder(
                builder: (context) {
                  String title = S().stalls_before_sending_tx_scanning_heading;
                  String subTitle =
                      S().stalls_before_sending_tx_scanning_subheading;
                  if (spendState.broadcastProgress !=
                      BroadcastProgress.inProgress) {
                    if (spendState.broadcastProgress ==
                        BroadcastProgress.success) {
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
    final spendState = ref.watch(spendTransactionProvider);
    if (spendState.broadcastProgress == BroadcastProgress.inProgress) {
      return const SizedBox();
    }
    if (spendState.broadcastProgress == BroadcastProgress.success) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        children: [
          EnvoyButton(
            S().component_continue,
            onTap: () async {
              final providerScope = ProviderScope.containerOf(context);
              clearSpendState(providerScope);
              providerScope.read(coinSelectionStateProvider.notifier).reset();
              GoRouter.of(context).go(ROUTE_ACCOUNT_DETAIL);
            },
          ),
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        EnvoyButton(
          enabled: spendState.broadcastProgress != BroadcastProgress.inProgress,
          S().component_tryAgain,
          type: EnvoyButtonTypes.secondary,
          onTap: () {
            broadcastTx(context);
          },
        ),
        const Padding(padding: EdgeInsets.all(6)),
        EnvoyButton(
          enabled: spendState.broadcastProgress != BroadcastProgress.inProgress,
          S().coincontrol_txDetail_ReviewTransaction,
          onTap: () {
            ref.read(spendTransactionProvider.notifier).resetBroadcastState();
          },
        ),
      ],
    );
  }

  void broadcastTx(BuildContext context) async {
    Account? account = ref.read(selectedAccountProvider);
    TransactionModel transactionModel = ref.read(spendTransactionProvider);

    if (account == null || transactionModel.psbt == null) {
      return;
    }

    try {
      _stateMachineController?.findInput<bool>("indeterminate")?.change(true);
      _stateMachineController?.findInput<bool>("happy")?.change(false);
      _stateMachineController?.findInput<bool>("unhappy")?.change(false);
      await ref
          .read(spendTransactionProvider.notifier)
          .broadcast(ProviderScope.containerOf(context));
      _stateMachineController?.findInput<bool>("indeterminate")?.change(false);
      _stateMachineController?.findInput<bool>("happy")?.change(true);
      _stateMachineController?.findInput<bool>("unhappy")?.change(false);
      addHapticFeedback();
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e, s) {
      kPrint(e, stackTrace: s);
      _stateMachineController?.findInput<bool>("indeterminate")?.change(false);
      _stateMachineController?.findInput<bool>("happy")?.change(false);
      _stateMachineController?.findInput<bool>("unhappy")?.change(true);
      await Future.delayed(const Duration(milliseconds: 800));
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
}

class TransactionDetailPreview extends ConsumerStatefulWidget {
  const TransactionDetailPreview({super.key});

  @override
  ConsumerState createState() => _TransactionDetailPreviewState();
}

class _TransactionDetailPreviewState
    extends ConsumerState<TransactionDetailPreview> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class TransactionReviewScreen extends ConsumerStatefulWidget {
  final Function onBroadcast;

  const TransactionReviewScreen({super.key, required this.onBroadcast});

  @override
  ConsumerState createState() => _TransactionReviewScreenState();
}

class _TransactionReviewScreenState
    extends ConsumerState<TransactionReviewScreen> {
  @override
  Widget build(BuildContext context) {
    Account? account = ref.watch(selectedAccountProvider);
    TransactionModel transactionModel = ref.watch(spendTransactionProvider);
    String address = ref.watch(spendAddressProvider);

    final coinSelectionChanged = ref.watch(coinSelectionChangedProvider);
    final userSelectedCoinsThisSession =
        ref.watch(userSelectedCoinsThisSessionProvider);
    final transactionInputsChanged =
        ref.watch(transactionInputsChangedProvider);
    final userHasChangedFees = ref.watch(userHasChangedFeesProvider);

    final showFeeChangeNotice = userSelectedCoinsThisSession &&
        coinSelectionChanged &&
        transactionInputsChanged &&
        userHasChangedFees;

    if (account == null || transactionModel.psbt == null) {
      return const Center(
        child: Text("Unable to build transaction"), //TODO: figma
      );
    }

    Psbt psbt = transactionModel.psbt!;
    int amount = transactionModel.amount;

    String header = (account.wallet.hot || transactionModel.isPSBTFinalized)
        ? S().coincontrol_tx_detail_heading
        : S().coincontrol_txDetail_heading_passport;

    String subHeading = (account.wallet.hot || transactionModel.isPSBTFinalized)
        ? S().coincontrol_tx_detail_subheading
        : S().coincontrol_txDetail_subheading_passport;

    int feePercentage = ((psbt.fee / (psbt.fee + amount)) * 100).round();

    return EnvoyScaffold(
      backgroundColor: Colors.transparent,
      hasScrollBody: true,
      extendBody: true,
      extendBodyBehindAppBar: true,
      removeAppBarPadding: true,
      topBarLeading: IconButton(
        icon: const EnvoyIcon(
          EnvoyIcons.chevron_left,
          color: EnvoyColors.textPrimary,
        ),
        onPressed: () {
          GoRouter.of(context).pop();
        },
      ),
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
              ).add(const EdgeInsets.only(bottom: EnvoySpacing.large1)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!transactionModel.isPSBTFinalized)
                    EnvoyButton(
                      enabled: !transactionModel.loading,
                      S().coincontrol_tx_detail_cta2,
                      type: EnvoyButtonTypes.secondary,
                      onTap: () {
                        ref.read(userHasChangedFeesProvider.notifier).state =
                            false;
                        editTransaction(context, ref);
                      },
                    ),
                  const Padding(padding: EdgeInsets.all(6)),
                  EnvoyButton(
                    enabled: !transactionModel.loading,
                    (account.wallet.hot || transactionModel.isPSBTFinalized)
                        ? S().coincontrol_tx_detail_cta1
                        : S().coincontrol_txDetail_cta1_passport,
                    onTap: () {
                      widget.onBroadcast();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                vertical: EnvoySpacing.small, horizontal: EnvoySpacing.medium1),
            child: ListTile(
              title: Text(header,
                  textAlign: TextAlign.center,
                  style: EnvoyTypography.subheading),
              subtitle: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: EnvoySpacing.small),
                child: Text(
                  subHeading,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 13, fontWeight: FontWeight.w400),
                ),
              ),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 160),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Consumer(builder: (context, ref, child) {
                            return TransactionReviewCard(
                              psbt: psbt,
                              onTxDetailTap: () {
                                if (transactionModel.psbt == null) return;
                                Navigator.of(context, rootNavigator: true).push(
                                    PageRouteBuilder(
                                        pageBuilder: (context, animation,
                                            secondaryAnimation) {
                                          return StagingTxDetails(
                                            psbt: transactionModel.psbt!,
                                          );
                                        },
                                        transitionDuration:
                                            const Duration(milliseconds: 100),
                                        transitionsBuilder: (context, animation,
                                            secondaryAnimation, child) {
                                          return FadeTransition(
                                            opacity: animation,
                                            child: child,
                                          );
                                        },
                                        opaque: false,
                                        fullscreenDialog: true));
                              },
                              psbtFinalized: transactionModel.isPSBTFinalized,
                              loading: transactionModel.loading,
                              address: address,
                              feeTitle: S().coincontrol_tx_detail_fee,
                              feeChooserWidget: FeeChooser(
                                onFeeSelect: (fee, context, bool customFee) {
                                  setFee(fee, context, customFee);
                                  ref
                                      .read(userHasChangedFeesProvider.notifier)
                                      .state = true;
                                },
                              ),
                            );
                          }),
                          if (feePercentage >= 25)
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: EnvoySpacing.small),
                              child: feeOverSpendWarning(feePercentage),
                            ),
                        ]),

                    // Special warning if we are sending max or the fee changed the TX
                    if (transactionModel.mode == SpendMode.sendMax ||
                        showFeeChangeNotice)
                      ListTile(
                        subtitle: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: EnvoySpacing.small),
                            child: Padding(
                              padding: const EdgeInsets.all(EnvoySpacing.small),
                              child: Text(
                                showFeeChangeNotice
                                    ? S()
                                        .coincontrol_tx_detail_feeChange_information
                                    : S().send_reviewScreen_sendMaxWarning,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400),
                                textAlign: TextAlign.center,
                              ),
                            )),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget feeOverSpendWarning(int feePercentage) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.only(right: EnvoySpacing.small),
          child: EnvoyIcon(EnvoyIcons.alert,
              size: EnvoyIconSize.extraSmall, color: EnvoyColors.copper500),
        ),
        Text("Fee is $feePercentage% of total amount", // TODO: Figma
            style:
                EnvoyTypography.button.copyWith(color: EnvoyColors.copper500)),
      ],
    );
  }

  void setFee(int fee, BuildContext context, bool customFee) async {
    if (!mounted) {
      return;
    }
    // Set the fee
    ref.read(spendFeeProcessing.notifier).state = true;
    int selectedItem = fee;
    ref.read(spendFeeRateProvider.notifier).state = selectedItem.toDouble();
    await ref
        .read(spendTransactionProvider.notifier)
        .validate(ProviderScope.containerOf(context), settingFee: true);
    ref.read(spendFeeProcessing.notifier).state = false;
    //hide fee slider bottom-sheet
    if (customFee && context.mounted) {
      Navigator.pop(context);
    }
  }
}

void editTransaction(BuildContext context, WidgetRef ref) async {
  final router = Navigator.of(context, rootNavigator: true);

  /// The user has is in edit mode and if the psbt
  /// has inputs then use them to populate the coin selection state
  if (ref.read(rawTransactionProvider) != null) {
    List<String> inputs = ref
        .read(rawTransactionProvider)!
        .inputs
        .map((e) => "${e.previousOutputHash}:${e.previousOutputIndex}")
        .toList();

    ref.read(coinSelectionStateProvider.notifier).reset();
    ref.read(coinSelectionStateProvider.notifier).addAll(inputs);

    ///make a copy of wallet selected coins so that we can backtrack to it
    ref.read(coinSelectionFromWallet.notifier).reset();
    ref.read(coinSelectionFromWallet.notifier).addAll(inputs);
  }

  if (ref.read(selectedAccountProvider) != null) {
    coinSelectionOverlayKey.currentState?.show(SpendOverlayContext.editCoins);
  }
  router
      .push(CupertinoPageRoute(
          builder: (context) => const ChooseCoinsWidget(),
          fullscreenDialog: true))
      .then((value) {});
}

class DiscardTransactionDialog extends ConsumerStatefulWidget {
  const DiscardTransactionDialog({super.key});

  @override
  ConsumerState<DiscardTransactionDialog> createState() =>
      _DiscardTransactionDialogState();
}

class _DiscardTransactionDialogState
    extends ConsumerState<DiscardTransactionDialog> {
  @override
  Widget build(BuildContext context) {
    Account? account = ref.watch(selectedAccountProvider);

    return Container(
      padding: const EdgeInsets.all(28).add(const EdgeInsets.only(top: -6)),
      constraints: const BoxConstraints(
        minHeight: 300,
        maxWidth: 280,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: EnvoyColors.accentSecondary,
            size: 42,
          ),
          const Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
          Text(S().manage_account_remove_heading,
              style: Theme.of(context).textTheme.titleSmall),
          const Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
          Text(
            S().coincontrol_tx_detail_passport_subheading,
            style: Theme.of(context).textTheme.titleSmall,
            textAlign: TextAlign.center,
          ),
          const Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
          EnvoyButton(
            S().coincontrol_tx_detail_passport_cta2,
            type: EnvoyButtonTypes.secondary,
            onTap: () async {
              final router = GoRouter.of(context);
              resetFeeChangeNoticeUserInteractionProviders(ref);
              router.pop(true);
              await Future.delayed(const Duration(milliseconds: 50));
              ref.read(selectedAccountProvider.notifier).state = account;
              router.pushReplacement(ROUTE_ACCOUNT_DETAIL, extra: account);
              await Future.delayed(const Duration(milliseconds: 50));
              router.pop();
            },
          ),
          const Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
          EnvoyButton(
            S().coincontrol_txDetail_ReviewTransaction,
            type: EnvoyButtonTypes.primaryModal,
            onTap: () {
              Navigator.of(context).pop(false);
            },
          )
        ],
      ),
    );
  }
}

void resetFeeChangeNoticeUserInteractionProviders(WidgetRef ref) {
  ref.read(userSelectedCoinsThisSessionProvider.notifier).state = false;
  ref.read(userHasChangedFeesProvider.notifier).state = false;
  ref.read(transactionInputsChangedProvider.notifier).state = false;
  ref.read(coinSelectionChangedProvider.notifier).state = false;
}

class TxReviewNoteDialog extends ConsumerStatefulWidget {
  final String txId;
  final Function(String) onAdd;
  final String noteTitle;
  final String? value;
  final String noteSubTitle;

  const TxReviewNoteDialog(
      {super.key,
      required this.noteTitle,
      this.value,
      required this.onAdd,
      required this.noteSubTitle,
      required this.txId});

  @override
  ConsumerState<TxReviewNoteDialog> createState() => _TxNoteDialogState();
}

class _TxNoteDialogState extends ConsumerState<TxReviewNoteDialog> {
  final TextEditingController _textEditingController = TextEditingController();
  bool dismissed = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      /// if value is passed as param, use that
      if (widget.value != null) {
        _textEditingController.text = widget.value!;
      } else {
        _textEditingController.text =
            ref.read(txNoteProvider(widget.txId)) ?? "";
      }
      EnvoyStorage()
          .checkPromptDismissed(DismissiblePrompt.addTxNoteWarning)
          .then((value) {
        setState(() {
          dismissed = value;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: 380,
      padding: const EdgeInsets.all(EnvoySpacing.small),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Container(
            padding: const EdgeInsets.only(
                left: EnvoySpacing.medium1,
                right: EnvoySpacing.medium1,
                top: EnvoySpacing.medium1),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(widget.noteTitle,
                    style: Theme.of(context).textTheme.titleLarge),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    widget.noteSubTitle,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: EnvoySpacing.xs),
                  child: Container(
                    decoration: BoxDecoration(
                        color: EnvoyColors.surface4,
                        borderRadius:
                            BorderRadius.circular(EnvoySpacing.small)),
                    child: TextFormField(
                      maxLines: 1,
                      maxLength: 34,
                      controller: _textEditingController,
                      textAlign: TextAlign.center,
                      textInputAction: TextInputAction.done,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontSize: 14),
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.all(EnvoySpacing.small),
                        border: InputBorder.none,
                        counter: SizedBox.shrink(),
                        fillColor: Colors.redAccent,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
          height: 180,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(
            horizontal: EnvoySpacing.medium1,
            vertical: EnvoySpacing.small,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    dismissed = !dismissed;
                  });
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      child: EnvoyCheckbox(
                        value: dismissed,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              dismissed = value;
                            });
                          }
                        },
                      ),
                    ),
                    Text(
                      S().component_dontShowAgain,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: dismissed
                                ? Colors.black
                                : const Color(0xff808080),
                          ),
                    ),
                  ],
                ),
              ),
              const Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
              EnvoyButton(S().stalls_before_sending_tx_add_note_modal_cta2,
                  onTap: () {
                Navigator.of(context).pop(false);
                if (dismissed) {
                  EnvoyStorage()
                      .addPromptState(DismissiblePrompt.addTxNoteWarning);
                }
              }, type: EnvoyButtonTypes.tertiary),
              const Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
              EnvoyButton(
                S().component_save,
                onTap: () {
                  ref.read(stagingTxNoteProvider.notifier).state =
                      _textEditingController.text;
                  Navigator.of(context).pop(true);
                  if (dismissed) {
                    EnvoyStorage()
                        .addPromptState(DismissiblePrompt.addTxNoteWarning);
                  }
                },
                type: EnvoyButtonTypes.primaryModal,
              )
            ],
          ),
        ),
      ),
    );
  }
}
