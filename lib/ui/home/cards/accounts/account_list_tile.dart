// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/settings.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/state/accounts_state.dart';
import 'package:envoy/ui/state/hide_balance_state.dart';
import 'package:envoy/ui/widgets/card_swipe_wrapper.dart';
import 'package:envoy/util/amount.dart';
import 'package:flutter/material.dart';
import 'package:envoy/business/account.dart';
import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/ui/background.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:envoy/business/devices.dart';
import 'package:envoy/ui/loader_ghost.dart';
import 'package:wallet/wallet.dart';

class AccountListTile extends ConsumerStatefulWidget {
  final void Function() onTap;
  final Account account;

  AccountListTile(
    this.account, {
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  ConsumerState<AccountListTile> createState() => _AccountListTileState();
}

class _AccountListTileState extends ConsumerState<AccountListTile> {
  final double containerHeight = 110;

  _redraw() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    // Redraw when we fetch exchange rate
    ExchangeRate().addListener(_redraw);

    // Redraw when we change bitcoin unit
    Settings().addListener(_redraw);
  }

  @override
  void dispose() {
    ExchangeRate().removeListener(_redraw);
    Settings().removeListener(_redraw);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(accountManagerProvider);
    return CardSwipeWrapper(
      height: containerHeight,
      account: widget.account,
      child: Container(
        height: containerHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          border: Border.all(
              color: Colors.black, width: 2, style: BorderStyle.solid),
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                widget.account.color,
                Colors.black,
              ]),
        ),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(18)),
              border: Border.all(
                  color: widget.account.color,
                  width: 2,
                  style: BorderStyle.solid)),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            child: GestureDetector(
              onTap: widget.onTap,
              child: Stack(children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: LinesPainter(
                        color: EnvoyColors.tilesLineDarkColor, opacity: 1.0),
                  ),
                ),
                Positioned.fill(
                    child: Column(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 13),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.account.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .copyWith(color: Colors.white),
                                  ),
                                  Text(
                                    Devices().getDeviceName(
                                        widget.account.deviceSerial),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .copyWith(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Container(
                                  width: widget.account.wallet.network ==
                                          Network.Testnet
                                      ? null
                                      : containerHeight / 2.2,
                                  height: containerHeight / 2.2,
                                  decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(
                                          containerHeight / 2),
                                      border: Border.all(
                                          color: widget.account.color,
                                          width: 3,
                                          style: BorderStyle.solid)),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(9.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          if (widget.account.wallet.network ==
                                              Network.Testnet)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 7.0),
                                              child: Text(
                                                "Testnet",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall!
                                                    .copyWith(
                                                        fontSize: 12,
                                                        color: Colors.white),
                                              ),
                                            ),
                                          getAccountIcon(widget.account),
                                        ],
                                      ),
                                    ),
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Consumer(
                        builder: (context, ref, child) {
                          final hide = ref.watch(
                              balanceHideStateStatusProvider(widget.account));
                          if (hide) {
                            return Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(16))),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 13.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: 200,
                                      height: 20,
                                      child: Container(
                                          width: double.infinity,
                                          height: double.infinity,
                                          decoration: BoxDecoration(
                                              color: Color(0xffEEEEEE),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(20)))),
                                    ),
                                    SizedBox(
                                        width: 50,
                                        height: 15,
                                        child: Container(
                                            width: double.infinity,
                                            height: double.infinity,
                                            decoration: BoxDecoration(
                                                color: Color(0xffEEEEEE),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20)))))
                                  ],
                                ),
                              ),
                            );
                          }
                          return Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(16))),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 13.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  FittedBox(
                                    fit: BoxFit.fitWidth,
                                    child: widget.account.dateSynced == null ||
                                            hide
                                        ? LoaderGhost(
                                            width: 200,
                                            height: 20,
                                          )
                                        : Text(
                                            getFormattedAmount(
                                                widget.account.wallet.balance,
                                                includeUnit: true,
                                                testnet: widget.account.wallet
                                                        .network ==
                                                    Network.Testnet),
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineSmall!
                                                .copyWith(
                                                    color: EnvoyColors.grey),
                                          ),
                                  ),
                                  widget.account.dateSynced == null || hide
                                      ? LoaderGhost(
                                          width: 50,
                                          height: 15,
                                        )
                                      : Text(
                                          ExchangeRate().getFormattedAmount(
                                              widget.account.wallet.balance),
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall!
                                              .copyWith(
                                                  color: EnvoyColors.grey),
                                        )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ))
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget getAccountIcon(Account account) {
    if (widget.account.wallet.hot) {
      return SvgPicture.asset(
        "assets/icons/ic_wallet_coins.svg",
        height: 20,
        width: 20,
        color: Colors.white,
      );
    }
    if (!widget.account.wallet.hot) {
      return SvgPicture.asset(
        "assets/icons/ic_passport_account.svg",
        height: 26,
        width: 26,
        color: Colors.white,
      );
    }
    return SvgPicture.asset(
      "assets/icons/bitcoin.svg",
      height: 20,
      width: 20,
      color: Colors.white,
    );
  }
}
