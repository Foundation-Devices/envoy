// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

// ignore_for_file: constant_identifier_names

import 'package:animations/animations.dart';
import 'package:envoy/business/account.dart';
import 'package:envoy/ui/home/cards/accounts/accounts_card.dart';
import 'package:envoy/ui/home/cards/accounts/address_card.dart';
import 'package:envoy/ui/home/cards/accounts/descriptor_card.dart';
import 'package:envoy/ui/home/cards/accounts/detail/account_card.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coins_state.dart';
import 'package:envoy/ui/home/cards/accounts/detail/filter_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/send_card.dart';
import 'package:envoy/ui/home/cards/accounts/spend/spend_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/tx_review.dart';
import 'package:envoy/ui/home/home_state.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:envoy/ui/home/cards/buy_bitcoin.dart';
import 'package:envoy/ui/home/cards/peer_to_peer_options.dart';

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

const _BUY_BITCOIN = 'buy';
const ROUTE_BUY_BITCOIN = '$ROUTE_ACCOUNTS_HOME/$_BUY_BITCOIN';

const _PEER_TO_PEER = 'peer';
const ROUTE_PEER_TO_PEER = '$ROUTE_BUY_BITCOIN/$_PEER_TO_PEER';

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

/// simple wrapper to add page animation
Page wrapWithVerticalAxisAnimation(
  Widget child,
) {
  return CustomTransitionPage(
    child: child,
    restorationId: child.toStringShort(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SharedAxisTransition(
          animation: animation,
          fillColor: Colors.transparent,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.vertical,
          child: child);
    },
  );
}

final accountsRouter = StatefulShellBranch(
    restorationScopeId: 'accountsHomeRouterScope',
    initialLocation: ROUTE_ACCOUNTS_HOME,
    routes: [
      GoRoute(
          path: ROUTE_ACCOUNTS_HOME,
          pageBuilder: (context, state) =>
              wrapWithVerticalAxisAnimation(const AccountsCard()),
          routes: [
            GoRoute(
              onExit: (context) async {
                ProviderContainer providerContainer =
                    ProviderScope.containerOf(context);
                bool isInEdit = providerContainer.read(spendEditModeProvider);
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
                    onExit: (context) {
                      /// if we are exiting the send screen, we need to clear the spend state
                      /// but only if we are not in edit mode
                      if (!ProviderScope.containerOf(context)
                          .read(spendEditModeProvider)) {
                        clearSpendState(ProviderScope.containerOf(context));
                      }
                      return true;
                    },
                    pageBuilder: (context, state) {
                      return wrapWithVerticalAxisAnimation(SendCard());
                    },
                    routes: [
                      GoRoute(
                        name: "spend_confirm",
                        onExit: (context) async {
                          ProviderContainer providerContainer =
                              ProviderScope.containerOf(context);

                          /// if the user is not going back for editing and broadcast is not finished
                          /// show a dialog to confirm the user wants to discard the transaction
                          if (providerContainer.read(spendEditModeProvider) ==
                              true) {
                            return true;
                          } else if (providerContainer
                                  .read(spendTransactionProvider)
                                  .broadcastProgress ==
                              BroadcastProgress.success) {
                            return true;
                          } else if (providerContainer
                                  .read(spendTransactionProvider)
                                  .broadcastProgress ==
                              BroadcastProgress.inProgress) {
                            /// if the broadcast is in progress, do not allow the user to go back
                            return false;
                          } else {
                            final exit = await showEnvoyDialog(
                                context: context,
                                dialog: const DiscardTransactionDialog());
                            if (exit) {
                              providerContainer
                                  .read(coinSelectionStateProvider.notifier)
                                  .reset();
                              providerContainer
                                  .read(spendEditModeProvider.notifier)
                                  .state = false;
                              providerContainer
                                  .read(hideBottomNavProvider.notifier)
                                  .state = false;
                              clearSpendState(providerContainer);
                            }
                            return exit;
                          }
                        },
                        path: _ACCOUNT_SEND_CONFIRM,
                        routes: [
                          GoRoute(
                            name: "spend_review",
                            onExit: (context) {
                              /// if we are exiting the send screen, we need to clear the spend state
                              /// but only if we are not in edit mode
                              if (!ProviderScope.containerOf(context)
                                  .read(spendEditModeProvider)) {
                                clearSpendState(
                                    ProviderScope.containerOf(context));
                              }
                              return true;
                            },
                            path: _ACCOUNT_SEND_REVIEW,
                            pageBuilder: (context, state) {
                              return wrapWithVerticalAxisAnimation(TxReview());
                            },
                          ),
                        ],
                        pageBuilder: (context, state) {
                          return wrapWithVerticalAxisAnimation(TxReview());
                        },
                      ),
                    ]),
                GoRoute(
                  path: _ACCOUNT_RECEIVE,
                  pageBuilder: (context, state) {
                    Account? account;
                    if (state.extra is Map) {
                      account =
                          Account.fromJson(state.extra as Map<String, dynamic>);
                    } else {
                      account = state.extra as Account;
                    }
                    return wrapWithVerticalAxisAnimation(AddressCard(account));
                  },
                ),
                GoRoute(
                  path: _ACCOUNT_DESCRIPTOR,
                  pageBuilder: (context, state) {
                    Account? account;
                    if (state.extra is Map) {
                      account =
                          Account.fromJson(state.extra as Map<String, dynamic>);
                    } else {
                      account = state.extra as Account;
                    }
                    return wrapWithVerticalAxisAnimation(
                        DescriptorCard(account));
                  },
                ),
              ],
              pageBuilder: (context, state) {
                return wrapWithVerticalAxisAnimation(AccountCard());
              },
            ),
            GoRoute(
                path: _BUY_BITCOIN,
                pageBuilder: (context, state) {
                  return wrapWithVerticalAxisAnimation(const BuyBitcoinCard());
                },
                routes: [
                  GoRoute(
                    path: _PEER_TO_PEER,
                    pageBuilder: (context, state) {
                      return wrapWithVerticalAxisAnimation(
                          const PeerToPeerCard());
                    },
                  ),
                ])
          ]),
    ]);

final accountFullScreenRoute = [];
