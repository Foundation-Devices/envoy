// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/onboard/onboard_page_wrapper.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/state/home_page_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart';

class WalletSetupSuccess extends ConsumerStatefulWidget {
  const WalletSetupSuccess({Key? key}) : super(key: key);

  @override
  ConsumerState<WalletSetupSuccess> createState() => _WalletSetupSuccessState();
}

class _WalletSetupSuccessState extends ConsumerState<WalletSetupSuccess> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        ref.read(homePageTabProvider.notifier).state =
            HomePageTabState.accounts;
        ref.read(homePageBackgroundProvider.notifier).state =
            HomePageBackgroundState.hidden;
        await Future.delayed(Duration(milliseconds: 200));
        Navigator.of(context).popUntil(ModalRoute.withName("/"));
        return false;
      },
      child: OnboardPageBackground(
        child: Material(
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 180,
                    margin: EdgeInsets.only(top: 24),
                    child: Transform.scale(
                      scale: 1.68,
                      child: RiveAnimation.asset(
                        "assets/envoy_loader.riv",
                        fit: BoxFit.contain,
                        animations: ["happy"],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(44.0),
                    child: Column(
                      children: [
                        Text(
                          S().wallet_setup_success_heading,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 36),
                          child: Text(
                            S().wallet_setup_success_subheading,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Consumer(
                      builder: (context, ref, child) {
                        return OnboardingButton(
                            label: S().wallet_setup_success_CTA,
                            onTap: () async {
                              ref.read(homePageTabProvider.notifier).state =
                                  HomePageTabState.accounts;
                              ref
                                  .read(homePageBackgroundProvider.notifier)
                                  .state = HomePageBackgroundState.hidden;
                              await Future.delayed(Duration(milliseconds: 200));
                              Navigator.of(context)
                                  .popUntil(ModalRoute.withName("/"));
                            });
                      },
                    ),
                  ),
                ],
              ),
            ),
            color: Colors.transparent),
      ),
    );
  }
}
