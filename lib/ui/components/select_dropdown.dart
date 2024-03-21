// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/material.dart';

enum EnvoyDropdownOptionType { normal, personalNode }

class EnvoyDropdownOption {
  final String label;
  final EnvoyDropdownOptionType type;

  EnvoyDropdownOption(this.label, {this.type = EnvoyDropdownOptionType.normal});
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
  bool _isTapped = true;
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
          _isTapped = hasFocus;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: widget.isDropdownActive
              ? EnvoyColors.surface2
              : EnvoyColors.surface2.withOpacity(0.5),
          borderRadius: BorderRadius.circular(EnvoySpacing.small),
          border: Border.all(
            color: (!_isTapped && widget.isDropdownActive)
                ? EnvoyColors.accentPrimary
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(EnvoySpacing.small),
          child: DropdownButton<EnvoyDropdownOption>(
            elevation: EnvoySpacing.xs.toInt(),
            borderRadius: BorderRadius.circular(EnvoySpacing.small),
            onChanged: widget.isDropdownActive
                ? (EnvoyDropdownOption? newValue) {
                    setState(() {
                      _selectedOption = newValue;
                      _selectedIndex = widget.options.indexOf(newValue!);
                      if (widget.onOptionChanged != null) {
                        widget.onOptionChanged!(newValue);
                      }
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
                  child: Container(
                    color: isSelectedOption
                        ? EnvoyColors.accentPrimary
                        : Colors.transparent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox.shrink(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14.0),
                          //size of the blue background
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                option.label,
                                style: EnvoyTypography.body.copyWith(
                                  color: isSelectedOption && _isTapped
                                      ? EnvoyColors.textPrimaryInverse
                                      : EnvoyColors.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (_isTapped)
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
                        ),
                        const SizedBox.shrink(),
                      ],
                    ),
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
