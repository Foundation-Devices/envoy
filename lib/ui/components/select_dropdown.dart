// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/local_storage.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/color_util.dart';
import 'package:flutter/material.dart';

enum EnvoyDropdownOptionType { normal, sectionBreak }

class EnvoyDropdownOption {
  final String label;
  final String value;
  final EnvoyDropdownOptionType type;

  EnvoyDropdownOption(
      {required this.label,
      required this.value,
      this.type = EnvoyDropdownOptionType.normal});
}

class EnvoyDropdown extends StatefulWidget {
  final List<EnvoyDropdownOption> options;
  final bool isDropdownActive;
  final Function(EnvoyDropdownOption?)? onOptionChanged;
  final int initialIndex;
  final GlobalKey<EnvoyDropdownState>? dropdownKey;

  const EnvoyDropdown({
    super.key,
    required this.options,
    this.isDropdownActive = true,
    this.onOptionChanged,
    this.initialIndex = 0,
    this.dropdownKey,
  });

  @override
  EnvoyDropdownState createState() => EnvoyDropdownState();

  void setSelectedIndex(int index) {
    if (dropdownKey?.currentState != null) {
      dropdownKey?.currentState?.setSelectedIndex(index);
    }
  }
}

class EnvoyDropdownState extends State<EnvoyDropdown> {
  int _selectedIndex = 0;
  EnvoyDropdownOption? _selectedOption;
  bool isFocused = true;
  late FocusNode _focusNode;

  EnvoyDropdownState() {
    _focusNode = FocusNode();
  }

  void setSelectedIndex(int index) {
    setState(() {
      _selectedIndex = index;
      _selectedOption = widget.options[_selectedIndex];
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _selectedOption =
        widget.options.isNotEmpty ? widget.options[_selectedIndex] : null;
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onFocusChange: (hasFocus) {
        setState(() {
          isFocused = hasFocus;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: widget.isDropdownActive
              ? EnvoyColors.surface2
              : EnvoyColors.surface2.applyOpacity(0.5),
          borderRadius: BorderRadius.circular(EnvoySpacing.small),
          border: Border.all(
            color: (!isFocused && widget.isDropdownActive)
                ? EnvoyColors.accentPrimary
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            focusColor: EnvoyColors.accentPrimary,
          ),
          child: _FastDropdownButton<EnvoyDropdownOption>(
            elevation: EnvoySpacing.xs.toInt(),
            borderRadius: BorderRadius.circular(EnvoySpacing.small),
            padding:
                const EdgeInsets.symmetric(horizontal: EnvoySpacing.medium1),
            onChanged: widget.isDropdownActive
                ? (EnvoyDropdownOption? newValue) {
                    if (newValue == null ||
                        newValue.type == EnvoyDropdownOptionType.sectionBreak) {
                      return;
                    }

                    final index = widget.options.indexOf(newValue);
                    //ENV-1689-buy-account-reorder-visual-miniglitch
                    if (index == -1) {
                      return;
                    }

                    setState(() {
                      _selectedOption = newValue;
                      _selectedIndex = index;
                      widget.onOptionChanged?.call(newValue);
                    });
                  }
                : null,
            selectedItemBuilder: (BuildContext context) {
              return widget.options.map((EnvoyDropdownOption option) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    option.label,
                    style: EnvoyTypography.body.copyWith(
                      color: EnvoyColors.textPrimary,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              }).toList();
            },
            underline: const SizedBox.shrink(),
            // _selected index becomes -1 for some reason
            value: widget.options[_selectedIndex],
            isExpanded: true,
            items: widget.options.map<DropdownMenuItem<EnvoyDropdownOption>>(
              (EnvoyDropdownOption option) {
                final bool isSelectedOption =
                    option.label == _selectedOption!.label;
                return DropdownMenuItem<EnvoyDropdownOption>(
                  value: option,
                  enabled: option.type != EnvoyDropdownOptionType.sectionBreak,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox.shrink(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            option.label,
                            style: option.type ==
                                    EnvoyDropdownOptionType.sectionBreak
                                ? EnvoyTypography.info.copyWith(
                                    color: EnvoyColors.textTertiary,
                                  )
                                : EnvoyTypography.body.copyWith(
                                    color: isSelectedOption
                                        ? EnvoyColors.textPrimaryInverse
                                        : EnvoyColors.textPrimary,
                                  ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (isFocused)
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: EnvoySpacing.medium1),
                              child: EnvoyIcon(
                                EnvoyIcons.check,
                                color: isSelectedOption
                                    ? EnvoyColors.textPrimaryInverse
                                    : Colors.transparent,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox.shrink(),
                    ],
                  ),
                );
              },
            ).toList(),
            icon: const Padding(
              padding: EdgeInsets.only(left: EnvoySpacing.medium1),
              child: EnvoyIcon(
                EnvoyIcons.chevron_down,
                color: EnvoyColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FastDropdownButton<T> extends StatelessWidget {
  final List<DropdownMenuItem<T>>? items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final List<Widget> Function(BuildContext)? selectedItemBuilder;
  final Widget? icon;
  final Widget? underline;
  final bool isExpanded;
  final int elevation;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? padding;

  const _FastDropdownButton({
    this.items,
    this.value,
    this.onChanged,
    this.selectedItemBuilder,
    this.icon,
    this.underline,
    this.isExpanded = false,
    this.elevation = 8,
    this.borderRadius = BorderRadius.zero,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: items == null || items!.isEmpty
          ? null
          : () async {
              final RenderBox button = context.findRenderObject() as RenderBox;
              final RenderBox overlay =
                  Overlay.of(context).context.findRenderObject() as RenderBox;

              final position = RelativeRect.fromRect(
                Rect.fromPoints(
                  button.localToGlobal(Offset.zero, ancestor: overlay),
                  button.localToGlobal(button.size.bottomRight(Offset.zero),
                      ancestor: overlay),
                ),
                Offset.zero & overlay.size,
              );

              final selected = await Navigator.push(
                context,
                _FastDropdownRoute<T>(
                  items: items!,
                  buttonRect: position.toRect(Offset.zero & overlay.size),
                  elevation: elevation,
                  borderRadius: borderRadius,
                  selected: value,
                  padding: padding,
                ),
              );

              if (selected != null && onChanged != null) {
                onChanged!(selected);
              }
            },
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.bodyMedium!,
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: selectedItemBuilder == null
                    ? (value != null
                        ? items!.firstWhere((item) => item.value == value).child
                        : const SizedBox())
                    : selectedItemBuilder!(context)[
                        items!.indexWhere((item) => item.value == value)],
              ),
              icon ?? const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }
}

class _FastDropdownRoute<T> extends PopupRoute<T> {
  final List<DropdownMenuItem<T>> items;
  final Rect buttonRect;
  final int elevation;
  final BorderRadius borderRadius;
  final T? selected;
  final EdgeInsetsGeometry? padding;

  _FastDropdownRoute({
    required this.items,
    required this.buttonRect,
    required this.elevation,
    required this.borderRadius,
    required this.selected,
    this.padding,
  });

  @override
  Duration get transitionDuration => const Duration(milliseconds: 150);

  @override
  bool get barrierDismissible => true;

  @override
  Color get barrierColor => Colors.transparent;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return CustomSingleChildLayout(
      delegate: _DropdownRouteLayout(
        RelativeRect.fromRect(
            buttonRect, Offset.zero & MediaQuery.of(context).size),
        buttonRect.height,
      ),
      child: FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: Material(
          elevation: elevation.toDouble(),
          borderRadius: borderRadius,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300, maxWidth: 340),
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: items.map((item) {
                final bool isSelected = item.value == selected;
                return InkWell(
                  onTap: () {
                    Navigator.pop(context, item.value);
                  },
                  child: Container(
                    width: double.infinity,
                    color: isSelected ? EnvoyColors.accentPrimary : null,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    child: item.child,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _DropdownRouteLayout extends SingleChildLayoutDelegate {
  final RelativeRect position;
  final double buttonHeight;

  _DropdownRouteLayout(this.position, this.buttonHeight);

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return constraints.loosen();
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return Offset(position.left, position.top + buttonHeight);
  }

  @override
  bool shouldRelayout(_DropdownRouteLayout oldDelegate) {
    return position != oldDelegate.position ||
        buttonHeight != oldDelegate.buttonHeight;
  }
}

int getInitialElectrumDropdownIndex() {
  final String? savedElectrumServerType =
      LocalStorage().prefs.getString("electrumServerType");

  bool isPersonalNode = savedElectrumServerType == "personalNode" ||
      (savedElectrumServerType == null &&
          !Settings().usingDefaultElectrumServer);

  if (Settings().usingDefaultElectrumServer ||
      savedElectrumServerType == "foundation") {
    return 0;
  } else if (isPersonalNode) {
    return 1;
  } else if (savedElectrumServerType == "blockStream") {
    return 3;
  } else if (savedElectrumServerType == "diyNodes") {
    return 4;
  }

  return 0; // Default to foundation as a safe fallback
}
