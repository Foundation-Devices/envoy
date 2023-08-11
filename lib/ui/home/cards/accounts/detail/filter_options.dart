// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:animations/animations.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/home/cards/accounts/detail/filter_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FilterOptions extends ConsumerStatefulWidget {
  const FilterOptions({Key? key}) : super(key: key);

  @override
  ConsumerState<FilterOptions> createState() => _FilterOptionsState();
}

class _FilterOptionsState extends ConsumerState<FilterOptions> {
  bool showFilterOptions = false;

  @override
  Widget build(BuildContext context) {
    AccountToggleState toggleState = ref.watch(accountToggleStateProvider);

    Widget txFilerOptions = _getTxFilterOptions(context);
    Widget coinFilerOptions = _getCoinFilterOptions(context);

    //margin on right is diff 8 compare to left, filter icon uses icon button that has touch target padding
    return Container(
      margin: EdgeInsets.only(left: 20, right: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: SlidingToggle(
                  onChange: (value) {
                    ref.read(accountToggleStateProvider.notifier).state =
                        toggleState == AccountToggleState.Tx
                            ? AccountToggleState.Coins
                            : AccountToggleState.Tx;
                  },
                  value: toggleState == AccountToggleState.Tx ? "Tx" : "Coins",
                ),
              ),
              Flexible(
                  flex: 1,
                  child: PageTransitionSwitcher(
                    reverse: toggleState == AccountToggleState.Tx,
                    transitionBuilder: (
                      Widget child,
                      Animation<double> animation,
                      Animation<double> secondaryAnimation,
                    ) {
                      return SharedAxisTransition(
                        animation: animation,
                        fillColor: Colors.transparent,
                        secondaryAnimation: secondaryAnimation,
                        transitionType: SharedAxisTransitionType.vertical,
                        child: child,
                      );
                    },
                    child: toggleState == AccountToggleState.Coins
                        ? coinFilerOptions
                        : txFilerOptions,
                  ))
            ],
          ),
        ],
      ),
    );
  }

  Widget _getTxFilterOptions(BuildContext context) {
    TxFilterState filterButtonState = ref.watch(txFilterStateProvider);

    return Filters(
      onChanged: (active) {
        setState(() {
          showFilterOptions = active;
          if (!showFilterOptions) {
            //Reset all the filter states
            ref.read(txFilterStateProvider.notifier).state = TxFilterState();
          }
        });
      },
      active: showFilterOptions,
      key: ValueKey("tx_filter_options"),
      filterItems: [
        FilterIcon(
          iconBuilder: (color) => Icon(Icons.arrow_circle_up),
          gestureDetector: () {
            var updatedState = filterButtonState.copy();
            updatedState.filterBySpend = updatedState.filterBySpend.toggle();
            ref.read(txFilterStateProvider.notifier).state = updatedState;
          },
          filterButtonState: filterButtonState.filterBySpend,
        ),
        FilterIcon(
          iconBuilder: (color) => Icon(Icons.currency_bitcoin_outlined),
          gestureDetector: () {
            var updatedState = filterButtonState.copy();
            updatedState.filterByAmount = updatedState.filterByAmount.toggle();
            ref.read(txFilterStateProvider.notifier).state = updatedState;
          },
          filterButtonState: filterButtonState.filterByAmount,
        ),
        FilterIcon(
          iconBuilder: (color) => Icon(Icons.calendar_today_outlined),
          gestureDetector: () {
            var updatedState = filterButtonState.copy();
            updatedState.filterByDate = updatedState.filterByDate.toggle();
            ref.read(txFilterStateProvider.notifier).state = updatedState;
          },
          filterButtonState: filterButtonState.filterByDate,
        ),
      ],
    );
  }

  Widget _getCoinFilterOptions(BuildContext context) {
    CoinFilterState filterState = ref.watch(coinFilterStateProvider);

    return Filters(
      active: showFilterOptions,
      onChanged: (active) {
        setState(() {
          showFilterOptions = active;
          if (!showFilterOptions) {
            //Reset all the filter states
            ref.read(coinFilterStateProvider.notifier).state =
                CoinFilterState();
          }
        });
      },
      key: ValueKey("coin_filter_options"),
      filterItems: [
        FilterIcon(
          iconBuilder: (color) => Icon(Icons.sell_outlined),
          gestureDetector: () {
            var updatedState = CoinFilterState();
            updatedState.filterByTagName =
                updatedState.filterByTagName.toggle();
            ref.read(coinFilterStateProvider.notifier).state = updatedState;
          },
          filterButtonState: filterState.filterByTagName,
        ),
        FilterIcon(
          iconBuilder: (color) => Icon(Icons.currency_bitcoin_outlined),
          gestureDetector: () {
            var updatedState = CoinFilterState();
            updatedState.filterByAmount = updatedState.filterByAmount.toggle();
            ref.read(coinFilterStateProvider.notifier).state = updatedState;
          },
          filterButtonState: filterState.filterByAmount,
        ),
        FilterIcon(
          iconBuilder: (color) {
            return SvgPicture.asset("assets/icons/ic_coin_stack.svg",
                color: color);
          },
          gestureDetector: () {
            var updatedState = CoinFilterState();
            updatedState.filterByNumberOfCoins =
                updatedState.filterByNumberOfCoins.toggle();
            ref.read(coinFilterStateProvider.notifier).state = updatedState;
          },
          filterButtonState: filterState.filterByNumberOfCoins,
        )
      ],
    );
  }
}

class Filters extends StatefulWidget {
  final List<Widget> filterItems;
  final bool active;
  final Function(bool active) onChanged;

  const Filters(
      {super.key,
      this.active = false,
      required this.onChanged,
      required this.filterItems});

  @override
  State<Filters> createState() => _FiltersState();
}

class _FiltersState extends State<Filters> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 250),
    vsync: this,
  )..addListener(() {
      setState(() {});
    });

  late final Animation<Alignment> _offsetAnimation = Tween<Alignment>(
    end: Alignment.center,
    begin: Alignment(1, 0.0),
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Curves.fastOutSlowIn,
  ));

  late final Animation<double> _optionsOpacity = Tween<double>(
    end: 1,
    begin: 0.0,
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Interval(
      0.0,
      0.600,
      curve: Curves.easeIn,
    ),
  ));

  @override
  void initState() {
    super.initState();
    // _controller.forward(from: 1);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (this.widget.active) {
        _controller.animateTo(1.0);
      } else {
        _controller.animateTo(0.0);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      alignment: Alignment.center,
      child: Stack(
        children: [
          AlignTransition(
            alignment: _offsetAnimation,
            child: FadeTransition(
              opacity: _optionsOpacity,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [...widget.filterItems],
              ),
            ),
          ),
          Align(
              alignment: Alignment.centerRight,
              heightFactor: 1,
              child: IconButton(
                  onPressed: () {
                    if (widget.active) {
                      _controller.reverse();
                    } else {
                      _controller.forward();
                    }
                    widget.onChanged(!widget.active);
                  },
                  icon: SvgPicture.asset(
                    "assets/icons/ic_filter_funnel.svg",
                    color: widget.active ? EnvoyColors.blue : Color(0xffC8C8C8),
                  )))
        ],
      ),
    );
  }
}

class FilterIcon extends StatelessWidget {
  final FilterButtonState filterButtonState;
  final Widget Function(Color color) iconBuilder;
  final GestureTapCallback gestureDetector;

  const FilterIcon(
      {Key? key,
      required this.gestureDetector,
      required this.iconBuilder,
      this.filterButtonState = FilterButtonState.none})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color iconColor = filterButtonState == FilterButtonState.none
        ? Color(0xff808080)
        : EnvoyColors.blackish;
    return InkWell(
      customBorder: CircleBorder(),
      onTap: gestureDetector,
      child: Container(
        height: 44,
        width: 48,
        margin: EdgeInsets.only(right: 4, top: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconTheme(
              child: iconBuilder(iconColor),
              data: IconThemeData(
                color: iconColor,
                size: 22,
              ),
            ),
            Transform.translate(
              offset: Offset(-4, 6),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.translate(
                      offset: Offset(0, -1),
                      child: Icon(
                        Icons.keyboard_arrow_up_outlined,
                        size: 22,
                        color: filterButtonState == FilterButtonState.up
                            ? EnvoyColors.blue
                            : EnvoyColors.grey,
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(0, -12),
                      child: Icon(
                        Icons.keyboard_arrow_down_outlined,
                        size: 22,
                        color: filterButtonState == FilterButtonState.down
                            ? EnvoyColors.blue
                            : EnvoyColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SlidingToggle extends StatefulWidget {
  final String value;
  final Duration duration;
  final Function(String value) onChange;

  const SlidingToggle(
      {Key? key,
      required this.value,
      required this.onChange,
      this.duration = const Duration(milliseconds: 250)})
      : super(key: key);

  @override
  State<SlidingToggle> createState() => _SlidingToggleState();
}

class _SlidingToggleState extends State<SlidingToggle>
    with SingleTickerProviderStateMixin {
  String value = "Tx";

  late AnimationController _animationController;
  late Animation<Alignment> _animation;
  late Animation<Color?> _textColorAnimation;
  late Animation<Color?> _listIconColorAnimation;
  late Animation<Color?> _tagListIconColorAnimation;
  final Color _iconDisabledColor = Color(0xFF808080);

  @override
  void initState() {
    super.initState();
    value = widget.value;
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250));
    _animation =
        AlignmentTween(begin: Alignment.centerLeft, end: Alignment.centerRight)
            .animate(CurvedAnimation(
                parent: _animationController, curve: Curves.easeInOutCubic));

    _listIconColorAnimation = TweenSequence([
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(
          begin: Colors.white,
          end: Colors.white10,
        ),
      ),
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(
          begin: Colors.white10,
          end: _iconDisabledColor,
        ),
      ),
    ]).animate(_animationController);

    _tagListIconColorAnimation = TweenSequence([
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(
          begin: _iconDisabledColor,
          end: Colors.white10,
        ),
      ),
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(
          begin: Colors.white10,
          end: Colors.white,
        ),
      ),
    ]).animate(_animationController);

    _textColorAnimation = TweenSequence([
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(
          begin: Colors.white,
          end: Colors.white10,
        ),
      ),
      TweenSequenceItem(
        weight: 1.0,
        tween: ColorTween(
          begin: Colors.white10,
          end: Colors.white,
        ),
      ),
    ]).animate(_animationController);

    _animationController.addListener(() {
      setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (value == "Tx")
        _animationController.reverse();
      else
        _animationController.animateTo(1.0,
            duration: Duration(milliseconds: 0));
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: () {
            setState(() {
              value = value == "Tx" ? "Coins" : "Tx";
            });
            if (_animationController.isAnimating) {
              _animationController.stop();
            }
            if (value == "Tx")
              _animationController.reverse();
            else
              _animationController.forward();
            widget.onChange(value);
          },
          child: Container(
            constraints: BoxConstraints.tight(Size(110, 40)),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(8)),
              child: Stack(
                children: [
                  //Show selection background with 71% of width
                  AlignTransition(
                    alignment: _animation,
                    child: FractionallySizedBox(
                      widthFactor: 0.71,
                      child: Container(
                        margin: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                            color: EnvoyColors.teal,
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Icon(CupertinoIcons.list_bullet,
                          color: _listIconColorAnimation.value),
                    ),
                  ),
                  AlignTransition(
                    alignment: Tween(
                            begin: Alignment.centerRight, end: Alignment.center)
                        .animate(CurvedAnimation(
                            parent: _animationController,
                            curve: Curves.easeInOutCubic)),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(Icons.view_agenda_outlined,
                          color: _tagListIconColorAnimation.value),
                    ),
                  ),
                  AlignTransition(
                      alignment: Tween(
                              begin: Alignment.center,
                              end: Alignment.centerRight)
                          .animate(CurvedAnimation(
                              parent: _animationController,
                              curve: Curves.easeInOutCubic)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          value == "Tx" ? "List" : "Tags",
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                  color: _textColorAnimation.value,
                                  fontWeight: FontWeight.bold),
                        ),
                      )),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
