// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/amount_widget.dart';
import 'package:envoy/ui/home/cards/accounts/spend/spend_fee_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/widgets/color_util.dart';
import 'package:envoy/ui/widgets/envoy_amount_widget.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:envoy/ui/components/draggable_overlay.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/home/cards/accounts/detail/filter_options.dart';
import 'package:ngwallet/ngwallet.dart';
import 'package:envoy/ui/home/cards/accounts/accounts_state.dart';

enum FeeOption {
  fast,
  standard,
  slow,
  custom,
}

final selectedFeeOptionProvider =
    StateProvider<FeeOption>((ref) => FeeOption.standard);

class FeeChooser extends ConsumerStatefulWidget {
  final Function(int fee, BuildContext context, bool setCustomFee) onFeeSelect;
  final BitcoinTransaction transaction;

  const FeeChooser(this.transaction, {super.key, required this.onFeeSelect});

  @override
  ConsumerState createState() => _FeeChooserState();
}

class _FeeChooserState extends ConsumerState<FeeChooser>
    with TickerProviderStateMixin {
  List<num> feeList = List.generate(2, (index) => index + 1);

  num standardFee = 1;
  num fasterFee = 2;
  num slowerFee = 1;

  FeeOption _selectedOption = FeeOption.standard;
  bool _showCustom = false;
  EnvoyAccount? account;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setFees(ref.read(feeChooserStateProvider));
      _selectedOption = ref.read(selectedFeeOptionProvider);
      _showCustom = ref.read(selectedFeeOptionProvider) == FeeOption.custom;
      account = ref.read(selectedAccountProvider);
    });

    Future.delayed(const Duration(milliseconds: 10)).then((_) {
      if (!mounted) return;
      calculateFeeBoundary();
    });
  }

  void setFees(FeeChooserState feeChooserState) {
    standardFee = feeChooserState.standardFeeRate;
    fasterFee = feeChooserState.fasterFeeRate;
    // choose a slower fee, e.g. minFeeRate or something below standard
    slowerFee = feeChooserState.minFeeRate;

    if (standardFee == fasterFee) {
      fasterFee = standardFee + 1;
    }
  }

  void _selectOptionLocal(FeeOption option) {
    setState(() {
      _selectedOption = option;
      _showCustom = option == FeeOption.custom;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(feeChooserStateProvider, (previous, feeChooserState) {
      setFees(feeChooserState);
      calculateFeeBoundary();
    });

    return DraggableOverlay(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _FeeOptionRow(
            selected: _selectedOption == FeeOption.fast,
            title: S().coincontrol_tx_detail_fee_fast,
            subtitle: getAproxTime(account, fasterFee),
            onTap: () => _selectOptionLocal(FeeOption.fast),
            trailing: (account != null)
                ? EnvoyAmount(
                    amountSats: getApproxFeeInSats(
                      feeRateSatsPerVb: fasterFee.toInt(),
                      txVSizeVb: widget.transaction.vsize.toInt(),
                    ),
                    // TODO fix vsize always 0
                    amountWidgetStyle: AmountWidgetStyle.normal,
                    account: account!)
                : null,
          ),
          const Divider(),
          _FeeOptionRow(
            selected: _selectedOption == FeeOption.standard,
            title: S().coincontrol_tx_detail_fee_standard,
            subtitle: getAproxTime(account, standardFee),
            onTap: () => _selectOptionLocal(FeeOption.standard),
            trailing: (account != null)
                ? EnvoyAmount(
                    amountSats: getApproxFeeInSats(
                      feeRateSatsPerVb: standardFee.toInt(),
                      txVSizeVb: widget.transaction.vsize.toInt(),
                    ),
                    // TODO fix vsize always 0
                    amountWidgetStyle: AmountWidgetStyle.normal,
                    account: account!)
                : null,
          ),
          const Divider(),
          _FeeOptionRow(
            selected: _selectedOption == FeeOption.slow,
            title: S().coincontrol_tx_detail_fee_slow,
            subtitle: getAproxTime(account, slowerFee),
            onTap: () => _selectOptionLocal(FeeOption.slow),
            trailing: (account != null)
                ? EnvoyAmount(
                    amountSats: getApproxFeeInSats(
                      feeRateSatsPerVb: slowerFee.toInt(),
                      txVSizeVb: widget.transaction.vsize.toInt(),
                    ),
                    // TODO fix vsize always 0
                    amountWidgetStyle: AmountWidgetStyle.normal,
                    account: account!)
                : null,
          ),
          const Divider(),
          _FeeOptionRow(
            selected: _selectedOption == FeeOption.custom,
            title: S().coincontrol_tx_detail_fee_custom,
            subtitle: _showCustom
                ? getAproxTime(account, ref.watch(_selectedFeeStateProvider))
                : null,
            trailing: _showCustom
                ? (account != null)
                    ? EnvoyAmount(
                        amountSats: getApproxFeeInSats(
                          feeRateSatsPerVb:
                              ref.watch(_selectedFeeStateProvider),
                          txVSizeVb: 202,
                        ),
                        // TODO fix vsize always null
                        amountWidgetStyle: AmountWidgetStyle.normal,
                        account: account!)
                    : null
                : const EnvoyIcon(EnvoyIcons.chevron_down,
                    size: EnvoyIconSize.extraSmall),
            onTap: () => _selectOptionLocal(FeeOption.custom),
          ),

          // Inline FeeSlider for custom
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: !_showCustom
                ? const SizedBox.shrink()
                : Padding(
                    key: const ValueKey('feeSlider'),
                    padding: const EdgeInsets.only(top: EnvoySpacing.medium2),
                    child: FeeSlider(
                      fees: feeList,
                      onFeeSelect: (fee) {
                        ref.read(_selectedFeeStateProvider.notifier).state =
                            fee;
                      },
                    ),
                  ),
          ),

          SizedBox(height: EnvoySpacing.large1),
          EnvoyButton(
            S().component_apply,
            onTap: () async {
              ref.read(selectedFeeOptionProvider.notifier).state =
                  _selectedOption;
              switch (_selectedOption) {
                case FeeOption.fast:
                  widget.onFeeSelect(fasterFee.toInt(), context, false);
                  break;
                case FeeOption.standard:
                  widget.onFeeSelect(standardFee.toInt(), context, false);
                  break;
                case FeeOption.slow:
                  widget.onFeeSelect(slowerFee.toInt(), context, false);
                  break;
                case FeeOption.custom:
                  final custom = ref.read(_selectedFeeStateProvider);
                  await widget.onFeeSelect(custom, context, true);
                  break;
              }
              Future.delayed(const Duration(milliseconds: 200)).then((_) {
                if (context.mounted) {
                  Navigator.of(context).maybePop();
                }
              });
            },
          ),
        ],
      ),
    );
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

class _FeeOptionRow extends StatelessWidget {
  const _FeeOptionRow({
    required this.selected,
    required this.title,
    this.trailing,
    this.subtitle,
    this.onTap,
  });

  final bool selected;
  final String title;
  final Widget? trailing;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      CheckBoxFilterItem(
        text: title,
        checked: selected,
        subtitle: subtitle,
        onTap: () {
          if (onTap != null) {
            onTap!();
          }
        },
      ),
      if (trailing != null) trailing!,
    ]);
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
                                      gradientOverlayColor.applyOpacity(0.0),
                                      gradientOverlayColor.applyOpacity(0.0),
                                      gradientOverlayColor.applyOpacity(0.0),
                                      gradientOverlayColor.applyOpacity(0.6),
                                      gradientOverlayColor.applyOpacity(0.7),
                                      gradientOverlayColor.applyOpacity(0.8),
                                      gradientOverlayColor.applyOpacity(0.8),
                                      gradientOverlayColor.applyOpacity(0.9),
                                      gradientOverlayColor.applyOpacity(0.9),
                                      gradientOverlayColor.applyOpacity(1),
                                    ],
                                  ),
                                )),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // const Spacer(),
                // Padding(
                //   padding:
                //       const EdgeInsets.symmetric(vertical: 12, horizontal: 34),
                //   child: EnvoyButton(
                //     S().coincontrol_tx_detail_custom_fee_cta,
                //     onTap: () {
                //       if (!processingFee) {
                //         widget.onFeeSelect(ref.read(_selectedFeeStateProvider));
                //       }
                //     },
                //   ),
                // ),
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
      ref.read(spendFeeRateProvider.notifier).state =
          widget.fees[index].toInt();
    }
  }
}
