// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:io';

import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/widgets/scanner/scanner_decoder.dart';
import 'package:envoy/ui/widgets/toast/envoy_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

showScannerDialog(
    {required BuildContext context,
    required Function(BuildContext context) onBackPressed,
    required ScannerDecoder decoder}) {
  return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return QrScanner(onBackPressed: onBackPressed, decoder: decoder);
      },
      useRootNavigator: true);
}

class QrScanner extends StatefulWidget {
  final Function(BuildContext context) onBackPressed;
  final ScannerDecoder decoder;

  const QrScanner(
      {super.key, required this.onBackPressed, required this.decoder});

  @override
  State<QrScanner> createState() => _QrScannerState();
}

class _QrScannerState extends State<QrScanner> {
  final GlobalKey qrViewKey = GlobalKey(debugLabel: "qr_view");
  QRViewController? controller;
  StreamSubscription? _qrStreamSubscription;
  List<int>? _lastRawBytesDetected = [];
  String _lastCodeDetected = "";
  String _lastScan = "";
  double _progress = 0.0;

  bool _viewReady = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        setState(() {
          _viewReady = true;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      primary: false,
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
          // Get rid of the shadow
          elevation: 0,
          backgroundColor: Colors.transparent,
          toolbarHeight: 100,
          leading: IconButton(
              icon: const Icon(
                Icons.close_rounded,
                size: 25,
                color: Colors.white54,
              ),
              onPressed: () {
                widget.onBackPressed(context);
              })),
      body: Stack(
        children: [
          Container(
            color: Colors.black,
          ),
          if (_viewReady)
            Expanded(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 600),
                opacity: controller != null ? 1 : 0,
                child: AnimatedScale(
                  scale: controller != null ? 1 : 1.2,
                  curve: Curves.linear,
                  duration: const Duration(milliseconds: 900),
                  child: QRView(
                    onQRViewCreated: (controller) =>
                        _onQRViewCreated(controller, context),
                    key: qrViewKey,
                  ),
                ),
              ),
            ),
          const AnimatedQrViewfinder(
            size: 280,
            strokeWidth: 4,
            strokeColor: Colors.white,
            cornerPadding: 65,
          ),
          Center(
              child: SizedBox(
                  height: 200,
                  width: 200,
                  child: TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 500),
                      tween: Tween<double>(
                        begin: 0.00,
                        end: _progress,
                      ),
                      builder:
                          (BuildContext context, double? value, Widget? child) {
                        return CircularProgressIndicator(
                          value: value,
                          color: EnvoyColors.white80,
                          strokeCap: StrokeCap.round,
                          strokeWidth: 5,
                        );
                      })))
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller, BuildContext context) {
    setState(() {
      this.controller = controller;
    });

    widget.decoder.onProgressUpdates(
      (progress) {
        if (mounted) {
          setState(() {
            _progress = progress;
          });
        }
      },
    );

    _qrStreamSubscription =
        controller.scannedDataStream.listen((barcode) async {
      if ((barcode.code != null && barcode.code != _lastCodeDetected) ||
          (barcode.rawBytes != null &&
              barcode.rawBytes != _lastRawBytesDetected)) {
        _lastCodeDetected = barcode.code!;
        _lastRawBytesDetected = barcode.rawBytes;
        //if the code is the same no need to re-validate
        if (_lastScan == barcode.code) {
          return;
        }
      }

      try {
        await widget.decoder.onDetectBarCode(barcode);
      } catch (e) {
        if (context.mounted) {
          EnvoyToast(
            replaceExisting: true,
            message: e.toString(),
            actionButtonText: S().component_retry,
            isDismissible: false,
            onActionTap: () {
              EnvoyToast.dismissPreviousToasts(context);
              setState(() {
                _lastScan = "";
                _progress = 0;
                _lastCodeDetected = "";
                _lastRawBytesDetected = [];
              });
            },
            icon: const Icon(
              Icons.info_outline,
              color: EnvoyColors.white95,
            ),
          ).show(context);
        }
      } finally {
        _lastScan = barcode.code ?? '';
      }
    });
    // ENV-252: hack to get camera on CalyxOS
    if (Platform.isAndroid) {
      controller.pauseCamera();
      controller.resumeCamera();
    }
  }

  // Fix hot reload
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    }
    controller?.resumeCamera();
  }

  @override
  void dispose() {
    _qrStreamSubscription?.cancel();
    controller?.dispose();
    super.dispose();
  }
}

class ViewFinder extends StatelessWidget {
  const ViewFinder({super.key});

  @override
  Widget build(BuildContext context) {
    final stroke = Padding(
        padding: const EdgeInsets.all(65),
        child: SvgPicture.asset("assets/viewfinder_stroke.svg"));
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          stroke,
          RotatedBox(
            quarterTurns: 1,
            child: stroke,
          )
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RotatedBox(
            quarterTurns: 3,
            child: stroke,
          ),
          RotatedBox(
            quarterTurns: 2,
            child: stroke,
          )
        ],
      ),
    ]);
  }
}

class AnimatedQrViewfinder extends StatefulWidget {
  final double size;
  final double strokeWidth;
  final Color strokeColor;
  final double cornerPadding;
  final Duration animationDuration;

  const AnimatedQrViewfinder({
    super.key,
    this.size = 280.0,
    this.strokeWidth = 4.0,
    this.strokeColor = Colors.white,
    this.cornerPadding = 65.0,
    this.animationDuration = const Duration(milliseconds: 1500),
  });

  @override
  State<AnimatedQrViewfinder> createState() => _AnimatedQrViewfinderState();
}

class _AnimatedQrViewfinderState extends State<AnimatedQrViewfinder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.98,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: const ViewFinder(),
          ),
        );
      },
    );
  }
}
