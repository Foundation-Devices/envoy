// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:ui';

import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/home/cards/accounts/account_list_tile.dart';
import 'package:envoy/ui/state/home_page_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/util/envoy_storage.dart' show EnvoyStorage;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:ngwallet/ngwallet.dart';

class AccountTutorialOverlay extends ConsumerStatefulWidget {
  final List<EnvoyAccount> accounts;
  const AccountTutorialOverlay({
    super.key,
    required this.accounts,
  });

  @override
  ConsumerState<AccountTutorialOverlay> createState() =>
      _AccountTutorialOverlayState();
}

class _AccountTutorialOverlayState
    extends ConsumerState<AccountTutorialOverlay> {
  int currentPageNumber = 1;

  @override
  Widget build(BuildContext context) {
    final accounts = widget.accounts;
    return PopScope(
      canPop: false,
      child: Stack(
        children: [
          Positioned.fill(
            child: TweenAnimationBuilder(
              duration: const Duration(milliseconds: 300),
              tween: ColorTween(begin: Colors.transparent, end: Colors.black),
              builder: (context, value, child) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                    value ?? Colors.transparent,
                    const Color(0x00000000),
                  ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                  child: child,
                );
              },
              child: TweenAnimationBuilder(
                duration: const Duration(milliseconds: 300),
                tween: Tween<double>(begin: 0, end: 5),
                builder: (context, value, child) {
                  return BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: value, sigmaY: value),
                      child: child);
                },
                child: Scaffold(
                  appBar: AppBar(
                    backgroundColor: Colors.transparent,
                    automaticallyImplyLeading: false,
                    elevation: 0,
                    centerTitle: true,
                    title: Text(
                      S().bottomNav_accounts.toUpperCase(),
                      style: EnvoyTypography.subheading
                          .copyWith(color: Colors.white),
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.only(right: EnvoySpacing.xs),
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            EnvoyStorage().addPromptState(
                                DismissiblePrompt.primeAccountTutorial);
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ],
                  ),
                  body: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: EnvoySpacing.medium1),
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: EnvoySpacing.medium1),
                      itemBuilder: (context, index) {
                        final account = accounts[index];

                        bool active = false;
                        if (account.isHot) {
                          //For mobile wallet
                          active = currentPageNumber == 1;
                        } else {
                          //For prime
                          active = currentPageNumber == 2;
                        }

                        return Padding(
                          padding: const EdgeInsets.all(EnvoySpacing.small),
                          child: AnimatedOpacity(
                            opacity: active ? 1 : 0.1,
                            duration: Duration(milliseconds: 300),
                            child: AnimatedScale(
                              scale: active ? 1 : 0.98,
                              duration: Duration(milliseconds: 200),
                              child: AccountListTile(
                                key: ValueKey(account.id),
                                account,
                                draggable: false,
                                onTap: () {},
                              ),
                            ),
                          ), // Keeps space when hidden
                        );
                      },
                      itemCount: accounts.length,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: EnvoySpacing.medium3,
            left: 0,
            right: 0,
            child: TutorialDialog(
              onPageSet: (int page) {
                setState(() {
                  currentPageNumber = page;
                });
              },
              titles: [
                S().onboarding_tutorialHotWallet_header,
                S().onboarding_tutorialColdWallet_header
              ],
              descriptions: [
                S().onboarding_tutorialHotWallet_content,
                S().onboarding_tutorialColdWallet_content,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TutorialDialog extends ConsumerStatefulWidget {
  final List<String> titles;
  final List<String> descriptions;
  final Function(int page) onPageSet;

  const TutorialDialog({
    super.key,
    required this.titles,
    required this.descriptions,
    required this.onPageSet,
  });

  @override
  ConsumerState<TutorialDialog> createState() => _TutorialDialogState();
}

class _TutorialDialogState extends ConsumerState<TutorialDialog> {
  int pageNumber = 1;
  @override
  Widget build(BuildContext context) {
    final int totalPages = widget.titles.length; // Dynamic total page count

    void nextPage() {
      if (pageNumber < totalPages) {
        pageNumber++;
        widget.onPageSet(pageNumber);
      } else {
        EnvoyStorage().addPromptState(DismissiblePrompt.primeAccountTutorial);
        Navigator.of(context).pop(); // Close dialog on "Done"
      }
    }

    void prevPage() {
      if (pageNumber > 1) {
        pageNumber--;
        widget.onPageSet(pageNumber);
      }
    }

    return SafeArea(
      minimum: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: EnvoySpacing.medium2),
        child: Card(
          color: EnvoyColors.textPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(EnvoySpacing.medium3)),
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    EnvoyColors.textSecondary,
                    EnvoyColors.textPrimary,
                  ],
                ),
                borderRadius: BorderRadius.circular(EnvoySpacing.medium3),
              ),
              child: Padding(
                padding: const EdgeInsets.all(EnvoySpacing.medium1),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: Column(
                        key: ValueKey<int>(pageNumber),
                        children: [
                          Text(
                            widget.titles[pageNumber - 1],
                            textAlign: TextAlign.center,
                            style: EnvoyTypography.heading
                                .copyWith(color: EnvoyColors.textPrimaryInverse)
                                .setWeight(FontWeight.w600),
                          ),
                          const SizedBox(height: EnvoySpacing.medium1),
                          SizedBox(
                            height: 180,
                            child: SingleChildScrollView(
                              child: Text(
                                widget.descriptions[pageNumber - 1],
                                textAlign: TextAlign.center,
                                style: EnvoyTypography.body.copyWith(
                                    color: EnvoyColors.contentTertiary),
                              ),
                            ),
                          ),
                          const SizedBox(height: EnvoySpacing.medium1),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: prevPage,
                                behavior: HitTestBehavior.opaque,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: EnvoySpacing.medium3,
                                      vertical: EnvoySpacing.medium1),
                                  child: Row(
                                    children: [
                                      EnvoyIcon(
                                        EnvoyIcons.chevron_left,
                                        size: EnvoyIconSize.small,
                                        color: pageNumber > 1
                                            ? EnvoyColors.accentPrimary
                                            : Colors.transparent,
                                      ),
                                      Text(
                                        S().component_back,
                                        style: EnvoyTypography.body.copyWith(
                                          color: pageNumber > 1
                                              ? EnvoyColors.accentPrimary
                                              : Colors.transparent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Text(
                                "$pageNumber/$totalPages",
                                textAlign: TextAlign.center,
                                style: EnvoyTypography.body.copyWith(
                                  color: EnvoyColors.textPrimaryInverse,
                                ),
                              ),
                              GestureDetector(
                                onTap: nextPage,
                                behavior: HitTestBehavior.opaque,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: EnvoySpacing.medium3,
                                      vertical: EnvoySpacing.medium1),
                                  child: Row(
                                    children: [
                                      Text(
                                        pageNumber == totalPages
                                            ? S().component_done
                                            : S().component_next,
                                        style: EnvoyTypography.body.copyWith(
                                          color: EnvoyColors.accentPrimary,
                                        ),
                                      ),
                                      EnvoyIcon(
                                        EnvoyIcons.chevron_right,
                                        size: EnvoyIconSize.small,
                                        color: pageNumber < totalPages
                                            ? EnvoyColors.accentPrimary
                                            : Colors.transparent,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
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
      ),
    );
  }
}
