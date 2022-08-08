// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/settings.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:envoy/business/account.dart';
import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/ui/background.dart';
import 'package:envoy/ui/amount.dart';
import 'package:flutter_svg/svg.dart';
import 'package:envoy/business/devices.dart';
import 'package:envoy/ui/loader_ghost.dart';
import 'package:wallet/wallet.dart';

class AccountListTile extends StatefulWidget {
  final void Function() onTap;
  final Account account;

  AccountListTile(
    this.account, {
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  State<AccountListTile> createState() => _AccountListTileState();
}

class _AccountListTileState extends State<AccountListTile> {
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
    return Container(
      height: containerHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        border:
            Border.all(color: Colors.black, width: 2, style: BorderStyle.solid),
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
                                      .subtitle1!
                                      .copyWith(color: Colors.white),
                                ),
                                Text(
                                  Devices().getDeviceName(
                                      widget.account.deviceSerial),
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle2!
                                      .copyWith(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Container(
                              width: containerHeight / 2.2,
                              height: containerHeight / 2.2,
                              decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(
                                      containerHeight / 2),
                                  border: Border.all(
                                      color: widget.account.color,
                                      width: 3,
                                      style: BorderStyle.solid)),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: SvgPicture.asset(
                                  "assets/bitcoin.svg",
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(16))),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 13.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            FittedBox(
                              fit: BoxFit.fitWidth,
                              child: !widget.account.initialSyncCompleted
                                  ? LoaderGhost(
                                      width: 200,
                                      height: 30,
                                    )
                                  : Text(
                                      getFormattedAmount(
                                          widget.account.wallet.balance,
                                          includeUnit: true),
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline5!
                                          .copyWith(color: EnvoyColors.grey),
                                    ),
                            ),
                            !widget.account.initialSyncCompleted
                                ? LoaderGhost(
                                    width: 50,
                                    height: 25,
                                  )
                                : Text(
                                    widget.account.wallet.network ==
                                            Network.Testnet
                                        ? "TESTNET"
                                        : ExchangeRate().getFormattedAmount(
                                            widget.account.wallet.balance),
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle2!
                                        .copyWith(color: EnvoyColors.grey),
                                  )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ))
            ]),
          ),
        ),
      ),
    );
  }
}
