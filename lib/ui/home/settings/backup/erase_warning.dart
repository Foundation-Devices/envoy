// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:envoy/business/account_manager.dart';
import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/envoy_scaffold.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/envoy_method_channel.dart';
import 'package:envoy/ui/onboard/manual/manual_setup.dart';
import 'package:envoy/ui/onboard/manual/widgets/mnemonic_grid_widget.dart';
import 'package:envoy/ui/onboard/onboard_page_wrapper.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/onboard/wallet_setup_success.dart';
import 'package:envoy/ui/state/home_page_state.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rive/rive.dart' as rive;
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/home/home_state.dart';
import 'package:envoy/ui/routes/accounts_router.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/widgets/expandable_page_view.dart';

class EraseWalletsAndBackupsWarning extends StatefulWidget {
  const EraseWalletsAndBackupsWarning({super.key});

  @override
  State<EraseWalletsAndBackupsWarning> createState() =>
      _EraseWalletsAndBackupsWarningState();
}

class _EraseWalletsAndBackupsWarningState
    extends State<EraseWalletsAndBackupsWarning> {
  final PageController _pageController = PageController();

  double estimateExpandablePageViewHeight(BuildContext context) {
    double text1Height = 0.0;
    double text2Height = 0.0;
    double biggerText = 0.0;

    String text1 = Platform.isAndroid
        ? S().backups_erase_wallets_and_backups_modal_1_2_android_subheading
        : S().backups_erase_wallets_and_backups_modal_1_2_ios_subheading;
    text1Height = estimateTextHeight(text1, EnvoyTypography.info, context);

    String text2 = S().backups_erase_wallets_and_backups_modal_2_2_subheading;
    text2Height += estimateTextHeight(text2, EnvoyTypography.info, context);

    biggerText = text1Height > text2Height ? text1Height : text2Height;

    return biggerText + EnvoySpacing.medium1;
  }

  double estimateTextHeight(
      String text, TextStyle style, BuildContext context) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: null,
    )..layout(maxWidth: MediaQuery.of(context).size.width * 0.5);

    return textPainter.size.height;
  }

  @override
  Widget build(BuildContext context) {
    double expandablePageViewHeight = estimateExpandablePageViewHeight(context);

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: EnvoySpacing.medium2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: EnvoySpacing.medium1),
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
            const Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
            Column(
              children: [
                const EnvoyIcon(EnvoyIcons.alert,
                    color: EnvoyColors.accentSecondary,
                    size: EnvoyIconSize.big),
                const Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
                Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: EnvoySpacing.small,
                        horizontal: EnvoySpacing.xs),
                    child: Text(
                      S().component_warning,
                      textAlign: TextAlign.center,
                      style: EnvoyTypography.info,
                    )),
                Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: EnvoySpacing.small,
                        horizontal: EnvoySpacing.medium1),
                    child: Container(
                      height: expandablePageViewHeight,
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height *
                            0.6, // max size of PageView
                      ),
                      child: SingleChildScrollView(
                        child: ExpandablePageView(
                          controller: _pageController,
                          children: [
                            Text(
                              Platform.isAndroid
                                  ? S()
                                      .backups_erase_wallets_and_backups_modal_1_2_android_subheading
                                  : S()
                                      .backups_erase_wallets_and_backups_modal_1_2_ios_subheading,
                              textAlign: TextAlign.center,
                              style: EnvoyTypography.info,
                            ),
                            Text(
                              S().backups_erase_wallets_and_backups_modal_2_2_subheading,
                              textAlign: TextAlign.center,
                              style: EnvoyTypography.info,
                            ),
                          ],
                        ),
                      ),
                    )),
                DotsIndicator(
                  totalPages: 2,
                  pageController: _pageController,
                ),
              ],
            ),
            OnboardingButton(
                type: EnvoyButtonTypes.tertiary,
                label: S().component_cancel,
                onTap: () {
                  Navigator.pop(context);
                }),
            OnboardingButton(
                type: EnvoyButtonTypes.primaryModal,
                label: S().component_continue,
                onTap: () {
                  int currentPage = _pageController.page?.toInt() ?? 0;
                  if (currentPage == 1) {
                    if (AccountManager().hotWalletAccountsEmpty()) {
                      // Safe to delete
                      displaySeedBeforeNuke(context);
                    } else {
                      showEnvoyDialog(
                          context: context,
                          dialog: const EraseWalletsBalanceWarning());
                    }
                  } else {
                    _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOutCubicEmphasized);
                  }
                }),
            const Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
          ],
        ),
      ),
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
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
            const Padding(padding: EdgeInsets.all(8)),
            Column(
              children: [
                Image.asset(
                  "assets/exclamation_triangle.png",
                  height: 80,
                  width: 80,
                ),
                const Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                  child: Text(
                    S().component_warning,
                    textAlign: TextAlign.center,
                    style: EnvoyTypography.info,
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Text(
                    S().manual_setup_recovery_import_backup_modal_fail_connectivity_subheading,
                    textAlign: TextAlign.center,
                    style: EnvoyTypography.info,
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: Text(
                    S().erase_wallet_with_balance_modal_subheading,
                    textAlign: TextAlign.center,
                    style: EnvoyTypography.info,
                  ),
                ),
                const Padding(padding: EdgeInsets.all(5)),
              ],
            ),
            OnboardingButton(
                type: EnvoyButtonTypes.tertiary,
                label: S().erase_wallet_with_balance_modal_CTA2,
                textStyle: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: EnvoyColors.danger),
                onTap: () {
                  Navigator.pop(context);
                  displaySeedBeforeNuke(context);
                }),
            OnboardingButton(
                type: EnvoyButtonTypes.primaryModal,
                label: S().erase_wallet_with_balance_modal_CTA1,
                onTap: () {
                  // Show home page and navigate to accounts
                  ref.read(homePageBackgroundProvider.notifier).state =
                      HomePageBackgroundState.hidden;
                  ref.read(homePageTabProvider.notifier).state =
                      HomePageTabState.accounts;
                  ref.read(homePageTitleProvider.notifier).state = "";

                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  GoRouter.of(context).go(ROUTE_ACCOUNTS_HOME);
                }),
            const Padding(padding: EdgeInsets.all(12)),
          ],
        ),
      ),
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
        padding: const EdgeInsets.symmetric(horizontal: EnvoySpacing.medium2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
            //const Padding(padding: EdgeInsets.all(8)),
            Image.asset(
              "assets/exclamation_triangle.png",
              height: 80,
              width: 80,
            ),
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: EnvoySpacing.medium2,
                      bottom: EnvoySpacing.medium3,
                      left: EnvoySpacing.medium3,
                      right: EnvoySpacing.medium3),
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
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const EraseProgress()));
                }),
            OnboardingButton(
                type: EnvoyButtonTypes.primaryModal,
                label: S().component_cancel,
                onTap: () {
                  OnboardingPage.popUntilHome(context);
                }),
            const SizedBox(
              height: EnvoySpacing.medium3,
            )
          ],
        ),
      ),
    );
  }
}

void displaySeedBeforeNuke(BuildContext context) {
  Navigator.of(context).pop();
  Navigator.of(context).push(MaterialPageRoute(builder: (context) {
    return const SeedIntroScreen(
      mode: SeedIntroScreenType.verify,
    );
  }));
}

class EraseProgress extends ConsumerStatefulWidget {
  const EraseProgress({super.key});

  @override
  ConsumerState<EraseProgress> createState() => _EraseProgressState();
}

class _EraseProgressState extends ConsumerState<EraseProgress> {
  rive.StateMachineController? _stateMachineController;

  bool _deleteInProgress = true;

  @override
  Widget build(BuildContext context) {
    return OnboardPageBackground(
        child: Material(
      color: Colors.transparent,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(
                height: 260,
                child: rive.RiveAnimation.asset(
                  "assets/envoy_loader.riv",
                  fit: BoxFit.contain,
                  onInit: (artboard) {
                    _stateMachineController =
                        rive.StateMachineController.fromArtboard(
                            artboard, 'STM');
                    artboard.addController(_stateMachineController!);
                    _stateMachineController
                        ?.findInput<bool>("indeterminate")
                        ?.change(true);
                    _onInit();
                  },
                ),
              ),
            ),
            const SliverPadding(padding: EdgeInsets.all(28)),
            SliverToBoxAdapter(
              child: Builder(
                builder: (context) {
                  String title = S().delete_wallet_for_good_loading_heading;
                  if (!_deleteInProgress) {
                    title = S().delete_wallet_for_good_success_heading;
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: EnvoyTypography.heading,
                        ),
                        const Padding(padding: EdgeInsets.all(18)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ));
  }

  _onInit() async {
    try {
      final navigator = Navigator.of(context);
      setState(() {
        _deleteInProgress = true;
      });
      _stateMachineController?.findInput<bool>("indeterminate")?.change(true);
      _stateMachineController?.findInput<bool>("happy")?.change(false);
      _stateMachineController?.findInput<bool>("unhappy")?.change(false);
      //wait for animation
      await Future.delayed(const Duration(seconds: 1));
      await EnvoySeed().delete();
      _stateMachineController?.findInput<bool>("indeterminate")?.change(false);
      _stateMachineController?.findInput<bool>("happy")?.change(true);
      _stateMachineController?.findInput<bool>("unhappy")?.change(false);
      setState(() {
        _deleteInProgress = false;
      });
      await Future.delayed(const Duration(milliseconds: 2000));

      //Show android backup info
      if (Platform.isAndroid) {
        await Future.delayed(const Duration(milliseconds: 300));
        await navigator.push(MaterialPageRoute(
            builder: (context) => const AndroidBackupWarning()));
      } else {
        //wait for pop animation to finish
        await Future.delayed(const Duration(milliseconds: 300));
        // Show home page and navigate to accounts
        if (mounted) {
          OnboardingPage.popUntilHome(context);
        }
        ref.read(homePageBackgroundProvider.notifier).state =
            HomePageBackgroundState.hidden;
        ref.read(homePageTabProvider.notifier).state =
            HomePageTabState.accounts;
        ref.read(homePageTitleProvider.notifier).state = "";
      }
    } catch (e) {
      kPrint(e);
    }
  }
}

class AndroidBackupWarning extends StatelessWidget {
  const AndroidBackupWarning({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    bool iphoneSE = MediaQuery.of(context).size.height < 700;
    return PopScope(
      onPopInvokedWithResult: (_, __) {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return const WalletSetupSuccess();
        }));
      },
      child: OnboardPageBackground(
        child: EnvoyScaffold(
          hasScrollBody: false,
          child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: iphoneSE ? 220 : 250,
                    child: Image.asset(
                      "assets/exclamation_icon.png",
                      height: 180,
                      width: 180,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          S().android_backup_info_heading,
                          textAlign: TextAlign.center,
                          style: EnvoyTypography.heading,
                        ),
                        const Padding(padding: EdgeInsets.all(12)),
                        LinkText(
                          text: S()
                              .delete_wallet_for_good_instant_android_subheading,
                          onTap: () {
                            openAndroidSettings();
                          },
                          linkStyle: EnvoyTypography.button
                              .copyWith(color: EnvoyColors.accentPrimary),
                          textStyle: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        right: EnvoySpacing.medium2,
                        left: EnvoySpacing.medium2,
                        bottom: EnvoySpacing.medium2),
                    child: Column(
                      children: [
                        Consumer(
                          builder: (context, ref, child) {
                            return OnboardingButton(
                              type: EnvoyButtonTypes.tertiary,
                              label: S().component_skip,
                              onTap: () async {
                                OnboardingPage.popUntilHome(context);
                                ref
                                    .read(homePageBackgroundProvider.notifier)
                                    .state = HomePageBackgroundState.hidden;
                                ref.read(homePageTabProvider.notifier).state =
                                    HomePageTabState.accounts;
                                ref.read(homePageTitleProvider.notifier).state =
                                    "";
                                await Future.delayed(
                                    const Duration(milliseconds: 100));
                              },
                            );
                          },
                        ),
                        OnboardingButton(
                          label: S().component_goToSettings,
                          onTap: () {
                            openAndroidSettings();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
