// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/fees.dart';
import 'package:envoy/ui/components/button.dart';
import 'package:envoy/ui/home/cards/accounts/accounts_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/spend_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wallet/wallet.dart';

class FeeChooser extends ConsumerStatefulWidget {
  const FeeChooser({super.key});

  @override
  ConsumerState createState() => _FeeChooserState();
}

class _FeeChooserState extends ConsumerState<FeeChooser>
    with TickerProviderStateMixin {
  late TabController _tabController;

  //default fee rates
  num standardFee = 1;
  num fasterFee = 2;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final rate = ref.read(spendFeeRateProvider);
      if (rate == standardFee) {
        _tabController.animateTo(0);
      } else {
        if (rate == fasterFee) {
          _tabController.animateTo(1);
        } else {
          _tabController.animateTo(2);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Wallet? wallet = ref.read(selectedAccountProvider)?.wallet;
    if (wallet != null) {
      standardFee = Fees().slowRate(wallet.network) * 100000;
      fasterFee = Fees().fastRate(wallet.network) * 100000;
      if (standardFee == fasterFee) {
        fasterFee = standardFee + 1;
      }
    }

    ref.listen(spendFeeRateProvider, (previous, next) {
      int index = 0;
      if (next == standardFee) {
        index = 0;
      } else {
        if (next == fasterFee) {
          index = 1;
        } else {
          index = 2;
        }
      }
      _tabController.animateTo(index.toInt(),
          duration: Duration(milliseconds: 200));
    });

    return Container(
      width: 160,
      height: 24,
      child: TabBar(
          controller: _tabController,
          onTap: (index) {
            switch (index) {
              case 0:
                ref.read(spendFeeRateProvider.notifier).state = standardFee;
                ref
                    .read(spendTransactionProvider.notifier)
                    .validate(ProviderScope.containerOf(context));
                break;
              case 1:
                ref.read(spendFeeRateProvider.notifier).state = fasterFee;
                ref
                    .read(spendTransactionProvider.notifier)
                    .validate(ProviderScope.containerOf(context));
                break;
              case 2:
                showModalBottomSheet(
                  context: context,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  useRootNavigator: true,
                  barrierColor: Colors.transparent,
                  builder: (context) {
                    return Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              spreadRadius: 2,
                              blurRadius: 24,
                              offset:
                                  Offset(0, -4), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FeeSlider(),
                          ),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(EnvoySpacing.medium2),
                              topRight: Radius.circular(EnvoySpacing.medium2),
                            ),
                          ),
                        ));
                  },
                );
                break;
            }
          },
          indicatorColor: Colors.white,
          labelPadding: EdgeInsets.symmetric(horizontal: 0),
          padding: EdgeInsets.symmetric(horizontal: 0),
          indicatorPadding: EdgeInsets.symmetric(horizontal: 0),
          labelColor: Colors.white,
          indicatorWeight: 1,
          tabAlignment: TabAlignment.fill,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(fontSize: 11, fontWeight: FontWeight.w600),
          tabs: [
            Tab(
              child: Text(
                "Standard",
              ),
            ),
            Tab(
              child: Text(
                "Faster",
              ),
            ),
            Tab(
              child: Text(
                "Custom",
              ),
            ),
          ]),
    );
  }
}

class FeeSlider extends ConsumerStatefulWidget {
  const FeeSlider({super.key});

  @override
  ConsumerState createState() => _FeeSliderState();
}

class _FeeSliderState extends ConsumerState<FeeSlider> {
  double yOffset = 0.0;
  num selectedItem = 0;
  int? _lastHapticIndex;

  bool _disableHaptic = false;
  FixedExtentScrollController _controller =
      FixedExtentScrollController(initialItem: 2);

  List<num> list = List.generate(2, (index) => index + 1);

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 10)).then((value) {
      int maxFeeRate = ref.read(spendMaxFeeRateProvider);
      setState(() {
        list = List.generate(maxFeeRate, (index) => index + 1);
      });
      num feeRate = ref.read(spendFeeRateProvider);
      if (feeRate != selectedItem) {
        setState(() {
          selectedItem = feeRate.toInt();
          //since we are setting the initial item, we need to disable haptic feedback
          _disableHaptic = true;
        });

        _controller
            .animateToItem(list.reversed.toList().indexOf(selectedItem),
                duration: Duration(milliseconds: 120), curve: Curves.easeInOut)
            .then((value) {
          _disableHaptic = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Color gradientOverlayColor = Colors.white54;

    ref.listen(spendMaxFeeRateProvider, (previous, maxFeeRate) {
      setState(() {
        list = List.generate(maxFeeRate, (index) => index + 1);
      });
    });

    return Container(
        height: (MediaQuery.of(context).size.height * 0.27).clamp(220, 250),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 100,
              width: MediaQuery.of(context).size.width,
              child: RotatedBox(
                quarterTurns: 1,
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: ListWheelScrollView.useDelegate(
                        controller: _controller,
                        physics: FixedExtentScrollPhysics(
                            parent: ClampingScrollPhysics()),
                        diameterRatio: 2.8,
                        offAxisFraction: -.3,
                        useMagnifier: false,
                        perspective: 0.004,
                        overAndUnderCenterOpacity: 1,
                        itemExtent: 48,
                        squeeze: 1.2,
                        onSelectedItemChanged: _handleItemChanged,
                        childDelegate: ListWheelChildListDelegate(
                            children: list.reversed
                                .map((index) => RotatedBox(
                                      quarterTurns: 3,
                                      child: Container(
                                        height: 68,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            AnimatedScale(
                                              duration:
                                                  Duration(milliseconds: 200),
                                              scale: selectedItem == index
                                                  ? 1.2
                                                  : 1,
                                              child: Text(
                                                "$index",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall
                                                    ?.copyWith(
                                                      fontSize: 13,
                                                      color: selectedItem ==
                                                              index
                                                          ? EnvoyColors.teal500
                                                          : EnvoyColors.gray600,
                                                    ),
                                              ),
                                            ),
                                            AnimatedContainer(
                                              duration:
                                                  Duration(milliseconds: 120),
                                              height: selectedItem == index
                                                  ? 34
                                                  : 32,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(2),
                                                color: selectedItem == index
                                                    ? EnvoyColors.teal500
                                                    : EnvoyColors.gray600,
                                              ),
                                              margin: EdgeInsets.only(
                                                  top: selectedItem == index
                                                      ? 4
                                                      : 0),
                                              width:
                                                  selectedItem == index ? 3 : 2,
                                            )
                                          ],
                                        ),
                                      ),
                                    ))
                                .toList()),
                      ),
                    ),
                    Center(
                      child: RotatedBox(
                        quarterTurns: 3,
                        child: Container(
                            alignment: Alignment(0.0, 1.3),
                            margin: EdgeInsets.only(top: 4),
                            child: Text(
                              "sats/Vb",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: EnvoyColors.accentPrimary,
                                  ),
                            )),
                      ),
                    ),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                transform: GradientRotation(1.6),
                                radius: 3,
                                focal: Alignment.center,
                                colors: [
                                  gradientOverlayColor.withOpacity(0.0),
                                  gradientOverlayColor.withOpacity(0.0),
                                  gradientOverlayColor.withOpacity(0.0),
                                  gradientOverlayColor.withOpacity(0.6),
                                  gradientOverlayColor.withOpacity(0.7),
                                  gradientOverlayColor.withOpacity(0.8),
                                  gradientOverlayColor.withOpacity(0.8),
                                  gradientOverlayColor.withOpacity(0.9),
                                  gradientOverlayColor.withOpacity(0.9),
                                  gradientOverlayColor.withOpacity(1),
                                ],
                              ),
                            )),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 34),
              child: EnvoyButton(
                  label: "Continue", //TODO: figma label
                  onTap: () => setFee(context),
                  type: ButtonType.primary,
                  state: ButtonState.default_state),
            ),
            Padding(padding: EdgeInsets.only(bottom: 8)),
          ],
        ));
  }

  void setFee(BuildContext context) {
    ref.read(spendFeeRateProvider.notifier).state = selectedItem.toDouble();
    ref
        .read(spendTransactionProvider.notifier)
        .validate(ProviderScope.containerOf(context));
    Navigator.pop(context);
  }

  void _handleItemChanged(int index) {
    if (index != _lastHapticIndex) {
      _lastHapticIndex = index;
      if (!_disableHaptic) HapticFeedback.selectionClick();
    }
    setState(() {
      selectedItem = list.reversed.toList()[index];
    });
  }
}
