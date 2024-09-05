// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/button.dart';
import 'package:envoy/ui/home/cards/accounts/spend/spend_fee_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/spend_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FeeChooser extends ConsumerStatefulWidget {
  final Function(int fee, BuildContext context, bool setCustomFee) onFeeSelect;

  const FeeChooser({super.key, required this.onFeeSelect});

  @override
  ConsumerState createState() => _FeeChooserState();
}

class _FeeChooserState extends ConsumerState<FeeChooser>
    with TickerProviderStateMixin {
  late TabController _tabController;

  List<num> feeList = List.generate(2, (index) => index + 1);

  //default fee rates
  num standardFee = 1;
  num fasterFee = 2;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final rate = ref.read(spendFeeRateProvider);
      setFees(ref.read(feeChooserStateProvider));
      selectFeeTab(rate);
    });
    Future.delayed(const Duration(milliseconds: 10))
        .then((value) => calculateFeeBoundary());
  }

  void setFees(FeeChooserState feeChooserState) {
    standardFee = feeChooserState.standardFeeRate;
    fasterFee = feeChooserState.fasterFeeRate;
    if (standardFee == fasterFee) {
      fasterFee = standardFee + 1;
    }
  }

  TextStyle? get _labelStyle {
    return Theme.of(context).textTheme.bodySmall?.copyWith(
        fontSize: 9.5,
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.normal);
  }

  selectFeeTab(num fee) {
    int index = 0;
    if (fee.toInt() == standardFee.toInt()) {
      index = 0;
    } else {
      if (fee.toInt() == fasterFee.toInt()) {
        index = 1;
      } else {
        index = 2;
      }
    }
    _tabController.animateTo(index.toInt(),
        duration: const Duration(milliseconds: 200));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(feeChooserStateProvider, (previous, feeChooserState) {
      setFees(feeChooserState);
      calculateFeeBoundary();
    });

    ref.listen(spendFeeRateProvider, (previous, next) {
      selectFeeTab(next);
    });

    TextScaler feeTextScaler = MediaQuery.textScalerOf(context)
        .clamp(minScaleFactor: 1, maxScaleFactor: 1.1);

    return Container(
        constraints: const BoxConstraints(
          maxWidth: 194,
          minWidth: 194,
          maxHeight: 24,
        ),
        child: Consumer(
          builder: (context, ref, child) {
            return IgnorePointer(
              ignoring: ref.watch(spendFeeProcessing),
              child: child,
            );
          },
          child: TabBar(
              textScaler: feeTextScaler,
              controller: _tabController,
              onTap: (index) {
                switch (index) {
                  case 0:
                    widget.onFeeSelect(standardFee.toInt(), context, false);
                    break;
                  case 1:
                    widget.onFeeSelect(fasterFee.toInt(), context, false);
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
                            decoration: const BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  spreadRadius: 2,
                                  blurRadius: 24,
                                  offset: Offset(
                                      0, -4), // changes position of shadow
                                ),
                              ],
                            ),
                            child: Card(
                              elevation: 0,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft:
                                      Radius.circular(EnvoySpacing.medium2),
                                  topRight:
                                      Radius.circular(EnvoySpacing.medium2),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Consumer(
                                  builder: (context, ref, child) {
                                    return FeeSlider(
                                      fees: feeList,
                                      onFeeSelect: (index) {
                                        widget.onFeeSelect(
                                            index, context, true);
                                      },
                                    );
                                  },
                                ),
                              ),
                            ));
                      },
                    ).then((value) {
                      /// if the user cancels/sets the fee slider , we need to reset/set the fee rate that used in block estimation
                      /// otherwise set the fee rate to selected value
                      ref
                          .read(spendFeeRateBlockEstimationProvider.notifier)
                          .state = ref.read(spendFeeRateProvider);
                      ref.read(userHasChangedFeesProvider.notifier).state =
                          true;
                    });
                    break;
                }
              },
              indicatorColor: Colors.white,
              labelPadding: const EdgeInsets.symmetric(horizontal: 0),
              padding: const EdgeInsets.symmetric(horizontal: 0),
              indicatorPadding: const EdgeInsets.symmetric(horizontal: 0),
              labelColor: Colors.white,
              indicatorWeight: 1,
              tabAlignment: TabAlignment.fill,
              splashBorderRadius: BorderRadius.circular(0),
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: _labelStyle,
              tabs: [
                Tab(
                  child: Text(
                    S().coincontrol_tx_detail_fee_standard,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Tab(
                  child: Text(
                    S().coincontrol_tx_detail_fee_faster,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Tab(
                  child: Text(
                    S().coincontrol_tx_detail_fee_custom,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ]),
        ));
  }

  void calculateFeeBoundary() {
    FeeChooserState feeChooserState = ref.read(feeChooserStateProvider);
    setState(() {
      if (feeChooserState.minFeeRate.abs() >=
          feeChooserState.maxFeeRate.abs()) {
        feeList = [feeChooserState.minFeeRate];
        return;
      }
      int totalFeeSuggestion =
          feeChooserState.maxFeeRate - feeChooserState.minFeeRate;
      kPrint(
          "totalFeeSuggestion $totalFeeSuggestion (${feeChooserState.minFeeRate} to ${feeChooserState.maxFeeRate})");
      if (totalFeeSuggestion <= 1) {
        feeList.add(feeChooserState.minFeeRate);
      } else {
        feeList = List.generate(totalFeeSuggestion,
            (index) => (feeChooserState.minFeeRate) + index).reversed.toList();
      }
    });
  }
}

class FeeSlider extends ConsumerStatefulWidget {
  final Function(int index) onFeeSelect;
  final int selectedItem;
  final List<num> fees;

  const FeeSlider(
      {super.key,
      this.selectedItem = 1,
      required this.onFeeSelect,
      required this.fees});

  @override
  ConsumerState createState() => _FeeSliderState();
}

//local state notifier to keep track of selected index,
//this is used to animate the selected item,
//by using provider we can avoid unnecessary rebuilds on scroll-wheel widget
final _selectedFeeStateProvider = StateProvider.autoDispose<int>((ref) => 0);

class _FeeSliderState extends ConsumerState<FeeSlider> {
  double yOffset = 0.0;
  int? _lastHapticIndex;

  bool _disableHaptic = false;
  bool _initializationFinished = false;
  final FixedExtentScrollController _controller =
      FixedExtentScrollController(initialItem: 2);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      //cache textStyle to avoid creating new instances
      initializeSelectedRate();
    });
  }

  void initializeSelectedRate() async {
    num feeRate = ref.read(spendFeeRateProvider);
    final num selectedItem = ref.read(_selectedFeeStateProvider);
    if (feeRate != selectedItem) {
      setState(() {
        ref.read(_selectedFeeStateProvider.notifier).state = feeRate.toInt();
        //since we are setting the initial item, we need to disable haptic feedback
        _disableHaptic = true;
      });
      int jumpIndex = widget.fees.indexOf(feeRate.toInt());
      if (jumpIndex < 0) {
        jumpIndex = widget.fees.length - 1;
      }
      _controller
          .animateToItem(jumpIndex,
              duration: const Duration(milliseconds: 60),
              curve: Curves.easeInOut)
          .then((value) {
        _disableHaptic = false;
        _initializationFinished = true;
      });
    }
  }

  TextStyle? get _unselectedTextStyle {
    return Theme.of(context).textTheme.titleSmall?.copyWith(
          fontSize: 12,
          color: EnvoyColors.gray600,
        );
  }

  TextStyle? get _selectedTextStyle {
    return Theme.of(context).textTheme.titleSmall?.copyWith(
          fontSize: 12,
          color: EnvoyColors.teal500,
        );
  }

  TextStyle? get _satPerVbStyle {
    return Theme.of(context).textTheme.bodySmall?.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: EnvoyColors.accentPrimary,
        );
  }

  //builds the indicator widget
  Widget _buildIndicatorWidget(num feeRate) {
    //consumer to listen to selected index changes, to animate the selected item
    return Consumer(
      builder: (context, ref, child) {
        final selectedItem = ref.watch(_selectedFeeStateProvider);
        return RotatedBox(
          quarterTurns: 3,
          child: SizedBox(
            height: 68,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  duration: const Duration(milliseconds: 200),
                  scale: selectedItem == feeRate ? 1.2 : 1,
                  child: Text(
                    "$feeRate",
                    style: selectedItem == feeRate
                        ? _selectedTextStyle
                        : _unselectedTextStyle,
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  height: selectedItem == feeRate ? 34 : 32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: selectedItem == feeRate
                        ? EnvoyColors.teal500
                        : EnvoyColors.gray600,
                  ),
                  margin: EdgeInsets.only(top: selectedItem == feeRate ? 4 : 0),
                  width: selectedItem == feeRate ? 3 : 2,
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Color gradientOverlayColor = Colors.white54;
    bool processingFee = ref.watch(spendFeeProcessing);
    return Consumer(
      builder: (context, ref, child) {
        ref.listen(spendFeeRateProvider, (previous, next) {
          initializeSelectedRate();
        });
        return Container(
            constraints: const BoxConstraints(minHeight: 190, maxHeight: 210),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 100,
                  width: MediaQuery.of(context).size.width,
                  child: RotatedBox(
                    quarterTurns: 1,
                    child: Stack(
                      children: <Widget>[
                        Positioned.fill(
                          child: ListWheelScrollView.useDelegate(
                            controller: _controller,
                            renderChildrenOutsideViewport: false,
                            physics: const FixedExtentScrollPhysics(
                                parent: ClampingScrollPhysics()),
                            diameterRatio: 2.8,
                            offAxisFraction: -.3,
                            useMagnifier: false,
                            perspective: 0.004,
                            overAndUnderCenterOpacity: 1,
                            itemExtent: 48,
                            squeeze: widget.fees.length > 1000 ? 1.0 : 1.3,
                            onSelectedItemChanged: _handleItemChanged,
                            childDelegate: ListWheelChildBuilderDelegate(
                              childCount: widget.fees.length,
                              builder: (context, index) {
                                return _buildIndicatorWidget(
                                    widget.fees[index]);
                              },
                            ),
                          ),
                        ),
                        Center(
                          child: RotatedBox(
                            quarterTurns: 3,
                            child: Container(
                                alignment: const Alignment(0.0, 1.3),
                                margin: const EdgeInsets.only(top: 4),
                                child: Text(
                                  "sats/Vb",
                                  style: _satPerVbStyle,
                                )),
                          ),
                        ),
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Container(
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  gradient: RadialGradient(
                                    transform: const GradientRotation(1.6),
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
                const Spacer(),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 34),
                  child: EnvoyButton(
                      label: S().coincontrol_tx_detail_custom_fee_cta,
                      onTap: () {
                        if (!processingFee) {
                          widget
                              .onFeeSelect(ref.read(_selectedFeeStateProvider));
                        }
                      },
                      type: ButtonType.primary,
                      state: processingFee
                          ? ButtonState.loading
                          : ButtonState.defaultState),
                ),
                const Padding(padding: EdgeInsets.only(bottom: 8)),
              ],
            ));
      },
    );
  }

  void _handleItemChanged(int index) {
    if (index != _lastHapticIndex) {
      _lastHapticIndex = index;
      if (!_disableHaptic) HapticFeedback.selectionClick();
    }
    ref.read(_selectedFeeStateProvider.notifier).state =
        widget.fees[index].toInt();
    if (_initializationFinished) {
      ref.read(spendFeeRateBlockEstimationProvider.notifier).state =
          widget.fees[index].toInt();
    }
  }
}
