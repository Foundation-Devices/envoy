// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

// ignore_for_file: constant_identifier_names

import 'package:animations/animations.dart';
import 'package:envoy/account/accounts_manager.dart';
import 'package:envoy/ui/home/cards/accounts/accounts_card.dart';
import 'package:envoy/ui/home/cards/accounts/address_card.dart';
import 'package:envoy/ui/home/cards/accounts/descriptor_card.dart';
import 'package:envoy/ui/home/cards/accounts/detail/account_card.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coins_state.dart';
import 'package:envoy/ui/home/cards/accounts/detail/filter_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/psbt_card.dart';
import 'package:envoy/ui/home/cards/accounts/spend/send_card.dart';
import 'package:envoy/ui/home/cards/accounts/spend/send_qr_review.dart';
import 'package:envoy/ui/home/cards/accounts/spend/state/spend_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/tx_review.dart';
import 'package:envoy/ui/home/cards/buy_bitcoin.dart';
import 'package:envoy/ui/home/cards/buy_bitcoin_account_selection.dart';
import 'package:envoy/ui/home/cards/peer_to_peer_options.dart';
import 'package:envoy/ui/home/cards/select_region.dart';
import 'package:envoy/ui/home/home_state.dart';
import 'package:envoy/ui/state/home_page_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ngwallet/ngwallet.dart';

/// Different routes for accounts.
/// The nested routes cannot start with a slash,
/// so we have to keep the sub-route values in a private variable (using _).
/// We cannot navigate to a route without the full path, so we will define a second
/// publicly accessible constant that will be used to navigate to the route.
/// example context.go(ROUTE_ACCOUNT_DETAIL) will route to _ACCOUNT_DETAIL
///

const ROUTE_ACCOUNTS_HOME = '/account';

const _ACCOUNT_DETAIL = 'details';
const ROUTE_ACCOUNT_DETAIL = '$ROUTE_ACCOUNTS_HOME/$_ACCOUNT_DETAIL';

const _SELECT_REGION = 'region';
const ROUTE_SELECT_REGION = '$ROUTE_ACCOUNTS_HOME/$_SELECT_REGION';

const _BUY_BITCOIN = 'buy';
const ROUTE_BUY_BITCOIN = '$ROUTE_SELECT_REGION/$_BUY_BITCOIN';

const _PEER_TO_PEER = 'peer';
const ROUTE_PEER_TO_PEER = '$ROUTE_BUY_BITCOIN/$_PEER_TO_PEER';

const _SELECT_ACCOUNT = 'select';
const ROUTE_SELECT_ACCOUNT = '$ROUTE_BUY_BITCOIN/$_SELECT_ACCOUNT';

const _ACCOUNT_RECEIVE = 'receive';
const ROUTE_ACCOUNT_RECEIVE = '$ROUTE_ACCOUNT_DETAIL/$_ACCOUNT_RECEIVE';

const _ACCOUNT_DESCRIPTOR = 'desc';
const ROUTE_ACCOUNT_DESCRIPTOR = '$ROUTE_ACCOUNT_DETAIL/$_ACCOUNT_DESCRIPTOR';

const _ACCOUNT_SEND = 'send';
const ROUTE_ACCOUNT_SEND = '$ROUTE_ACCOUNT_DETAIL/$_ACCOUNT_SEND';

const _ACCOUNT_SEND_CONFIRM = 'confirm';
const ROUTE_ACCOUNT_SEND_CONFIRM = '$ROUTE_ACCOUNT_SEND/$_ACCOUNT_SEND_CONFIRM';

const _ACCOUNT_SEND_REVIEW = 'review';
const ROUTE_ACCOUNT_SEND_REVIEW =
    '$ROUTE_ACCOUNT_SEND_CONFIRM/$_ACCOUNT_SEND_REVIEW';

const ACCOUNT_SEND_SCAN_PSBT = "spend_scan_psbt";

const ACCOUNT_SEND_SCAN_QR = "spend_scan_qr";

/// simple wrapper to add page animation
Page wrapWithEnvoyPageAnimation(
    {required Widget child,
    Duration reverseTransitionDuration = const Duration(milliseconds: 360)}) {
  return CustomTransitionPage(
    child: child,
    reverseTransitionDuration: reverseTransitionDuration,
    restorationId: child.toStringShort(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SharedAxisTransition(
          animation: animation,
          fillColor: Colors.transparent,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.vertical,
          key: child.key,
          child: child);
    },
  );
}

final accountsRouter = StatefulShellBranch(
    restorationScopeId: 'accountsHomeRouterScope',
    initialLocation: ROUTE_ACCOUNTS_HOME,
    routes: [
      GoRoute(
          onExit: (context, state) {
            final scope = ProviderScope.containerOf(context);
            final shellMenuOpened = scope.read(homePageBackgroundProvider);
            if (shellMenuOpened == HomePageBackgroundState.hidden) {
              return true;
            } else {
              if (shellMenuOpened == HomePageBackgroundState.menu) {
                scope.read(homePageBackgroundProvider.notifier).state =
                    HomePageBackgroundState.hidden;
              } else {
                scope.read(homePageBackgroundProvider.notifier).state =
                    HomePageBackgroundState.menu;
              }
              return false;
            }
          },
          path: ROUTE_ACCOUNTS_HOME,
          pageBuilder: (context, state) {
            return wrapWithEnvoyPageAnimation(
                child: Consumer(
              builder: (context, ref, child) {
                final shellMenuOpened = ref.watch(homePageBackgroundProvider);
                return PopScope(
                  canPop: shellMenuOpened == HomePageBackgroundState.hidden,
                  child: child!,
                );
              },
              child: const AccountsCard(),
            ));
          },
          routes: [
            GoRoute(
              onExit: (context, GoRouterState state) async {
                ProviderContainer providerContainer =
                    ProviderScope.containerOf(context);
                bool isInEdit = providerContainer.read(spendEditModeProvider) !=
                    SpendOverlayContext.hidden;
                if (providerContainer
                        .read(coinSelectionStateProvider)
                        .isNotEmpty ||
                    isInEdit) {
                  await Future.delayed(const Duration(milliseconds: 50));
                  providerContainer.read(hideBottomNavProvider.notifier).state =
                      false;

                  ///TODO: show a dialog to confirm the user wants to exit the selection mode;
                  return false;
                }
                ProviderScope.containerOf(context)
                    .read(accountToggleStateProvider.notifier)
                    .state = AccountToggleState.tx;
                return true;
              },
              path: _ACCOUNT_DETAIL,
              routes: [
                GoRoute(
                    path: _ACCOUNT_SEND,
                    onExit: (context, GoRouterState state) {
                      //always clear the spend state when exiting the send screen
                      //coin reselection happens within the send screen,
                      //so no need to check for coin selection overlay
                      final scope = ProviderScope.containerOf(context);
                      scope.read(coinSelectionStateProvider.notifier).reset();
                      scope.read(accountToggleStateProvider.notifier).state =
                          AccountToggleState.tx;
                      clearSpendState(ProviderScope.containerOf(context));
                      scope.read(spendEditModeProvider.notifier).state =
                          SpendOverlayContext.hidden;
                      scope.read(hideBottomNavProvider.notifier).state = false;
                      return true;
                    },
                    pageBuilder: (context, state) {
                      return wrapWithEnvoyPageAnimation(child: SendCard());
                    },
                    routes: [
                      GoRoute(
                        name: "spend_confirm",
                        path: _ACCOUNT_SEND_CONFIRM,
                        routes: [
                          GoRoute(
                            name: "spend_review",
                            routes: [
                              GoRoute(
                                  name: ACCOUNT_SEND_SCAN_PSBT,
                                  path: "scan",
                                  pageBuilder: (context, state) {
                                    return wrapWithEnvoyPageAnimation(
                                        child: PsbtCard(
                                            state.extra as DraftTransaction,
                                            false));
                                  },
                                  routes: [
                                    GoRoute(
                                      name: ACCOUNT_SEND_SCAN_QR,
                                      path: "qr_review",
                                      pageBuilder: (context, state) {
                                        return wrapWithEnvoyPageAnimation(
                                            child: SendQrReview(state.extra
                                                as DraftTransaction));
                                      },
                                    )
                                  ]),
                            ],
                            onExit: (context, GoRouterState state) {
                              /// if we are exiting the send screen, we need to clear the spend state
                              /// but only if we are not in edit mode
                              if (ProviderScope.containerOf(context)
                                      .read(spendEditModeProvider) !=
                                  SpendOverlayContext.hidden) {
                                clearSpendState(
                                    ProviderScope.containerOf(context));
                              }
                              return true;
                            },
                            path: _ACCOUNT_SEND_REVIEW,
                            pageBuilder: (context, state) {
                              return wrapWithEnvoyPageAnimation(
                                  child: TxReview());
                            },
                          ),
                        ],
                        pageBuilder: (context, state) {
                          return wrapWithEnvoyPageAnimation(child: TxReview());
                        },
                      ),
                    ]),
                GoRoute(
                  path: _ACCOUNT_RECEIVE,
                  pageBuilder: (context, state) {
                    EnvoyAccount? account;
                    try {
                      account = NgAccountManager()
                          .getAccountById(state.extra as String);
                      if (account == null) {
                        throw Exception("Account not found");
                      }
                      return wrapWithEnvoyPageAnimation(
                          child: AddressCard(account));
                    } catch (e) {
                      return wrapWithEnvoyPageAnimation(child: Container());
                    }
                  },
                ),
                GoRoute(
                  path: _ACCOUNT_DESCRIPTOR,
                  pageBuilder: (context, state) {
                    EnvoyAccount? account;
                    try {
                      account = NgAccountManager()
                          .getAccountById(state.extra as String);
                      if (account == null) {
                        throw Exception("Account not found");
                      }
                      return wrapWithEnvoyPageAnimation(
                          child: DescriptorCard(account));
                    } catch (e) {
                      return wrapWithEnvoyPageAnimation(
                          child: Container(
                        padding: const EdgeInsets.all(20),
                        child: Center(child: Text("Account not found")),
                      ));
                    }
                  },
                ),
              ],
              pageBuilder: (context, state) {
                return wrapWithEnvoyPageAnimation(child: AccountCard());
              },
            ),
            GoRoute(
                path: _SELECT_REGION,
                pageBuilder: (context, state) {
                  return wrapWithEnvoyPageAnimation(
                    child: const SelectRegion(),
                  );
                },
                routes: [
                  GoRoute(
                      path: _BUY_BITCOIN,
                      onExit: (context, GoRouterState state) {
                        ProviderScope.containerOf(context)
                            .read(buyBTCPageProvider.notifier)
                            .state = false;
                        return true;
                      },
                      pageBuilder: (context, state) {
                        return wrapWithEnvoyPageAnimation(
                            child: const BuyBitcoinCard());
                      },
                      routes: [
                        GoRoute(
                          path: _PEER_TO_PEER,
                          pageBuilder: (context, state) {
                            return wrapWithEnvoyPageAnimation(
                                child: const PeerToPeerCard());
                          },
                        ),
                        GoRoute(
                          path: _SELECT_ACCOUNT,
                          name: ROUTE_SELECT_ACCOUNT,
                          pageBuilder: (context, state) {
                            return wrapWithEnvoyPageAnimation(
                                child: const SelectAccount());
                          },
                        ),
                      ]),
                ])
          ]),
    ]);

final accountFullScreenRoute = [];
