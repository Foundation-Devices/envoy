// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/account.dart';
import 'package:envoy/business/coin_tag.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/fading_edge_scroll_view.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coin_balance_widget.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coin_tag_details_screen.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coins_state.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/color_util.dart';
import 'package:envoy/util/blur_container_transform.dart';
import 'package:envoy/util/haptics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:envoy/ui/components/stripe_painter.dart';
import 'package:ngwallet/ngwallet.dart';

//to track if the coin details screen is active,
//so we can close it when the use exits coin selection screen
//We can't use the navigator stack to track due to the animations used in the coin details screen.
final coinDetailsActiveProvider = StateProvider<bool>((ref) => false);

class CoinsList extends ConsumerStatefulWidget {
  final EnvoyAccount account;

  const CoinsList({super.key, required this.account});

  @override
  ConsumerState<CoinsList> createState() => _CoinsListState();
}

class _CoinsListState extends ConsumerState<CoinsList> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    List<CoinTag> tags = ref.watch(coinsTagProvider(widget.account.id ?? ""));
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: EnvoySpacing.xs),
      child: FadingEdgeScrollView.fromScrollView(
        scrollController: _scrollController,
        child: StatefulBuilder(
          builder: (context, setState) {
            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              //accommodate bottom nav bar spacing
              padding: const EdgeInsets.only(bottom: EnvoySpacing.medium3),
              controller: _scrollController,
              itemCount: tags.length,
              itemBuilder: (BuildContext context, int index) {
                return BlurContainerTransform(
                  useRootNavigator: true,
                  onTap: () {
                    ref.read(coinDetailsActiveProvider.notifier).state = true;
                    Haptics.lightImpact();
                  },
                  closedBuilder: (context, action) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: CoinItemWidget(tag: tags[index]),
                    );
                  },
                  onClosed: (_) {
                    ref.read(coinDetailsActiveProvider.notifier).state = false;
                  },
                  openBuilder: (context, action) {
                    return CoinTagDetailsScreen(
                        showCoins: true, coinTag: tags[index]);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class CoinItemWidget extends ConsumerWidget {
  final CoinTag tag;

  const CoinItemWidget({super.key, required this.tag});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TextStyle textStyleWallet =
        Theme.of(context).textTheme.titleMedium!.copyWith(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            );

    Color cardBackground = tag.untagged
        ? const Color(0xff808080)
        : tag.getAccount()?.color ?? EnvoyColors.listAccountTileColors[0];
    double cardRadius = EnvoySpacing.medium2;
    double textHeight =
        (EnvoyTypography.info.height ?? 1.3) * EnvoyTypography.info.fontSize!;
    double extraSpace = getMessage(tag, ref).length < 50 ? 0.0 : textHeight;

    return Container(
      height: 108 + extraSpace,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(cardRadius - 1)),
        border:
            Border.all(color: Colors.black, width: 2, style: BorderStyle.solid),
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              cardBackground,
              Colors.black,
            ]),
      ),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(cardRadius - 3)),
            border: Border.all(
                color: cardBackground, width: 2, style: BorderStyle.solid)),
        child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(cardRadius - 4)),
            child: CustomPaint(
              isComplex: true,
              willChange: false,
              painter: StripePainter(
                EnvoyColors.gray1000.applyOpacity(0.4),
              ),
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
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  tag.name,
                                  style: textStyleWallet,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                CoinSubTitleText(tag),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: 30,
                          margin: const EdgeInsets.all(EnvoySpacing.xs),
                          child: Consumer(
                            builder: (context, ref, child) {
                              return CoinTagBalanceWidget(
                                coinTag: tag,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
