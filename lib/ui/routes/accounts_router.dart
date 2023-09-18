// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:animations/animations.dart';
import 'package:envoy/business/account.dart';
import 'package:envoy/ui/home/cards/accounts/accounts_card.dart';
import 'package:envoy/ui/home/cards/accounts/address_card.dart';
import 'package:envoy/ui/home/cards/accounts/descriptor_card.dart';
import 'package:envoy/ui/home/cards/accounts/detail/account_card.dart';
import 'package:envoy/ui/home/cards/accounts/spend/confirmation_card.dart';
import 'package:envoy/ui/home/cards/accounts/spend/send_card.dart';
import 'package:envoy/ui/home/cards/accounts/spend/tx_review.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wallet/wallet.dart';

/// Different routes for accounts.
/// The nested routes cannot start with a slash,
/// so we have to keep the sub-route values in a private variable (using _).
/// We cannot navigate to a route without the full path, so we will define a second
/// publicly accessible constant that will be used to navigate to the route.
/// example context.go(ROUTE_ACCOUNT_DETAIL) will route to _ACCOUNT_DETAIL
///

const ROUTE_ACCOUNTS_HOME = '/account';

const _ACCOUNT_DETAIL = 'details';
const ROUTE_ACCOUNT_DETAIL = '${ROUTE_ACCOUNTS_HOME}/${_ACCOUNT_DETAIL}';

const _ACCOUNT_SEND = 'send';
const ROUTE_ACCOUNT_SEND = '${ROUTE_ACCOUNT_DETAIL}/${_ACCOUNT_SEND}';

const _ACCOUNT_RECEIVE = 'receive';
const ROUTE_ACCOUNT_RECEIVE = '${ROUTE_ACCOUNT_DETAIL}/${_ACCOUNT_RECEIVE}';

const _ACCOUNT_DESCRIPTOR = 'desc';
const ROUTE_ACCOUNT_DESCRIPTOR =
    '${ROUTE_ACCOUNT_DETAIL}/${_ACCOUNT_DESCRIPTOR}';

const _ACCOUNT_SEND_CONFIRM = 'confirm';
const ROUTE_ACCOUNT_SEND_CONFIRM =
    '${ROUTE_ACCOUNT_SEND}/${_ACCOUNT_SEND_CONFIRM}';

const _ACCOUNT_SEND_REVIEW = 'review';
const ROUTE_ACCOUNT_SEND_REVIEW =
    '${ROUTE_ACCOUNT_SEND_CONFIRM}/${_ACCOUNT_SEND_REVIEW}';

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
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.vertical,
          child: child);
    },
  );
}

final accountsRouter =
    StatefulShellBranch(restorationScopeId: 'accountsHomeRouterScope', routes: [
  GoRoute(
      path: ROUTE_ACCOUNTS_HOME,
      pageBuilder: (context, state) =>
          wrapWithVerticalAxisAnimation(AccountsCard()),
      routes: [
        GoRoute(
          path: _ACCOUNT_DETAIL,
          routes: [
            GoRoute(
                path: _ACCOUNT_SEND,
                pageBuilder: (context, state) {
                  Account? account;
                  if (state.extra is Map) {
                    account =
                        Account.fromJson(state.extra as Map<String, dynamic>);
                  } else {
                    account = state.extra as Account;
                  }
                  return wrapWithVerticalAxisAnimation(SendCard(account));
                },
                routes: [
                  GoRoute(
                    name: "spend_confirm",
                    path: _ACCOUNT_SEND_CONFIRM,
                    routes: [
                      GoRoute(
                        name: "spend_review",
                        path: _ACCOUNT_SEND_REVIEW,
                        pageBuilder: (context, state) {
                          Account? account;
                          Psbt? psbt;
                          if (state.extra is Map) {
                            Map extras = state.extra as Map;
                            if (extras['account'] is Account) {
                              account = extras['account'] as Account;
                            } else {
                              account = Account.fromJson(
                                  extras['account'] as Map<String, dynamic>);
                            }
                            if (extras['psbt'] is Psbt) {
                              psbt = extras['psbt'] as Psbt;
                            }
                          }
                          return wrapWithVerticalAxisAnimation(TxReview(
                            psbt!,
                            account!,
                            onFinishNavigationClick: () {
                              context.go(ROUTE_ACCOUNT_DETAIL, extra: account);
                            },
                          ));
                        },
                      ),
                    ],
                    pageBuilder: (context, state) {
                      Account? account;
                      int amount = 0;
                      String initialAddress = "";
                      if (state.extra is Map) {
                        Map extras = state.extra as Map;
                        amount = extras["amount"] as int? ?? 0;
                        initialAddress = extras['address'] as String;
                        if (extras['account'] is Account) {
                          account = extras['account'] as Account;
                        } else {
                          account = Account.fromJson(
                              extras['account'] as Map<String, dynamic>);
                        }
                      }
                      return wrapWithVerticalAxisAnimation(
                          ConfirmationCard(account!, amount, initialAddress));
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
                return wrapWithVerticalAxisAnimation(DescriptorCard(account));
              },
            ),
          ],
          pageBuilder: (context, state) {
            Account? account;
            if (state.extra is Map) {
              account = Account.fromJson(state.extra as Map<String, dynamic>);
            } else {
              account = state.extra as Account;
            }
            return wrapWithVerticalAxisAnimation(AccountCard(
              account,
            ));
          },
        ),
      ]
      // builder: (context, state) => AccountsCard(),
      ),
]);

final accountFullScreenRoute = [];
