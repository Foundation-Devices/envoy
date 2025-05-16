// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/account_manager.dart';
import 'package:envoy/business/envoy_seed.dart';
import 'package:envoy/ui/routes/accounts_router.dart';
import 'package:envoy/ui/routes/route_state.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/widgets/color_util.dart';
import 'package:envoy/ui/widgets/toast/envoy_toast.dart';
import 'package:envoy/util/haptics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/components/stripe_painter.dart';
import 'package:envoy/ui/glow.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:go_router/go_router.dart';
import 'package:envoy/ui/onboard/prime/prime_routes.dart';
import 'package:envoy/ui/onboard/routes/onboard_routes.dart';
import 'package:envoy/ui/widgets/scanner/decoders/generic_qr_decoder.dart';
import 'package:envoy/ui/widgets/scanner/qr_scanner.dart';
import 'package:envoy/ui/pages/legal/passport_tou.dart';

import '../routes/routes.dart';

double cardButtonHeight = 125;

class AnimatedBottomOverlay extends ConsumerStatefulWidget {
  const AnimatedBottomOverlay({super.key});

  @override
  ConsumerState createState() => _AnimatedBottomOverlayState();
}

class _AnimatedBottomOverlayState extends ConsumerState<AnimatedBottomOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late double overlayHeight;
  late String path;
  late int numOfButtons;

  @override
  void initState() {
    super.initState();

    path = ref.read(routePathProvider);

    numOfButtons =
        path == ROUTE_ACCOUNTS_HOME && !AccountManager().hotAccountsExist()
            ? 2
            : 1;

    overlayHeight = (cardButtonHeight + EnvoySpacing.medium3) * numOfButtons +
        EnvoySpacing.large2 * 2; // + extra

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0, end: overlayHeight).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward(); // Start animation
  }

  void _closeOverlay() {
    _controller.reverse().then((_) async {
      if (mounted) {
        Navigator.of(context).pop();

        await Future.delayed(const Duration(milliseconds: 100));
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _closeOverlay,
      behavior: HitTestBehavior.opaque, // Close when tapping outside
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {}, // Prevent taps inside the overlay
              onVerticalDragUpdate: (details) {
                _controller.value -= details.primaryDelta! / overlayHeight;
              },
              onVerticalDragEnd: (details) {
                if (_controller.value < 0.5) {
                  _closeOverlay(); // Close if dragged down enough
                } else {
                  _controller.forward(); // Snap back if not enough
                }
              },

              child: Transform.scale(
                scale: 1.0,
                child: SizedBox(
                  height: _animation.value,
                  width: MediaQuery.of(context).size.width,
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.applyOpacity(0.2),
                          spreadRadius: 0,
                          blurRadius: 10,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: EnvoySpacing.xs),
                      child: Card(
                        elevation: 100,
                        margin: EdgeInsets.zero,
                        shadowColor: Colors.black,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(EnvoySpacing.medium2),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                                width: 40,
                                height: 4,
                                margin: const EdgeInsets.only(
                                    top: EnvoySpacing.xs,
                                    bottom: EnvoySpacing.small),
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(2),
                                )),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: EnvoySpacing.medium1),
                                child: SingleChildScrollView(
                                  physics: const NeverScrollableScrollPhysics(),
                                  // this is to remove overflow warning while animating
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      if (numOfButtons == 2)
                                        Column(
                                          children: [
                                            const SizedBox(
                                                height: EnvoySpacing.medium3),
                                            EnvoyCardButton(
                                              image:
                                                  'assets/welcome_envoy_sm.png',
                                              imagePaddingLeft: 22,
                                              title: S()
                                                  .onboarding_welcome_createMobileWallet,
                                              onTap: () {
                                                Navigator.pop(context);
                                                EnvoySeed().generate();
                                                context.pushNamed(
                                                    ONBOARD_ENVOY_SETUP,
                                                    queryParameters: {
                                                      "setupEnvoy": "1"
                                                    });
                                              },
                                            ),
                                          ],
                                        ),
                                      const SizedBox(
                                          height: EnvoySpacing.medium3),
                                      EnvoyCardButton(
                                        image: 'assets/passport_and_prime.png',
                                        imagePaddingLeft: 15,
                                        title: S()
                                            .onboarding_welcome_setUpPassport,
                                        onTap: () {
                                          showPassportScannerDialog(
                                              context, false);
                                        },
                                      ),
                                      const SizedBox(
                                          height: EnvoySpacing.medium3),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

void showPassportScannerDialog(BuildContext context, bool callFromOnboard) {
  showScannerDialog(
      context: context,
      onBackPressed: (context) {
        Navigator.pop(context);
      },
      child: GestureDetector(
        // prevent scanner drag
        onVerticalDragUpdate: (_) {},
        onVerticalDragStart: (_) {},
        onVerticalDragEnd: (_) {},
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: EnvoySpacing.medium3,
                ),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: EnvoySpacing.medium3),
                      child: Text(
                        S().onboarding_passpportSelectCamera_sub235VersionAlert,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: EnvoyColors.textPrimaryInverse,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    TextButton(
                      child: Text(
                        S().onboarding_passpportSelectCamera_tapHere,
                        style: EnvoyTypography.button
                            .copyWith(color: EnvoyColors.textPrimaryInverse),
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return TouPage(
                            callFromOnboard: callFromOnboard,
                          );
                        }));
                      },
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      decoder: GenericQrDecoder(onScan: (String payload) {
        final uri = Uri.parse(payload);
        final params = uri.queryParameters;

        if (params.containsKey("p")) {
          Navigator.pop(context);
          context.goNamed(ONBOARD_PRIME, queryParameters: params);
        } else if (params.containsKey("t")) {
          Navigator.pop(context);
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return TouPage(
              callFromOnboard: callFromOnboard,
            );
          }));
        } else {
          // TODO: manage this inside QR decoder ???
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
      }));
}

class EnvoyCardButton extends StatefulWidget {
  final String image;
  final String title;
  final double imagePaddingLeft;
  final VoidCallback onTap;

  const EnvoyCardButton({
    super.key,
    required this.image,
    required this.title,
    required this.onTap,
    this.imagePaddingLeft = 0,
  });

  @override
  State<EnvoyCardButton> createState() => _EnvoyCardButtonState();
}

class _EnvoyCardButtonState extends State<EnvoyCardButton> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    double cardButtonWidth = MediaQuery.of(context).size.width * 0.9;
    const cardRadius = EnvoySpacing.medium2;
    double imageSize = cardButtonWidth * 0.32;

    return GestureDetector(
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
        tween:
            pressed ? Tween(begin: 0.0, end: 1.0) : Tween(begin: 1.0, end: 0.0),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: Tween(begin: 1.0, end: .96).transform(value),
            child: child,
          );
        },
        child: Container(
          width: cardButtonWidth,
          height: cardButtonHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(cardRadius),
            boxShadow: const [
              BoxShadow(
                color: EnvoyColors.textInactive,
                blurRadius: 6,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(cardRadius),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(cardRadius),
                              bottomLeft: Radius.circular(cardRadius),
                            ),
                            child: Container(
                              color: EnvoyColors.textPrimaryInverse,
                            ),
                          ),
                          Glow(
                            innerColor:
                                EnvoyColors.accentSecondary.applyOpacity(0.1),
                            middleColor:
                                EnvoyColors.accentSecondary.applyOpacity(0.1),
                            outerColor: EnvoyColors.textPrimaryInverse
                                .applyOpacity(0.85),
                            stops: const [0.0, 0.05, 1.0],
                          ),
                          Positioned.fill(
                            child: ShaderMask(
                              shaderCallback: (Rect bounds) {
                                return const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.transparent,
                                    Colors.white,
                                  ],
                                  stops: [0.0, 0.3, 1.0],
                                ).createShader(bounds);
                              },
                              blendMode: BlendMode.dstIn,
                              child: CustomPaint(
                                isComplex: true,
                                willChange: false,
                                painter: StripePainter(
                                  EnvoyColors.gray1000.applyOpacity(0.1),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      color: EnvoyColors.accentSecondary,
                      height: double.infinity,
                    ),
                    Expanded(
                      flex: 2,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(cardRadius),
                          bottomRight: Radius.circular(cardRadius),
                        ),
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                EnvoyColors.textSecondary,
                                EnvoyColors.textPrimary,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: EnvoySpacing.medium1),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: SingleChildScrollView(
                                child: Text(
                                  widget.title,
                                  textAlign: TextAlign.start,
                                  style: EnvoyTypography.heading.copyWith(
                                    color: EnvoyColors.textPrimaryInverse,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  left: widget.imagePaddingLeft,
                  top: 10,
                  child: Image.asset(
                    widget.image,
                    height: imageSize,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
