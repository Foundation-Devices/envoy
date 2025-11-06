// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';
import 'dart:math';

import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/business/local_storage.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/background.dart';
import 'package:envoy/ui/components/button.dart';
import 'package:envoy/ui/envoy_pattern_scaffold.dart';
import 'package:envoy/ui/onboard/prime/prime_routes.dart';
import 'package:envoy/ui/onboard/routes/onboard_routes.dart';
import 'package:envoy/ui/routes/routes.dart';
import 'package:envoy/ui/state/home_page_state.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/ui/widgets/color_util.dart';
import 'package:envoy/ui/widgets/scanner/decoders/generic_qr_decoder.dart';
import 'package:envoy/ui/widgets/scanner/qr_scanner.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:envoy/util/haptics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rive/rive.dart' as rive;

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

  Future<void> registerEscapeTap(EscapeHatchTap tap) async {
    final scaffold = ScaffoldMessenger.of(context);
    escapeHatchTaps.add(tap);

    if (listEquals(
        escapeHatchTaps,
        secretCombination
            .getRange(0, min(escapeHatchTaps.length, secretCombination.length))
            .toList())) {
      if (escapeHatchTaps.length == secretCombination.length) {
        escapeHatchTaps.clear();
        try {
          await EnvoySeed().removeSeedFromNonSecure();
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
                        Text(
                          S().welcome_screen_heading,
                          style: EnvoyTypography.heading,
                          textAlign: TextAlign.center,
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
                        context.goNamed(ONBOARD_PASSPORT_SCAN);
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

// ignore: unused_element
  void showScanDialog(BuildContext context) async {
    bool promptDismissed = await EnvoyStorage()
        .checkPromptDismissed(DismissiblePrompt.scanToConnect);

    if (!promptDismissed && context.mounted) {
      final assetPath =
          Platform.isIOS ? "assets/ios_scan.riv" : "assets/android_scan.riv";

      rive.File? file;
      rive.RiveWidgetController? controller;

      try {
        file = await rive.File.asset(assetPath, riveFactory: rive.Factory.rive);
        controller = rive.RiveWidgetController(file!);
        if (context.mounted) {
          showEnvoyDialog(
                  context: context,
                  useRootNavigator: true,
                  dialog: StatefulBuilder(
                    builder: (context, setState) {
                      return Container(
                        width: MediaQuery.of(context).size.width * 0.85,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(EnvoySpacing.medium2),
                          ),
                          color: EnvoyColors.textPrimaryInverse,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(EnvoySpacing.medium2),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  height: 200,
                                  child: rive.RiveWidget(
                                    controller: controller!,
                                    fit: rive.Fit.contain,
                                  ),
                                ),
                                //TODO: add more context instead of dismissible
                                // GestureDetector(
                                //   onTap: () {
                                //     setState(() {
                                //       dismissed = !dismissed;
                                //     });
                                //   },
                                //   child: Row(
                                //     crossAxisAlignment: CrossAxisAlignment.center,
                                //     mainAxisAlignment: MainAxisAlignment.center,
                                //     children: [
                                //       SizedBox(
                                //         child: EnvoyCheckbox(
                                //           value: dismissed,
                                //           onChanged: (value) {
                                //             if (value != null) {
                                //               setState(() {
                                //                 dismissed = value;
                                //               });
                                //             }
                                //           },
                                //         ),
                                //       ),
                                //       Text(
                                //         S().component_dontShowAgain,
                                //         style: Theme.of(context)
                                //             .textTheme
                                //             .bodyMedium
                                //             ?.copyWith(
                                //               color: dismissed
                                //                   ? Colors.black
                                //                   : const Color(0xff808080),
                                //             ),
                                //       ),
                                //     ],
                                //   ),
                                // ),
                                EnvoyButton(
                                  label: "Continue",
                                  type: ButtonType.primary,
                                  state: ButtonState.defaultState,
                                  onTap: () {
                                    // if (dismissed) {
                                    //   EnvoyStorage().addPromptState(
                                    //       DismissiblePrompt.scanToConnect);
                                    // }
                                    // Navigator.pop(context);

                                    showScannerDialog(
                                        showInfoDialog: true,
                                        context: context,
                                        onBackPressed: (context) {
                                          Navigator.pop(context);
                                        },
                                        decoder: GenericQrDecoder(
                                            onScan: (String payload) {
                                          Navigator.pop(context);
                                          final uri = Uri.parse(payload);
                                          kPrint(
                                              "BLE UriParams ${uri.queryParameters}");
                                          context.pushNamed(
                                            ONBOARD_PRIME,
                                            queryParameters:
                                                uri.queryParameters,
                                          );
                                        }));
                                  },
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  dismissible: true)
              .then((_) {
            // Clean up resources when dialog is dismissed
            controller?.dispose();
            file?.dispose();
          });
        }
      } catch (e) {
        // Handle error loading Rive file
        kPrint('Error loading Rive file: $e');
        controller?.dispose();
        file?.dispose();
      }
    } else {
      if (context.mounted) {
        context.goNamed(ONBOARD_PRIME);
      }
    }
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
