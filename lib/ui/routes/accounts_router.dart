import 'package:animations/animations.dart';
import 'package:envoy/business/account.dart';
import 'package:envoy/ui/home/cards/accounts/accounts_card.dart';
import 'package:envoy/ui/home/cards/accounts/address_card.dart';
import 'package:envoy/ui/home/cards/accounts/descriptor_card.dart';
import 'package:envoy/ui/home/cards/accounts/detail/account_card.dart';
import 'package:envoy/ui/home/cards/accounts/send_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const ROUTE_ACCOUNTS_HOME = '/account';

const _SUB_ROUTE_ACCOUNT_DETAIL = 'details';
const ROUTE_ACCOUNT_DETAIL = '${ROUTE_ACCOUNTS_HOME}/${_SUB_ROUTE_ACCOUNT_DETAIL}';

const _SUB_ROUTE_ACCOUNT_SEND = 'send';
const ROUTE_ACCOUNT_SEND = '${ROUTE_ACCOUNT_DETAIL}/${_SUB_ROUTE_ACCOUNT_SEND}';

const _SUB_ROUT_ACCOUNT_RECEIVE = 'receive';
const ROUTE_ACCOUNT_RECEIVE = '${ROUTE_ACCOUNT_DETAIL}/${_SUB_ROUT_ACCOUNT_RECEIVE}';

const _SUB_ROUT_ACCOUNT_DESCRIPTOR = 'desc';
const ROUTE_ACCOUNT_DESCRIPTOR = '${ROUTE_ACCOUNT_DETAIL}/${_SUB_ROUT_ACCOUNT_DESCRIPTOR}';

Page wrapWithVerticalAxisAnimation(Widget child) {
  return CustomTransitionPage(
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.scaled,
          child: child);
    },
  );
}

final accountsRouter = StatefulShellBranch(restorationScopeId: 'accountsHomeRouterScope', routes: [
  GoRoute(
      path: ROUTE_ACCOUNTS_HOME,
      pageBuilder: (context, state) => wrapWithVerticalAxisAnimation(AccountsCard()),
      routes: [
        GoRoute(
          path: _SUB_ROUTE_ACCOUNT_DETAIL,
          routes: [
            GoRoute(
              path: _SUB_ROUTE_ACCOUNT_SEND,
              pageBuilder: (context, state) {
                Account? account;
                if (state.extra is Map) {
                  account = Account.fromJson(state.extra as Map<String, dynamic>);
                } else {
                  account = state.extra as Account;
                }
                return wrapWithVerticalAxisAnimation(SendCard(account));
              },
            ),
            GoRoute(
              path: _SUB_ROUT_ACCOUNT_RECEIVE,
              pageBuilder: (context, state) {
                Account? account;
                if (state.extra is Map) {
                  account = Account.fromJson(state.extra as Map<String, dynamic>);
                } else {
                  account = state.extra as Account;
                }
                return wrapWithVerticalAxisAnimation(AddressCard(account));
              },
            ),
            GoRoute(
              path: _SUB_ROUT_ACCOUNT_DESCRIPTOR,
              pageBuilder: (context, state) {
                Account? account;
                if (state.extra is Map) {
                  account = Account.fromJson(state.extra as Map<String, dynamic>);
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
            return wrapWithVerticalAxisAnimation(AccountCard(account,));
          },
        ),
      ]
      // builder: (context, state) => AccountsCard(),
      ),
]);

final accountFullScreenRoute = [];
