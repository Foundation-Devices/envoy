// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EnvoyTextField extends StatefulWidget {
  const EnvoyTextField({
    super.key,
    this.defaultText,
    this.informationalText,
    this.additionalButtons = false,
    this.onQrScan,
    this.validator,
  });

  final defaultText;
  final String? informationalText;
  final bool additionalButtons;
  final Function? onQrScan;
  final Function? validator;

  @override
  State<EnvoyTextField> createState() => _EnvoyTextFieldState();
}

class _EnvoyTextFieldState extends State<EnvoyTextField> {
  FocusNode _focus = FocusNode();
  final _controller = TextEditingController();
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    super.dispose();
    _focus.removeListener(_onFocusChange);
    _focus.dispose();
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
          duration: Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(horizontal: EnvoySpacing.medium1),
          decoration: BoxDecoration(
            color: EnvoyColors.surface2,
            border: _focus.hasFocus
                ? (_isError
                    ? Border.all(color: EnvoyColors.danger)
                    : Border.all(color: EnvoyColors.accentPrimary))
                : Border.all(color: Colors.transparent),
            borderRadius: BorderRadius.all(
              Radius.circular(EnvoySpacing.small),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  onChanged: (text) {
                    setState(() {
                      _isError = !widget.validator!(text);
                    });
                  },
                  style: EnvoyTypography.body1Medium,
                  controller: _controller,
                  focusNode: _focus,
                  cursorColor:
                      _isError ? EnvoyColors.danger : EnvoyColors.accentPrimary,
                  decoration: InputDecoration(
                    labelText: widget.defaultText,
                    labelStyle: EnvoyTypography.body1Medium
                        .copyWith(color: EnvoyColors.textTertiary),
                    floatingLabelStyle: EnvoyTypography.body1Medium.copyWith(
                        color: _focus.hasFocus
                            ? (_isError
                                ? EnvoyColors.danger
                                : EnvoyColors.accentPrimary)
                            : EnvoyColors.textTertiary),
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
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: EnvoySpacing.medium1),
                      child: GestureDetector(
                        child: EnvoyIcon(
                          EnvoyIcons.scan,
                        ),
                        onTap: () {
                          if (widget.onQrScan != null) {
                            widget.onQrScan!();
                          }
                        },
                      ),
                    ),
                    GestureDetector(
                      child: EnvoyIcon(
                        EnvoyIcons.clipboard,
                      ),
                      onTap: () async {
                        ClipboardData? cdata =
                            await Clipboard.getData(Clipboard.kTextPlain);
                        String? text = cdata?.text ?? null;
                        if (text != null) {
                          _controller.text = text;
                          // validate(text);
                        }
                      },
                    ),
                  ],
                )
            ],
          ),
        ),
        if (widget.informationalText != null)
          Padding(
            padding: const EdgeInsets.only(
                left: EnvoySpacing.medium1, top: EnvoySpacing.small),
            child: Text(
              widget.informationalText!,
              style: EnvoyTypography.caption1Medium.copyWith(
                  color: _isError
                      ? EnvoyColors.danger
                      : EnvoyColors.textSecondary),
            ),
          )
      ],
    );
  }
}
