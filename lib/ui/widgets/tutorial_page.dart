// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:ui';

import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/home/cards/accounts/account_list_tile.dart';
import 'package:envoy/ui/state/accounts_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/business/account.dart';

final pageProvider =
    StateProvider<int>((ref) => 1); // TODO: regular state instead ??

class AccountTutorialOverlay extends ConsumerStatefulWidget {
  const AccountTutorialOverlay({
    super.key,
  });

  @override
  ConsumerState<AccountTutorialOverlay> createState() =>
      _AccountTutorialOverlayState();
}

class _AccountTutorialOverlayState extends ConsumerState<AccountTutorialOverlay>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    List<Account> accounts = ref.watch(accountsProvider);
    final currentPageNumber = ref.watch(pageProvider);
    const double accountHeight = 114;

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
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ],
                  ),
                  body: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: EnvoySpacing.medium1),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: ListView.builder(
                        key: ValueKey(currentPageNumber),
                        padding:
                            const EdgeInsets.only(top: EnvoySpacing.medium1),
                        itemBuilder: (context, index) {
                          final account = accounts[index];

                          return Padding(
                            padding: const EdgeInsets.all(EnvoySpacing.small),
                            child: index == currentPageNumber - 1
                                ? AccountListTile(
                                    key: ValueKey(account.id),
                                    account,
                                    draggable: false,
                                    onTap: () {},
                                  )
                                : const SizedBox(
                                    height:
                                        accountHeight), // Keeps space when hidden
                          );
                        },
                        itemCount: accounts.length,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Positioned(
            bottom: EnvoySpacing.medium3,
            left: 0,
            right: 0,
            child: TutorialDialog(
              titles: ["Mobile Wallet", "Cold Wallet"],
              descriptions: [
                "Also known as a “hot wallet.” Spending from this wallet requires only your phone for authorization. \n\n Since your Mobile Wallet is connected to the Internet, use this wallet to store small amounts of Bitcoin for frequent transactions.",
                "Also known as a “cold wallet.” Spending from this wallet requires authorization from your Passport device. \n\n Your Passport Master Key is always stored securely offline. \n\n  Use this wallet to secure the majority of your Bitcoin savings."
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

  const TutorialDialog({
    super.key,
    required this.titles,
    required this.descriptions,
  });

  @override
  ConsumerState<TutorialDialog> createState() => _TutorialDialogState();
}

class _TutorialDialogState extends ConsumerState<TutorialDialog> {
  @override
  Widget build(BuildContext context) {
    final pageNumber = ref.watch(pageProvider);
    final pageNotifier = ref.read(pageProvider.notifier);

    final int totalPages = widget.titles.length; // Dynamic total page count

    void nextPage() {
      if (pageNumber < totalPages) {
        pageNotifier.state++;
      } else {
        Navigator.of(context).pop(); // Close dialog on "Done"
      }
    }

    void prevPage() {
      if (pageNumber > 1) {
        pageNotifier.state--;
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
              // constraints: const BoxConstraints( // TODO:
              //   maxHeight: 180,
              // ),
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
                            style: EnvoyTypography.subheading.copyWith(
                                color: EnvoyColors.textPrimaryInverse),
                          ),
                          const SizedBox(height: EnvoySpacing.medium1),
                          SingleChildScrollView(
                            // TODO: make this work with a Container ?
                            child: Text(
                              widget.descriptions[pageNumber - 1],
                              textAlign: TextAlign.center,
                              style: EnvoyTypography.info
                                  .copyWith(color: EnvoyColors.textTertiary),
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
