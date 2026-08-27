// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/envoy_scaffold.dart';
import 'package:envoy/ui/components/pop_up.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/envoy_method_channel.dart';
import 'package:envoy/ui/home/home_state.dart';
import 'package:envoy/ui/onboard/manual/manual_setup.dart';
import 'package:envoy/ui/onboard/onboard_page_wrapper.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/routes/accounts_router.dart';
import 'package:envoy/ui/routes/routes.dart';
import 'package:envoy/ui/state/accounts_state.dart';
import 'package:envoy/ui/state/home_page_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rive/rive.dart' as rive;

class EraseWalletsAndBackupsWarning extends ConsumerWidget {
  const EraseWalletsAndBackupsWarning({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final platformWarning = Platform.isAndroid
        ? S().backups_erase_wallets_and_backups_modal_1_2_android_subheading
        : S().backups_erase_wallets_and_backups_modal_1_2_ios_subheading;
    final backupWarning =
        S().backups_erase_wallets_and_backups_modal_2_2_subheading;

    return EnvoyPopUp(
      icon: EnvoyIcons.alert,
      typeOfMessage: PopUpState.warning,
      title: S().component_warning,
      showCloseButton: false,
      content: "${platformWarning.trim()}\n\n${backupWarning.trim()}",
      secondaryButtonLabel: S().component_cancel,
      onSecondaryButtonTap: (context) => Navigator.pop(context),
      primaryButtonLabel: S().component_continue,
      onPrimaryButtonTap: (context) {
        if (ref.read(hotWalletAccountsEmptyProvider)) {
          displaySeedBeforeNuke(context);
        } else {
          showEnvoyDialog(
            context: context,
            dialog: const EraseWalletsBalanceWarning(),
          );
        }
      },
    );
  }
}

class EraseWalletsBalanceWarning extends ConsumerStatefulWidget {
  const EraseWalletsBalanceWarning({super.key});

  @override
  ConsumerState<EraseWalletsBalanceWarning> createState() =>
      _EraseWalletsBalanceWarningState();
}

class _EraseWalletsBalanceWarningState
    extends ConsumerState<EraseWalletsBalanceWarning> {
  @override
  Widget build(BuildContext context) {
    return EnvoyPopUp(
      icon: EnvoyIcons.alert,
      typeOfMessage: PopUpState.warning,
      title: S().component_warning,
      showCloseButton: true,
      content: S()
          .manual_setup_recovery_import_backup_modal_fail_connectivity_subheading,
      customWidget: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Text(
          S().erase_wallet_with_balance_modal_subheading,
          textAlign: TextAlign.center,
          style: EnvoyTypography.info,
        ),
      ),
      primaryButtonLabel: S().erase_wallet_with_balance_modal_CTA1,
      onPrimaryButtonTap: (context) {
        // Show home page and navigate to accounts
        ref.read(homePageBackgroundProvider.notifier).state =
            HomePageBackgroundState.hidden;
        ref.read(homePageTabProvider.notifier).state =
            HomePageTabState.accounts;
        ref.read(homePageTitleProvider.notifier).state = "";

        Navigator.of(context).pop();
        Navigator.of(context).pop();
        GoRouter.of(context).go(ROUTE_ACCOUNTS_HOME);
      },
      tertiaryButtonLabel: S().erase_wallet_with_balance_modal_CTA2,
      tertiaryButtonTextColor: EnvoyColors.danger,
      onTertiaryButtonTap: (context) {
        Navigator.pop(context);
        displaySeedBeforeNuke(context);
      },
    );
  }
}

class EraseWalletsConfirmation extends ConsumerStatefulWidget {
  const EraseWalletsConfirmation({super.key});

  @override
  ConsumerState<EraseWalletsConfirmation> createState() =>
      _EraseWalletsConfirmationState();
}

class _EraseWalletsConfirmationState
    extends ConsumerState<EraseWalletsConfirmation> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      constraints: const BoxConstraints(maxHeight: 360, maxWidth: 320),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: EnvoySpacing.medium2,
          vertical: EnvoySpacing.medium2,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            Image.asset(
              "assets/exclamation_triangle.png",
              height: 80,
              width: 80,
              color: EnvoyColors.danger,
            ),
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: EnvoySpacing.small,
                    vertical: EnvoySpacing.medium2,
                  ),
                  child: Text(
                    S().delete_wallet_for_good_modal_subheading,
                    textAlign: TextAlign.center,
                    style: EnvoyTypography.info,
                  ),
                ),
              ),
            ),
            OnboardingButton(
              type: EnvoyButtonTypes.tertiary,
              label: S().delete_wallet_for_good_modal_cta2,
              textStyle: EnvoyTypography.subheading.copyWith(
                color: EnvoyColors.danger,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EraseProgress(),
                  ),
                );
              },
            ),
            OnboardingButton(
              type: EnvoyButtonTypes.primaryModal,
              label: S().component_cancel,
              onTap: () {
                context.go("/");
              },
            ),
          ],
        ),
      ),
    );
  }
}

void displaySeedBeforeNuke(BuildContext context) async {
  Navigator.of(context).pop();
  context.pushNamed(SEED_INTRO, extra: SeedIntroScreenType.verify.toString());
}

class EraseProgress extends ConsumerStatefulWidget {
  const EraseProgress({super.key});

  @override
  ConsumerState<EraseProgress> createState() => _EraseProgressState();
}

class _EraseProgressState extends ConsumerState<EraseProgress> {
  rive.File? _riveFile;
  rive.RiveWidgetController? _controller;
  bool _isInitialized = false;

  bool _deleteInProgress = true;
  bool _isDeleted = false;

  @override
  void initState() {
    super.initState();
    _initRive();
  }

  void _initRive() async {
    _riveFile = await rive.File.asset(
      "assets/envoy_loader.riv",
      riveFactory: rive.Factory.rive,
    );
    _controller = rive.RiveWidgetController(
      _riveFile!,
      stateMachineSelector: rive.StateMachineSelector.byName('STM'),
    );

    //TODO: fix rive with databindings.
    // ignore: deprecated_member_use
    _controller?.stateMachine.boolean("indeterminate")?.value = true;

    setState(() => _isInitialized = true);

    _onInit();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _riveFile?.dispose();
    super.dispose();
  }

  void _setAnimationState({
    required bool indeterminate,
    required bool happy,
    required bool unhappy,
  }) {
    if (_controller?.stateMachine == null) return;
    final stateMachine = _controller!.stateMachine;
    //TODO: fix rive with databindings.
    // ignore: deprecated_member_use
    stateMachine.boolean("indeterminate")?.value = indeterminate;
    //TODO: fix rive with databindings.
    // ignore: deprecated_member_use
    stateMachine.boolean("happy")?.value = happy;
    //TODO: fix rive with databindings.
    // ignore: deprecated_member_use
    stateMachine.boolean("unhappy")?.value = unhappy;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_deleteInProgress,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          context.go("/");
        }
      },
      child: OnboardPageBackground(
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 260,
                    child: _isInitialized && _controller != null
                        ? rive.RiveWidget(
                            controller: _controller!,
                            fit: rive.Fit.contain,
                          )
                        : const SizedBox(),
                  ),

                  //const Padding(padding: EdgeInsets.all(28)),
                  Builder(
                    builder: (context) {
                      String title = S().delete_wallet_for_good_loading_heading;
                      if (!_deleteInProgress) {
                        title = _isDeleted
                            ? S().delete_wallet_for_good_success_heading
                            : S().delete_wallet_for_good_error_title;
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: EnvoySpacing.medium1,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          spacing: EnvoySpacing.large3,
                          children: [
                            Text(
                              title,
                              textAlign: TextAlign.center,
                              style: EnvoyTypography.heading,
                            ),
                            if (!_isDeleted && !_deleteInProgress)
                              Text(
                                S().delete_wallet_for_good_error_content,
                                textAlign: TextAlign.center,
                                style: EnvoyTypography.info.copyWith(
                                  color: EnvoyColors.textSecondary,
                                ),
                              ),

                            //const Padding(padding: EdgeInsets.all(18)),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              if (!_isDeleted && !_deleteInProgress)
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: EnvoySpacing.medium2,
                    right: EnvoySpacing.medium2,
                    left: EnvoySpacing.medium2,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: EnvoySpacing.medium1,
                    children: [
                      EnvoyButton(
                        S().component_cancel,
                        type: EnvoyButtonTypes.secondary,
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      EnvoyButton(
                        S().component_retry,
                        onTap: () {
                          _onInit();
                        },
                      ),
                    ],
                  ),
                ),
              if (_isDeleted && !_deleteInProgress)
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: EnvoySpacing.medium2,
                    right: EnvoySpacing.medium2,
                    left: EnvoySpacing.medium2,
                  ),
                  child: EnvoyButton(
                    S().component_continue,
                    type: EnvoyButtonTypes.primary,
                    onTap: () {
                      if (Platform.isAndroid) {
                        context.pushNamed(WALLET_BACKUP_WARNING, extra: true);
                      } else {
                        // Show home page and navigate to accounts
                        context.goNamed("/");

                        ref.read(homePageBackgroundProvider.notifier).state =
                            HomePageBackgroundState.hidden;
                        ref.read(homePageTabProvider.notifier).state =
                            HomePageTabState.accounts;
                        ref.read(homePageTitleProvider.notifier).state = "";
                      }
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onInit() async {
    try {
      setState(() {
        _deleteInProgress = true;
      });

      _setAnimationState(indeterminate: true, happy: false, unhappy: false);

      //wait for animation
      await Future.delayed(const Duration(seconds: 1));

      final seed = EnvoySeed();

      final isDeleted = await seed.delete();

      setState(() {
        _isDeleted = isDeleted;
        _deleteInProgress = false;
      });

      if (_isDeleted) {
        _setAnimationState(indeterminate: false, happy: true, unhappy: false);
      } else {
        _setAnimationState(indeterminate: false, happy: false, unhappy: true);
      }
    } catch (e) {
      kPrint(e);
    }
  }
}

class AndroidBackupWarning extends StatefulWidget {
  final bool skipSuccess;

  const AndroidBackupWarning({super.key, this.skipSuccess = false});

  @override
  State<AndroidBackupWarning> createState() => _AndroidBackupWarningState();
}

class _AndroidBackupWarningState extends State<AndroidBackupWarning> {
  bool canPop = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (widget.skipSuccess) {
          context.go("/");
        } else {
          context.goNamed(WALLET_SUCCESS);
        }
      },
      child: OnboardPageBackground(
        child: EnvoyScaffold(
          hasScrollBody: false,
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: EnvoySpacing.medium2,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: EnvoySpacing.xl),
                      SizedBox(
                        height: 184,
                        child: Image.asset(
                          "assets/images/onboarding_info.png",
                          height: 184,
                        ),
                      ),
                      const SizedBox(height: EnvoySpacing.medium3),
                      Text(
                        S().android_backup_info_heading,
                        textAlign: TextAlign.center,
                        style: EnvoyTypography.heading,
                      ),
                      const SizedBox(height: EnvoySpacing.medium3),
                      LinkText(
                        text: S()
                            .delete_wallet_for_good_instant_android_subheading,
                        linkStyle: EnvoyTypography.body.copyWith(
                          color: EnvoyColors.textSecondary,
                        ),
                        textStyle: EnvoyTypography.body.copyWith(
                          color: EnvoyColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: EnvoySpacing.medium2,
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: EnvoySpacing.medium1,
                          ),
                          child: Consumer(
                            builder: (context, ref, child) {
                              return EnvoyButton(
                                S().component_skip,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(EnvoySpacing.medium1),
                                ),
                                type: EnvoyButtonTypes.secondary,
                                onTap: () async {
                                  if (widget.skipSuccess) {
                                    context.go("/");
                                  } else {
                                    context.goNamed(WALLET_SUCCESS);
                                  }
                                  ref
                                      .read(homePageBackgroundProvider.notifier)
                                      .state = HomePageBackgroundState.hidden;
                                  ref.read(homePageTabProvider.notifier).state =
                                      HomePageTabState.accounts;
                                  ref
                                      .read(homePageTitleProvider.notifier)
                                      .state = "";
                                  await Future.delayed(
                                    const Duration(milliseconds: 100),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        EnvoyButton(
                          S().component_goToSettings,
                          borderRadius: BorderRadius.all(
                            Radius.circular(EnvoySpacing.medium1),
                          ),
                          onTap: () {
                            openAndroidSettings();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
