import 'dart:math';

import 'package:envoy/business/coin_tag.dart';
import 'package:envoy/business/coins.dart';
import 'package:envoy/ui/background.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/home/settings/setting_toggle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class CoinTagWidget extends StatefulWidget {
  final bool showCoins;

  const CoinTagWidget({super.key, this.showCoins = false});

  @override
  State<CoinTagWidget> createState() => _CoinTagWidgetState();
}

final random = Random();

int randomMinMax(int min, int max) {
  return random.nextInt(max - min + 1) + min;
}

class _CoinTagWidgetState extends State<CoinTagWidget> {
  final _scrollController = ScrollController();
  final coinTag = CoinTag(
      id: "xmcmcmc",
      name: "Conference",
      coins: List.generate(12, (index) {
        return Coin(
            amount: randomMinMax(10000, 100000).toDouble(),
            hash: Uuid().v4(),
            index: randomMinMax(2, 7),
            locked: false);
      }));

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
    // if (_childKey.currentContext?.findRenderObject() != null)
    //   print("_childKey ${(_childKey.currentContext?.findRenderObject() as RenderBox).size}");

    double totalTagHeight = 108;
    double coinListHeight =
        (coinTag.coins.length * 36).toDouble().clamp(50, 260);
    if (widget.showCoins) {
      totalTagHeight += coinListHeight;
    }

    return Container(
      padding: EdgeInsets.all(8),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          // minHeight: coinListHeight,
          maxHeight: 680,
        ),
        child: Container(
          height: totalTagHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(22)),
            border: Border.all(
                color: Colors.black, width: 2, style: BorderStyle.solid),
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 0),
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
                                      "Conference ",
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 13.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 4.0)),
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
                        Container(
                          margin: EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12))),
                            height: coinListHeight,
                            child: ListView.builder(
                              itemCount: coinTag.coins.length,
                              itemBuilder: (context, index) => CoinItem(
                                coin: coinTag.coins[index],
                              ),
                              padding: coinTag.coins.length >= 8
                                  ? EdgeInsets.only(bottom: 4, top: 4)
                                  : EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
          ),
        ),
      ),
    );
  }
}

class CoinItem extends StatelessWidget {
  final Coin coin;

  const CoinItem({super.key, required this.coin});

  @override
  Widget build(BuildContext context) {
    TextStyle _textStyleFiat = Theme.of(context).textTheme.titleSmall!.copyWith(
          color: EnvoyColors.grey,
          fontSize: 11,
          fontWeight: FontWeight.w400,
        );
    TextStyle _textStyleSatBtc =
        Theme.of(context).textTheme.headlineSmall!.copyWith(
              color: EnvoyColors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            );

    TextStyle _textStyleAmountSatBtc =
        Theme.of(context).textTheme.headlineSmall!.copyWith(
              color: EnvoyColors.grey,
              fontSize: 24,
              fontWeight: FontWeight.w400,
            );
    return SizedBox(
      height: 34,
      child: Container(
          alignment: Alignment.center,
          margin: EdgeInsets.symmetric(vertical: 0, horizontal: 4),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Text(
                  "0.00000000",
                  style: _textStyleSatBtc,
                ),
              ),
              Flexible(
                child: Text(
                  "0.052555 USD",
                  style: _textStyleFiat,
                ),
              ),
              Flexible(
                  child: Transform.scale(
                scale: 0.8,
                filterQuality: FilterQuality.high,
                child: Container(
                  height: 30,
                  child: EnvoySwitch(
                    value: true,
                    onChanged: (value) {},
                  ),
                ),
              )),
            ],
          )),
    );
  }
}

class StripBackground extends StatelessWidget {
  final Widget child;

  const StripBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: constraints.minHeight,
          width: constraints.maxWidth,
          child: CustomPaint(
            isComplex: true,
            willChange: false,
            child: child,
            painter: LinesPainter(
                color: EnvoyColors.tilesLineDarkColor, opacity: 1.0),
          ),
        );
      },
    );
  }
}
