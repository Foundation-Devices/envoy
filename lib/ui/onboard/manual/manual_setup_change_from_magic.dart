// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later
// ignore_for_file: constant_identifier_names

import 'dart:io';
import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/ui/onboard/onboard_page_wrapper.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';

class MagicBackupDeactivated extends ConsumerStatefulWidget {
  const MagicBackupDeactivated({super.key});

  @override
  ConsumerState<MagicBackupDeactivated> createState() =>
      _MagicBackupDeactivatedState();
}

class _MagicBackupDeactivatedState
    extends ConsumerState<MagicBackupDeactivated> {
  bool _loading = true;

  @override
  void initState() {
    _deleteMagicBackup();

    super.initState();
  }

  Future<void> _deleteMagicBackup() async {
    await EnvoySeed().deleteMagicBackup();
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return OnboardPageBackground(
        child: Material(
      color: Colors.transparent,
      child: mainWidget(context),
    ));
  }

  Widget mainWidget(BuildContext context) {
    if (_loading) {
      return const Center(
        child: SizedBox(
          height: 180,
          width: 180,
          child: CircularProgressIndicator(
            color: EnvoyColors.tealLight,
            backgroundColor: EnvoyColors.surface4,
            strokeWidth: 15,
            strokeCap: StrokeCap.round,
          ),
        ),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(height: EnvoySpacing.small),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: EnvoySpacing.medium1),
            child: Image.asset("assets/exclamation_icon.png"),
          ),
          const SizedBox(height: EnvoySpacing.medium1),
          Flexible(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: EnvoySpacing.medium3),
                child: Column(
                  children: [
                    Text(S().manual_setup_change_from_magic_header,
                        textAlign: TextAlign.center,
                        style: EnvoyTypography.heading),
                    const SizedBox(height: EnvoySpacing.medium1),
                    Text(
                      Platform.isAndroid
                          ? S().manual_setup_change_from_magic_subheaderGoogle
                          : S().manual_setup_change_from_magic_subheaderApple,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: EnvoySpacing.medium1),
          Padding(
            padding: const EdgeInsets.only(
                left: EnvoySpacing.xs,
                right: EnvoySpacing.xs,
                bottom: EnvoySpacing.medium2),
            child: OnboardingButton(
                type: EnvoyButtonTypes.primary,
                label: S().component_confirm,
                onTap: () async {
                  context.go("/");
                }),
          )
        ],
      );
    }
  }
}
