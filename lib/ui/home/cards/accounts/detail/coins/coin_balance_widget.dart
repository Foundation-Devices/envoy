// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/coin_tag.dart';
import 'package:envoy/business/exchange_rate.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coins_state.dart';
import 'package:envoy/util/amount.dart';
import 'package:envoy/util/rive_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rive/rive.dart' as Rive;
import 'package:rive/rive.dart';

//Widget that displays the balance,lock icon etc of a coin
class CoinBalanceWidget extends StatelessWidget {
  final int amount;
  final bool locked;
  final bool showLock;
  final GestureTapCallback? onLockTap;
  final Widget? switchWidget;

  const CoinBalanceWidget({
    super.key,
    required this.amount,
    required this.locked,
    this.onLockTap = null,
    this.switchWidget = null,
    this.showLock = true,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle _textStyleFiat = Theme.of(context).textTheme.titleSmall!.copyWith(
          color: EnvoyColors.grey,
          fontSize: 11,
          fontWeight: FontWeight.w400,
        );

    TextStyle _textStyleAmountSatBtc =
        Theme.of(context).textTheme.headlineSmall!.copyWith(
              color: EnvoyColors.grey,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            );

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
              flex: 3,
              child: Container(
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 1,
                      child: SizedBox.square(
                          dimension: 18,
                          child: SvgPicture.asset(
                            "assets/icons/ic_sats.svg",
                            color: Colors.black,
                          )),
                    ),
                    Flexible(
                      flex: 4,
                      child: SizedBox.expand(
                        child: Container(
                          width: double.infinity,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 4.0),
                          child: Text(
                            "${getFormattedSatsAmount(amount)}",
                            textAlign: TextAlign.end,
                            style: _textStyleAmountSatBtc,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          Flexible(
            flex: 4,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  constraints: BoxConstraints(minWidth: 80),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Text(
                    ExchangeRate().getFormattedAmount(amount),
                    style: _textStyleFiat,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
                showLock
                    ? FittedBox(
                        child: StatefulBuilder(
                          builder: (context, setState) {
                            return CoinLockButton(
                              locked: locked,
                              gestureTapCallback: onLockTap ?? () => {},
                            );
                          },
                        ),
                      )
                    : SizedBox.shrink(),
                Flexible(
                    child: AnimatedOpacity(
                        opacity: locked ? 0.2 : 1,
                        duration: Duration(milliseconds: 250),
                        child: IgnorePointer(
                            ignoring: locked,
                            child: switchWidget ?? SizedBox.shrink()))),
              ],
            ),
          )
        ],
      ),
    );
  }
}

//Lock button with rive animation
class CoinLockButton extends StatefulWidget {
  final bool locked;
  final GestureTapCallback gestureTapCallback;

  const CoinLockButton(
      {super.key, required this.locked, required this.gestureTapCallback});

  @override
  State<CoinLockButton> createState() => _CoinLockButtonState();
}

class _CoinLockButtonState extends State<CoinLockButton> {
  Rive.StateMachineController? _controller;
  late Rive.RiveFile riveFile;

  void _onInit(Artboard art) {
    var ctrl = StateMachineController.fromArtboard(art, 'CoinStateMachine')
        as StateMachineController;
    art.addController(ctrl);
    _controller = ctrl;
    _controller?.findInput<bool>("Lock")?.change(widget.locked);
  }

  @override
  Widget build(BuildContext context) {
    _controller?.findInput<bool>("Lock")?.change(widget.locked);
    return Consumer(builder: (context, ref, child) {
      RiveFile? riveFile = ref.watch(coinLockRiveProvider);
      return GestureDetector(
          onTap: widget.gestureTapCallback,
          child: Container(
              child: SizedBox(
                  height: 30,
                  width: 30,
                  child: riveFile != null
                      ? Rive.RiveAnimation.direct(
                          riveFile,
                          onInit: _onInit,
                        )
                      : SizedBox.shrink())));
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }
}

//Widget to show coin tag selections and lock states
class CoinSubTitleText extends ConsumerWidget {
  final CoinTag tag;

  CoinSubTitleText(this.tag);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TextStyle _textStyleTagSubtitle =
        Theme.of(context).textTheme.titleSmall!.copyWith(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            );
    final selections = ref.watch(coinSelectionStateProvider);
    final selected =
        selections.where((element) => tag.coins_id.contains(element));
    final lockedCoins = tag.coins.where((element) => element.locked);
    final selectionMessage =
        "${selected.length} of ${tag.numOfCoins} coins selected";
    String message = "${tag.numOfCoins} coins";

    if (selected.isNotEmpty) {
      message = "${selectionMessage} | ${message}";
    } else {
      if (lockedCoins.length == tag.coins.length) {
        message = "${lockedCoins.length} coins locked";
      } else if (lockedCoins.isNotEmpty) {
        message = "${message} | ${lockedCoins.length} locked";
      }
    }
    if (tag.coins.isEmpty) {
      message = "0 coins";
    }
    return Text(
      message,
      style: _textStyleTagSubtitle,
    );
  }
}
