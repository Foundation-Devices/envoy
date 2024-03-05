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

  EnvoyDropdown({
    super.key,
    required this.options,
    this.isDropdownActive = true,
    this.onOptionChanged,
    this.initialIndex = 0,
  });

  @override
  _EnvoyDropdownState createState() => _EnvoyDropdownState();
}

class _EnvoyDropdownState extends State<EnvoyDropdown> {
  int _selectedIndex = 0;
  EnvoyDropdownOption? _selectedOption;
  bool _isTapped = true;
  late FocusNode _focusNode;

  _EnvoyDropdownState() {
    _focusNode = FocusNode();
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

                      for (final (int index, EnvoyDropdownOption option)
                          in widget.options.indexed) {
                        if (option.type == newValue!.type) {
                          _selectedIndex = index;
                        }
                      }

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
                    ),
                  ),
                );
              }).toList();
            },
            underline: Container(height: 0, width: 0),
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
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
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
