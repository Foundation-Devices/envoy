// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/fading_edge_scroll_view.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coin_tag_widget.dart';
import 'package:envoy/util/tag_details_container_transform.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CoinsList extends ConsumerStatefulWidget {
  final GestureTapCallback callback;

  const CoinsList({super.key, required this.callback});

  @override
  ConsumerState<CoinsList> createState() => _CoinsListState();
}

class _CoinsListState extends ConsumerState<CoinsList> {
  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    List<int> coinSets = [1, 48, 2, 3, 4];

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

    TextStyle _textStyleSatBtc =
        Theme.of(context).textTheme.headlineSmall!.copyWith(
              color: EnvoyColors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            );

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
              itemCount: coinSets.length,
              itemBuilder: (BuildContext context, int index) {
                return TagDetailsContainerTransform(
                  closedBuilder: (context, action) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: CoinItemWidget(),
                    );
                  },
                  openBuilder: (context, action) {
                    return Scaffold(
                      appBar: AppBar(
                        elevation: 0,
                        backgroundColor: Colors.transparent,
                      ),
                      body: GestureDetector(
                          onTap: () {
                            action.call();
                          },
                          child: CoinTagWidget(showCoins: true)),
                    );
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
  const CoinItemWidget({super.key});

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

    TextStyle _textStyleSatBtc =
        Theme.of(context).textTheme.headlineSmall!.copyWith(
              color: EnvoyColors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            );
    return Container(
      height: 96,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(22)),
        border:
            Border.all(color: Colors.black, width: 2, style: BorderStyle.solid),
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              EnvoyColors.listAccountTileColors[0],
              Colors.black,
            ]),
      ),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(22)),
            border: Border.all(
                color: EnvoyColors.listAccountTileColors.first,
                width: 2,
                style: BorderStyle.solid)),
        child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(22)),
            child: StripBackground(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12, top: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Conference",
                                style: _textStyleWallet,
                              ),
                              Text(
                                "4 of 4 coins",
                                style: _textStyleWalletName,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Consumer(
                    builder: (context, ref, child) {
                      //TODO: hide tag balance using [ balanceHideStateStatusProvider]
                      // final hide = ref.watch(balanceHideStateStatusProvider(account));
                      final hide = false;
                      if (hide) {
                        return Container();
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 4),
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(17))),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 13.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                        padding:
                                            const EdgeInsets.only(left: 4.0)),
                                    Text(
                                      "0.00000000",
                                      style: _textStyleSatBtc,
                                    ),
                                  ],
                                ),
                                Flexible(
                                  child: Text(
                                    "0.052555 USD",
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
                ],
              ),
            )),
      ),
    );
  }
}
