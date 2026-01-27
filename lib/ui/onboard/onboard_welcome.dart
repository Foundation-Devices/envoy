// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:math';

import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/business/local_storage.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/background.dart';
import 'package:envoy/ui/envoy_pattern_scaffold.dart';
import 'package:envoy/ui/home/setup_overlay.dart' show addPassportAccount;
import 'package:envoy/ui/onboard/prime/prime_routes.dart';
import 'package:envoy/ui/onboard/routes/onboard_routes.dart';
import 'package:envoy/ui/routes/routes.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/color_util.dart';
import 'package:envoy/ui/widgets/scanner/decoders/device_decoder.dart'
    show DeviceDecoder;
import 'package:envoy/ui/widgets/scanner/decoders/pair_decoder.dart'
    show PairPayloadDecoder;
import 'package:envoy/ui/widgets/scanner/qr_scanner.dart';
import 'package:envoy/ui/widgets/toast/envoy_toast.dart' show EnvoyToast;
import 'package:envoy/util/haptics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:envoy/business/settings.dart';

enum EscapeHatchTap { logo, text }

const List<EscapeHatchTap> secretCombination = [
  EscapeHatchTap.logo,
  EscapeHatchTap.logo,
  EscapeHatchTap.text,
  EscapeHatchTap.text,
  EscapeHatchTap.logo,
  EscapeHatchTap.logo,
];

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

final successfulSetupWallet = StateProvider((ref) => false);
final successfulManualRecovery = StateProvider((ref) => false);
final triedAutomaticRecovery = StateProvider((ref) => false);

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  List<EscapeHatchTap> escapeHatchTaps = [];
  bool escapeHatchAccessed = false;

  Future<void> registerEscapeTap(EscapeHatchTap tap) async {
    final scaffold = ScaffoldMessenger.of(context);
    escapeHatchTaps.add(tap);

    if (listEquals(
        escapeHatchTaps,
        secretCombination
            .getRange(0, min(escapeHatchTaps.length, secretCombination.length))
            .toList())) {
      if (escapeHatchTaps.length == secretCombination.length) {
        escapeHatchAccessed = true;
        escapeHatchTaps.clear();
        try {
          //old storage configuration
          FlutterSecureStorage storage = const FlutterSecureStorage();
          await storage.deleteAll();

          await EnvoySeed().removeSeedFromNonSecure();
          await EnvoySeed().removeSeedFromSecure();
          //new storage configuration, delete all entries from secure storage fixes
          // issue where old seeds were not deleted properly
          await LocalStorage().secureStorage.deleteAll();
          await Future.delayed(const Duration(milliseconds: 500));
          scaffold.showSnackBar(const SnackBar(
            content: Text("Envoy Seed deleted!"), // TODO: FIGMA
          ));
        } on Exception catch (_) {
          scaffold.showSnackBar(const SnackBar(
            content: Text("Couldn't delete Envoy Seed!"), // TODO: FIGMA
          ));
        }
      }
    } else {
      escapeHatchTaps.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isOnboardingComplete =
        LocalStorage().prefs.getBool(PREFS_ONBOARDED) ?? false;

    return PopScope(
      child: EnvoyPatternScaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: isOnboardingComplete && GoRouter.of(context).canPop()
              ? CupertinoNavigationBarBackButton(
                  color: EnvoyColors.textPrimaryInverse,
                  onPressed: () => context.go("/"),
                )
              : const SizedBox.shrink(),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextButton(
                child: Text(S().component_advanced,
                    style: EnvoyTypography.button
                        .copyWith(color: EnvoyColors.textPrimaryInverse)),
                onPressed: () {
                  context.pushNamed(ADVANCED_SETTINGS);
                },
              ),
            )
          ],
        ),
        heroTag: "shield",
        header: GestureDetector(
          onTap: () {
            registerEscapeTap(EscapeHatchTap.logo);
          },
          onLongPress: () {
            if (escapeHatchAccessed) {
              Settings().skipPrimeSecurityCheck = true;
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Security check disabled"),
              ));
            }
          },
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.25,
            child: Image.asset(
              "assets/envoy_logo_with_title.png",
            ),
          ),
        ),
        shield: Padding(
          padding: const EdgeInsets.symmetric(
              vertical: EnvoySpacing.xs, horizontal: EnvoySpacing.medium1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: EnvoySpacing.medium1,
                        vertical: EnvoySpacing.xs),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(height: EnvoySpacing.medium1),
                        GestureDetector(
                          onLongPress: () {
                            ref.read(devModeEnabledProvider.notifier).state =
                                true;
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text("Dev mode enabled"),
                            ));
                          },
                          child: Text(
                            S().welcome_screen_heading,
                            style: EnvoyTypography.heading,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const Padding(
                            padding: EdgeInsets.all(EnvoySpacing.small)),
                        GestureDetector(
                          onTap: () {
                            registerEscapeTap(EscapeHatchTap.text);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: EnvoySpacing.xs),
                            child: Text(
                              //TODO: sync latest copy and button links
                              S().onboarding_welcome_content,
                              style: EnvoyTypography.info
                                  .copyWith(color: EnvoyColors.textTertiary),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(height: EnvoySpacing.medium3),
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: EnvoySpacing.medium2,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    flex: 1,
                    child: EnvoyWelcomeButton(
                      asset: Image.asset(
                        'assets/welcome_envoy_sm.png',
                        fit: BoxFit.cover,
                      ),
                      title: S().onboarding_welcome_createMobileWallet,
                      onTap: () {
                        context.pushNamed(ONBOARD_ENVOY_SETUP,
                            queryParameters: {"setupEnvoy": "1"});
                      },
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: EnvoyWelcomeButton(
                      asset: Image.asset(
                        'assets/passport_and_prime.png',
                        fit: BoxFit.cover,
                      ),
                      title: S().onboarding_welcome_setUpPassport,
                      onTap: () {
                        WakelockPlus.enable();
                        showScanner(context);
                        // context.goNamed(ONBOARD_PASSPORT_SCAN);
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void showScanner(BuildContext context) {
    showScannerDialog(
      context: context,
      onBackPressed: (context) {
        Navigator.pop(context);
      },
      decoder: DeviceDecoder(pairPayloadDecoder: PairPayloadDecoder(
        onScan: (binary) {
          addPassportAccount(binary, context);
        },
      ), onScan: (String payload) {
        final uri = Uri.parse(payload);
        final params = uri.queryParameters;

        if (params.containsKey("p")) {
          context.pop();
          context.goNamed(ONBOARD_PRIME, queryParameters: params);
        } else if (params.containsKey("t")) {
          context.pop();
          context.goNamed(ONBOARD_PASSPORT_TOU, queryParameters: params);
        } else {
          context.pop();
          EnvoyToast(
            replaceExisting: true,
            duration: const Duration(seconds: 6),
            message: "Invalid QR code",
            isDismissible: true,
            onActionTap: () {
              EnvoyToast.dismissPreviousToasts(context);
            },
            icon: const Icon(
              Icons.info_outline,
              color: EnvoyColors.accentPrimary,
            ),
          ).show(context);
        }
      }),
      child: LegacyFirmwareAlert(),
    );
  }
}

class EnvoyWelcomeButton extends StatefulWidget {
  final Widget asset;
  final String title;
  final GestureTapCallback onTap;

  const EnvoyWelcomeButton(
      {super.key,
      required this.asset,
      required this.onTap,
      required this.title});

  @override
  State<EnvoyWelcomeButton> createState() => _EnvoyWelcomeButtonState();
}

class _EnvoyWelcomeButtonState extends State<EnvoyWelcomeButton> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double buttonWidth = constraints.minWidth.clamp(110, 184);
        //image needs to be center of the button,
        //to make it responsive width will be used anchor the size
        double imageSize = buttonWidth * 0.65;
        return Center(
          child: SizedBox(
            width: buttonWidth,
            //
            height: buttonWidth + 30,
            child: GestureDetector(
              onTap: widget.onTap,
              onTapDown: (details) => setState(() {
                Haptics.buttonPress();
                pressed = true;
              }),
              onTapCancel: () => setState(() {
                pressed = false;
              }),
              onTapUp: (_) => setState(() {
                pressed = false;
              }),
              child: TweenAnimationBuilder(
                duration: const Duration(milliseconds: 300),
                tween: pressed
                    ? Tween(begin: 0.0, end: 1.0)
                    : Tween(begin: 1.0, end: 0.0),
                curve: Curves.easeInOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: Tween(begin: 1.0, end: .96).transform(value),
                    child: Card(
                      elevation: Tween(begin: 6.0, end: 4.0).transform(value),
                      shadowColor: Colors.black,
                      borderOnForeground: true,
                      clipBehavior: Clip.hardEdge,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                              Radius.circular(EnvoySpacing.medium1))),
                      child: child,
                    ),
                  );
                },
                child: SizedBox.expand(
                    child: Stack(
                  children: [
                    Positioned.fill(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Flexible(
                            flex: 5,
                            child: Container(
                              color: Colors.white,
                            ),
                          ),
                          Container(
                            height: 2,
                          ),
                          Flexible(
                            flex: 4,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  // Adjust if needed
                                  end: Alignment.bottomRight,
                                  // Adjust if needed
                                  colors: [
                                    EnvoyColors.gray1000,
                                    EnvoyColors.gray1000.applyOpacity(0.62),
                                  ],
                                  stops: const [
                                    0.0754, // 7.54%
                                    0.9235, // 92.35%
                                  ],
                                  transform: const GradientRotation(10 *
                                      3.14159 /
                                      180), // 10 degrees to radians
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(
                                        0x1A000000), // rgba(0, 0, 0, 0.10)
                                    blurRadius: 14.0,
                                    offset: Offset(0, 0), // No offset
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Flexible(flex: 1, child: Container())
                        ],
                      ),
                    ),
                    Positioned.fill(
                        child: ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          colors: [
                            EnvoyColors.gray1000.applyOpacity(1.02),
                            EnvoyColors.gray1000.applyOpacity(0.01),
                            EnvoyColors.gray1000.applyOpacity(0.1),
                            EnvoyColors.gray1000.applyOpacity(0.2),
                            EnvoyColors.gray1000.applyOpacity(0.8),
                            EnvoyColors.gray1000.applyOpacity(0.002),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ).createShader(bounds);
                      },
                      child: CustomPaint(
                        isComplex: true,
                        willChange: false,
                        painter: LinesPainter(
                          opacity: 1,
                          hideLineGap: false,
                          color: EnvoyColors.gray1000,
                        ),
                      ),
                    )),
                    Positioned.fill(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Flexible(
                            flex: 5,
                            child: Container(
                              color: Colors.transparent,
                              alignment: Alignment.bottomCenter,
                              child: Image.asset(
                                'assets/crop_glow.png',
                                fit: BoxFit.cover,
                                scale: .5,
                                filterQuality: FilterQuality.high,
                              ),
                            ),
                          ),
                          Container(
                            height: 2,
                            color: EnvoyColors.accentSecondary,
                          ),
                          Flexible(
                            flex: 4,
                            child: Container(),
                          ),
                          // Flexible(flex: 1, child: Container())
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.center.add(const Alignment(0, -.5)),
                      child: SizedBox(
                        height: imageSize,
                        child: widget.asset,
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: EnvoySpacing.medium1,
                        ),
                        child: Text(
                          widget.title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11),
                        ),
                      ),
                    )
                  ],
                )),
              ),
            ),
          ),
        );
      },
    );
  }
}

class LegacyFirmwareAlert extends StatefulWidget {
  const LegacyFirmwareAlert({super.key});

  @override
  State<LegacyFirmwareAlert> createState() => _LegacyFirmwareAlertState();
}

class _LegacyFirmwareAlertState extends State<LegacyFirmwareAlert>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _heightAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _heightAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
  }

  void _toggleAdvanced() {
    if (_controller.isCompleted) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: EnvoySpacing.medium3),
          alignment: Alignment.center,
          child: Column(
            children: [
              GestureDetector(
                onTap: _toggleAdvanced,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _controller.value * pi,
                      child: child,
                    );
                  },
                  child: const Icon(
                    Icons.keyboard_arrow_up_sharp,
                    color: Colors.white,
                  ),
                ),
              ),
              SizeTransition(
                sizeFactor: _heightAnimation,
                axisAlignment: -1.0, // slide down from top
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: EnvoySpacing.medium3,
                      vertical: EnvoySpacing.small),
                  child: Column(
                    children: [
                      Text(
                        S().onboarding_passpportSelectCamera_sub235VersionAlert,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: EnvoyColors.textPrimaryInverse,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(EnvoySpacing.small),
                        child: TextButton(
                          child: Text(
                            S().onboarding_passpportSelectCamera_tapHere,
                            style: EnvoyTypography.button.copyWith(
                              color: EnvoyColors.textPrimaryInverse,
                            ),
                          ),
                          onPressed: () async {
                            context.goNamed(ONBOARD_PASSPORT_SETUP);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class WelcomeButtonGradientPainter extends CustomPainter {
  final double gradientRadius;
  final double gradientHeight;

  WelcomeButtonGradientPainter(
      {required this.gradientRadius, this.gradientHeight = 1.5});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const RadialGradient(
        center: Alignment.center,
        radius: 0.5,
        colors: [
          Color.fromRGBO(150, 92, 75, 0.6),
          Color.fromRGBO(214, 139, 110, 0.6),
          Color.fromRGBO(240, 187, 164, 0.0),
        ],
        stops: [0.0, 0.4836, 0.9466], // Corresponding to the percentages
      ).createShader(Rect.fromCircle(
          center: Offset(size.width / 2, size.height / gradientHeight),
          radius: min(size.width, size.width * gradientRadius)));

    final rxect = Rect.fromPoints(
        Offset(0, -size.height), Offset(size.width, size.height));
    canvas.drawRRect(RRect.fromRectXY(rxect, 0, 0), paint);

    canvas.drawPath(
        Path()
          ..addRect(Rect.fromPoints(Offset(size.width / 2, -size.height),
              Offset(size.width, size.height)))
          ..fillType = PathFillType.evenOdd,
        Paint()
          ..color = Colors.black.withAlpha(50)
          ..maskFilter =
              MaskFilter.blur(BlurStyle.normal, convertRadiusToSigma(2)));
  }

  @override
  bool shouldRepaint(covariant WelcomeButtonGradientPainter oldDelegate) {
    return oldDelegate.gradientRadius != gradientRadius;
  }

  static double convertRadiusToSigma(double radius) {
    return radius * 0.57735 + 0.5;
  }
}
