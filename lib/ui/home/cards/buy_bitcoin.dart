// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/components/button.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/icon_tab.dart';
import 'package:envoy/ui/components/map_widget.dart';
import 'package:envoy/ui/routes/accounts_router.dart';
import 'package:envoy/ui/shield.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:envoy/ui/home/home_page.dart';
import 'package:envoy/ui/home/home_state.dart';
import 'package:envoy/ui/state/home_page_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:envoy/ui/routes/route_state.dart';
import 'package:envoy/business/region_manager.dart';
import 'package:envoy/util/envoy_storage.dart';

enum BuyBitcoinCardState { buyInEnvoy, peerToPeer, vouchers, atms, none }

class BuyBitcoinCard extends ConsumerStatefulWidget {
  const BuyBitcoinCard({super.key});

  @override
  ConsumerState<BuyBitcoinCard> createState() => _BuyBitcoinCardState();
}

class _BuyBitcoinCardState extends ConsumerState<BuyBitcoinCard>
    with SingleTickerProviderStateMixin {
  BuyBitcoinCardState currentState = BuyBitcoinCardState.buyInEnvoy;
  late AnimationController animationController;
  late Animation<Alignment> animation;
  bool regionCanBuy = false;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    animation =
        Tween(begin: const Alignment(0.0, 1.0), end: const Alignment(0.0, 0.65))
            .animate(CurvedAnimation(
                parent: animationController, curve: Curves.easeInOut));

    Future.delayed(const Duration()).then((value) {
      ref.read(homePageTitleProvider.notifier).state = "";

      ref.read(homeShellOptionsProvider.notifier).state = HomeShellOptions(
          optionsWidget: const CountryOptions(),
          rightAction: Consumer(
            builder: (context, ref, child) {
              bool menuVisible = ref.watch(homePageOptionsVisibilityProvider);
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HomePageState.of(context)?.toggleOptions();
                },
                child: Container(
                  height: 55,
                  width: 55,
                  color: Colors.transparent,
                  child: Icon(
                    menuVisible ? Icons.close : Icons.more_horiz_outlined,
                  ),
                ),
              );
            },
          ));
      String path = ref.read(routePathProvider);

      if (path == ROUTE_BUY_BITCOIN) {
        ref.read(buyBTCPageProvider.notifier).state = true;
      }
      _checkSelectedRegion();
    });
  }

  void _updateState(BuyBitcoinCardState newState) {
    setState(() {
      currentState = newState;
    });
  }

  Future<void> _checkSelectedRegion() async {
    var region = await EnvoyStorage().getCountry();
    if (region != null) {
      bool newRegionCanBuy =
          await AllowedRegions.isRegionAllowed(region.code, region.division);
      if (!newRegionCanBuy) {
        setState(() {
          currentState = BuyBitcoinCardState.none;
        });
      }
      if (newRegionCanBuy != regionCanBuy) {
        setState(() {
          regionCanBuy = newRegionCanBuy;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: EnvoySpacing.medium1, horizontal: EnvoySpacing.medium2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    S().buy_bitcoin_buyOptions_atms_heading,
                    style: EnvoyTypography.subheading,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: EnvoySpacing.medium2,
                  ),
                  IconTab(
                    label: S().buy_bitcoin_buyOptions_card_inEnvoy_heading,
                    isLocked: !regionCanBuy,
                    icon: EnvoyIcons.btc,
                    bigTab: true,
                    isSelected: currentState == BuyBitcoinCardState.buyInEnvoy,
                    description:
                        S().buy_bitcoin_buyOptions_card_inEnvoy_subheading,
                    lockedInfoText: S().buy_bitcoin_buyOptions_card_commingSoon,
                    onSelect: (selected) {
                      if (regionCanBuy) {
                        _updateState(BuyBitcoinCardState.buyInEnvoy);
                      }
                    },
                    poweredByIcons: const [EnvoyIcons.ramp],
                  ),
                  const SizedBox(
                    height: EnvoySpacing.medium2,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: IconTab(
                          label: S().buy_bitcoin_buyOptions_card_peerToPeer,
                          icon: EnvoyIcons.privacy,
                          isSelected:
                              currentState == BuyBitcoinCardState.peerToPeer,
                          onSelect: (selected) {
                            _updateState(BuyBitcoinCardState.peerToPeer);
                          },
                        ),
                      ),
                      const SizedBox(
                        width: EnvoySpacing.xs,
                      ),
                      Expanded(
                        child: IconTab(
                          label: S().buy_bitcoin_buyOptions_card_vouchers,
                          icon: EnvoyIcons.shield,
                          isSelected:
                              currentState == BuyBitcoinCardState.vouchers,
                          onSelect: (selected) {
                            _updateState(BuyBitcoinCardState.vouchers);
                          },
                        ),
                      ),
                      const SizedBox(
                        width: EnvoySpacing.xs,
                      ),
                      Expanded(
                        child: IconTab(
                          label: S().buy_bitcoin_buyOptions_card_atms,
                          icon: EnvoyIcons.location_tab,
                          isSelected: currentState == BuyBitcoinCardState.atms,
                          onSelect: (selected) {
                            _updateState(BuyBitcoinCardState.atms);
                          },
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: EnvoySpacing.medium2),
                    child: Text(
                      additionalInfo(currentState),
                      style: EnvoyTypography.info,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (currentState != BuyBitcoinCardState.none)
                    GestureDetector(
                      onTap: () {
                        showAdditionalInfoDialog(currentState, context);
                      },
                      child: Text(
                        S().component_learnMore,
                        style: EnvoyTypography.button
                            .copyWith(color: EnvoyColors.accentPrimary),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: EnvoySpacing.large1),
            child: EnvoyButton(
              label: S().component_continue,
              type: ButtonType.primary,
              state: currentState == BuyBitcoinCardState.none
                  ? ButtonState.disabled
                  : ButtonState.defaultState,
              icon: currentState == BuyBitcoinCardState.vouchers
                  ? EnvoyIcons.externalLink
                  : null,
              onTap: () {
                switch (currentState) {
                  case BuyBitcoinCardState.buyInEnvoy:
                    context.go(
                      ROUTE_SELECT_ACCOUNT,
                    );
                  case BuyBitcoinCardState.peerToPeer:
                    context.go(
                      ROUTE_PEER_TO_PEER,
                    );
                  case BuyBitcoinCardState.vouchers:
                    launchUrl(Uri.parse("https://azte.co/"));
                  case BuyBitcoinCardState.atms:
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(builder: (context) {
                        return MediaQuery.removePadding(
                            context: context,
                            child: fullScreenShield(const MarkersPage()));
                      }),
                    );
                  case BuyBitcoinCardState.none:
                }
              },
            ),
          )
        ],
      ),
    );
  }
}

String additionalInfo(BuyBitcoinCardState state) {
  switch (state) {
    case BuyBitcoinCardState.peerToPeer:
      return S().buy_bitcoin_buyOptions_peerToPeer_subheading;
    case BuyBitcoinCardState.vouchers:
      return S().buy_bitcoin_buyOptions_vouchers_subheading;
    case BuyBitcoinCardState.atms:
      return S().buy_bitcoin_buyOptions_atms_subheading;
    case BuyBitcoinCardState.none:
      return S().buy_bitcoin_buyOptions_notSupported_subheading;
    case BuyBitcoinCardState.buyInEnvoy:
      return S().buy_bitcoin_buyOptions_inEnvoy_subheading;
  }
}

void showAdditionalInfoDialog(BuyBitcoinCardState state, BuildContext context) {
  EnvoyIcons icon = EnvoyIcons.location;
  String title = "";
  String description = "";
  InfoState addressRequired = InfoState.unknown;
  InfoState bankingInfoRequired = InfoState.unknown;
  InfoState emailRequired = InfoState.unknown;
  InfoState identificationRequired = InfoState.unknown;
  List<EnvoyIcons>? poweredByIcons;

  switch (state) {
    case BuyBitcoinCardState.peerToPeer:
      icon = EnvoyIcons.privacy;
      title = S().buy_bitcoin_buyOptions_card_peerToPeer;
      description = S().buy_bitcoin_buyOptions_peerToPeer_modal_subheading;
      addressRequired = InfoState.notRequired;
      bankingInfoRequired = InfoState.unknown;
      emailRequired = InfoState.unknown;
      identificationRequired = InfoState.notRequired;
      poweredByIcons = [
        EnvoyIcons.hodlHodl,
        EnvoyIcons.bisq,
        EnvoyIcons.robosats,
        EnvoyIcons.peach
      ];
    case BuyBitcoinCardState.vouchers:
      icon = EnvoyIcons.shield;
      title = S().buy_bitcoin_buyOptions_card_vouchers;
      description = S().buy_bitcoin_buyOptions_vouchers_modal_subheading;
      addressRequired = InfoState.notRequired;
      bankingInfoRequired = InfoState.notRequired;
      emailRequired = InfoState.unknown;
      identificationRequired = InfoState.unknown;
      poweredByIcons = [EnvoyIcons.azteco];
    case BuyBitcoinCardState.atms:
      icon = EnvoyIcons.location;
      title = S().buy_bitcoin_buyOptions_card_atms;
      description = S().buy_bitcoin_buyOptions_atms_modal_subheading;
      addressRequired = InfoState.unknown;
      bankingInfoRequired = InfoState.notRequired;
      emailRequired = InfoState.unknown;
      identificationRequired = InfoState.unknown;

    case BuyBitcoinCardState.buyInEnvoy:
      icon = EnvoyIcons.btc;
      title = S().buy_bitcoin_buyOptions_card_inEnvoy_heading;
      description = S().buy_bitcoin_buyOptions_inEnvoy_modal_subheading;
      addressRequired = InfoState.required;
      bankingInfoRequired = InfoState.required;
      emailRequired = InfoState.required;
      identificationRequired = InfoState.required;
      poweredByIcons = [EnvoyIcons.ramp];
    case BuyBitcoinCardState.none:
  }

  showEnvoyDialog(
      context: context,
      dialog: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: BuyOptionDialog(
          icon: icon,
          title: title,
          description: description,
          addressRequired: addressRequired,
          bankingInfoRequired: bankingInfoRequired,
          emailRequired: emailRequired,
          identificationRequired: identificationRequired,
          poweredByIcons: poweredByIcons,
        ),
      ));
}

class BuyOptionDialog extends StatelessWidget {
  const BuyOptionDialog({
    super.key,
    required this.description,
    required this.icon,
    required this.title,
    this.poweredByIcons,
    required this.emailRequired,
    required this.identificationRequired,
    required this.addressRequired,
    required this.bankingInfoRequired,
  });

  final String title;
  final EnvoyIcons icon;
  final String description;

  final InfoState emailRequired;
  final InfoState identificationRequired;
  final InfoState addressRequired;
  final InfoState bankingInfoRequired;

  final List<EnvoyIcons>? poweredByIcons;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(EnvoySpacing.medium2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              child: const EnvoyIcon(EnvoyIcons.close),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: EnvoySpacing.medium2),
            child: EnvoyIcon(
              icon,
              size: EnvoyIconSize.big,
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: EnvoyTypography.subheading,
          ),
          Padding(
            padding: const EdgeInsets.only(top: EnvoySpacing.medium1),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: EnvoyTypography.info,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: EnvoySpacing.medium2),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: EnvoySpacing.medium2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InfoRequired(
                        info: S().buy_bitcoin_buyOptions_modal_email,
                        state: emailRequired,
                      ),
                      const SizedBox(
                        height: EnvoySpacing.medium1,
                      ),
                      InfoRequired(
                        info: S().buy_bitcoin_buyOptions_modal_address,
                        state: addressRequired,
                      ),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InfoRequired(
                        info: S().buy_bitcoin_buyOptions_modal_identification,
                        state: identificationRequired,
                      ),
                      const SizedBox(
                        height: EnvoySpacing.medium1,
                      ),
                      InfoRequired(
                        info: S().buy_bitcoin_buyOptions_modal_bankingInfo,
                        state: bankingInfoRequired,
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          if (poweredByIcons != null)
            Padding(
              padding: const EdgeInsets.only(top: EnvoySpacing.medium2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    S().buy_bitcoin_buyOptions_modal_poweredBy,
                    style: EnvoyTypography.info
                        .copyWith(color: EnvoyColors.textTertiary),
                  ),
                  ...poweredByIcons!.map((icon) => Padding(
                        padding: const EdgeInsets.only(left: EnvoySpacing.xs),
                        child: EnvoyIcon(
                          icon,
                          size: EnvoyIconSize.extraSmall,
                        ),
                      )),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

enum InfoState { required, notRequired, unknown }

class InfoRequired extends StatelessWidget {
  const InfoRequired({
    super.key,
    required this.info,
    required this.state,
  });

  final String info;
  final InfoState state;

  @override
  Widget build(BuildContext context) {
    EnvoyIcons iconData;
    Color iconColor;
    TextStyle textStyle;
    switch (state) {
      case InfoState.required:
        iconData = EnvoyIcons.checked_circle;
        iconColor = EnvoyColors.copper500;
        textStyle = EnvoyTypography.body.copyWith(color: EnvoyColors.copper500);
        break;
      case InfoState.notRequired:
        iconData = EnvoyIcons.close_circle;
        iconColor = EnvoyColors.accentPrimary;
        textStyle =
            EnvoyTypography.body.copyWith(color: EnvoyColors.accentPrimary);
        break;
      case InfoState.unknown:
        iconData = EnvoyIcons.unknown_circle;
        iconColor = EnvoyColors.textTertiary;
        textStyle =
            EnvoyTypography.body.copyWith(color: EnvoyColors.textTertiary);
        break;
    }

    return Row(
      children: [
        EnvoyIcon(
          iconData,
          color: iconColor,
          size: EnvoyIconSize.extraSmall,
        ),
        const SizedBox(width: EnvoySpacing.xs),
        Text(info, style: textStyle),
      ],
    );
  }
}

class CountryOptions extends ConsumerStatefulWidget {
  const CountryOptions({super.key});

  @override
  ConsumerState<CountryOptions> createState() => _CountryOptionsState();
}

class _CountryOptionsState extends ConsumerState<CountryOptions> {
  @override
  Widget build(context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(
          height: 10,
        ),
        GestureDetector(
          child: Text(
            S().buy_bitcoin_details_menu_editRegion,
            style: const TextStyle(color: Colors.white),
          ),
          onTap: () {
            HomePageState.of(context)?.toggleOptions();
            context.go(
              ROUTE_SELECT_REGION,
            );
          },
        ),
      ],
    );
  }
}
