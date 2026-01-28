// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/account/sync_manager.dart';
import 'package:envoy/business/devices.dart';
import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/amount_widget.dart';
import 'package:envoy/ui/components/stripe_painter.dart';
import 'package:envoy/ui/loader_ghost.dart';
import 'package:envoy/ui/state/accounts_state.dart';
import 'package:envoy/ui/state/hide_balance_state.dart';
import 'package:envoy/ui/state/home_page_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/card_swipe_wrapper.dart';
import 'package:envoy/ui/widgets/color_util.dart';
import 'package:envoy/ui/widgets/envoy_amount_widget.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ngwallet/ngwallet.dart';

class AccountListTile extends ConsumerStatefulWidget {
  final void Function() onTap;
  final EnvoyAccount account;
  final bool draggable;
  final bool inactive;
  final bool useHero;

  const AccountListTile(
    this.account, {
    super.key,
    required this.onTap,
    this.draggable = true,
    this.inactive = false,
    this.useHero = true,
  });

  @override
  ConsumerState<AccountListTile> createState() => _AccountListTileState();
}

class _AccountListTileState extends ConsumerState<AccountListTile> {
  final double containerHeight = 114;

  @override
  void initState() {
    super.initState();
    // Redraw when we fetch exchange rate
    ExchangeRate().addListener(_redraw);
  }

  @override
  void dispose() {
    ExchangeRate().removeListener(_redraw);
    super.dispose();
  }

  void _redraw() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(settingsProvider);
    ref.watch(accountsProvider);
    final currentProgress = ref.watch(accountSync);
    final requiredScan = ref.watch(isAccountRequiredScan(widget.account));
    bool isScanning = false;
    if (currentProgress is Scanning) {
      isScanning = currentProgress.id == widget.account.id;
    }
    if (requiredScan) {
      isScanning = true;
    }
    EnvoyAccount? account = ref.watch(accountStateProvider(widget.account.id));
    if (widget.account.xfp == "ghost") {
      account = widget.account;
    }
    if (account == null) {
      return const SizedBox.shrink();
    }
    int balance = widget.account.xfp == "ghost"
        ? 0
        : ref.watch(accountBalanceProvider(account.id));

    double cardRadius = EnvoySpacing.medium2;

    Widget tile = Opacity(
      opacity: widget.inactive ? 0.4 : 1.0,
      child: CardSwipeWrapper(
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
                fromHex(account.color),
                Colors.black,
              ],
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(cardRadius - 3)),
              border: Border.all(
                  color: fromHex(account.color),
                  width: 2,
                  style: BorderStyle.solid),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(cardRadius - 4)),
              child: GestureDetector(
                onTap: widget.inactive
                    ? null
                    : () {
                        EnvoyStorage().addPromptState(
                          DismissiblePrompt.userInteractedWithAccDetail,
                        );
                        widget.onTap();
                      },
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        isComplex: true,
                        willChange: false,
                        painter: StripePainter(
                          EnvoyColors.gray1000.applyOpacity(0.4),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal:
                                    EnvoySpacing.medium1 - EnvoySpacing.xs,
                                vertical: EnvoySpacing.small - 3,
                              ),
                              child: Center(
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
                                          DefaultTextStyle(
                                            style: EnvoyTypography.subheading
                                                .copyWith(
                                                    color:
                                                        EnvoyColors.solidWhite),
                                            child: Text(
                                              account.name,
                                              style: EnvoyTypography.subheading
                                                  .copyWith(
                                                color: EnvoyColors.solidWhite,
                                              ),
                                            ),
                                          ),
                                          DefaultTextStyle(
                                            style: EnvoyTypography.info
                                                .copyWith(
                                                    color:
                                                        EnvoyColors.solidWhite),
                                            child: Text(
                                              Devices().getDeviceName(
                                                  account.deviceSerial ?? ""),
                                              style:
                                                  EnvoyTypography.info.copyWith(
                                                color: EnvoyColors.solidWhite,
                                              ),
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
                                  balanceHideStateStatusProvider(account!.id),
                                );

                                if (hide || isScanning) {
                                  return Container(
                                    decoration: ShapeDecoration(
                                      color: const Color(0xFFF8F8F8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            EnvoySpacing.medium1),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: EnvoySpacing.xs),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          LoaderGhost(
                                            width: 200,
                                            height: 24,
                                            animate: isScanning,
                                          ),
                                          LoaderGhost(
                                            width: 50,
                                            height: 24,
                                            animate: isScanning,
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
                                        cardRadius - EnvoySpacing.small,
                                      ),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: EnvoyAmount(
                                      account: widget.account,
                                      amountSats: balance.toInt(),
                                      amountWidgetStyle:
                                          AmountWidgetStyle.singleLine,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (!widget.useHero) {
      return tile;
    }

    return Hero(
      tag: "account_card_${account.id}",
      child: tile,
    );
  }
}

class AccountBadge extends StatelessWidget {
  const AccountBadge({
    super.key,
    required this.account,
  });

  final EnvoyAccount account;
  final double containerHeight = 100;

  @override
  Widget build(BuildContext context) {
    bool isTestnet = account.network == Network.testnet ||
        account.network == Network.testnet4;
    bool isSignet = account.network == Network.signet;

    bool isNotCircular = isTestnet || isSignet;
    return Container(
        width: (isNotCircular) ? null : containerHeight / 2,
        height: containerHeight / 2.0,
        decoration: BoxDecoration(
            color: Colors.black.applyOpacity(0.6),
            borderRadius: isNotCircular
                ? BorderRadius.circular(containerHeight / 2)
                : null,
            shape: isNotCircular ? BoxShape.rectangle : BoxShape.circle,
            border: Border.all(
                color: fromHex(account.color),
                width: 3,
                style: BorderStyle.solid)),
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
                            style: EnvoyTypography.info
                                .copyWith(color: Colors.white)),
                      ),
                  ],
                ),
                BadgeIcon(
                  account: account,
                ),
              ],
            ),
          ),
        ));
  }
}

class BadgeIcon extends StatelessWidget {
  const BadgeIcon({super.key, required this.account});

  final EnvoyAccount account;

  @override
  Widget build(BuildContext context) {
    if (account.isHot) {
      return SvgPicture.asset(
        "assets/icons/ic_wallet_coins.svg",
        height: 24,
        width: 24,
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      );
    }
    if (!account.isHot) {
      Device? device = Devices().getDeviceBySerial(account.deviceSerial ?? "");
      if (device != null && device.type == DeviceType.passportPrime) {
        return EnvoyIcon(
          EnvoyIcons.prime_front,
          color: EnvoyColors.solidWhite,
        );
      }

      return SvgPicture.asset(
        "assets/icons/ic_passport_account.svg",
        height: 24,
        width: 24,
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      );
    }
    return SvgPicture.asset(
      "assets/icons/bitcoin.svg",
      height: 20,
      width: 20,
      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
    );
  }
}
