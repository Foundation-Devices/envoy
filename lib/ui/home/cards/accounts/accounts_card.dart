// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:ui';

import 'package:envoy/account/accounts_manager.dart';
import 'package:envoy/business/region_manager.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';
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
import 'package:envoy/util/envoy_storage.dart';
import 'package:envoy/util/list_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ngwallet/ngwallet.dart';

class AccountsCard extends ConsumerStatefulWidget {
  const AccountsCard({
    super.key,
  });

  @override
  ConsumerState<AccountsCard> createState() => _AccountsCardState();
}

// The keep alive mixin is necessary to maintain state when widget is not visible
// Unfortunately it seems to only work with TabView
class _AccountsCardState extends ConsumerState<AccountsCard>
    with AutomaticKeepAliveClientMixin<AccountsCard> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    // ignore: unused_local_variable

    final mainNetAccounts = ref.watch(mainnetAccountsProvider(null));
    final allowBuyInEnvoy = ref.watch(allowBuyInEnvoyProvider);

    return Stack(
      children: [
        AccountsList(),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FutureBuilder(
              future: AllowedRegions.checkBuyDisabled(),
              builder: (context, snapshot) {
                bool countryRestricted =
                    snapshot.data != null && snapshot.data!;
                bool disabled = mainNetAccounts.isEmpty;

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
                            vertical: EnvoySpacing.small),
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
                                  bottom: EnvoySpacing.xs),
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
              }),
        )
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

//ignore: must_be_immutable
class AccountsList extends ConsumerStatefulWidget {
  const AccountsList({super.key});

  @override
  ConsumerState<AccountsList> createState() => _AccountsListState();
}

class _AccountsListState extends ConsumerState<AccountsList> {
  final ScrollController _scrollController = ScrollController();
  final double _accountHeight = 124;
  bool _onReOrderStart = false;

  //keep order state in the widget to avoid unnecessary rebuilds
  List<String> _accountsOrder = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountsProvider);
    final listContentHeight = accounts.length * _accountHeight;
    //update order if and only if new accounts are added
    ref.listen(accountOrderStream,
        (List<String>? previous, List<String>? next) {
      if (previous?.length != next?.length) {
        setState(() {
          _accountsOrder = next!;
        });
      }
    });

    if (_accountsOrder.isEmpty) {
      _accountsOrder = ref.read(accountOrderStream);
    }

    ref.listen(accountsProvider,
        (List<EnvoyAccount>? previous, List<EnvoyAccount> next) {
      final nextIds = next.map((e) => e.id).toSet();

      setState(() {
        _accountsOrder =
            _accountsOrder.where((id) => nextIds.contains(id)).toList();

        //update order if and only if new accounts are added
        for (var account in next) {
          if (!_accountsOrder.contains(account.id)) {
            _accountsOrder.add(account.id);
          }
        }
      });

      NgAccountManager().updateAccountOrder(_accountsOrder);

      if (previous!.length < next.length) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            listContentHeight, //when new acc, go to bottom to see the acc
            duration: const Duration(milliseconds: 1),
            curve: Curves.ease,
          );
        }
      }

      if (previous.length > next.length) {
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
            NgAccountManager().updateAccountOrder(toReorder);
          });
          await EnvoyStorage().addPromptState(DismissiblePrompt.dragAndDrop);
        },
        children: buildListItems(_accountsOrder, accounts),
      ),
    );

    return accounts.isEmpty && _accountsOrder.isEmpty
        ? Padding(
            padding: const EdgeInsets.all(EnvoySpacing.medium2),
            child: EmptyAccountsCard(),
          )
        : scrollView;
  }

  List<Widget> buildListItems(
      List<String> accountsOrder, List<EnvoyAccount> accounts) {
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

class AccountPrompts extends ConsumerWidget {
  const AccountPrompts({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var isHideAmountDismissed =
        ref.watch(arePromptsDismissedProvider(DismissiblePrompt.hideAmount));

    var isDragAndDropDismissed =
        ref.watch(arePromptsDismissedProvider(DismissiblePrompt.dragAndDrop));

    var userInteractedWithAccDetail = ref.watch(arePromptsDismissedProvider(
        DismissiblePrompt.userInteractedWithAccDetail));
    var accounts = ref.watch(accountsProvider);
    var accountsHaveZeroBalance = ref.watch(accountsZeroBalanceProvider);

    //Show if the user never visited account detail screen
    if (!userInteractedWithAccDetail) {
      return Center(
          child: Wrap(alignment: WrapAlignment.center, spacing: 5, children: [
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
            style: EnvoyTypography.explainer
                .copyWith(color: EnvoyColors.accentPrimary),
          ),
          onTap: () {
            EnvoyStorage()
                .addPromptState(DismissiblePrompt.userInteractedWithAccDetail);
          },
        ),
        Container(
          height: 40,
          color: Colors.transparent,
        )
      ]));
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
                child: Text(S().component_dismiss,
                    style: EnvoyTypography.explainer
                        .copyWith(color: EnvoyColors.accentPrimary)),
                onTap: () {
                  EnvoyStorage().addPromptState(DismissiblePrompt.hideAmount);
                },
              ),
              Container(
                height: 40,
                color: Colors.transparent,
              )
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
                  style: EnvoyTypography.explainer
                      .copyWith(color: EnvoyColors.accentPrimary),
                ),
                onTap: () {
                  if (userInteractedWithAccDetail) {
                    EnvoyStorage()
                        .addPromptState(DismissiblePrompt.dragAndDrop);
                  } else {
                    EnvoyStorage().addPromptState(
                        DismissiblePrompt.userInteractedWithAccDetail);
                  }
                },
              ),
              Container(
                height: 40,
                color: Colors.transparent,
              )
            ],
          ),
        );
      }
    }

    return Container(
      height: 40,
      color: Colors.transparent,
    );
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
                        vertical: EnvoySpacing.small, horizontal: 12),
                    child: Text(S().wallet_security_modal__heading,
                        textAlign: TextAlign.center,
                        style: EnvoyTypography.heading),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: EnvoySpacing.small, horizontal: 12),
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
                  }),
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
                            child: const Material(child: DeviceEmptyVideo()));
                      },
                    );
                  }),
              const Padding(padding: EdgeInsets.all(12)),
            ],
          ),
        ),
      ));
}
