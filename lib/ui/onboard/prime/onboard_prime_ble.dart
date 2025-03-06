// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:animations/animations.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/envoy_pattern_scaffold.dart';
import 'package:envoy/ui/onboard/manual/widgets/mnemonic_grid_widget.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/onboard/prime/prime_routes.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/ui/widgets/expandable_page_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class OnboardPrimeBluetooth extends StatefulWidget {
  const OnboardPrimeBluetooth({super.key});

  @override
  State<OnboardPrimeBluetooth> createState() => _OnboardPrimeBluetoothState();
}

class _OnboardPrimeBluetoothState extends State<OnboardPrimeBluetooth>
    with SingleTickerProviderStateMixin {
  final s = Settings();
  bool scanForPayload = false;

  bool deniedBluetooth = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //TODO: update copy based on s.syncToCloud
    // bool enabledMagicBackup = s.syncToCloud;
    return EnvoyPatternScaffold(
        gradientHeight: 1.8,
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: kToolbarHeight,
          backgroundColor: Colors.transparent,
          leading: CupertinoNavigationBarBackButton(
            color: Colors.white,
            onPressed: () {
              context.pop();
              return;
            },
          ),
          automaticallyImplyLeading: false,
        ),
        header: Transform.translate(
          offset: const Offset(0, 54),
          child: TweenAnimationBuilder(
            duration: const Duration(milliseconds: 600),
            tween: Tween<double>(end: 1.0, begin: 0.0),
            curve: Curves.decelerate,
            builder: (context, value, child) {
              return Opacity(opacity: value, child: child);
            },
            child: Image.asset(
              "assets/images/prime_bluetooth_shield.png",
              alignment: Alignment.bottomCenter,
              width: MediaQuery.of(context).size.width * 0.8,
              height: 320,
            ),
          ),
        ),
        shield: PageTransitionSwitcher(
            transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
              return SharedAxisTransition(
                  fillColor: Colors.transparent,
                  animation: primaryAnimation,
                  secondaryAnimation: secondaryAnimation,
                  transitionType: SharedAxisTransitionType.vertical,
                  child: child);
            },
            child: !deniedBluetooth
                ? quantumLinkIntro(context)
                : bluetoothPermission(context)));
  }

  requestBluetooth(BuildContext context) async {
    //   //TODO: call ble
    // setState(() {
    //   deniedBluetooth = true;
    // });

    context.goNamed(ONBOARD_PRIME_PAIR);
  }

  Widget quantumLinkIntro(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: EnvoySpacing.medium1),
        Flexible(
          child: Container(
            constraints: const BoxConstraints(
              minHeight: 300,
            ),
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(
                  vertical: EnvoySpacing.large1,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: EnvoySpacing.medium1),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                //TODO: copy update
                                "Secure Bluetooth with\nQuantumLink",
                                textAlign: TextAlign.center,
                                style: EnvoyTypography.body.copyWith(
                                  fontSize: 20,
                                  color: EnvoyColors.gray1000,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              const SizedBox(height: EnvoySpacing.small),
                              Text(
                                "QuantumLink creates an end-to-end encrypted Bluetooth tunnel using post-quantum encryption technology.\nPassport Prime’s Bluetooth chip only relays already encrypted data, ensuring private and secure communications.",
                                style: EnvoyTypography.info.copyWith(
                                  color: EnvoyColors.inactiveDark,
                                  decoration: TextDecoration.none,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: EnvoySpacing.medium1,
            right: EnvoySpacing.medium1,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const SizedBox(height: EnvoySpacing.medium1),
              // Consumer(
              //   builder: (context, ref, child) {
              //     final payload = GoRouter.of(context)
              //         .state
              //         ?.uri
              //         .queryParameters["p"];
              //     return Text("Debug Payload : $payload");
              //   },
              // ),
              const SizedBox(height: EnvoySpacing.medium1),
              EnvoyButton(S().component_continue, onTap: () {
                showCommunicationModal(context);
              }),
              const SizedBox(height: EnvoySpacing.small),
            ],
          ),
        ),
      ],
    );
  }

  Widget bluetoothPermission(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: EnvoySpacing.medium1),
        Flexible(
          child: Container(
            constraints: const BoxConstraints(
              minHeight: 300,
            ),
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(
                  vertical: EnvoySpacing.large1,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: EnvoySpacing.medium1),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                //TODO: copy update
                                "Enable Bluetooth for\nencrypted communication",
                                textAlign: TextAlign.center,
                                style: EnvoyTypography.body.copyWith(
                                  fontSize: 20,
                                  color: EnvoyColors.gray1000,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              const SizedBox(height: EnvoySpacing.small),
                              Text(
                                //TODO: copy update
                                "Lorem Ipsum, we strongly suggest you to\nallow envoy bluetooth communication, so\nthat you enjoy easy and secure backups.",
                                style: EnvoyTypography.info.copyWith(
                                  color: EnvoyColors.inactiveDark,
                                  decoration: TextDecoration.none,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              TextButton(
                                  onPressed: () {},
                                  child: Text(S().component_learnMore))
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: EnvoySpacing.medium1,
            right: EnvoySpacing.medium1,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const SizedBox(height: EnvoySpacing.medium1),
              // Consumer(
              //   builder: (context, ref, child) {
              //     final payload = GoRouter.of(context)
              //         .state
              //         ?.uri
              //         .queryParameters["p"];
              //     return Text("Debug Payload : $payload");
              //   },
              // ),
              const SizedBox(height: EnvoySpacing.medium1),
              EnvoyButton("Scan", onTap: () {
                requestBluetooth(context);
              }),
              const SizedBox(height: EnvoySpacing.small),
            ],
          ),
        ),
      ],
    );
  }

  showCommunicationModal(BuildContext context) {
    showEnvoyDialog(
        context: context,
        dismissible: false,
        dialog: QuantumLinkCommunicationInfo(
          onContinue: () => {
            setState(() {
              scanForPayload = true;
            })
          },
        ));
  }
}

//TODO: implement platform specific copy with appropriate
class QuantumLinkCommunicationInfo extends StatefulWidget {
  final GestureTapCallback onContinue;

  const QuantumLinkCommunicationInfo({super.key, required this.onContinue});

  @override
  State<QuantumLinkCommunicationInfo> createState() =>
      _QuantumLinkCommunicationInfoState();
}

class _QuantumLinkCommunicationInfoState
    extends State<QuantumLinkCommunicationInfo> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      //TODO: test for different sizes
      height: 500,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: EnvoySpacing.medium2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: EnvoySpacing.medium1),
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
            const Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
            Column(
              children: [
                SvgPicture.asset(
                  "assets/images/bluetooth_communication_info.svg",
                  height: 100,
                ),
                const Padding(padding: EdgeInsets.all(EnvoySpacing.xs)),
                Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: EnvoySpacing.small,
                        horizontal: EnvoySpacing.xs),
                    child: Text(
                      //TODO: copy update
                      "The Communication is Secured",
                      textAlign: TextAlign.center,
                      style: EnvoyTypography.info,
                    )),
                Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: EnvoySpacing.small,
                        horizontal: EnvoySpacing.medium1),
                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height *
                            0.6, // max size of PageView
                      ),
                      child: SingleChildScrollView(
                        child: ExpandablePageView(
                          controller: _pageController,
                          children: [
                            Text(
                              //TODO: copy update
                              "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam quis dolor nec orci aliquam volutpat. Fusce non enim a nibh mattis condimentum id et tortor. Proin aliquet augue felis, vel vestibulum felis tincidunt id.",
                              textAlign: TextAlign.center,
                              style: EnvoyTypography.info,
                            ),
                            Text(
                              S().backups_erase_wallets_and_backups_modal_2_2_subheading,
                              textAlign: TextAlign.center,
                              style: EnvoyTypography.info,
                            ),
                          ],
                        ),
                      ),
                    )),
                DotsIndicator(
                  totalPages: 2,
                  pageController: _pageController,
                ),
              ],
            ),
            OnboardingButton(
                type: EnvoyButtonTypes.tertiary,
                label: S().component_cancel,
                onTap: () {
                  context.pop(context);
                }),
            OnboardingButton(
                type: EnvoyButtonTypes.primaryModal,
                label: S().component_continue,
                onTap: () {
                  context.pop();
                  widget.onContinue();
                }),
            const Padding(padding: EdgeInsets.all(EnvoySpacing.small)),
          ],
        ),
      ),
    );
  }
}
