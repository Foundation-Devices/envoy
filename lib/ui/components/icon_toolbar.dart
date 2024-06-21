// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'icon_tab.dart';

class IconToolbarOption {
  final String label;
  final EnvoyIcons icon;
  final bool isSelected;
  final VoidCallback onSelect;

  IconToolbarOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onSelect,
  });
}

class IconToolbar extends StatefulWidget {
  final List<IconToolbarOption> options;
  final double spacing;

  const IconToolbar({
    super.key,
    required this.options,
    this.spacing = EnvoySpacing.xs,
  });

  @override
  State<IconToolbar> createState() => _IconToolbarState();
}

class _IconToolbarState extends State<IconToolbar> {
  bool hasMeasured = false;
  double maxHeight = 0;
  final List<GlobalKey> _keys = [];

  @override
  void initState() {
    super.initState();
    _keys.addAll(List.generate(widget.options.length, (_) => GlobalKey()));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateMaxHeight();
    });
  }

  void _calculateMaxHeight() {
    final heights = _keys.map((key) => _getHeight(key)).toList();
    final max = heights.reduce((a, b) => a > b ? a : b);

    setState(() {
      maxHeight = max;
      hasMeasured = true;
    });
  }

  double _getHeight(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      final renderBox = context.findRenderObject() as RenderBox;
      return renderBox.size.height;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: List.generate(widget.options.length, (index) {
        final option = widget.options[index];
        return _buildIconTab(
          _keys[index],
          option.label,
          option.icon,
          option.isSelected,
          option.onSelect,
          index,
        );
      }),
    );
  }

  Widget _buildIconTab(
    GlobalKey key,
    String label,
    EnvoyIcons icon,
    bool isSelected,
    VoidCallback onSelect,
    int index,
  ) {
    return Expanded(
      child: Container(
        key: key,
        height: hasMeasured ? maxHeight : null,
        padding: EdgeInsets.only(left: index == 0 ? 0 : widget.spacing),
        child: IconTab(
          label: label,
          icon: icon,
          isSelected: isSelected,
          onSelect: (selected) {
            onSelect();
          },
        ),
      ),
    );
  }
}
