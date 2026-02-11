// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:ui';

import 'package:envoy/account/accounts_manager.dart';
import 'package:envoy/business/region_manager.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/label_switch.dart';
import 'package:envoy/ui/components/linear_gradient.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/home/cards/accounts/account_list_tile.dart';
import 'package:envoy/ui/home/cards/accounts/accounts_state.dart';
import 'package:envoy/ui/home/cards/accounts/detail/filter_state.dart';
import 'package:envoy/ui/home/cards/accounts/empty_accounts_card.dart';
import 'package:envoy/ui/home/cards/devices/devices_card.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/routes/accounts_router.dart';
import 'package:envoy/ui/shield.dart';
import 'package:envoy/ui/state/accounts_state.dart';
import 'package:envoy/ui/state/home_page_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';

import 'package:collection/collection.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ngwallet/ngwallet.dart';

class AccountsCard extends ConsumerStatefulWidget {
  const AccountsCard({super.key});

  @override
  ConsumerState<AccountsCard> createState() => _AccountsCardState();
}

// The keep alive mixin is necessary to maintain state when widget is not visible
// Unfortunately it seems to only work with TabView
class _AccountsCardState extends ConsumerState<AccountsCard>
    with AutomaticKeepAliveClientMixin<AccountsCard> {
  bool? _buyDisabled;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // Watch passphrase event handler to enable auto-switching
    ref.watch(passphraseEventHandlerProvider);

    final mainNetAccounts = ref.watch(mainnetAccountsProvider(null));
    final allowBuyInEnvoy = ref.watch(allowBuyInEnvoyProvider);
    final showDefaultAccounts = ref.watch(showDefaultAccountProvider);
    final hasPassphraseAccounts =
        ref.watch(primePassphraseAccountsProvider).isNotEmpty;

    // Auto-switch to default accounts when passphrase accounts become empty
    ref.listen(primePassphraseAccountsProvider, (
      List<EnvoyAccount>? previous,
      List<EnvoyAccount> next,
    ) {
      if (next.isEmpty && !ref.read(showDefaultAccountProvider)) {
        ref.read(showDefaultAccountProvider.notifier).state = true;
      }
    });

    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              clipBehavior: Clip.none,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, -0.5),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOut,
                      )),
                      child: child,
                    ),
                  );
                },
                child: hasPassphraseAccounts
                    ? Padding(
                        key: const ValueKey('passphrase-pill'),
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, top: EnvoySpacing.medium2),
                        child: LabelSwitch(
                          initialValue: showDefaultAccounts,
                          onChanged: (bool newValue) {
                            ref
                                .read(showDefaultAccountProvider.notifier)
                                .state = newValue;
                          },
                          trueOption: LabelSwitchOption(
                            label: S().accounts_switchDefault,
                          ),
                          falseOption: LabelSwitchOption(
                            label: S().accounts_switchPassphrase,
                            icon: EnvoyIcons.passphrase_shield,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(key: ValueKey('empty')),
              ),
            ),
            Flexible(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                layoutBuilder:
                    (Widget? currentChild, List<Widget> previousChildren) {
                  return Stack(
                    alignment: Alignment.topCenter,
                    children: <Widget>[
                      ...previousChildren,
                      if (currentChild != null) currentChild,
                    ],
                  );
                },
                child: showDefaultAccounts
                    ? const DefaultAccountsList(key: ValueKey('default'))
                    : const PassphraseAccountsList(key: ValueKey('passphrase')),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FutureBuilder(
            future: AllowedRegions.checkBuyDisabled(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const SizedBox.shrink();
              }
              bool countryRestricted = snapshot.data != null && snapshot.data!;
              //if there are no mainnet accounts or the future is still loading, disable the button
              bool disabled = mainNetAccounts.isEmpty || _buyDisabled == null;

              _buyDisabled = snapshot.data;

              if (countryRestricted || !allowBuyInEnvoy) {
                return const SizedBox.shrink();
              }
              return GestureDetector(
                onTap: () async {
                  if (countryRestricted || disabled) {
                    return;
                  }
                  context.go(
                    await EnvoyStorage().getCountry() != null
                        ? ROUTE_BUY_BITCOIN
                        : ROUTE_SELECT_REGION,
                  );
                },
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: QrShield(
                    arcSizeRatio: 15.0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: EnvoySpacing.large3,
                        vertical: EnvoySpacing.small,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          EnvoyIcon(
                            EnvoyIcons.btc,
                            color: disabled
                                ? EnvoyColors.textTertiary
                                : EnvoyColors.accentPrimary,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: EnvoySpacing.xs,
                            ),
                            child: Text(
                              S().component_minishield_buy,
                              style: EnvoyTypography.label.copyWith(
                                color: disabled
                                    ? EnvoyColors.textTertiary
                                    : EnvoyColors.accentPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

/// Widget for displaying default (non-passphrase) accounts with reordering support
class DefaultAccountsList extends ConsumerStatefulWidget {
  const DefaultAccountsList({super.key});

  @override
  ConsumerState<DefaultAccountsList> createState() =>
      _DefaultAccountsListState();
}

class _DefaultAccountsListState extends ConsumerState<DefaultAccountsList> {
  final ScrollController _scrollController = ScrollController();
  final double _accountHeight = 124;
  bool _onReOrderStart = false;

  //keep order state in the widget to avoid unnecessary rebuilds
  List<String> _accountsOrder = [];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<EnvoyAccount> primePassphraseAccounts = ref.watch(
      primePassphraseAccountsProvider,
    );
    List<EnvoyAccount> accounts = ref.watch(accountsProvider);

    // Filter to only default accounts (exclude passphrase accounts)
    accounts = accounts.where((account) {
      if (primePassphraseAccounts.contains(account)) return false;
      if (account.seedHasPassphrase) return false;
      return true;
    }).toList();

    final listContentHeight = accounts.length * _accountHeight;

    // Keep _accountsOrder in sync with accountOrderStream
    ref.listen(accountOrderStream, (
      List<String>? previous,
      List<String>? next,
    ) {
      if (next == null) return;

      final currentIds = accounts.map((e) => e.id).toSet();

      // Only keep IDs that exist in current accounts
      final filteredOrder =
          next.where((id) => currentIds.contains(id)).toList();

      // Only update state if the order actually changed to avoid unnecessary rebuilds
      if (!const ListEquality().equals(_accountsOrder, filteredOrder)) {
        setState(() {
          _accountsOrder = filteredOrder;
        });
      }

      // Persist the cleaned order if stale IDs were removed
      if (next.length != filteredOrder.length) {
        Future.microtask(
          () => NgAccountManager().updateAccountOrder(filteredOrder),
        );
      }
    });

    ref.listen(accountsProvider,
        (List<EnvoyAccount>? previous, List<EnvoyAccount> next) {
      // Skip processing for passphrase accounts since they are displayed
      // in PassphraseAccountsList, not here. Avoids unnecessary rebuilds.
      if (previous != null && previous.length < next.length) {
        final previousIds = previous.map((e) => e.id).toSet();
        final newAccount = next.firstWhereOrNull(
          (account) => !previousIds.contains(account.id),
        );
        if (newAccount != null &&
            (primePassphraseAccounts.contains(newAccount) ||
                newAccount.seedHasPassphrase)) {
          return;
        }
      }

      final nextIds = next.map((e) => e.id).toSet();

      // Compute the new order
      final newOrder =
          _accountsOrder.where((id) => nextIds.contains(id)).toList();

      // Add new accounts that aren't in the order yet
      for (var account in next) {
        if (!newOrder.contains(account.id)) {
          newOrder.add(account.id);
        }
      }

      // Only update state if the order actually changed to avoid unnecessary rebuilds
      if (!const ListEquality().equals(_accountsOrder, newOrder)) {
        setState(() {
          _accountsOrder = newOrder;
        });

        Future.microtask(
            () => NgAccountManager().updateAccountOrder(_accountsOrder));
      }

      if (previous != null &&
          previous.length < next.length &&
          next.length >= 5) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            listContentHeight, //when new acc, go to bottom to see the acc
            duration: const Duration(milliseconds: 1),
            curve: Curves.ease,
          );
        }
      }

      if (previous != null && previous.length > next.length) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0, //when delete acc go to top
            duration: const Duration(seconds: 1),
            curve: Curves.ease,
          );
        }
      }
    });

    final scrollView = ScrollGradientMask(
      start: 0.00,
      topGradientValue: 0.045,
      bottomGradientValue: 0.845,
      end: 0.89,
      child: ReorderableListView(
        // env-2000-line-through-shade
        header: const SizedBox(height: 20),
        footer: Opacity(
          opacity: _onReOrderStart ? 0.0 : 1.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              AccountPrompts(),
              SizedBox(height: 80), // env-2000-line-through-shade
            ],
          ),
        ),
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollController: _scrollController,
        //proxyDecorator is the widget that is shown when dragging
        proxyDecorator: (widget, index, animation) {
          return FadeTransition(
            opacity: animation.drive(Tween<double>(begin: 1.0, end: 0.5)),
            child: ScaleTransition(
              scale: animation.drive(Tween<double>(begin: 0.95, end: 1.02)),
              child: widget,
            ),
          );
        },
        onReorderEnd: (index) {
          setState(() {
            _onReOrderStart = false;
          });
        },
        onReorderStart: (index) {
          setState(() {
            _onReOrderStart = true;
          });
        },
        onReorder: (oldIndex, newIndex) async {
          final order = List<String>.from(_accountsOrder);
          final currentVisibleAccountsId = accounts.map((e) => e.id).toList();
          final List<String> toReorder = order
              .where((element) => currentVisibleAccountsId.contains(element))
              .toList();
          setState(() {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final String item = toReorder.removeAt(oldIndex);
            toReorder.insert(newIndex, item);
            //After moving visible accounts, add the rest of the accounts to the end of the list
            for (var element in order) {
              if (!toReorder.contains(element)) {
                toReorder.add(element);
              }
            }
            _accountsOrder = toReorder;

            Future.microtask(
              () => NgAccountManager().updateAccountOrder(toReorder),
            );
          });
          await EnvoyStorage().addPromptState(DismissiblePrompt.dragAndDrop);
        },
        children: _buildListItems(accounts, _accountsOrder),
      ),
    );

    return accounts.isEmpty && _accountsOrder.isEmpty
        ? Padding(
            padding: const EdgeInsets.all(EnvoySpacing.medium2),
            child: EmptyAccountsCard(),
          )
        : scrollView;
  }

  List<Widget> _buildListItems(
    List<EnvoyAccount> accounts,
    List<String> accountsOrder,
  ) {
    final List<Widget> items = [];

    final orderToUse = accountsOrder.isEmpty
        ? accounts.map((e) => e.id).toList()
        : accountsOrder;

    for (final id in orderToUse) {
      final account = accounts.firstWhereOrNull((element) => element.id == id);
      if (account != null) {
        items.add(
          SizedBox(
            key: ValueKey(account.id),
            height: _accountHeight,
            child: AccountListTile(
              account,
              onTap: () async {
                clearFilterState(ref);
                ref.read(selectedAccountProvider.notifier).state = account;
                context.go(ROUTE_ACCOUNT_DETAIL, extra: account);
                return;
              },
            ),
          ),
        );
      }
    }
    return items;
  }
}

/// Widget for displaying passphrase accounts (no reordering)
class PassphraseAccountsList extends ConsumerWidget {
  const PassphraseAccountsList({super.key});

  static const double _accountHeight = 124;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<EnvoyAccount> accounts = ref.watch(
      primePassphraseAccountsProvider,
    );

    if (accounts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(EnvoySpacing.medium2),
        child: EmptyAccountsCard(),
      );
    }

    return ScrollGradientMask(
      start: 0.00,
      topGradientValue: 0.045,
      bottomGradientValue: 0.845,
      end: 0.89,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const BouncingScrollPhysics(),
        itemCount: accounts.length + 2, // +2 for header and footer spacing
        itemBuilder: (context, index) {
          // Header spacing
          if (index == 0) {
            return const SizedBox(height: 20);
          }
          // Footer spacing
          if (index == accounts.length + 1) {
            return const SizedBox(height: 80);
          }
          final account = accounts[index - 1];
          return SizedBox(
            height: _accountHeight,
            child: AccountListTile(
              account,
              onTap: () async {
                clearFilterState(ref);
                ref.read(selectedAccountProvider.notifier).state = account;
                context.go(ROUTE_ACCOUNT_DETAIL, extra: account);
              },
            ),
          );
        },
      ),
    );
  }
}

class AccountPrompts extends ConsumerWidget {
  const AccountPrompts({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var isHideAmountDismissed = ref.watch(
      arePromptsDismissedProvider(DismissiblePrompt.hideAmount),
    );

    var isDragAndDropDismissed = ref.watch(
      arePromptsDismissedProvider(DismissiblePrompt.dragAndDrop),
    );

    var userInteractedWithAccDetail = ref.watch(
      arePromptsDismissedProvider(
        DismissiblePrompt.userInteractedWithAccDetail,
      ),
    );
    var accounts = ref.watch(accountsProvider);
    var accountsHaveZeroBalance = ref.watch(accountsZeroBalanceProvider);

    //Show if the user never visited account detail screen
    if (!userInteractedWithAccDetail) {
      return Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 5,
          children: [
            Text(
              accounts.length == 1
                  ? S().hot_wallet_accounts_creation_done_text_explainer
                  : S()
                      .hot_wallet_accounts_creation_done_text_explainer_more_than_1_accnt,
              style: EnvoyTypography.explainer,
            ),
            GestureDetector(
              child: Text(
                S().component_dismiss,
                style: EnvoyTypography.explainer.copyWith(
                  color: EnvoyColors.accentPrimary,
                ),
              ),
              onTap: () {
                EnvoyStorage().addPromptState(
                  DismissiblePrompt.userInteractedWithAccDetail,
                );
              },
            ),
            Container(height: 40, color: Colors.transparent),
          ],
        ),
      );
    } else {
      if (!isHideAmountDismissed && !accountsHaveZeroBalance) {
        return Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 5,
            children: [
              Text(
                S().hide_amount_first_time_text,
                style: EnvoyTypography.explainer,
              ),
              GestureDetector(
                child: Text(
                  S().component_dismiss,
                  style: EnvoyTypography.explainer.copyWith(
                    color: EnvoyColors.accentPrimary,
                  ),
                ),
                onTap: () {
                  EnvoyStorage().addPromptState(DismissiblePrompt.hideAmount);
                },
              ),
              Container(height: 40, color: Colors.transparent),
            ],
          ),
        );
      }

      if (!isDragAndDropDismissed && accounts.length > 1 ||
          !userInteractedWithAccDetail) {
        return Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 5,
            children: [
              Text(
                userInteractedWithAccDetail
                    ? S().tap_and_drag_first_time_text
                    : S()
                        .hot_wallet_accounts_creation_done_text_explainer_more_than_1_accnt,
                style: EnvoyTypography.explainer,
              ),
              GestureDetector(
                child: Text(
                  S().component_dismiss,
                  style: EnvoyTypography.explainer.copyWith(
                    color: EnvoyColors.accentPrimary,
                  ),
                ),
                onTap: () {
                  if (userInteractedWithAccDetail) {
                    EnvoyStorage().addPromptState(
                      DismissiblePrompt.dragAndDrop,
                    );
                  } else {
                    EnvoyStorage().addPromptState(
                      DismissiblePrompt.userInteractedWithAccDetail,
                    );
                  }
                },
              ),
              Container(height: 40, color: Colors.transparent),
            ],
          ),
        );
      }
    }

    return Container(height: 40, color: Colors.transparent);
  }
}

void showSecurityDialog(BuildContext context) {
  EnvoyStorage().addPromptState(DismissiblePrompt.secureWallet);
  showEnvoyDialog(
    context: context,
    dismissible: false,
    dialog: SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: EnvoySpacing.medium2),
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
            const Padding(padding: EdgeInsets.all(EnvoySpacing.medium1)),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/exclamation_icon.png",
                  height: 60,
                  width: 60,
                ),
                const Padding(padding: EdgeInsets.all(EnvoySpacing.medium1)),
                Container(
                  constraints: const BoxConstraints(maxWidth: 200),
                  padding: const EdgeInsets.symmetric(
                    vertical: EnvoySpacing.small,
                    horizontal: 12,
                  ),
                  child: Text(
                    S().wallet_security_modal__heading,
                    textAlign: TextAlign.center,
                    style: EnvoyTypography.heading,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: EnvoySpacing.small,
                    horizontal: 12,
                  ),
                  child: Text(
                    S().wallet_security_modal_subheading,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            OnboardingButton(
              type: EnvoyButtonTypes.tertiary,
              label: S().component_back,
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
            OnboardingButton(
              type: EnvoyButtonTypes.primaryModal,
              label: S().component_learnMore,
              onTap: () {
                Navigator.of(context).pop();
                showDialog(
                  context: context,
                  builder: (context) {
                    return BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: const Material(child: DeviceEmptyVideo()),
                    );
                  },
                );
              },
            ),
            const Padding(padding: EdgeInsets.all(12)),
          ],
        ),
      ),
    ),
  );
}
