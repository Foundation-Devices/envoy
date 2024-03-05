// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';

class EnvoyTextField extends StatefulWidget {
  const EnvoyTextField({
    Key? key,
    this.defaultText,
    this.informationalText,
    this.additionalButtons = false,
    this.onQrScan,
    required this.onChanged,
    this.errorText,
    this.isError = false,
    this.isLoading,
    required this.controller,
  }) : super(key: key);

  final dynamic defaultText;
  final String? informationalText;
  final String? errorText;
  final bool additionalButtons;
  final void Function()? onQrScan;
  final void Function(String) onChanged;
  final bool isError;
  final bool? isLoading;
  final TextEditingController controller;

  @override
  State<EnvoyTextField> createState() => _EnvoyTextFieldState();
}

class _EnvoyTextFieldState extends State<EnvoyTextField> {
  late FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _focus = FocusNode();
    _focus.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(
            horizontal: EnvoySpacing.medium1,
          ),
          decoration: BoxDecoration(
            color: EnvoyColors.surface2,
            border: _focus.hasFocus
                ? (widget.isError
                    ? Border.all(color: EnvoyColors.danger)
                    : Border.all(color: EnvoyColors.accentPrimary))
                : Border.all(color: Colors.transparent),
            borderRadius: const BorderRadius.all(
              const Radius.circular(EnvoySpacing.small),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  onChanged: (text) {
                    widget.onChanged(text);
                  },
                  style: EnvoyTypography.body,
                  controller: widget.controller,
                  focusNode: _focus,
                  cursorColor: widget.isError
                      ? EnvoyColors.danger
                      : EnvoyColors.accentPrimary,
                  decoration: InputDecoration(
                    labelText: widget.defaultText.toString(),
                    labelStyle: EnvoyTypography.body.copyWith(
                      color: EnvoyColors.textTertiary,
                    ),
                    floatingLabelStyle: EnvoyTypography.body.copyWith(
                      color: _focus.hasFocus
                          ? (widget.isError
                              ? EnvoyColors.danger
                              : EnvoyColors.accentPrimary)
                          : EnvoyColors.textTertiary,
                    ),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                  ),
                ),
              ),
              if (widget.additionalButtons)
                Row(
                  children: [
                    const SizedBox(width: EnvoySpacing.medium1),
                    if (widget.isLoading ?? false)
                      Container(
                        width: EnvoySpacing.medium1,
                        height: EnvoySpacing.medium1,
                        child: const CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: EnvoyColors.textPrimary,
                        ),
                      ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: EnvoySpacing.medium1),
                      child: GestureDetector(
                        child: const EnvoyIcon(EnvoyIcons.scan),
                        onTap: () {
                          widget.onQrScan!();
                        },
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: EnvoySpacing.medium1),
                      child: GestureDetector(
                        child: const EnvoyIcon(EnvoyIcons.clipboard),
                        onTap: () async {
                          final cdata =
                              await Clipboard.getData(Clipboard.kTextPlain);
                          final text = cdata?.text ?? null;
                          if (text != null) {
                            widget.controller.text = text;
                          }
                        },
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        if (widget.informationalText != null)
          Padding(
            padding: const EdgeInsets.only(top: EnvoySpacing.medium1),
            child: Text(
              widget.isError ? widget.errorText! : widget.informationalText!,
              style: EnvoyTypography.info.copyWith(
                color: widget.isError
                    ? EnvoyColors.danger
                    : EnvoyColors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }
}
