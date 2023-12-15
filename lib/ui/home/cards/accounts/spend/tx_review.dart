// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:envoy/business/account.dart';
import 'package:envoy/business/coin_tag.dart';
import 'package:envoy/business/coins.dart';
import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/amount_entry.dart';
import 'package:envoy/ui/background.dart';
import 'package:envoy/ui/components/envoy_checkbox.dart';
import 'package:envoy/ui/components/envoy_scaffold.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/home/cards/accounts/accounts_state.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coins_state.dart';
import 'package:envoy/ui/home/cards/accounts/detail/filter_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/fee_slider.dart';
import 'package:envoy/ui/home/cards/accounts/spend/psbt_card.dart';
import 'package:envoy/ui/home/cards/accounts/spend/spend_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/staging_tx_details.dart';
import 'package:envoy/ui/home/cards/accounts/spend/staging_tx_tagging.dart';
import 'package:envoy/ui/routes/accounts_router.dart';
import 'package:envoy/ui/state/home_page_state.dart';
import 'package:envoy/ui/state/send_screen_state.dart';
import 'package:envoy/ui/state/transactions_note_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/util/amount.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:envoy/util/list_utils.dart';
import 'package:envoy/util/tuple.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:rive/rive.dart' as Rive;
import 'package:wallet/wallet.dart';

//ignore: must_be_immutable
class TxReview extends ConsumerStatefulWidget {
  TxReview() : super(key: UniqueKey()) {}

  @override
  ConsumerState<TxReview> createState() => _TxReviewState();
}

final _truncatedAddressLength = 16.0;

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
                  icon: Icon(
                    Icons.close,
                    color: EnvoyColors.textPrimary,
                  ),
                  onPressed: () {
                    GoRouter.of(context).pop();
                  },
                )),
            body: Center(
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
              key: Key("review"),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              child: TransactionReviewScreen(
                onBroadcast: () async {
                  BuildContext _rootContext = context;
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
                      !dismissedNoteDialog) {
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
                          noteTitle: S().coincontrol_tx_add_note_heading,
                          value: ref.read(stagingTxNoteProvider),
                        ),
                        alignment: Alignment(0.0, -0.5));

                    ///wait for the dialog to pop
                    await Future.delayed(Duration(milliseconds: 200));
                  }

                  Tuple<String, int>? changeOutPut =
                      ref.read(changeOutputProvider);
                  bool hasChangeOutPutPresent =
                      changeOutPut != null && changeOutPut.item2 != 0;

                  ///then show the tag selection dialog
                  if (!userChosenTag &&
                      tagInputs != null &&
                      hasManyTagsAsInput &&
                      hasChangeOutPutPresent) {
                    await showTagDialog(
                        context, account, _rootContext, transactionModel);
                  } else {
                    if (account.wallet.hot ||
                        ref.read(spendTransactionProvider).isPSBTFinalized) {
                      broadcastTx(context);
                    } else {
                      await Navigator.of(_rootContext, rootNavigator: false)
                          .push(MaterialPageRoute(
                              builder: (context) => Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: PsbtCard(
                                        transactionModel.psbt!, account),
                                  )));
                      await Future.delayed(Duration(milliseconds: 200));
                    }
                  }
                },
              ),
            )
          : _buildBroadcastProgress(),
    );
  }

  Future<void> showTagDialog(BuildContext context, Account account,
      BuildContext _rootContext, TransactionModel transactionModel) async {
    await showEnvoyDialog(
        useRootNavigator: true,
        context: context,
        builder: Builder(
          builder: (context) => ChooseTagForStagingTx(
            accountId: account.id!,
            onEditTransaction: () {
              Navigator.pop(context);
              editTransaction(context);
            },
            hasMultipleTagsInput: true,
            onTagUpdate: () async {
              Navigator.pop(context);
              if (account.wallet.hot ||
                  ref.read(spendTransactionProvider).isPSBTFinalized) {
                broadcastTx(context);
              } else {
                await Navigator.of(_rootContext, rootNavigator: false)
                    .push(MaterialPageRoute(
                        builder: (context) => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: PsbtCard(transactionModel.psbt!, account),
                            )));
                await Future.delayed(Duration(milliseconds: 200));
              }
            },
          ),
        ),
        alignment: Alignment(0.0, -.6));
  }

  Rive.StateMachineController? _stateMachineController;

  Widget _buildBroadcastProgress() {
    final spendState = ref.watch(spendTransactionProvider);
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
                    broadcastTx(context);
                  },
                ),
              ),
            ),
            SliverPadding(padding: EdgeInsets.all(28)),
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
    final spendState = ref.watch(spendTransactionProvider);
    if (spendState.broadcastProgress == BroadcastProgress.inProgress) {
      return SizedBox();
    }
    if (spendState.broadcastProgress == BroadcastProgress.success) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        children: [
          EnvoyButton(
            S().stalls_before_sending_tx_scanning_broadcasting_success_cta,
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
          S().stalls_before_sending_tx_scanning_broadcasting_fail_cta1,
          type: EnvoyButtonTypes.secondary,
          onTap: () {
            broadcastTx(context);
          },
        ),
        Padding(padding: EdgeInsets.all(6)),
        EnvoyButton(
          enabled: spendState.broadcastProgress != BroadcastProgress.inProgress,
          S().stalls_before_sending_tx_scanning_broadcasting_fail_cta2,
          onTap: () {
            ref.read(spendTransactionProvider.notifier).resetBroadcastState();
          },
        ),
      ],
    );
  }

  // TODO: refactor similar function to just one
  void editTransaction(BuildContext context) async {
    final router = GoRouter.of(context);

    ///indicating that we are in edit mode
    ref.read(spendEditModeProvider.notifier).state = true;
    ref.read(userHasEnteredEditModeProvider.notifier).state = true;

    /// The user has is in edit mode and if the psbt
    /// has inputs then use them to populate the coin selection state
    if (ref.read(rawTransactionProvider) != null) {
      List<String> inputs = ref
          .read(rawTransactionProvider)!
          .inputs
          .map((e) => "${e.previousOutputHash}:${e.previousOutputIndex}")
          .toList();

      if (ref.read(coinSelectionStateProvider).isEmpty) {
        ref.read(coinSelectionStateProvider.notifier).addAll(inputs);
      }

      ///make a copy of wallet selected coins so that we can backtrack to it
      ref.read(coinSelectionFromWallet.notifier).reset();
      ref.read(coinSelectionFromWallet.notifier).addAll(inputs);
    }

    ///toggle to coins view for coin control
    ref.read(accountToggleStateProvider.notifier).state =
        AccountToggleState.Coins;

    ///pop review
    router.pop();
    await Future.delayed(Duration(milliseconds: 100));

    ///pop spend form
    router.pop();
  }

  void broadcastTx(BuildContext context) async {
    Account? account = ref.watch(selectedAccountProvider);
    TransactionModel transactionModel = ref.watch(spendTransactionProvider);

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
      await Future.delayed(Duration(milliseconds: 500));
    } catch (e) {
      _stateMachineController?.findInput<bool>("indeterminate")?.change(false);
      _stateMachineController?.findInput<bool>("happy")?.change(false);
      _stateMachineController?.findInput<bool>("unhappy")?.change(true);
      await Future.delayed(Duration(milliseconds: 800));
    }
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
  bool _showFullAddress = false;

  @override
  Widget build(BuildContext context) {
    Account? account = ref.watch(selectedAccountProvider);
    TransactionModel transactionModel = ref.watch(spendTransactionProvider);
    String address = ref.watch(spendAddressProvider);
    final amount = ref.watch(receiveAmountProvider);
    final uneconomicSpends = ref.watch(uneconomicSpendsProvider);

    final spendScreenUnit = ref.watch(sendScreenUnitProvider);

    final userHasSelectedCoins = ref.watch(userHasSelectedCoinsProvider);
    final userHasEnteredEditMode = ref.watch(userHasEnteredEditModeProvider);
    final transactionInputsChanged =
        ref.watch(transactionInputsChangedProvider);
    final userHasChangedFees = ref.watch(userHasChangedFeesProvider);

    final feeChangeNotice = userHasEnteredEditMode &&
        userHasSelectedCoins &&
        transactionInputsChanged &&
        userHasChangedFees;

    /// if user selected unit from the form screen then use that, otherwise use the default
    DisplayUnit unit = spendScreenUnit == AmountDisplayUnit.btc
        ? DisplayUnit.btc
        : DisplayUnit.sat;
    if (spendScreenUnit == AmountDisplayUnit.fiat) {
      unit = Settings().displayUnit;
    }
    AmountDisplayUnit formatUnit =
        unit == DisplayUnit.btc ? AmountDisplayUnit.btc : AmountDisplayUnit.sat;

    if (account == null || transactionModel.psbt == null) {
      return Container(
          child: Center(
        child: Text("Unable to build transaction"), //TODO: figma
      ));
    }

    Psbt psbt = transactionModel.psbt!;

    TextStyle? titleStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
        color: EnvoyColors.textPrimaryInverse, fontWeight: FontWeight.w700);

    TextStyle? trailingStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
        color: EnvoyColors.textPrimaryInverse,
        fontWeight: FontWeight.w400,
        fontSize: 13);

    // total amount to spend including fee
    int totalSpendAmount = amount + psbt.fee;

    String header = (account.wallet.hot || transactionModel.isPSBTFinalized)
        ? S().coincontrol_tx_detail_heading
        : S().coincontrol_txDetail_heading_passport;

    String subHeading = (account.wallet.hot || transactionModel.isPSBTFinalized)
        ? S().coincontrol_tx_detail_subheading
        : S().coincontrol_txDetail_subheading_passport;

    TextStyle contentLeadingStyle =
        Theme.of(context).textTheme.headlineSmall!.copyWith(
              color: Color(0xFF808080),
              fontWeight: FontWeight.w400,
              fontSize: 18,
            );
    TextStyle contentTrailingStyle =
        Theme.of(context).textTheme.headlineSmall!.copyWith(
              color: Color(0xFF808080),
              fontWeight: FontWeight.w400,
              fontSize: 16,
            );
    return EnvoyScaffold(
      backgroundColor: Colors.transparent,
      hasScrollBody: true,
      extendBody: true,
      extendBodyBehindAppBar: true,
      removeAppBarPadding: true,
      topBarLeading: IconButton(
        icon: EnvoyIcon(
          EnvoyIcons.chevron_left,
          color: EnvoyColors.textPrimary,
        ),
        onPressed: () {
          GoRouter.of(context).pop();
        },
      ),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: EnvoySpacing.small,
                  horizontal: EnvoySpacing.medium1),
              child: ListTile(
                title: Text(header.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: EnvoyTypography.heading),
                subtitle: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
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
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(24)),
                color: account.color,
                border: Border.all(
                    color: Colors.black, width: 2, style: BorderStyle.solid),
              ),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(22)),
                    gradient: LinearGradient(
                      begin: Alignment(0.00, 1.00),
                      end: Alignment(0, -1),
                      stops: [0, .65, 1],
                      colors: [
                        Colors.black.withOpacity(0.65),
                        Colors.black.withOpacity(0.13),
                        Colors.black.withOpacity(0)
                      ],
                    ),
                    border: Border.all(
                        width: 2,
                        color: account.color,
                        style: BorderStyle.solid)),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  child: CustomPaint(
                    isComplex: true,
                    willChange: false,
                    painter: LinesPainter(
                        lineDistance: 2.5,
                        color: EnvoyColors.gray1000,
                        opacity: 0.4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: EnvoySpacing.small,
                          horizontal: EnvoySpacing.xs),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: EnvoySpacing.xs,
                                horizontal: EnvoySpacing.small),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  S().coincontrol_tx_detail_amount_to_sent,
                                  style: titleStyle,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    // Navigator.of(context,rootNavigator: true).push(MaterialTransparentRoute(builder: (context) {
                                    //   return SpendTxDetails();
                                    // },fullscreenDialog: true));
                                    Navigator.of(context, rootNavigator: true)
                                        .push(PageRouteBuilder(
                                            pageBuilder: (context, animation,
                                                secondaryAnimation) {
                                              return StagingTxDetails();
                                            },
                                            transitionDuration:
                                                Duration(milliseconds: 100),
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
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (uneconomicSpends)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: EnvoySpacing.xs),
                                          child: EnvoyIcon(EnvoyIcons.info,
                                              color: EnvoyColors.solidWhite),
                                        ),
                                      Text(
                                        S().coincontrol_tx_detail_amount_details,
                                        style: trailingStyle,
                                      ),
                                      Icon(
                                        Icons.chevron_right_outlined,
                                        color: EnvoyColors.textPrimaryInverse,
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          _whiteContainer(
                              child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    alignment: Alignment(0, 0),
                                    child: SizedBox.square(
                                        dimension: 12,
                                        child: SvgPicture.asset(
                                          unit == DisplayUnit.btc
                                              ? "assets/icons/ic_bitcoin_straight.svg"
                                              : "assets/icons/ic_sats.svg",
                                          color: EnvoyColors.textSecondary,
                                        )),
                                  ),
                                  Container(
                                    alignment: Alignment.centerRight,
                                    padding: EdgeInsets.only(
                                        left: unit == DisplayUnit.btc ? 4 : 0,
                                        right: unit == DisplayUnit.btc ? 0 : 8),
                                    child: Text(
                                      "${getFormattedAmount(amount.toInt(), trailingZeroes: true, unit: formatUnit)}",
                                      style: contentLeadingStyle,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                  ExchangeRate().getFormattedAmount(
                                      amount.toInt(),
                                      wallet: account.wallet),
                                  style: contentTrailingStyle),
                            ],
                          )),
                          Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: EnvoySpacing.xs,
                                horizontal: EnvoySpacing.small),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  S().coincontrol_tx_detail_destination,
                                  style: titleStyle,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _showFullAddress = !_showFullAddress;
                                    });
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        S().coincontrol_tx_detail_destination_details,
                                        style: trailingStyle,
                                      ),
                                      AnimatedRotation(
                                        duration: Duration(milliseconds: 200),
                                        turns: _showFullAddress ? -.25 : 0,
                                        child: Icon(
                                          Icons.chevron_right_outlined,
                                          color: EnvoyColors.textPrimaryInverse,
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          AnimatedContainer(
                            duration: Duration(milliseconds: 120),
                            height: _showFullAddress ? 56 : 44,
                            child: _whiteContainer(
                                child: TweenAnimationBuilder(
                              duration: Duration(milliseconds: 320),
                              curve: Curves.easeInOut,
                              tween: Tween<double>(
                                  begin: _truncatedAddressLength,
                                  end: _showFullAddress
                                      ? address.length.toDouble()
                                      : _truncatedAddressLength),
                              builder: (context, value, child) {
                                return Text(
                                  "${truncateWithEllipsisInCenter(address, value.toInt())}",
                                  style: contentLeadingStyle,
                                );
                              },
                              // child: Text(
                              //     "${truncateWithEllipsisInCenter(address, _showFullAddress ?  address.length : 12)}"),
                            )),
                          ),
                          Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: EnvoySpacing.xs,
                                horizontal: EnvoySpacing.small),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  S().coincontrol_tx_detail_fee,
                                  style: titleStyle,
                                ),
                                Padding(padding: EdgeInsets.all(12)),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Opacity(
                                        opacity:
                                            transactionModel.loading ? 1 : 0,
                                        child: SizedBox.square(
                                          dimension: 8,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 1,
                                            color:
                                                EnvoyColors.textPrimaryInverse,
                                          ),
                                        ),
                                      ),
                                      Padding(padding: EdgeInsets.all(4)),
                                      Opacity(
                                        child: FeeChooser(),
                                        opacity:
                                            transactionModel.isPSBTFinalized
                                                ? 0.0
                                                : 1,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          _whiteContainer(
                              child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    alignment: Alignment(0, 0),
                                    child: SizedBox.square(
                                        dimension: 12,
                                        child: SvgPicture.asset(
                                          unit == DisplayUnit.btc
                                              ? "assets/icons/ic_bitcoin_straight.svg"
                                              : "assets/icons/ic_sats.svg",
                                          color: EnvoyColors.textSecondary,
                                        )),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(
                                        left: unit == DisplayUnit.btc ? 4 : 0,
                                        right: unit == DisplayUnit.btc ? 0 : 8),
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      getFormattedAmount(psbt.fee,
                                          unit: formatUnit),
                                      style: contentLeadingStyle,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "${ExchangeRate().getFormattedAmount(
                                      psbt.fee,
                                      wallet: account.wallet,
                                    )}",
                                    textAlign: unit == DisplayUnit.btc
                                        ? TextAlign.start
                                        : TextAlign.end,
                                    style: contentTrailingStyle,
                                  )
                                ],
                              ),
                            ],
                          )),
                          Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: EnvoySpacing.small,
                                horizontal: EnvoySpacing.small),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  S().coincontrol_tx_detail_total,
                                  style: titleStyle,
                                ),
                                GestureDetector(
                                  onTap: () {},
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.timer_outlined,
                                        size: 14,
                                        color: EnvoyColors.textPrimaryInverse,
                                      ),
                                      Consumer(builder: (context, ref, child) {
                                        final spendTimeEstimationProvider =
                                            ref.watch(
                                                spendEstimatedBlockTimeProvider);
                                        return Text(
                                          " $spendTimeEstimationProvider min",
                                          //TODO: figma
                                          style: trailingStyle,
                                        );
                                      }),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          _whiteContainer(
                              child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    alignment: Alignment(0, 0),
                                    child: SizedBox.square(
                                        dimension: 12,
                                        child: SvgPicture.asset(
                                          unit == DisplayUnit.btc
                                              ? "assets/icons/ic_bitcoin_straight.svg"
                                              : "assets/icons/ic_sats.svg",
                                          color: EnvoyColors.textSecondary,
                                        )),
                                  ),
                                  Container(
                                    alignment: Alignment.centerRight,
                                    padding: EdgeInsets.only(
                                        left: unit == DisplayUnit.btc ? 4 : 0,
                                        right: unit == DisplayUnit.btc ? 0 : 8),
                                    child: Text(
                                      "${getFormattedAmount(totalSpendAmount, trailingZeroes: true, unit: formatUnit)}",
                                      style: contentLeadingStyle,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                  ExchangeRate().getFormattedAmount(
                                      totalSpendAmount.toInt(),
                                      wallet: account.wallet),
                                  style: contentTrailingStyle),
                            ],
                          )),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Special warning if we are sending max or the fee changed the TX
          if (transactionModel.mode == SpendMode.sendMax || feeChangeNotice)
            SliverToBoxAdapter(
              child: ListTile(
                subtitle: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        feeChangeNotice
                            ? S().coincontrol_tx_detail_feeChange_information
                            : S().send_reviewScreen_sendMaxWarning,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 13, fontWeight: FontWeight.w400),
                        textAlign: TextAlign.center,
                      ),
                    )),
              ),
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
                horizontal: 12,
              ).add(EdgeInsets.only(bottom: EnvoySpacing.large1)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!transactionModel.isPSBTFinalized)
                    EnvoyButton(
                      S().coincontrol_tx_detail_cta2,
                      type: EnvoyButtonTypes.secondary,
                      onTap: () => editTransaction(context),
                    ),
                  Padding(padding: EdgeInsets.all(6)),
                  EnvoyButton(
                    readOnly: transactionModel.loading,
                    (account.wallet.hot || transactionModel.isPSBTFinalized)
                        ? S().coincontrol_tx_detail_cta1
                        : S().coincontrol_txDetail_cta1_passport,
                    onTap: transactionModel.loading
                        ? null
                        : () {
                            widget.onBroadcast();
                          },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void editTransaction(BuildContext context) async {
    final router = GoRouter.of(context);

    ///indicating that we are in edit mode
    ref.read(spendEditModeProvider.notifier).state = true;
    ref.read(userHasEnteredEditModeProvider.notifier).state = true;

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

    ///toggle to coins view for coin control
    ref.read(accountToggleStateProvider.notifier).state =
        AccountToggleState.Coins;

    ///pop review
    router.pop();
    await Future.delayed(Duration(milliseconds: 100));

    ///pop spend form
    router.pop();
  }

  Widget _whiteContainer({required Widget child}) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        constraints: BoxConstraints(
          minHeight: 44,
        ),
        alignment: Alignment.centerLeft,
        width: double.infinity,
        decoration: BoxDecoration(
            borderRadius:
                BorderRadius.all(Radius.circular(constraints.maxWidth)),
            color: EnvoyColors.textPrimaryInverse),
        padding:
            EdgeInsets.symmetric(vertical: 6, horizontal: EnvoySpacing.small),
        child: child,
      );
    });
  }
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
      padding: EdgeInsets.all(28).add(EdgeInsets.only(top: -6)),
      constraints: BoxConstraints(
        minHeight: 300,
        maxWidth: 280,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: EnvoyColors.accentSecondary,
            size: 42,
          ),
          Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
          Text(S().coincontrol_tx_detail_passport_heading,
              style: Theme.of(context).textTheme.titleSmall),
          Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
          Text(
            S().coincontrol_tx_detail_passport_subheading,
            style: Theme.of(context).textTheme.titleSmall,
            textAlign: TextAlign.center,
          ),
          Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
          EnvoyButton(
            S().coincontrol_tx_detail_passport_cta2,
            type: EnvoyButtonTypes.secondary,
            onTap: () async {
              resetUserInteractionProviders();
              GoRouter.of(context).pop(true);
              await Future.delayed(Duration(milliseconds: 50));
              ref.read(selectedAccountProvider.notifier).state = account;
              context.go(ROUTE_ACCOUNT_DETAIL, extra: account);
            },
          ),
          Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
          EnvoyButton(
            S().coincontrol_tx_detail_passport_cta,
            type: EnvoyButtonTypes.primaryModal,
            onTap: () {
              Navigator.of(context).pop(false);
            },
          )
        ],
      ),
    );
  }

  void resetUserInteractionProviders() {
    ref.read(userHasEnteredEditModeProvider.notifier).state = false;
    ref.read(userHasChangedFeesProvider.notifier).state = false;
    ref.read(transactionInputsChangedProvider.notifier).state = false;
    ref.read(userHasSelectedCoinsProvider.notifier).state = false;
  }
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
  TextEditingController _textEditingController = TextEditingController();
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
      padding: EdgeInsets.all(EnvoySpacing.small),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Container(
            padding: EdgeInsets.only(
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
                  margin: EdgeInsets.only(top: EnvoySpacing.xs),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Color(0xffD9D9D9),
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
                      decoration: InputDecoration(
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
          padding: EdgeInsets.symmetric(
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
                          if (value != null)
                            setState(() {
                              dismissed = value;
                            });
                        },
                      ),
                    ),
                    Text(
                      S().coincontrol_lock_coin_modal_dontShowAgain,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: dismissed ? Colors.black : Color(0xff808080),
                          ),
                    ),
                  ],
                ),
              ),
              Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
              EnvoyButton(S().stalls_before_sending_tx_add_note_modal_cta2,
                  onTap: () {
                Navigator.of(context).pop(false);
                if (dismissed) {
                  EnvoyStorage()
                      .addPromptState(DismissiblePrompt.addTxNoteWarning);
                }
              }, type: EnvoyButtonTypes.tertiary),
              Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
              EnvoyButton(
                S().stalls_before_sending_tx_add_note_modal_cta1,
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
