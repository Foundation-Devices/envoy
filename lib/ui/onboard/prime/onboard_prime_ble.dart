// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:io';

import 'package:animations/animations.dart';
import 'package:envoy/ble/bluetooth_manager.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/envoy_pattern_scaffold.dart';
import 'package:envoy/ui/onboard/manual/widgets/mnemonic_grid_widget.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/onboard/prime/connection_lost_dialog.dart';
import 'package:envoy/ui/onboard/prime/prime_onboard_connection.dart';
import 'package:envoy/ui/onboard/prime/prime_routes.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/ui/widgets/expandable_page_view.dart';
import 'package:envoy/ui/widgets/scanner/decoders/prime_ql_payload_decoder.dart';
import 'package:envoy/ui/widgets/scanner/qr_scanner.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foundation_api/foundation_api.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

// TODO: remove this, store somewhere else
final primeDeviceVersionProvider = StateProvider<String>((ref) => '');

final primeDeviceNewVersionProvider = StateProvider<String>((ref) => '');

final estimatedTimeProvider = StateProvider<int>((ref) => 0);

class OnboardPrimeBluetooth extends ConsumerStatefulWidget {
  const OnboardPrimeBluetooth({super.key});

  @override
  ConsumerState<OnboardPrimeBluetooth> createState() =>
      _OnboardPrimeBluetoothState();
}

PairingResponse? pairingResponse;

class _OnboardPrimeBluetoothState extends ConsumerState<OnboardPrimeBluetooth>
    with SingleTickerProviderStateMixin {
  final s = Settings();
  bool dialogShown = false;
  bool scanForPayload = false;
  bool onboardingCompleted = false;

  Completer<QuantumLinkMessage_BroadcastTransaction>? _completer;

  Completer<QuantumLinkMessage_BroadcastTransaction>? get completer =>
      _completer;

  StreamSubscription<PassportMessage>? _passportMessagesSubscription;

  @override
  void initState() {
    super.initState();
    _listenForPassportMessages();
  }

  @override
  void dispose() {
    _passportMessagesSubscription?.cancel();
    _connectionMonitorSubscription?.cancel();
    super.dispose();
  }

  void _listenForPassportMessages() {
    onboardingCompleted = GoRouter.of(context).state.extra as bool? ?? false;
  }

  StreamSubscription? _connectionMonitorSubscription;

  //TODO: show overlay properly after onboarding
  // void _notifyAfterOnboardingTutorial(BuildContext context) async {
  //   final accounts = ref.read(accountsProvider);
  //
  //   if (accounts.length == 2) {
  //     // make sure there are two wallets hot and prime
  //     final hasHotWallet = accounts.any((account) => account.isHot);
  //
  //     if (hasHotWallet) {
  //       if (context.mounted) {
  //         Navigator.of(context).push(
  //           PageRouteBuilder(
  //             opaque: false,
  //             pageBuilder: (context, animation, secondaryAnimation) =>
  //                 const AccountTutorialOverlay(),
  //           ),
  //         );
  //       }
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    startBluetoothDisconnectionListener(context, ref);
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
          offset: const Offset(0, 70),
          child: TweenAnimationBuilder(
            duration: const Duration(milliseconds: 600),
            tween: Tween<double>(end: 1.0, begin: 0.0),
            curve: Curves.decelerate,
            builder: (context, value, child) {
              return Opacity(opacity: value, child: child);
            },
            child: Hero(
              tag: "hero_prime_devices",
              child: Image.asset(
                "assets/images/prime_bluetooth_shield.png",
                alignment: Alignment.bottomCenter,
                width: MediaQuery.of(context).size.width * 0.8,
                height: 320,
              ),
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
            child: quantumLinkIntro(context)));
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
                  vertical: EnvoySpacing.medium3,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: EnvoySpacing.medium2),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                S().onboarding_bluetoothIntro_header,
                                textAlign: TextAlign.center,
                                style: EnvoyTypography.body.copyWith(
                                  fontSize: 20,
                                  color: EnvoyColors.gray1000,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              const SizedBox(height: EnvoySpacing.small),
                              Text(
                                S().onboarding_bluetoothIntro_content,
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
              //const SizedBox(height: EnvoySpacing.medium1),
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
              EnvoyButton(S().component_learnMore,
                  type: EnvoyButtonTypes.tertiary, onTap: () {
                launchUrl(
                    Uri.parse("https://docs.foundation.xyz/prime/quantumlink"));
              }),
              const SizedBox(height: EnvoySpacing.medium1),
              EnvoyButton(S().onboarding_bluetoothIntro_connect,
                  onTap: () async {
                final qrDecoder = await getQrDecoder();

                if (!context.mounted) return;

                await showScannerDialog(
                  showInfoDialog: true,
                  context: context,
                  onBackPressed: (ctx) {
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  decoder: PrimeQlPayloadDecoder(
                    decoder: qrDecoder,
                    onScan: (XidDocument payload) async {
                      // TODO: process XidDocument for connection

                      if (!context.mounted) return;

                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }

                      await Future.delayed(const Duration(milliseconds: 200));

                      if (!onboardingCompleted) {
                        await pairWithPrime(payload);
                        if (!context.mounted) return;
                        context.goNamed(ONBOARD_PRIME_PAIR);
                      } else {
                        if (context.mounted) {
                          context.goNamed(ONBOARD_REPAIRING);
                        }
                        await Future.delayed(Duration(milliseconds: 400));
                        await pairWithPrime(payload);
                      }
                    },
                  ),
                );
              }),
              const SizedBox(height: EnvoySpacing.small),
            ],
          ),
        ),
      ],
    );
  }

  Future<bool> pairWithPrime(XidDocument payload) async {
    return await BluetoothManager().pair(payload);
  }

  Future<void> showCommunicationModal(BuildContext context) async {
    if (!context.mounted) return;

    showEnvoyDialog(
      context: context,
      dismissible: false,
      dialog: QuantumLinkCommunicationInfo(
        onContinue: () async {
          final qrDecoder = await getQrDecoder();

          if (!context.mounted) return;

          await showScannerDialog(
            showInfoDialog: true,
            context: context,
            onBackPressed: (ctx) {
              if (ctx.mounted) Navigator.pop(ctx);
            },
            decoder: PrimeQlPayloadDecoder(
              decoder: qrDecoder,
              onScan: (XidDocument payload) async {
                // TODO: process XidDocument for connection

                if (!context.mounted) return;

                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }

                primeXid = payload;
                await Future.delayed(const Duration(milliseconds: 200));
                if (!context.mounted) return;
                context.goNamed(ONBOARD_PRIME_PAIR);
                await Future.delayed(const Duration(milliseconds: 300));
              },
            ),
          );
        },
      ),
    );
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
      height: 550,
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
                            LinkText(
                              text: Platform.isAndroid
                                  ? S()
                                      .wallet_security_modal_1_4_android_subheading
                                  : S()
                                      .wallet_security_modal_1_4_ios_subheading,
                              linkStyle: EnvoyTypography.info.copyWith(
                                color: EnvoyColors.accentPrimary,
                              ),
                              onTap: () => launchUrl(
                                Uri.parse(
                                  Platform.isAndroid
                                      ? "https://developer.android.com/guide/topics/data/autobackup"
                                      : "https://support.apple.com/en-us/HT202303",
                                ),
                              ),
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

class OnboardBluetoothDenied extends StatelessWidget {
  const OnboardBluetoothDenied({super.key});

  @override
  Widget build(BuildContext context) {
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
          offset: const Offset(0, 70),
          child: TweenAnimationBuilder(
            duration: const Duration(milliseconds: 600),
            tween: Tween<double>(end: 1.0, begin: 0.0),
            curve: Curves.decelerate,
            builder: (context, value, child) {
              return Opacity(opacity: value, child: child);
            },
            child: Image.asset(
              "assets/images/bluetooth_shield_denied.png",
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
            child: bluetoothPermission(context)));
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
                  vertical: EnvoySpacing.medium3,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: EnvoySpacing.medium2),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                S().onboarding_bluetoothDisabled_header,
                                textAlign: TextAlign.center,
                                style: EnvoyTypography.body.copyWith(
                                  fontSize: 20,
                                  color: EnvoyColors.gray1000,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              const SizedBox(height: EnvoySpacing.medium2),
                              Text(
                                S().onboarding_bluetoothDisabled_content,
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
              EnvoyButton(S().component_learnMore,
                  type: EnvoyButtonTypes.tertiary, onTap: () {
                launchUrl(
                    Uri.parse("https://docs.foundation.xyz/prime/quantumlink"));
              }),
              const SizedBox(height: EnvoySpacing.medium1),
              EnvoyButton(S().onboarding_bluetoothDisabled_enable, onTap: () {
                context.pop();
                openAppSettings();
              }),
              const SizedBox(height: EnvoySpacing.small),
            ],
          ),
        ),
      ],
    );
  }
}
