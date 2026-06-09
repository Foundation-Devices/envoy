// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';

class DraggableOverlay extends StatefulWidget {
  const DraggableOverlay({super.key, required this.child, this.closeResult});

  final Widget child;

  /// Value returned to the caller via [Navigator.pop] when the overlay is
  /// dismissed by tapping the backdrop or dragging down. Has no effect when
  /// the route is popped via the system back gesture/button (which returns
  /// null by default).
  final dynamic closeResult;

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
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(widget.closeResult);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _close,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final t = _controller.value.clamp(0.0, 1.0);
                return Container(
                  color: Color.fromRGBO(0, 0, 0, 0.7 * t),
                );
              },
            ),
          ),
          Align(
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
                      SizedBox(
                        height: EnvoySpacing.medium2 +
                            MediaQuery.viewPaddingOf(context).bottom,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
