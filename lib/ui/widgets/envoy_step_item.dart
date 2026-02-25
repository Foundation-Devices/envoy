// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// ignore_for_file: constant_identifier_names

import 'package:envoy/ui/components/envoy_loaders.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/cupertino.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';

//TODO: add more concrete states based on bluetooth implementation
enum EnvoyStepState { LOADING, FINISHED, ERROR, IDLE, HIDDEN }

class StepModel {
  final String stepName;
  EnvoyStepState state;

  StepModel({required this.stepName, this.state = EnvoyStepState.LOADING});
}

class EnvoyStepItem extends StatefulWidget {
  final StepModel? step;
  final bool highlight;

  const EnvoyStepItem({super.key, this.step, this.highlight = false});

  @override
  State<EnvoyStepItem> createState() => _EnvoyStepItemState();
}

class _EnvoyStepItemState extends State<EnvoyStepItem> {
  @override
  Widget build(BuildContext context) {
    final step = widget.step;

    if (step == null || step.state == EnvoyStepState.HIDDEN) {
      return const SizedBox.shrink();
    }

    final Widget leading = switch (step.state) {
      EnvoyStepState.LOADING => const EnvoyActivityIndicator(),
      EnvoyStepState.FINISHED => const Icon(CupertinoIcons.checkmark_alt,
          color: EnvoyColors.textPrimary),
      EnvoyStepState.ERROR => const Icon(
          CupertinoIcons.exclamationmark_triangle,
          color: EnvoyColors.copper500,
        ),
      EnvoyStepState.IDLE => const Icon(
          CupertinoIcons.arrow_right,
          color: EnvoyColors.contentTertiary,
        ),
      _ => Container(),
    };
    return AnimatedOpacity(
      opacity: step.state == EnvoyStepState.LOADING ? 1 : .6,
      duration: const Duration(milliseconds: 320),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          leading,
          const SizedBox(width: EnvoySpacing.small),
          Flexible(
            child: Text(
              step.stepName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
              textWidthBasis: TextWidthBasis.longestLine,
              style: EnvoyTypography.info.copyWith(color: _color(step)),
            ),
          ),
        ],
      ),
    );
  }

  Color? _color(StepModel step) {
    if (step.state == EnvoyStepState.ERROR) {
      return EnvoyColors.copper500;
    }

    return widget.highlight
        ? EnvoyColors.contentSecondary
        : EnvoyColors.contentTertiary;
  }
}
