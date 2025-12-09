// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';

class DraggableOverlay extends StatefulWidget {
  const DraggableOverlay({super.key, required this.child});

  final Widget child;

  @override
  State<DraggableOverlay> createState() => _DraggableOverlayState();
}

class _DraggableOverlayState extends State<DraggableOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
  )..forward();

  void _close() async {
    await _controller.reverse();
    if (!mounted) return;
    if (Navigator.of(context).canPop()) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _close,
      behavior: HitTestBehavior.opaque,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SizeTransition(
          sizeFactor: _controller,
          axisAlignment: -1.0,
          child: GestureDetector(
            onTap: () {},

            // drag to close
            onVerticalDragUpdate: (details) {
              final height = 500;
              _controller.value -= details.primaryDelta! / height;
            },
            onVerticalDragEnd: (details) {
              if (_controller.value < 0.5) {
                _close();
              } else {
                _controller.forward();
              }
            },

            child: Material(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              color: Colors.white,
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: EnvoySpacing.medium1,
                    ),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: EnvoySpacing.medium1,
                    ),
                    child: widget.child,
                  ),
                  const SizedBox(height: EnvoySpacing.medium3),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
