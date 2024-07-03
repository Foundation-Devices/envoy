// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/account.dart';
import 'package:envoy/business/devices.dart';
import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/background.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
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
import 'package:envoy/util/envoy_storage.dart';
import 'package:envoy/ui/state/home_page_state.dart';

class AccountListTile extends ConsumerStatefulWidget {
  final void Function() onTap;
  final Account account;
  final bool draggable;

  const AccountListTile(
    this.account, {
    super.key,
    required this.onTap,
    this.draggable = true,
  });

  @override
  ConsumerState<AccountListTile> createState() => _AccountListTileState();
}

class _AccountListTileState extends ConsumerState<AccountListTile> {
  final double containerHeight = 114;

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
    var account = widget.account.wallet is GhostWallet
        ? widget.account
        : ref.watch(accountStateProvider(widget.account.id!));

    if (account == null) {
      return const SizedBox.shrink();
    }

    int balance = widget.account.wallet is GhostWallet
        ? 0
        : ref.watch(accountBalanceProvider(account.id));

    double cardRadius = EnvoySpacing.medium2;

    return CardSwipeWrapper(
      height: containerHeight,
      draggable: widget.draggable,
      account: account,
      child: Container(
        height: containerHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(cardRadius - 1)),
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
              borderRadius: BorderRadius.all(Radius.circular(cardRadius - 3)),
              border: Border.all(
                  color: account.color, width: 2, style: BorderStyle.solid)),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(cardRadius - 5)),
            child: GestureDetector(
              onTap: () {
                EnvoyStorage().addPromptState(
                    DismissiblePrompt.userInteractedWithAccDetail);
                widget.onTap();
              },
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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: EnvoySpacing.medium1 - EnvoySpacing.xs,
                          vertical: EnvoySpacing.small - 3,
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    DefaultTextStyle(
                                      style: EnvoyTypography.subheading
                                          .copyWith(
                                              color: EnvoyColors.solidWhite),
                                      child: Text(
                                        account.name,
                                        style: EnvoyTypography.subheading
                                            .copyWith(
                                                color: EnvoyColors.solidWhite),
                                      ),
                                    ),
                                    DefaultTextStyle(
                                      style: EnvoyTypography.info.copyWith(
                                          color: EnvoyColors.solidWhite),
                                      child: Text(
                                        Devices().getDeviceName(
                                            account.deviceSerial),
                                        style: EnvoyTypography.info.copyWith(
                                            color: EnvoyColors.solidWhite),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              AccountBadge(account: account),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 30,
                      margin: const EdgeInsets.all(EnvoySpacing.xs),
                      child: Consumer(
                        builder: (context, ref, child) {
                          final hide = ref.watch(
                              balanceHideStateStatusProvider(account.id));
                          if (hide || account.dateSynced == null) {
                            return Container(
                              decoration: ShapeDecoration(
                                color: const Color(0xFFF8F8F8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      EnvoySpacing.medium1),
                                ),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    LoaderGhost(
                                      width: 200,
                                      height: 22,
                                      animate: account.dateSynced == null,
                                    ),
                                    LoaderGhost(
                                      width: 50,
                                      height: 18,
                                      animate: account.dateSynced == null,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return Container(
                            decoration: ShapeDecoration(
                              color: const Color(0xFFF8F8F8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    cardRadius - (EnvoySpacing.small)),
                              ),
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: EnvoyAmount(
                                  account: widget.account,
                                  amountSats: balance,
                                  amountWidgetStyle:
                                      AmountWidgetStyle.singleLine),
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
    bool isSignet = account?.wallet.network == Network.Signet;

    bool isNotCircular = isTestnet || isTaproot || isSignet;
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
                    if (isTestnet || isSignet)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: EnvoySpacing.xs),
                        child: Text(
                            isTestnet
                                ? S().account_type_sublabel_testnet
                                : "Signet",
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
                        child: DefaultTextStyle(
                          style: EnvoyTypography.info
                              .copyWith(color: Colors.white),
                          child: Text(
                            S().account_type_label_taproot,
                            style: EnvoyTypography.info
                                .copyWith(color: Colors.white),
                          ),
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
