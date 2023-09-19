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
    TextStyle _textStyleWallet =
        Theme.of(context).textTheme.titleMedium!.copyWith(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            );

    TextStyle _textStyleWalletName =
        Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            );

    TextStyle _textStyleFiat = Theme.of(context).textTheme.titleSmall!.copyWith(
          color: EnvoyColors.grey,
          fontSize: 11,
          fontWeight: FontWeight.w400,
        );

    TextStyle _textStyleAmountSatBtc =
        Theme.of(context).textTheme.headlineSmall!.copyWith(
              color: EnvoyColors.grey,
              fontSize: 24,
              fontWeight: FontWeight.w400,
            );

    ref.watch(accountManagerProvider);
    var account = widget.account.wallet is GhostWallet
        ? widget.account
        : ref.watch(accountStateProvider(widget.account.id!));

    int balance = widget.account.wallet is GhostWallet
        ? 0
        : ref.watch(accountBalanceProvider(account!.id));

    return CardSwipeWrapper(
      height: containerHeight,
      account: account!,
      child: Container(
        height: containerHeight,
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
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(22)),
              border: Border.all(
                  color: account.color, width: 2, style: BorderStyle.solid)),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(22)),
            child: GestureDetector(
              onTap: widget.onTap,
              child: Stack(children: [
                Positioned.fill(
                  child: CustomPaint(
                    willChange: false,
                    isComplex: true,
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
                                    account.name,
                                    style: _textStyleWallet,
                                  ),
                                  Text(
                                    Devices()
                                        .getDeviceName(account.deviceSerial),
                                    style: _textStyleWalletName,
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Container(
                                  width:
                                      account.wallet.network == Network.Testnet
                                          ? null
                                          : containerHeight / 2.2,
                                  height: containerHeight / 2.2,
                                  decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(
                                          containerHeight / 2),
                                      border: Border.all(
                                          color: account.color,
                                          width: 3,
                                          style: BorderStyle.solid)),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(9.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          if (account.wallet.network ==
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
                                          getAccountIcon(account),
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
                              balanceHideStateStatusProvider(account.id));
                          if (hide) {
                            return Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(22))),
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
                                                    Radius.circular(22)))),
                                      ),
                                      SizedBox(
                                          width: 50,
                                          height: 15,
                                          child: Container(
                                              width: double.infinity,
                                              height: double.infinity,
                                              decoration: BoxDecoration(
                                                  color: Color(0xffEEEEEE),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              22)))))
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                          return Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(17))),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 13.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                            height: 20,
                                            child: getUnitIcon(widget.account)),
                                        Padding(
                                            padding: const EdgeInsets.only(
                                                right: 2.0)),
                                        FittedBox(
                                          fit: BoxFit.fitWidth,
                                          child: account.dateSynced == null ||
                                                  hide
                                              ? LoaderGhost(
                                                  width: 200,
                                                  height: 20,
                                                )
                                              : Text(
                                                  getFormattedAmount(balance,
                                                      testnet: account
                                                              .wallet.network ==
                                                          Network.Testnet),
                                                  style: _textStyleAmountSatBtc,
                                                ),
                                        ),
                                      ],
                                    ),
                                    account.dateSynced == null || hide
                                        ? LoaderGhost(
                                            width: 50,
                                            height: 15,
                                          )
                                        : Flexible(
                                            child: Text(
                                              ExchangeRate().getFormattedAmount(
                                                  balance,
                                                  wallet:
                                                      widget.account.wallet),
                                              style: _textStyleFiat,
                                            ),
                                          )
                                  ],
                                ),
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
    if (account.wallet.hot) {
      return SvgPicture.asset(
        "assets/icons/ic_wallet_coins.svg",
        height: 20,
        width: 20,
        color: Colors.white,
      );
    }
    if (!account.wallet.hot) {
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
