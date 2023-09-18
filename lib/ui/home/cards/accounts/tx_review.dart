// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:animations/animations.dart';
import 'package:envoy/business/devices.dart';
import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/ui/amount_entry.dart';
import 'package:envoy/ui/background.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/envoy_icons.dart';
import 'package:envoy/ui/home/cards/accounts/send_card.dart';
import 'package:envoy/ui/home/cards/navigation_card.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/state/send_screen_state.dart';
import 'package:envoy/util/amount.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rive/rive.dart' as Rive;
import 'package:tor/tor.dart';
import 'package:wallet/wallet.dart';
import 'package:flutter/material.dart';
import 'package:envoy/business/account.dart';
import 'package:envoy/util/envoy_storage.dart';

//ignore: must_be_immutable
class TxReview extends ConsumerStatefulWidget with NavigationCard {
  final Psbt psbt;
  final Account account;
  final GestureTapCallback onFinishNavigationClick;

  TxReview(this.psbt, this.account,
      {this.navigator, required this.onFinishNavigationClick})
      : super(key: UniqueKey()) {}

  @override
  IconData? rightFunctionIcon = null;

  @override
  bool modal = true;

  @override
  CardNavigator? navigator;

  @override
  Function()? onPop;

  @override
  Widget? optionsWidget = null;

  @override
  Function()? rightFunction;

  @override
  String? title = S().send_qr_code_heading.toUpperCase();

  @override
  ConsumerState<TxReview> createState() => _TxReviewState();
}

class _TxReviewState extends ConsumerState<TxReview> {
  bool _showBroadcastProgress = false;

  //TODO: disable note
  // String _txNote = "";

  @override
  Widget build(BuildContext context) {
    int amount = ref.watch(spendAmountProvider);
    AmountDisplayUnit unit = ref.watch(sendScreenUnitProvider);
    String address = ref.watch(spendAddressProvider);

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
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 18, horizontal: 8),
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
                            padding: const EdgeInsets.symmetric(vertical: 32.0),
                            child: Text(
                              S().stalls_before_sending_tx_subheading,
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
                    ),
                    SliverToBoxAdapter(
                      child: Container(
                        height: 184,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          border: Border.all(
                              color: Colors.black,
                              width: 2,
                              style: BorderStyle.solid),
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                EnvoyColors.darkCopper,
                                Colors.black,
                              ]),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(18)),
                              border: Border.all(
                                  color: EnvoyColors.brown,
                                  width: 2,
                                  style: BorderStyle.solid)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                            child: GestureDetector(
                              onTap: () {},
                              child: Stack(children: [
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: LinesPainter(
                                        color: EnvoyColors.tilesLineDarkColor,
                                        opacity: 1.0),
                                  ),
                                ),
                                Positioned.fill(
                                    child: Column(
                                  children: [
                                    Padding(padding: EdgeInsets.all(6)),
                                    Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 13),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    widget.account.name,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium!
                                                        .copyWith(
                                                            color:
                                                                Colors.white),
                                                  ),
                                                  Text(
                                                    Devices().getDeviceName(
                                                        widget.account
                                                            .deviceSerial),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleSmall!
                                                        .copyWith(
                                                            color:
                                                                Colors.white),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 12),
                                              child: Container(
                                                  height: 44,
                                                  width: 44,
                                                  decoration: BoxDecoration(
                                                      color: Colors.black
                                                          .withOpacity(0.6),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              44),
                                                      border: Border.all(
                                                          color:
                                                              EnvoyColors.brown,
                                                          width: 3,
                                                          style: BorderStyle
                                                              .solid)),
                                                  child: Center(
                                                    child: Container(
                                                      alignment:
                                                          Alignment.center,
                                                      child: Container(
                                                        child: SvgPicture.asset(
                                                          "assets/i.svg",
                                                          height: 22,
                                                          width: 22,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  )),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(padding: EdgeInsets.all(6)),
                                    Expanded(
                                      flex: 5,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16))),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12.0, vertical: 4),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              _buildTxListItem(
                                                  icon: EnvoyIcon(
                                                    icon: 'ic_spend.svg',
                                                    size: 14,
                                                  ),
                                                  title: S()
                                                      .stalls_before_sending_tx_address,
                                                  tail: Row(
                                                    children: [
                                                      Expanded(
                                                          child: Text(
                                                              "${address}",
                                                              textAlign:
                                                                  TextAlign.end,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis))
                                                    ],
                                                  )),
                                              _buildTxListItem(
                                                  icon: EnvoyIcon(
                                                    icon:
                                                        'ic_bitcoin_circle.svg',
                                                    size: 16,
                                                  ),
                                                  title: S()
                                                      .stalls_before_sending_tx_amount,
                                                  tail: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text(
                                                            getDisplayAmount(
                                                              amount,
                                                              unit ==
                                                                      AmountDisplayUnit
                                                                          .fiat
                                                                  ? AmountDisplayUnit
                                                                          .values[
                                                                      Settings()
                                                                          .displayUnit
                                                                          .index]
                                                                  : unit,
                                                            ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            textAlign:
                                                                TextAlign.end,
                                                          ),
                                                          displayIcon(
                                                              widget.account,
                                                              unit),
                                                        ],
                                                      ),
                                                      Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  2)),
                                                      Text(
                                                        "${ExchangeRate().getFormattedAmount(amount, wallet: widget.account.wallet)}",
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodySmall,
                                                      ),
                                                      Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  3)),
                                                    ],
                                                  )),
                                              _buildTxListItem(
                                                  icon: EnvoyIcon(
                                                    icon: 'ic_compass.svg',
                                                    size: 16,
                                                  ),
                                                  title: S()
                                                      .stalls_before_sending_tx_txid,
                                                  tail: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                            "${widget.psbt.txid}",
                                                            textAlign:
                                                                TextAlign.end,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis),
                                                      )
                                                    ],
                                                  )),
                                              //TODO: disable notes
                                              // _buildTxListItem(
                                              //     icon: EnvoyIcon(
                                              //       icon: 'ic_note.svg',
                                              //       size: 16,
                                              //     ),
                                              //     title: S()
                                              //         .stalls_before_sending_tx_add_note,
                                              //     tail: InkWell(
                                              //       onTap: () {
                                              //         _showNoteDialog(context);
                                              //       },
                                              //       child: Row(
                                              //         mainAxisAlignment:
                                              //             MainAxisAlignment.end,
                                              //         children: [
                                              //           Expanded(
                                              //               child: Text(
                                              //             "${_txNote}",
                                              //             maxLines: 2,
                                              //             textAlign:
                                              //                 TextAlign.end,
                                              //             overflow: TextOverflow
                                              //                 .ellipsis,
                                              //           )),
                                              //           Padding(
                                              //               padding:
                                              //                   EdgeInsets.all(
                                              //                       4)),
                                              //           InkWell(
                                              //             onTap: () {
                                              //               _showNoteDialog(
                                              //                   context);
                                              //             },
                                              //             child: Container(
                                              //               height: 18,
                                              //               width: 18,
                                              //               decoration:
                                              //                   BoxDecoration(
                                              //                 color: EnvoyColors
                                              //                     .darkTeal,
                                              //                 borderRadius:
                                              //                     BorderRadius
                                              //                         .circular(
                                              //                             18),
                                              //               ),
                                              //               child: Icon(
                                              //                 Icons.add,
                                              //                 size: 18,
                                              //                 color:
                                              //                     Colors.white,
                                              //               ),
                                              //             ),
                                              //           )
                                              //         ],
                                              //       ),
                                              //     )),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ))
                              ]),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Special warning if we are sending the whole balance
                    if (widget.account.wallet.balance ==
                        (amount + widget.psbt.fee))
                      SliverToBoxAdapter(
                        child: ListTile(
                          subtitle: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 24, horizontal: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  S().send_reviewScreen_sendMaxWarning,
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
                      ),
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 18, vertical: 44),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            EnvoyButton(
                              S().stalls_before_sending_tx_cta2,
                              type: EnvoyButtonTypes.secondary,
                              onTap: () {
                                widget.navigator?.pop();
                              },
                            ),
                            Padding(padding: EdgeInsets.all(6)),
                            EnvoyButton(
                              S().stalls_before_sending_tx_cta1,
                              onTap: () {
                                setState(() {
                                  _showBroadcastProgress = true;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTxListItem(
      {required Widget icon, required String title, required Widget tail}) {
    return Builder(
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          child: Row(
            children: [
              Flexible(
                flex: 4,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.only(right: 8),
                      child: icon,
                    ),
                    Text(
                      title,
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              Flexible(
                flex: 6,
                child: tail,
              )
            ],
          ),
        );
      },
    );
  }

  //TODO: disable notes
  // void _showNoteDialog(BuildContext context) {
  //   FocusNode focusNode = FocusNode();
  //   bool isKeyboardShown = false;
  //   showEnvoyDialog(
  //     context: context,
  //     dialog: Builder(
  //       builder: (context) {
  //         var textEntry = TextEntry(
  //           focusNode: focusNode,
  //           placeholder: _txNote,
  //         );
  //         if (!isKeyboardShown) {
  //           Future.delayed(Duration(milliseconds: 200)).then((value) {
  //             FocusScope.of(context).requestFocus(focusNode);
  //           });
  //           isKeyboardShown = true;
  //         }
  //         return EnvoyDialog(
  //           content: Column(
  //             children: [
  //               Padding(padding: EdgeInsets.all(8)),
  //               Text(
  //                 S().stalls_before_sending_tx_add_note,
  //                 style: Theme.of(context).textTheme.titleLarge,
  //                 textAlign: TextAlign.center,
  //               ),
  //               Padding(
  //                 padding:
  //                     const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
  //                 child: Text(
  //                   "Transaction notes can be useful when making future spends.",
  //                   textAlign: TextAlign.center,
  //                 ),
  //               ),
  //               Padding(padding: EdgeInsets.all(8)),
  //               textEntry
  //             ],
  //           ),
  //           actions: [
  //             EnvoyButton(
  //               S().component_save.toUpperCase(),
  //               onTap: () async {
  //                 await EnvoyStorage()
  //                     .addTxNote(textEntry.enteredText, widget.psbt.txid);
  //                 setState(() {
  //                   _txNote = textEntry.enteredText;
  //                 });
  //                 Navigator.pop(context);
  //               },
  //             ),
  //           ],
  //         );
  //       },
  //     ),
  //   );
  // }

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
              widget.onFinishNavigationClick();
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
    setState(() {
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
      await widget.account.wallet.getChangeAddress();

      //Broadcast transaction
      await widget.account.wallet.broadcastTx(
          Settings().electrumAddress(widget.account.wallet.network),
          Tor().port,
          widget.psbt.rawTx);

      await EnvoyStorage().addPendingTx(
          widget.psbt.txid,
          widget.account.id!,
          DateTime.now(),
          TransactionType.pending,
          widget.psbt.sent + widget.psbt.fee);

      //wait for animation
      await Future.delayed(Duration(seconds: 1));
      _stateMachineController?.findInput<bool>("indeterminate")?.change(false);
      _stateMachineController?.findInput<bool>("happy")?.change(true);
      _stateMachineController?.findInput<bool>("unhappy")?.change(false);
      await Future.delayed(Duration(milliseconds: 1000));
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
