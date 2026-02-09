// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:io';

import 'package:animations/animations.dart';
import 'package:envoy/ble/bluetooth_manager.dart';
import 'package:envoy/business/settings.dart';
import 'package:envoy/channels/ql_connection.dart';
import 'package:envoy/channels/bluetooth_channel.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/pop_up.dart';
import 'package:envoy/ui/envoy_button.dart';
import 'package:envoy/ui/envoy_pattern_scaffold.dart';
import 'package:envoy/ui/onboard/manual/widgets/mnemonic_grid_widget.dart';
import 'package:envoy/ui/onboard/onboarding_page.dart';
import 'package:envoy/ui/onboard/prime/connection_lost_dialog.dart';
import 'package:envoy/ui/onboard/prime/prime_routes.dart';
import 'package:envoy/ui/onboard/prime/state/ble_onboarding_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_icons.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/ui/widgets/expandable_page_view.dart';
import 'package:envoy/ui/widgets/scanner/decoders/prime_ql_payload_decoder.dart';
import 'package:envoy/ui/widgets/scanner/qr_scanner.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/console.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foundation_api/foundation_api.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

QLConnection? _onboardingDevice;
// TODO: remove this, store somewhere else
final estimatedTimeProvider = StateProvider<int>((ref) => 0);
final bleMacRegex = RegExp(r'^([0-9A-Fa-f]{2}:){5}([0-9A-Fa-f]{2})$');

enum BleConnectState { idle, invalidId, connecting, connected }

String? _bleIdCache;

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
  BleConnectState bleConnectState = BleConnectState.idle;
  int colorWay = 1;

  Completer<QuantumLinkMessage_BroadcastTransaction>? _completer;

  Completer<QuantumLinkMessage_BroadcastTransaction>? get completer =>
      _completer;

  StreamSubscription<PassportMessage>? _passportMessagesSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final params = GoRouter.of(context).state.uri.queryParameters;
      setState(() {
        final param = params["c"] ?? "1";
        onboardingCompleted = int.tryParse(params["o"] ?? "0") == 1;
        colorWay = int.tryParse(param) ?? 1;
      });
      if (GoRouter.of(context).state.extra is bool) {
        onboardingCompleted = GoRouter.of(context).state.extra as bool;
      }
    });
  }

  @override
  void dispose() {
    _passportMessagesSubscription?.cancel();
    _connectionMonitorSubscription?.cancel();
    super.dispose();
  }

  StreamSubscription? _connectionMonitorSubscription;

  Future<void> _connectToPrime() async {
    // Check Bluetooth permissions
    bool isDenied = false;
    if (Platform.isAndroid) {
      await BluetoothManager().getPermissions();
      isDenied = await BluetoothManager.isBluetoothDenied();
    }
    String? bleId;

    if (mounted) {
      // Get the initial bleId from the router (if available)
      bleId = GoRouter.of(context).state.uri.queryParameters["p"];
      if (GoRouter.of(context).state.uri.queryParameters["p"] == null &&
          _bleIdCache != null) {
        bleId = _bleIdCache;
      }
      _bleIdCache = bleId;
    }

    if (isDenied && mounted) {
      // Navigate to the permission denied screen and wait for result
      final result = await context.pushNamed(
        ONBOARD_BLUETOOTH_DENIED,
        queryParameters: {"p": bleId ?? ""},
      );

      // If user provided a bleId, use it; else exit
      if (result is String) {
        bleId = result;
      } else {
        return;
      }
    }

    if (!mounted) return;

    setState(() {
      bleConnectState = BleConnectState.connecting;
    });

    try {
      if (bleMacRegex.hasMatch(bleId ?? "")) {
        if (!Platform.isIOS) {
          await BluetoothManager().getPermissions();
        }

        _onboardingDevice = await BluetoothChannel().setupBle(
          bleId ?? "",
          colorWay,
        );

        ref.read(onboardingDeviceProvider.notifier).state = _onboardingDevice;
        if (_onboardingDevice == null) {
          throw Exception("Got null device when trying to connect to Prime.");
        }
        final connectionStatus = _onboardingDevice!.lastDeviceStatus;
        if (!connectionStatus.connected && mounted) {
          setState(() {
            bleConnectState = BleConnectState.idle;
          });
          //on ios accessory setup handles connection failures
          if (!Platform.isIOS) {
            throw Exception("Failed to connect to Prime device.");
          }
        }
        if (mounted && connectionStatus.connected) {
          setState(() {
            bleConnectState = BleConnectState.connected;
          });
          if (context.mounted && mounted) {
            showQLScanner(context);
          }
        }
      } else {
        throw Exception("Invalid Prime Serial");
      }
    } catch (e, stack) {
      setState(() {
        bleConnectState = BleConnectState.idle;
      });
      String message = "";
      if (e is PlatformException) {
        //only for Android
        if (e.code == "BLUETOOTH_DISABLED") {
          final bool? allowed = await BluetoothChannel().requestEnableBle();
          if (allowed == true) {
            return _connectToPrime();
          } else {
            message = "Unable to connect to device, Error code ${e.code}";
          }
        }
      }
      if (mounted) {
        setState(() {
          bleConnectState = BleConnectState.idle;
        });

        //handle specific errors
        if (e is BleSetupTimeoutException) {
          message = S().onboarding_modalBluetoothUnableConnect_content;
        }

        showEnvoyDialog(
          context: context,
          dismissible: true,
          dialog: EnvoyPopUp(
            icon: EnvoyIcons.alert,
            typeOfMessage: PopUpState.warning,
            showCloseButton: false,
            content: message,
            title: S().onboarding_modalBluetoothUnableConnect_header,
            primaryButtonLabel: S().component_retry,
            secondaryButtonLabel: S().component_dismiss,
            onSecondaryButtonTap: (BuildContext context) {
              Navigator.pop(context);
            },
            onPrimaryButtonTap: (BuildContext context) async {
              Navigator.pop(context);
              _connectToPrime();
            },
          ),
        );
        kPrint(e, stackTrace: stack);
        EnvoyReport().log("BleConnect", e.toString(), stackTrace: stack);
      }
    }
  }

  void showQLScanner(BuildContext context) async {
    final qrDecoder = await getQrDecoder();

    if (!context.mounted) return;

    await showScannerDialog(
      infoType: QrIntentInfoType.prime,
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
            await Future.delayed(const Duration(milliseconds: 400));
            await pairWithPrime(payload);
          }
        },
      ),
    );
  }

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
            child: child,
          );
        },
        child: quantumLinkIntro(context),
      ),
    );
  }

  Widget quantumLinkIntro(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: EnvoySpacing.medium2,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: EnvoySpacing.large1),
                  Text(
                    S().onboarding_bluetoothIntro_header,
                    textAlign: TextAlign.center,
                    style: EnvoyTypography.heading.copyWith(
                      color: EnvoyColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: EnvoySpacing.medium1),
                  Text(
                    S().onboarding_bluetoothIntro_content,
                    style: EnvoyTypography.info.copyWith(
                      color: EnvoyColors.contentSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: EnvoySpacing.medium1,
            right: EnvoySpacing.medium1,
            bottom: EnvoySpacing.medium1,
            top: EnvoySpacing.small,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              EnvoyButton(
                S().component_learnMore,
                type: EnvoyButtonTypes.tertiary,
                onTap: () {
                  launchUrl(
                    Uri.parse("https://docs.foundation.xyz/prime/quantumlink"),
                  );
                },
              ),
              const SizedBox(height: EnvoySpacing.small),
              Opacity(
                opacity: (bleConnectState == BleConnectState.invalidId ||
                        bleConnectState == BleConnectState.connecting)
                    ? 0.5
                    : 1,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Opacity(
                      opacity: bleConnectState == BleConnectState.connecting
                          ? 0.5
                          : 1,
                      child: EnvoyButton(
                        S().onboarding_bluetoothIntro_connect,
                        onTap: () {
                          _connectToPrime();
                        },
                      ),
                    ),
                    if (bleConnectState == BleConnectState.connecting)
                      const CupertinoActivityIndicator(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<bool> pairWithPrime(XidDocument payload) async {
    return await _onboardingDevice?.pair(payload) ?? false;
  }

  Future<void> showCommunicationModal(BuildContext context) async {
    if (!context.mounted) return;

    showEnvoyDialog(
      context: context,
      dismissible: false,
      dialog: QuantumLinkCommunicationInfo(
        onContinue: () async {
          showQLScanner(context);
        },
      ),
    );
  }
}

//TODO: QL intro implmenentation
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
                    horizontal: EnvoySpacing.xs,
                  ),
                  child: Text(
                    //TODO: copy update
                    "The Communication is Secured",
                    textAlign: TextAlign.center,
                    style: EnvoyTypography.info,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: EnvoySpacing.small,
                    horizontal: EnvoySpacing.medium1,
                  ),
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
                                : S().wallet_security_modal_1_4_ios_subheading,
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
                  ),
                ),
                DotsIndicator(totalPages: 2, pageController: _pageController),
              ],
            ),
            OnboardingButton(
              type: EnvoyButtonTypes.tertiary,
              label: S().component_cancel,
              onTap: () {
                context.pop(context);
              },
            ),
            OnboardingButton(
              type: EnvoyButtonTypes.primaryModal,
              label: S().component_continue,
              onTap: () {
                context.pop();
                widget.onContinue();
              },
            ),
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
            child: child,
          );
        },
        child: bluetoothPermission(context),
      ),
    );
  }

  Widget bluetoothPermission(BuildContext context) {
    return Column(
      children: [
        Flexible(
          child: Container(
            constraints: const BoxConstraints(minHeight: 300),
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(
                  vertical: EnvoySpacing.medium3,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: EnvoySpacing.medium1,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              EnvoyButton(
                S().component_learnMore,
                type: EnvoyButtonTypes.tertiary,
                onTap: () {
                  launchUrl(
                    Uri.parse("https://docs.foundation.xyz/prime/quantumlink"),
                  );
                },
              ),
              const SizedBox(height: EnvoySpacing.small),
              EnvoyButton(
                S().onboarding_bluetoothDisabled_enable,
                onTap: () {
                  context.pop();
                  openAppSettings();
                },
              ),
              const SizedBox(height: EnvoySpacing.small),
            ],
          ),
        ),
      ],
    );
  }
}
