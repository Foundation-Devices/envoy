// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:animations/animations.dart';
import 'package:envoy/business/account.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/home/cards/accounts/account_list_tile.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:wallet/wallet.dart';

class ConnectPrimeAccount extends StatefulWidget {
  const ConnectPrimeAccount({super.key});

  @override
  State<ConnectPrimeAccount> createState() => _ConnectPrimeAccountState();
}

class _ConnectPrimeAccountState extends State<ConnectPrimeAccount> {
  StateMachineController? _stateMachineController;

  bool connectingInProgress = true;

  @override
  void dispose() {
    _stateMachineController?.dispose();
    super.dispose();
  }

  _onRiveInit(Artboard artBoard) {
    _stateMachineController =
        StateMachineController.fromArtboard(artBoard, 'STM');
    artBoard.addController(_stateMachineController!);

    Future.delayed(const Duration(milliseconds: 300), () {
      _stateMachineController?.findInput<bool>("indeterminate")?.change(true);
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      init();
    });
  }

  init() async {
    await Future.delayed(const Duration(milliseconds: 2800));
    _stateMachineController?.findInput<bool>("indeterminate")?.change(false);
    _stateMachineController?.findInput<bool>("happy")?.change(true);
    _stateMachineController?.findInput<bool>("unhappy")?.change(false);
    setState(() {
      connectingInProgress = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    String message = "Connecting Wallet…";
    if (!connectingInProgress) {
      message = "Wallet connected successfully";
    }

    return CustomScrollView(
      shrinkWrap: true,
      slivers: [
        const SliverPadding(padding: EdgeInsets.all(EnvoySpacing.medium1)),
        SliverToBoxAdapter(
          child: Container(
            constraints: BoxConstraints.tight(const Size.fromHeight(200)),
            child: Transform.scale(
              scale: 1.2,
              child: RiveAnimation.asset(
                "assets/envoy_loader.riv",
                fit: BoxFit.contain,
                onInit: _onRiveInit,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 340),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: Text(
                key: ValueKey(message),
                message,
                style: EnvoyTypography.heading,
              ),
            ),
          ),
        ),
        const SliverPadding(padding: EdgeInsets.all(EnvoySpacing.medium3)),
        SliverFillRemaining(
            fillOverscroll: false,
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  PageTransitionSwitcher(
                    duration: const Duration(milliseconds: 340),
                    transitionBuilder:
                        (child, primaryAnimation, secondaryAnimation) {
                      return SharedAxisTransition(
                        animation: primaryAnimation,
                        secondaryAnimation: secondaryAnimation,
                        transitionType: SharedAxisTransitionType.vertical,
                        child: child,
                      );
                    },
                    child: connectingInProgress
                        ? Container()
                        : PhysicalModel(
                            elevation: 8,
                            borderRadius: BorderRadius.circular(16),
                            color: EnvoyColors.transparent,
                            child: AccountListTile(
                              //TODO: Add proper account
                              Account(
                                deviceSerial: 'prime',
                                dateAdded: DateTime.now(),
                                number: 5,
                                id: '',
                                dateSynced: DateTime.now(),
                                name: "Primary",
                                wallet: GhostWallet(hot: false),
                              ),
                              draggable: false,
                              onTap: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                  ),
                ],
              ),
            ))
      ],
    );
  }
}
