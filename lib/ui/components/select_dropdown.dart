// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/material.dart';

class SelectDropdown extends StatefulWidget {
  final String labelOption1;
  final String labelOption2;
  final bool isDropdownActive;

  SelectDropdown({
    required this.labelOption1,
    required this.labelOption2,
    this.isDropdownActive = true,
  });

  @override
  _SelectDropdownState createState() => _SelectDropdownState();
}

class _SelectDropdownState extends State<SelectDropdown> {
  String? selectedValue;
  bool isTapped = true;
  late FocusNode focusNode;

  _SelectDropdownState() {
    focusNode = FocusNode();
  }

  @override
  void initState() {
    super.initState();
    selectedValue = widget.labelOption1; // default
    focusNode = FocusNode();
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: focusNode,
      onFocusChange: (hasFocus) {
        setState(() {
          isTapped = hasFocus;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: widget.isDropdownActive
              ? EnvoyColors.surface2
              : EnvoyColors.surface2.withOpacity(0.5),
          borderRadius: BorderRadius.circular(EnvoySpacing.xs),
          border: Border.all(
            color: (!isTapped && widget.isDropdownActive)
                ? EnvoyColors.accentPrimary
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(EnvoySpacing.medium1),
          child: Theme(
            data: ThemeData.light().copyWith(
              focusColor: EnvoyColors.accentPrimary,
            ),
            child: DropdownButton<String>(
              onChanged: widget.isDropdownActive
                  ? (String? newValue) {
                      setState(() {
                        selectedValue = newValue;
                      });
                    }
                  : null,
              selectedItemBuilder: (BuildContext context) {
                return <String>[widget.labelOption1, widget.labelOption2]
                    .map((String value) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style: EnvoyTypography.body1Medium.copyWith(
                        color: EnvoyColors.textPrimary,
                      ),
                    ),
                  );
                }).toList();
              },
              underline: Container(height: 0, width: 0),
              value: selectedValue,
              isExpanded: true,
              items: <String>[widget.labelOption1, widget.labelOption2]
                  .map<DropdownMenuItem<String>>((String value) {
                final bool isSelectedLabel = (value == selectedValue);
                return DropdownMenuItem<String>(
                  value: value,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        value,
                        style: EnvoyTypography.body1Medium.copyWith(
                          color: isSelectedLabel && isTapped
                              ? EnvoyColors.textPrimaryInverse
                              : EnvoyColors.textPrimary,
                        ),
                      ),
                      if (isTapped)
                        Padding(
                          padding:
                              const EdgeInsets.only(left: EnvoySpacing.medium1),
                          child: EnvoyIcon(
                            EnvoyIcons.check,
                            color: isSelectedLabel
                                ? EnvoyColors.textPrimaryInverse
                                : Colors.transparent,
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
              icon: Padding(
                padding: const EdgeInsets.only(left: EnvoySpacing.medium1),
                child: EnvoyIcon(
                  EnvoyIcons.chevron_down,
                  color: EnvoyColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
