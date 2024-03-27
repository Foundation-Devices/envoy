// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/account.dart';
import 'package:envoy/business/devices.dart';
import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/background.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/loader_ghost.dart';
import 'package:envoy/ui/state/accounts_state.dart';
import 'package:envoy/ui/state/hide_balance_state.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/card_swipe_wrapper.dart';
import 'package:envoy/ui/widgets/envoy_amount_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wallet/wallet.dart';
import 'package:envoy/ui/components/amount_widget.dart';

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

    ref.watch(accountManagerProvider);
    var account = widget.account.wallet is GhostWallet
        ? widget.account
        : ref.watch(accountStateProvider(widget.account.id!));

    if (account == null) {
      return SizedBox.shrink();
    }

    int balance = widget.account.wallet is GhostWallet
        ? 0
        : ref.watch(accountBalanceProvider(account.id));

    double cardRadius = 26;

    return CardSwipeWrapper(
      height: containerHeight,
      account: account,
      child: Container(
        height: containerHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(cardRadius)),
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
              borderRadius: BorderRadius.all(Radius.circular(cardRadius)),
              border: Border.all(
                  color: account.color, width: 2, style: BorderStyle.solid)),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(cardRadius - 2)),
            child: GestureDetector(
              onTap: widget.onTap,
              child: Stack(children: [
                Positioned.fill(
                  child: CustomPaint(
                    willChange: false,
                    isComplex: true,
                    painter:
                        LinesPainter(color: EnvoyColors.gray1000, opacity: 0.4),
                  ),
                ),
                Positioned.fill(
                    child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: EnvoySpacing.medium1,
                          right: EnvoySpacing.xs,
                          top: EnvoySpacing.xs,
                        ),
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
                            AccountBadge(account: account),
                          ],
                        ),
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: 34,
                            margin: const EdgeInsets.symmetric(
                                horizontal: EnvoySpacing.xs + 2,
                                vertical: EnvoySpacing.xs),
                            child: Container(
                              child: Consumer(
                                builder: (context, ref, child) {
                                  final hide = ref.watch(
                                      balanceHideStateStatusProvider(
                                          account.id));
                                  if (hide || account.dateSynced == null) {
                                    return Container(
                                      decoration: ShapeDecoration(
                                        color: Color(0xFFF8F8F8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              cardRadius + 8),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            LoaderGhost(
                                              width: 200,
                                              height: 22,
                                              animate:
                                                  account.dateSynced == null,
                                            ),
                                            LoaderGhost(
                                              width: 50,
                                              height: 18,
                                              animate:
                                                  account.dateSynced == null,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                  return Container(
                                    decoration: ShapeDecoration(
                                      color: Color(0xFFF8F8F8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            cardRadius + 8),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: EnvoyAmount(
                                          account: widget.account,
                                          amountSats: balance,
                                          amountWidgetStyle:
                                              AmountWidgetStyle.singleLine),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
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
}

class AccountBadge extends StatelessWidget {
  const AccountBadge({
    super.key,
    required this.account,
  });

  final Account? account;
  final double containerHeight = 100;

  @override
  Widget build(BuildContext context) {
    bool isTaproot = account?.wallet.type == WalletType.taproot;
    bool isTestnet = account?.wallet.network == Network.Testnet;
    bool isNotCircular = isTestnet || isTaproot;
    return Container(
        width: (isNotCircular) ? null : containerHeight / 2,
        height: containerHeight / 2.0,
        decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: isNotCircular
                ? BorderRadius.circular(containerHeight / 2)
                : null,
            shape: isNotCircular ? BoxShape.rectangle : BoxShape.circle,
            border: Border.all(
                color: account!.color, width: 3, style: BorderStyle.solid)),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isTestnet)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: EnvoySpacing.xs),
                        child: Text(S().account_type_sublabel_testnet,
                            style: isTaproot
                                ? EnvoyTypography.label
                                    .copyWith(color: Colors.white)
                                : EnvoyTypography.info
                                    .copyWith(color: Colors.white)),
                      ),
                    if (isTaproot)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: EnvoySpacing.xs),
                        child: Text(
                          S().account_type_label_taproot,
                          style: EnvoyTypography.info
                              .copyWith(color: Colors.white),
                        ),
                      ),
                  ],
                ),
                BadgeIcon(
                  account: account!,
                ),
              ],
            ),
          ),
        ));
  }
}

class BadgeIcon extends StatelessWidget {
  const BadgeIcon({super.key, required this.account});

  final Account account;

  @override
  Widget build(BuildContext context) {
    if (account.wallet.hot) {
      return SvgPicture.asset(
        "assets/icons/ic_wallet_coins.svg",
        height: 24,
        width: 24,
        color: Colors.white,
      );
    }
    if (!account.wallet.hot) {
      return SvgPicture.asset(
        "assets/icons/ic_passport_account.svg",
        height: 24,
        width: 24,
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
