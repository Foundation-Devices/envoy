// SPDX-FileCopyrightText: 2023 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/account.dart';
import 'package:envoy/ui/home/cards/accounts/accounts_state.dart';
import 'package:envoy/ui/home/cards/accounts/detail/coins/coins_state.dart';
import 'package:envoy/ui/home/cards/accounts/spend/spend_state.dart';
import 'package:envoy/ui/home/home_state.dart';
import 'package:envoy/ui/routes/accounts_router.dart';
import 'package:envoy/ui/routes/route_state.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/widgets/color_util.dart';
import 'package:envoy/util/easing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../components/stripe_painter.dart';
import '../glow.dart';
import '../theme/envoy_colors.dart';
import '../theme/envoy_typography.dart';

class AnimatedBottomOverlay extends ConsumerStatefulWidget {
  const AnimatedBottomOverlay({super.key});

  @override
  ConsumerState createState() => _AnimatedBottomOverlayState();
}

class _AnimatedBottomOverlayState extends ConsumerState<AnimatedBottomOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0, end: 406).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward(); // Start animation
  }

  void _closeOverlay() {
    _controller.reverse().then((_) async {
      if (mounted) {
        Navigator.of(context).pop(); // Close overlay after animation

        await Future.delayed(const Duration(milliseconds: 300));
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
      // Close when tapping outside
      behavior: HitTestBehavior.opaque,
      // Ensures the gesture is detected anywhere
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {}, // Prevent taps inside the overlay from closing it
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
                    child: Card(
                      elevation: 100,
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
                          // Handle Bar
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

                          // Content Goes Here
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: EnvoySpacing.medium1),
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                          height: EnvoySpacing.medium3),
                                      // Optional spacing
                                      EnvoyCardButton(
                                        image: 'assets/passport_and_prime.png',
                                        title: S()
                                            .onboarding_welcome_createMobileWallet,
                                        onTap: () {
                                          // Your onTap action here
                                        },
                                      ),

                                      // Add a space between the buttons (optional)
                                      const SizedBox(
                                          height: EnvoySpacing.medium3),
                                      // Optional spacing

                                      // Second EnvoyCardButton
                                      EnvoyCardButton(
                                        image: 'assets/welcome_envoy_sm.png',
                                        title: S()
                                            .onboarding_welcome_setUpPassport,
                                        onTap: () {
                                          // Your onTap action here
                                        },
                                      ),

                                      // Optional spacing
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),

                          // Bottom Padding for spacing
                          const SizedBox(height: EnvoySpacing.medium3),
                        ],
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

class EnvoyCardButton extends StatelessWidget {
  final String image;
  final String title;
  final VoidCallback onTap; // Add a callback for the tap action

  const EnvoyCardButton({
    super.key,
    required this.image,
    required this.title,
    required this.onTap, // Pass the callback when creating the card
  });

  @override
  Widget build(BuildContext context) {
    double cardWidth = MediaQuery.of(context).size.width * 0.85;
    const cardRadius = EnvoySpacing.medium2;

    return GestureDetector(
      onTap: onTap, // Trigger the action when the card is tapped
      child: Container(
        width: cardWidth,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(EnvoySpacing.medium2),
          boxShadow: const [
            BoxShadow(
              color: EnvoyColors.textInactive,
              blurRadius: 6,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none, // Allows image to go outside
          children: [
            Row(
              children: [
                // Left White Section (1/3 width) with rounded corners
// Left White Section (1/3 width) with CustomPaint
                Expanded(
                  flex: 1,
                  child: Stack(
                    children: [
                      // Custom Paint Background (Fills the left rectangle)

                      // Left Section with Rounded Corners
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(cardRadius),
                          bottomLeft: Radius.circular(cardRadius),
                        ),
                        child: Container(
                          color: EnvoyColors.textPrimaryInverse,
                        ),
                      ),
                      ClipRRect(
                        child: Positioned.fill(
                          child: CustomPaint(
                            isComplex: true,
                            willChange: false,
                            painter: StripePainter(
                              // TODO: make this work and clip it!!!!
                              EnvoyColors.gray1000.applyOpacity(0.4),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Divider
                Container(
                  width: 1,
                  color: EnvoyColors.accentSecondary,
                  height: double.infinity,
                ),

                // Right Black Section (2/3 width)
                Expanded(
                  flex: 2,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(EnvoySpacing.medium2),
                      bottomRight: Radius.circular(EnvoySpacing.medium2),
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
                      child: Center(
                        child: Text(
                          title,
                          style: EnvoyTypography.heading.copyWith(
                            color: EnvoyColors.textPrimaryInverse,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Image positioned on top (centered)
// Image with Glow behind it
            Positioned(
              left: 7, // Adjust to position as needed
              top: 25, // Moves it slightly outside the container
              child: Stack(
                alignment: Alignment.center, // Center the glow behind the image
                children: [
                  // Glow effect
                  // Positioned.fill(
                  //   child: CustomPaint(
                  //     isComplex: true,
                  //     willChange: false,
                  //     painter: StripePainter(
                  //       EnvoyColors.gray1000.applyOpacity(0.4),
                  //     ),
                  //   ),
                  // ),

                  // The actual image on top of the glow
                  Image.asset(
                    image,
                    width: 110, // Adjust size as needed
                    height: 110,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
