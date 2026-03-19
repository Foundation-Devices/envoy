// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/amount_widget.dart';
import 'package:envoy/ui/components/pop_up.dart';
import 'package:envoy/ui/home/cards/accounts/spend/spend_fee_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/state/spend_notifier.dart';
import 'package:envoy/ui/home/cards/accounts/spend/state/spend_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/tx_review.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/theme/new_envoy_color.dart';
import 'package:envoy/ui/widgets/color_util.dart';
import 'package:envoy/ui/widgets/envoy_amount_widget.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:envoy/ui/components/draggable_overlay.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/home/cards/accounts/detail/filter_options.dart';
import 'package:envoy/business/fee_rate.dart';
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

String selectedFeeLabel(WidgetRef ref) {
  final option = ref.watch(selectedFeeOptionProvider); // or ref.read(...)
  switch (option) {
    case FeeOption.fast:
      return S().coincontrol_tx_detail_fee_fast;
    case FeeOption.standard:
      return S().coincontrol_tx_detail_fee_standard;
    case FeeOption.slow:
      return S().coincontrol_tx_detail_fee_slow;
    case FeeOption.custom:
      return S().coincontrol_tx_detail_fee_custom;
  }
}

class FeeChooser extends ConsumerStatefulWidget {
  final Function(FeeRate fee, BuildContext context, bool setCustomFee)
      onFeeSelect;
  final BitcoinTransaction transaction;

  /// When false, the custom fee slider will not show sub-sat values (<1 sat/vB).
  /// Should be false for RBF, where the minimum is always ≥1 sat/vB.
  final bool allowSubOneInCustom;

  const FeeChooser(
    this.transaction, {
    super.key,
    required this.onFeeSelect,
    this.allowSubOneInCustom = true,
  });

  @override
  ConsumerState createState() => _FeeChooserState();
}

class _FeeChooserState extends ConsumerState<FeeChooser>
    with TickerProviderStateMixin {
  List<FeeRate> feeList = List.generate(
    2,
    (index) => FeeRate.fromSatPerKvb((index + 1) * 1000),
  );

  FeeRate standardFee = FeeRate.fromSatPerKvb(1000);
  FeeRate fasterFee = FeeRate.fromSatPerKvb(2000);
  FeeRate slowerFee = FeeRate.fromSatPerKvb(1000);

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
    slowerFee = feeChooserState.minFeeRate;

    if (standardFee == fasterFee) {
      fasterFee = standardFee + FeeRate.fromSatPerVb(1);
    }
  }

  void _selectOptionLocal(FeeOption option) {
    setState(() {
      _selectedOption = option;
      _showCustom = option == FeeOption.custom;
    });
  }

  /// Returns the vsize derived from the current transaction, falling back to
  /// [spendFeeRateProvider] when [transaction.feeRate] is 0 (sub-sat tx).
  int _txVSize() {
    final txFeeRateSatVb = widget.transaction.feeRate.field0 > BigInt.zero
        ? FeeRate.fromBigInt(widget.transaction.feeRate.field0).satPerVb
        : ref.read(spendFeeRateProvider).satPerVb;
    return _safeTxVSizeVb(widget.transaction.fee.toDouble(), txFeeRateSatVb);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(feeChooserStateProvider, (previous, feeChooserState) {
      setFees(feeChooserState);
      calculateFeeBoundary();
    });
    TransactionModel transactionModel = ref.watch(spendTransactionProvider);
    final coinSelectionChanged = ref.watch(coinSelectionChangedProvider);
    final userSelectedCoinsThisSession =
        ref.watch(userSelectedCoinsThisSessionProvider);
    final transactionInputsChanged =
        ref.watch(transactionInputsChangedProvider);
    final userHasChangedFees = ref.watch(userHasChangedFeesProvider);
    final showFeeChangeNotice = userSelectedCoinsThisSession &&
        coinSelectionChanged &&
        transactionInputsChanged &&
        userHasChangedFees;
    final uneconomicSpends = ref.watch(uneconomicSpendsProvider);
    return DraggableOverlay(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (transactionModel.mode == SpendMode.sendMax ||
              showFeeChangeNotice ||
              uneconomicSpends)
            Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: EnvoySpacing.small, horizontal: EnvoySpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 16,
                    child: Center(
                      child: EnvoyIcon(EnvoyIcons.info,
                          size: EnvoyIconSize.superSmall,
                          color: NewEnvoyColor.contentTertiary),
                    ),
                  ),
                  SizedBox(width: EnvoySpacing.xs),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          showFeeChangeNotice
                              ? S().coincontrol_tx_detail_feeChange_information
                              : uneconomicSpends
                                  ? S()
                                      .coincontrol_tx_detail_high_fee_info_overlay_subheading
                                  : S().send_reviewScreen_sendMaxWarning,
                          style: EnvoyTypography.info
                              .copyWith(color: NewEnvoyColor.contentTertiary),
                          textAlign: TextAlign.start,
                        ),
                        if (uneconomicSpends)
                          Padding(
                            padding:
                                const EdgeInsets.only(top: EnvoySpacing.xs),
                            child: GestureDetector(
                              onTap: () {
                                //TODO: open link
                              },
                              child: Text(
                                S().component_learnMore,
                                style: EnvoyTypography.info
                                    .copyWith(color: NewEnvoyColor.contentLink),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          _FeeOptionRow(
            selected: _selectedOption == FeeOption.fast,
            title: S().coincontrol_tx_detail_fee_fast,
            subtitle: getAproxTime(account, fasterFee),
            onTap: () => _selectOptionLocal(FeeOption.fast),
            trailing: (account != null)
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: EnvoySpacing.xs),
                        child: Text("~",
                            style: EnvoyTypography.body
                                .copyWith(color: EnvoyColors.textTertiary)),
                      ),
                      EnvoyAmount(
                          amountSats: getApproxFeeInSats(
                              feeRate: fasterFee, txVSizeVb: _txVSize()),
                          amountWidgetStyle: AmountWidgetStyle.normal,
                          account: account!),
                    ],
                  )
                : null,
          ),
          const Divider(),
          _FeeOptionRow(
            selected: _selectedOption == FeeOption.standard,
            title: S().coincontrol_tx_detail_fee_standard,
            subtitle: getAproxTime(account, standardFee),
            onTap: () => _selectOptionLocal(FeeOption.standard),
            trailing: (account != null)
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: EnvoySpacing.xs),
                        child: Text("~",
                            style: EnvoyTypography.body
                                .copyWith(color: EnvoyColors.textTertiary)),
                      ),
                      EnvoyAmount(
                          amountSats: getApproxFeeInSats(
                              feeRate: standardFee, txVSizeVb: _txVSize()),
                          amountWidgetStyle: AmountWidgetStyle.normal,
                          account: account!),
                    ],
                  )
                : null,
          ),
          const Divider(),
          _FeeOptionRow(
            selected: _selectedOption == FeeOption.slow,
            title: S().coincontrol_tx_detail_fee_slow,
            subtitle: getAproxTime(account, slowerFee),
            onTap: () => _selectOptionLocal(FeeOption.slow),
            trailing: (account != null)
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: EnvoySpacing.xs),
                        child: Text("~",
                            style: EnvoyTypography.body
                                .copyWith(color: EnvoyColors.textTertiary)),
                      ),
                      EnvoyAmount(
                          amountSats: getApproxFeeInSats(
                              feeRate: slowerFee, txVSizeVb: _txVSize()),
                          amountWidgetStyle: AmountWidgetStyle.normal,
                          account: account!),
                    ],
                  )
                : null,
          ),
          const Divider(),
          _FeeOptionRow(
            selected: _selectedOption == FeeOption.custom,
            title: S().coincontrol_tx_detail_fee_custom,
            subtitle: _showCustom
                ? getAproxTime(account, ref.watch(_selectedFeeStateProvider))
                : null,
            // _selectedFeeStateProvider is sat/kvB
            trailing: _showCustom
                ? (account != null)
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(right: EnvoySpacing.xs),
                            child: Text("~",
                                style: EnvoyTypography.body
                                    .copyWith(color: EnvoyColors.textTertiary)),
                          ),
                          EnvoyAmount(
                              amountSats: getApproxFeeInSats(
                                  feeRate: ref.watch(_selectedFeeStateProvider),
                                  txVSizeVb: _safeTxVSizeVb(
                                    widget.transaction.fee.toDouble(),
                                    FeeRate.fromBigInt(
                                            widget.transaction.feeRate.field0)
                                        .satPerVb,
                                  )),
                              amountWidgetStyle: AmountWidgetStyle.normal,
                              account: account!),
                        ],
                      )
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
                      transaction: widget.transaction,
                      onFeeSelect: (fee) {
                        ref.read(_selectedFeeStateProvider.notifier).state =
                            fee;
                      },
                      allowSubOne: widget.allowSubOneInCustom &&
                          (Settings().usingDefaultElectrumServer ||
                              Settings().subSatFeeEnabled),
                    ),
                  ),
          ),

          SizedBox(height: EnvoySpacing.medium1),
          EnvoyButton(
            S().component_apply,
            onTap: () async {
              ref.read(selectedFeeOptionProvider.notifier).state =
                  _selectedOption;
              switch (_selectedOption) {
                case FeeOption.fast:
                  widget.onFeeSelect(fasterFee, context, false);
                  break;
                case FeeOption.standard:
                  widget.onFeeSelect(standardFee, context, false);
                  break;
                case FeeOption.slow:
                  widget.onFeeSelect(slowerFee, context, false);
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
      if (feeChooserState.minFeeRate >= feeChooserState.maxFeeRate) {
        feeList = [feeChooserState.minFeeRate];
        return;
      }
      // One step per sat/vB
      final int totalSteps = (feeChooserState.maxFeeRate.satPerKvb -
              feeChooserState.minFeeRate.satPerKvb) ~/
          1000;
      kPrint(
        "totalFeeSuggestion $totalSteps steps "
        "(${feeChooserState.minFeeRate} to ${feeChooserState.maxFeeRate})",
      );
      if (totalSteps <= 0) {
        feeList = [feeChooserState.minFeeRate];
      } else {
        feeList = List.generate(
          totalSteps,
          (index) =>
              feeChooserState.minFeeRate + FeeRate.fromSatPerKvb(index * 1000),
        ).reversed.toList();
      }
    });
  }
}

int _safeTxVSizeVb(double fee, double feeRate) {
  if (feeRate == 0 || feeRate.isNaN || !feeRate.isFinite) {
    // fallback – ovisno što ti ima smisla: 0, neki default, ili skip UI
    return 0;
  }
  final vsize = fee / feeRate;
  if (vsize.isNaN || !vsize.isFinite) {
    return 0;
  }
  return vsize.round(); // ili .toInt(), kako želiš
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
  final Function(FeeRate fee) onFeeSelect;
  final int selectedItem;
  final List<FeeRate> fees;
  final BitcoinTransaction transaction;

  /// This feature will be implemented in future release
  final bool allowSubOne;

  const FeeSlider({
    super.key,
    this.selectedItem = 1,
    required this.onFeeSelect,
    required this.fees,
    required this.transaction,
    required this.allowSubOne,
  });

  @override
  ConsumerState createState() => _FeeSliderState();
}

//local state notifier to keep track of selected index,
//this is used to animate the selected item,
//by using provider we can avoid unnecessary rebuilds on scroll-wheel widget
final _selectedFeeStateProvider =
    StateProvider.autoDispose<FeeRate>((ref) => FeeRate.fromSatPerKvb(0));

class _FeeSliderState extends ConsumerState<FeeSlider> {
  double yOffset = 0.0;
  int? _lastHapticIndex;

  bool _disableHaptic = false;
  bool _initializationFinished = false;
  final FixedExtentScrollController _controller = FixedExtentScrollController(
    initialItem: 2,
  );

  late List<FeeRate> _effectiveFees;

  bool _allowSubOne = false;

  @override
  void initState() {
    super.initState();
    _allowSubOne = widget.allowSubOne;
    _effectiveFees = _buildEffectiveFees();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeSelectedRate();
    });
  }

  List<FeeRate> _buildEffectiveFees() {
    final base = [...widget.fees]
      ..sort((a, b) => a.satPerKvb.compareTo(b.satPerKvb));

    final result = <FeeRate>[];

    // Keep only ≥1 sat/vB, sorted descending
    final baseGe1 = base.where((f) => !f.isSubSat).toList();
    result.addAll(baseGe1.reversed);

    if (_allowSubOne) {
      // 0.99 → 0.10 sat/vB in 0.01 steps
      for (int i = 990; i >= 100; i -= 10) {
        result.add(FeeRate.fromSatPerKvb(i));
      }
    }

    return result;
  }

  void initializeSelectedRate() async {
    FeeRate feeRate = ref.read(spendFeeRateProvider);
    final FeeRate selectedItem = ref.read(_selectedFeeStateProvider);

    if (feeRate != selectedItem) {
      setState(() {
        ref.read(_selectedFeeStateProvider.notifier).state = feeRate;
        _disableHaptic = true;
      });

      int jumpIndex = _effectiveFees.indexWhere((f) => f == feeRate);
      if (jumpIndex < 0) {
        jumpIndex = _effectiveFees.length - 1;
      }

      _controller
          .animateToItem(
        jumpIndex,
        duration: const Duration(milliseconds: 60),
        curve: Curves.easeInOut,
      )
          .then((_) {
        _disableHaptic = false;
        _initializationFinished = true;
      });
    }
  }

  TextStyle? get _unselectedTextStyle {
    return Theme.of(
      context,
    ).textTheme.titleSmall?.copyWith(fontSize: 12, color: EnvoyColors.gray600);
  }

  TextStyle? get _selectedTextStyle {
    return EnvoyTypography.body.copyWith(
      color: EnvoyColors.accentPrimary,
    );
  }

  TextStyle? get _warningTextStyle {
    return EnvoyTypography.body.copyWith(
      color: EnvoyColors.warning,
    );
  }

  TextStyle? get _satPerVbStyle {
    return EnvoyTypography.body.copyWith(
      color: EnvoyColors.accentPrimary,
    );
  }

  TextStyle? get _satPerVbWarningStyle {
    return EnvoyTypography.body.copyWith(
      color: EnvoyColors.warning,
    );
  }

  Widget _buildIndicatorWidget(FeeRate feeRate, int feePercentage) {
    //consumer to listen to selected index changes, to animate the selected item
    return Consumer(
      builder: (context, ref, child) {
        final selectedItem = ref.watch(_selectedFeeStateProvider);
        return RotatedBox(
          quarterTurns: 3,
          child: SizedBox(
            height: 68,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  duration: const Duration(milliseconds: 200),
                  scale: selectedItem == feeRate ? 1.2 : 1,
                  child: Text(
                    feeRate.displayString,
                    style: selectedItem == feeRate
                        ? feePercentage >= 25
                            ? _warningTextStyle
                            : _selectedTextStyle
                        : _unselectedTextStyle,
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  height: selectedItem == feeRate ? 34 : 32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: selectedItem == feeRate
                        ? feePercentage >= 25
                            ? EnvoyColors.warning
                            : EnvoyColors.teal500
                        : EnvoyColors.gray600,
                  ),
                  margin: EdgeInsets.only(top: selectedItem == feeRate ? 4 : 0),
                  width: selectedItem == feeRate ? 3 : 2,
                ),
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
    FeeRate selectedFee = ref.watch(_selectedFeeStateProvider);
    final double txFeeRateSatVb =
        widget.transaction.feeRate.field0 > BigInt.zero
            ? FeeRate.fromBigInt(widget.transaction.feeRate.field0).satPerVb
            : ref.read(spendFeeRateProvider).satPerVb;
    int aproxFee = getApproxFeeInSats(
        feeRate: selectedFee,
        txVSizeVb: _safeTxVSizeVb(
          widget.transaction.fee.toDouble(),
          txFeeRateSatVb,
        ));
    int feePercentage =
        ((aproxFee / (aproxFee + widget.transaction.amount.abs())) * 100)
            .round();

    return Consumer(
      builder: (context, ref, child) {
        ref.listen(spendFeeRateProvider, (previous, next) {
          initializeSelectedRate();
        });
        return Container(
            constraints: const BoxConstraints(maxHeight: 210),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 100,
                  child: Stack(
                    children: [
                      // Slider always full-width so 1 sat/vB stays centred.
                      Positioned.fill(
                        child: SizedBox(
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
                                    squeeze: _effectiveFees.length > 1000
                                        ? 1.0
                                        : 1.3,
                                    onSelectedItemChanged: _handleItemChanged,
                                    childDelegate:
                                        ListWheelChildBuilderDelegate(
                                      childCount: _effectiveFees.length,
                                      builder: (context, index) {
                                        return _buildIndicatorWidget(
                                            _effectiveFees[index],
                                            feePercentage);
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
                                          selectedFee == FeeRate.fromSatPerVb(1)
                                              ? "sat/vb"
                                              : "sats/vb",
                                          style: feePercentage >= 25
                                              ? _satPerVbWarningStyle
                                              : _satPerVbStyle,
                                        )),
                                  ),
                                ),
                                Positioned.fill(
                                  child: IgnorePointer(
                                    child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                          gradient: RadialGradient(
                                            transform:
                                                const GradientRotation(1.6),
                                            radius: 3,
                                            focal: Alignment.center,
                                            colors: [
                                              gradientOverlayColor
                                                  .applyOpacity(0.0),
                                              gradientOverlayColor
                                                  .applyOpacity(0.0),
                                              gradientOverlayColor
                                                  .applyOpacity(0.0),
                                              gradientOverlayColor
                                                  .applyOpacity(0.6),
                                              gradientOverlayColor
                                                  .applyOpacity(0.7),
                                              gradientOverlayColor
                                                  .applyOpacity(0.8),
                                              gradientOverlayColor
                                                  .applyOpacity(0.8),
                                              gradientOverlayColor
                                                  .applyOpacity(0.9),
                                              gradientOverlayColor
                                                  .applyOpacity(0.9),
                                              gradientOverlayColor
                                                  .applyOpacity(1),
                                            ],
                                          ),
                                        )),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Warning centred in the left half of the screen.
                      if (!_allowSubOne &&
                          selectedFee == FeeRate.fromSatPerVb(1))
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          width: MediaQuery.of(context).size.width / 2,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: EnvoySpacing.medium2),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    S().coincontrol_subsat_selectorWarning,
                                    style: EnvoyTypography.label.copyWith(
                                      color: EnvoyColors.textTertiary,
                                    ),
                                    textAlign: TextAlign.center,
                                    softWrap: true,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      showEnvoyPopUp(
                                          context,
                                          S()
                                              .send_editTxDetailsSubsatModal_content,
                                          S()
                                              .settings_advanced_taproot_modal_cta1,
                                          (context) {
                                            Navigator.of(context).pop();
                                            Settings().subSatFeeEnabled = true;
                                            Settings().store();
                                            setState(() {
                                              _allowSubOne = true;
                                              _effectiveFees =
                                                  _buildEffectiveFees();
                                              final selectedFee = ref.read(
                                                  _selectedFeeStateProvider);
                                              final idx =
                                                  _effectiveFees.indexWhere(
                                                      (f) => f == selectedFee);
                                              if (idx != -1) {
                                                _controller.jumpToItem(idx);
                                              }
                                            });
                                          },
                                          title: S()
                                              .send_editTxDetailsSubsatModal_header,
                                          showCloseButton: false,
                                          icon: EnvoyIcons.info,
                                          learnMoreText:
                                              S().component_learnMore,
                                          onLearnMore: () {},
                                          secondaryButtonLabel:
                                              S().component_back,
                                          onSecondaryButtonTap: (context) {
                                            Navigator.of(context).pop();
                                          });
                                    },
                                    child: Text(
                                      S().component_learnMore,
                                      textAlign: TextAlign.center,
                                      style: EnvoyTypography.label.copyWith(
                                        color: EnvoyColors.accentPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
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
                if (feePercentage >= 25)
                  Padding(
                    padding: const EdgeInsets.only(top: EnvoySpacing.medium2),
                    child: feeOverSpendWarning(feePercentage),
                  ),
                const Padding(
                    padding: EdgeInsets.only(bottom: EnvoySpacing.medium1)),
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

    final FeeRate fee = _effectiveFees[index];
    ref.read(_selectedFeeStateProvider.notifier).state = fee;

    if (_initializationFinished) {
      ref.read(spendFeeRateProvider.notifier).state = fee;
    }
  }
}
