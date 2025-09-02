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
  final double dropdownMaxHeight;
  final bool showCheckIcon;
  final bool openAbove;

  const EnvoyDropdown(
      {super.key,
      required this.options,
      this.isDropdownActive = true,
      this.onOptionChanged,
      this.initialIndex = 0,
      this.dropdownKey,
      this.dropdownMaxHeight = 300,
      this.showCheckIcon = true,
      this.openAbove = false});

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
          child: _EnvoyDropdownButton<EnvoyDropdownOption>(
            openAbove: widget.openAbove,
            dropdownMaxHeight: widget.dropdownMaxHeight,
            elevation: EnvoySpacing.xs.toInt(),
            borderRadius: BorderRadius.circular(EnvoySpacing.small),
            padding: const EdgeInsets.symmetric(
                horizontal: EnvoySpacing.medium1,
                vertical: EnvoySpacing.medium1),
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
            // _selected index becomes -1 for some reason
            selectedItem: widget.options[_selectedIndex],
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
                                color: isSelectedOption && widget.showCheckIcon
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

class _EnvoyDropdownButton<T> extends StatefulWidget {
  final List<DropdownMenuItem<T>>? items;
  final T? selectedItem;
  final ValueChanged<T?>? onChanged;
  final List<Widget> Function(BuildContext)? selectedItemBuilder;
  final Widget? icon;
  final int elevation;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? padding;
  final double dropdownMaxHeight;
  final bool openAbove;

  const _EnvoyDropdownButton({
    this.items,
    this.selectedItem,
    this.onChanged,
    this.selectedItemBuilder,
    this.icon,
    this.elevation = 8,
    this.borderRadius =
        const BorderRadius.all(Radius.circular(EnvoySpacing.small)),
    this.padding,
    this.dropdownMaxHeight = 300,
    this.openAbove = false,
  });

  @override
  State<_EnvoyDropdownButton<T>> createState() =>
      _EnvoyDropdownButtonState<T>();
}

class _EnvoyDropdownButtonState<T> extends State<_EnvoyDropdownButton<T>> {
  OverlayEntry? _overlayEntry;
  bool _isDropdownOpen = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleDropdown() {
    if (_isDropdownOpen) {
      _removeDropdown();
    } else {
      _showDropdownInternal();
    }
  }

  void _showDropdownInternal() {
    if (widget.items == null || widget.items!.isEmpty) return;

    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context, rootOverlay: true)
        .context
        .findRenderObject() as RenderBox;

    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero),
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    final double topPosition = widget.openAbove
        ? position.top - widget.dropdownMaxHeight + button.size.height
        : position.top + button.size.height;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // Tap anywhere outside closes the dropdown
            Positioned.fill(
              child: GestureDetector(
                onTap: _removeDropdown,
                behavior: HitTestBehavior.translucent,
              ),
            ),
            Positioned(
              left: position.left,
              top: topPosition,
              width: button.size.width,
              child: Material(
                elevation: widget.elevation.toDouble(),
                borderRadius: widget.borderRadius,
                child: ClipRRect(
                  borderRadius: widget.borderRadius,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: widget.dropdownMaxHeight,
                      minWidth: button.size.width + 1, // +1 pixel to border
                      maxWidth: button.size.width + 1,
                    ),
                    child: Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      thickness: 3,
                      radius: Radius.circular(EnvoySpacing.small),
                      child: ListView(
                        controller: _scrollController,
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        children: widget.items!.map((item) {
                          final bool isSelected =
                              item.value == widget.selectedItem;
                          return InkWell(
                            onTap: () {
                              _removeDropdown();
                              widget.onChanged?.call(item.value);
                            },
                            child: Container(
                              width: double.infinity,
                              color: isSelected
                                  ? EnvoyColors.accentPrimary
                                  : null, // highlight
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
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
    _isDropdownOpen = true;
  }

  void _removeDropdown() {
    if (_isDropdownOpen) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _isDropdownOpen = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (_isDropdownOpen) {
          _removeDropdown(); // Close dropdown if open
        }
      },
      child: InkWell(
        onTap: _toggleDropdown,
        child: DefaultTextStyle(
          style: Theme.of(context).textTheme.bodyMedium!,
          child: Padding(
            padding: widget.padding ?? EdgeInsets.zero,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: widget.selectedItemBuilder == null
                      ? (widget.selectedItem != null
                          ? widget.items!
                              .firstWhere(
                                  (item) => item.value == widget.selectedItem)
                              .child
                          : const SizedBox())
                      : widget.selectedItemBuilder!(context)[widget.items!
                          .indexWhere(
                              (item) => item.value == widget.selectedItem)],
                ),
                widget.icon ?? const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ),
    );
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
