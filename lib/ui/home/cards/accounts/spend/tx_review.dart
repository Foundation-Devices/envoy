// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:envoy/business/account.dart';
import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/background.dart';
import 'package:envoy/ui/components/envoy_scaffold.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/home/cards/accounts/accounts_state.dart';
import 'package:envoy/ui/home/cards/accounts/detail/filter_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/fee_slider.dart';
import 'package:envoy/ui/home/cards/accounts/spend/psbt_card.dart';
import 'package:envoy/ui/home/cards/accounts/spend/spend_state.dart';
import 'package:envoy/ui/routes/accounts_router.dart';
import 'package:envoy/ui/theme/envoy_colors.dart' as EnvoyNewColors;
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/util/amount.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:rive/rive.dart' as Rive;
import 'package:tor/tor.dart';
import 'package:wallet/wallet.dart';

//ignore: must_be_immutable
class TxReview extends ConsumerStatefulWidget {
  TxReview() : super(key: UniqueKey()) {}

  @override
  ConsumerState<TxReview> createState() => _TxReviewState();
}

final _truncatedAddressLength = 16.0;

class _TxReviewState extends ConsumerState<TxReview> {
  bool _showBroadcastProgress = false;

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
                    color: Colors.black,
                  ),
                  onPressed: () {
                    GoRouter.of(context).pop();
                  },
                )),
            body: Center(
              child: Text("Unable to build transaction"),
            )),
      );
    }
    return PageTransitionSwitcher(
      reverse: !_showBroadcastProgress,
      transitionBuilder: (child, animation, secondaryAnimation) {
        return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.vertical,
          child: child,
        );
      },
      child: _showBroadcastProgress
          ? _buildBroadcastProgress()
          : Padding(
              key: Key("review"),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              child: TransactionReviewScreen(
                onBroadcast: () async {
                  if (account.wallet.hot) {
                    broadcastTx(context);
                  } else {
                    await Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            PsbtCard(transactionModel.psbt!, account)));
                    await Future.delayed(Duration(milliseconds: 200));
                    if (ref.read(spendTransactionProvider).isPSBTFinalized) {
                      broadcastTx(context);
                    }
                  }
                },
              ),
            ),
    );
  }

  Rive.StateMachineController? _stateMachineController;

  bool _isBroadcastSuccess = false;
  bool _isBroadcastInProgress = false;

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
                  if (!_isBroadcastInProgress) {
                    if (_isBroadcastSuccess) {
                      title = S()
                          .stalls_before_sending_tx_scanning_broadcasting_success_heading;
                      subTitle = "";
                      // Disabled until coin control
                      // S() .stalls_before_sending_tx_scanning_broadcasting_success_subheading;
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
    if (_isBroadcastInProgress) {
      return SizedBox();
    }
    if (_isBroadcastSuccess) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        children: [
          EnvoyButton(
            S().stalls_before_sending_tx_scanning_broadcasting_success_cta,
            onTap: () {
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
          S().stalls_before_sending_tx_scanning_broadcasting_fail_cta1,
          type: EnvoyButtonTypes.secondary,
          onTap: () {
            broadcastTx(context);
          },
        ),
        Padding(padding: EdgeInsets.all(6)),
        EnvoyButton(
          S().stalls_before_sending_tx_scanning_broadcasting_fail_cta2,
          onTap: () {
            setState(() {
              _showBroadcastProgress = false;
            });
          },
        ),
      ],
    );
  }

  void broadcastTx(BuildContext context) async {
    Account? account = ref.watch(selectedAccountProvider);
    TransactionModel transactionModel = ref.watch(spendTransactionProvider);

    if (account == null || transactionModel.psbt == null) {
      return;
    }

    Psbt psbt = transactionModel.psbt!;

    setState(() {
      _showBroadcastProgress = true;
      _isBroadcastInProgress = true;
      _isBroadcastSuccess = false;
    });
    try {
      _stateMachineController?.findInput<bool>("indeterminate")?.change(true);
      _stateMachineController?.findInput<bool>("happy")?.change(false);
      _stateMachineController?.findInput<bool>("unhappy")?.change(false);
      //wait for animation
      await Future.delayed(Duration(seconds: 1));

      // Increment the change index before broadcasting
      await account.wallet.getChangeAddress();

      //Broadcast transaction
      await account.wallet.broadcastTx(
          Settings().electrumAddress(account.wallet.network),
          Tor.instance.port,
          psbt.rawTx);

      await EnvoyStorage().addPendingTx(psbt.txid, account.id!, DateTime.now(),
          TransactionType.pending, psbt.sent + psbt.fee);

      //wait for animation
      await Future.delayed(Duration(seconds: 1));
      _stateMachineController?.findInput<bool>("indeterminate")?.change(false);
      _stateMachineController?.findInput<bool>("happy")?.change(true);
      _stateMachineController?.findInput<bool>("unhappy")?.change(false);
      await Future.delayed(Duration(milliseconds: 1000));
      clearSpendState(ProviderScope.containerOf(context));
      setState(() {
        _isBroadcastInProgress = false;
        _isBroadcastSuccess = true;
      });
    } catch (e) {
      _stateMachineController?.findInput<bool>("indeterminate")?.change(false);
      _stateMachineController?.findInput<bool>("happy")?.change(false);
      _stateMachineController?.findInput<bool>("unhappy")?.change(true);
      await Future.delayed(Duration(milliseconds: 800));
      setState(() {
        _isBroadcastInProgress = false;
        _isBroadcastSuccess = false;
      });
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
    int amount = ref.watch(spendAmountProvider);
    Account? account = ref.watch(selectedAccountProvider);
    TransactionModel transactionModel = ref.watch(spendTransactionProvider);
    String address = ref.watch(spendAddressProvider);

    if (account == null || transactionModel.psbt == null) {
      return Container(
          child: Center(
        child: Text("Unable to build transaction"),
      ));
    }

    Psbt psbt = transactionModel.psbt!;

    TextStyle? titleStyle = Theme.of(context)
        .textTheme
        .titleSmall
        ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700);

    TextStyle? trailingStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
        color: Colors.white, fontWeight: FontWeight.w400, fontSize: 13);

    return EnvoyScaffold(
      backgroundColor: Colors.transparent,
      hasScrollBody: true,
      extendBody: true,
      removeAppBarPadding: true,
      topBarLeading: IconButton(
        icon: Icon(
          Icons.close,
          color: Colors.black,
        ),
        onPressed: () {
          GoRouter.of(context).pop();
        },
      ),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: ListTile(
                title: Text(
                  S().stalls_before_sending_tx_heading,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontSize: 20),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(
                    S().stalls_before_sending_tx_subheading,
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
                borderRadius: BorderRadius.all(Radius.circular(22)),
                border: Border.all(
                    color: Colors.black, width: 2, style: BorderStyle.solid),
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      account.color,
                      Colors.black,
                    ]),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(16)),
                child: CustomPaint(
                  isComplex: true,
                  willChange: false,
                  painter: LinesPainter(
                      color: EnvoyColors.tilesLineDarkColor, opacity: 1.0),
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
                                "Amount to send",
                                style: titleStyle,
                              ),
                              GestureDetector(
                                onTap: () {},
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Show details",
                                      style: trailingStyle,
                                    ),
                                    Icon(
                                      Icons.chevron_right_outlined,
                                      color: Colors.white,
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
                                        Settings().displayUnit ==
                                                DisplayUnit.btc
                                            ? "assets/icons/ic_bitcoin_straight.svg"
                                            : "assets/icons/ic_sats.svg",
                                        color: Color(0xff808080),
                                      )),
                                ),
                                Container(
                                  alignment: Alignment.centerRight,
                                  padding: EdgeInsets.only(
                                      left: Settings().displayUnit ==
                                              DisplayUnit.btc
                                          ? 4
                                          : 0,
                                      right: Settings().displayUnit ==
                                              DisplayUnit.btc
                                          ? 0
                                          : 8),
                                  child: Text(
                                    "${getFormattedAmount(amount, trailingZeroes: true)}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall!
                                        .copyWith(
                                          color: EnvoyNewColors
                                              .EnvoyColors.textPrimary,
                                          fontSize: 15,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                                ExchangeRate().getFormattedAmount(amount,
                                    wallet: account.wallet),
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall!
                                    .copyWith(
                                      color: EnvoyNewColors
                                          .EnvoyColors.textPrimary,
                                      fontSize: 15,
                                    )),
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
                                "Destination",
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
                                      "Show address",
                                      style: trailingStyle,
                                    ),
                                    AnimatedRotation(
                                      duration: Duration(milliseconds: 200),
                                      turns: _showFullAddress ? -.25 : 0,
                                      child: Icon(
                                        Icons.chevron_right_outlined,
                                        color: Colors.white,
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
                          height: _showFullAddress ? 54 : 34,
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
                                  "${truncateWithEllipsisInCenter(address, value.toInt())}");
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Fee",
                                style: titleStyle,
                              ),
                              Row(
                                children: [
                                  Opacity(
                                    opacity: transactionModel.loading ? 1 : 0,
                                    child: SizedBox.square(
                                      dimension: 8,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Padding(padding: EdgeInsets.all(4)),
                                  Opacity(
                                    child: FeeChooser(),
                                    opacity: transactionModel.isPSBTFinalized
                                        ? 0.1
                                        : 1,
                                  ),
                                ],
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
                                        Settings().displayUnit ==
                                                DisplayUnit.btc
                                            ? "assets/icons/ic_bitcoin_straight.svg"
                                            : "assets/icons/ic_sats.svg",
                                        color: Color(0xff808080),
                                      )),
                                ),
                                Container(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    getFormattedAmount(psbt.fee),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall!
                                        .copyWith(
                                          color: EnvoyNewColors
                                              .EnvoyColors.textPrimary,
                                          fontSize: 15,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  alignment: Alignment(0, 0),
                                  child: SizedBox.square(
                                      dimension: 12,
                                      child: SvgPicture.asset(
                                        Settings().displayUnit ==
                                                DisplayUnit.btc
                                            ? "assets/icons/ic_bitcoin_straight.svg"
                                            : "assets/icons/ic_sats.svg",
                                        color: Color(0xff808080),
                                      )),
                                ),
                                Text(
                                  "${ExchangeRate().getFormattedAmount(psbt.fee)}",
                                  textAlign:
                                      Settings().displayUnit == DisplayUnit.btc
                                          ? TextAlign.start
                                          : TextAlign.end,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall!
                                      .copyWith(
                                        color: EnvoyNewColors
                                            .EnvoyColors.textPrimary,
                                        fontSize: 15,
                                      ),
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
                                "Total",

                                /// TODO: figma localize
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
                                      color: Colors.white,
                                    ),
                                    Consumer(builder: (context, ref, child) {
                                      // final spendTimeEstimationProvider = ref.watch(spendTimeEstimationProvider);
                                      return Text(
                                        "10 min",
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
                                        Settings().displayUnit ==
                                                DisplayUnit.btc
                                            ? "assets/icons/ic_bitcoin_straight.svg"
                                            : "assets/icons/ic_sats.svg",
                                        color: Color(0xff808080),
                                      )),
                                ),
                                Container(
                                  alignment: Alignment.centerRight,
                                  padding: EdgeInsets.only(
                                      left: Settings().displayUnit ==
                                              DisplayUnit.btc
                                          ? 4
                                          : 0,
                                      right: Settings().displayUnit ==
                                              DisplayUnit.btc
                                          ? 0
                                          : 8),
                                  child: Text(
                                    "${getFormattedAmount(amount, trailingZeroes: true)}",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall!
                                        .copyWith(
                                          color: EnvoyNewColors
                                              .EnvoyColors.textPrimary,
                                          fontSize: 15,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                                ExchangeRate().getFormattedAmount(amount,
                                    wallet: account.wallet),
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall!
                                    .copyWith(
                                      color: EnvoyNewColors
                                          .EnvoyColors.textPrimary,
                                      fontSize: 15,
                                    )),
                          ],
                        )),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Special warning if we are sending the whole balance
          if (account.wallet.balance == (amount + psbt.fee))
            SliverToBoxAdapter(
              child: ListTile(
                subtitle: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        S().send_reviewScreen_sendMaxWarning,
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
                  EnvoyButton(
                    S().coincontrol_tx_detail_cta2,
                    type: EnvoyButtonTypes.secondary,
                    onTap: () {
                      ///indicating that we are in edit mode
                      ref.read(spendEditModeProvider.notifier).state = true;

                      ///toggle to coins view for coin control
                      ref.read(accountToggleStateProvider.notifier).state =
                          AccountToggleState.Coins;
                      context.go(ROUTE_ACCOUNT_DETAIL);
                    },
                  ),
                  Padding(padding: EdgeInsets.all(6)),
                  EnvoyButton(
                    account.wallet.hot
                        ? S().coincontrol_tx_detail_cta1
                        : S().stalls_before_sending_tx_cta1,
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
    );
  }

  Widget _whiteContainer({required Widget child}) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        constraints: BoxConstraints(
          minHeight: 34,
        ),
        alignment: Alignment.centerLeft,
        width: double.infinity,
        decoration: BoxDecoration(
            borderRadius:
                BorderRadius.all(Radius.circular(constraints.maxWidth)),
            color: Colors.white),
        padding:
            EdgeInsets.symmetric(vertical: 6, horizontal: EnvoySpacing.small),
        child: child,
      );
    });
  }
}
