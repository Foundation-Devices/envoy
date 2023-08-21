// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/account.dart';
import 'package:envoy/business/coin_tag.dart';
import 'package:envoy/ui/background.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/fading_edge_scroll_view.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coin_balance_widget.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coin_tag_details_screen.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coins_state.dart';
import 'package:envoy/util/blur_container_transform.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CoinsList extends ConsumerStatefulWidget {
  final Account account;

  const CoinsList({super.key, required this.account});

  @override
  ConsumerState<CoinsList> createState() => _CoinsListState();
}

class _CoinsListState extends ConsumerState<CoinsList> {
  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    List<CoinTag> tags = ref.watch(coinsTagProvider(widget.account.id ?? ""));
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12),
      child: FadingEdgeScrollView.fromScrollView(
        scrollController: _scrollController,
        child: StatefulBuilder(
          builder: (context, setState) {
            return ListView.builder(
              physics: BouncingScrollPhysics(),
              //accommodate bottom nav bar spacing
              padding: EdgeInsets.only(bottom: 120),
              controller: _scrollController,
              itemCount: tags.length,
              itemBuilder: (BuildContext context, int index) {
                return BlurContainerTransform(
                  closedBuilder: (context, action) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: CoinItemWidget(tag: tags[index]),
                    );
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

class CoinItemWidget extends StatelessWidget {
  final CoinTag tag;

  const CoinItemWidget({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    TextStyle _textStyleWallet =
        Theme.of(context).textTheme.titleMedium!.copyWith(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            );

    Color cardBackground = tag.untagged
        ? Color(0xff808080)
        : tag.getAccount()?.color ?? EnvoyColors.listAccountTileColors[0];
    return Container(
      height: 108,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(22)),
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
            borderRadius: BorderRadius.all(Radius.circular(22)),
            border: Border.all(
                color: cardBackground, width: 2, style: BorderStyle.solid)),
        child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(22)),
            child: StripesBackground(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12, top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${tag.name}",
                                style: _textStyleWallet,
                              ),
                              CoinSubTitleText(tag),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Consumer(
                    builder: (context, ref, child) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 4),
                        child: Container(
                          height: 40,
                          child: CoinTagBalanceWidget(
                            coinTag: tag,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
