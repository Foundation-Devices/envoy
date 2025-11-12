// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:io';

import 'package:envoy/ui/envoy_colors.dart';
import 'package:envoy/ui/widgets/blur_dialog.dart';
import 'package:envoy/ui/widgets/scanner/scanner_decoder.dart';
import 'package:envoy/util/rive_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:rive/rive.dart' as rive;

bool _isScanDialogOpen = false;

Future showScannerDialog(
    {required BuildContext context,
    Widget? child,
    required Function(BuildContext context) onBackPressed,
    required ScannerDecoder decoder,
    bool showInfoDialog = false}) {
  return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return QrScanner(
          onBackPressed: onBackPressed,
          decoder: decoder,
          showInfoDialog: showInfoDialog,
          child: child,
        );
      },
      useRootNavigator: true);
}

class QrScanner extends StatefulWidget {
  final Function(BuildContext context) onBackPressed;
  final ScannerDecoder decoder;
  final Widget? child;
  final bool showInfoDialog;

  const QrScanner(
      {super.key,
      required this.onBackPressed,
      required this.decoder,
      this.child,
      this.showInfoDialog = false});

  @override
  State<QrScanner> createState() => _QrScannerState();
}

class _QrScannerState extends State<QrScanner>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey qrViewKey = GlobalKey(debugLabel: "qr_view");
  late Timer _userInteractionTimer;
  QRViewController? _controller;
  StreamSubscription? _qrStreamSubscription;
  List<int>? _lastRawBytesDetected = [];
  String _lastCodeDetected = "";
  String _lastScan = "";
  double _progress = 0.0;

  bool _viewReady = false;

  @override
  void initState() {
    _userInteractionTimer = Timer(const Duration(seconds: 8), () {
      if (mounted && widget.showInfoDialog) {
        showScanDialog(context);
        _userInteractionTimer.cancel();
      }
    });
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
    super.build(context);
    return Scaffold(
      extendBody: true,
      primary: true,
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
            }),
        actions: [
          IconButton(
              onPressed: () {
                showScanDialog(context);
              },
              icon: const Icon(Icons.info_outline, color: Colors.white54))
        ],
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.black,
          ),
          if (_viewReady)
            Positioned.fill(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 600),
                opacity: _controller != null ? 1 : 0,
                child: AnimatedScale(
                  scale: _controller != null ? 1 : 1.2,
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
                      }))),
          Consumer(
            builder: (context, ref, child) {
              ref.read(animatedQrScannerRiveProvider);
              return Container();
            },
          ),
          if (_viewReady)
            if (widget.child != null)
              Positioned.fill(
                child: widget.child!,
              )
            else
              const SizedBox(),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller, BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _controller = controller;
        });
      }
    });
    final navigator = Navigator.of(context);
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
      _userInteractionTimer.cancel();
      if (_isScanDialogOpen) {
        navigator.pop();
        _isScanDialogOpen = false;
      }
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
      } on UnableToDecodeException catch (e) {
        if (context.mounted) {
          widget.decoder.onDecodeError(
            context,
            e,
            onRetry: () {
              Navigator.pop(context); // Close popup first
              setState(() {
                _lastScan = "";
                _progress = 0;
                _lastCodeDetected = "";
                _lastRawBytesDetected = [];
              });
              controller.resumeCamera();
            },
            onCancel: () {
              Navigator.pop(context); // Close popup
              Navigator.pop(context); // Close camera
            },
          );
          controller.pauseCamera();
        }
      } catch (e) {
        if (context.mounted) {
          widget.decoder.onDecodeError(
            context,
            e as Exception,
            onRetry: () {
              setState(() {
                _lastScan = "";
                _progress = 0;
                _lastCodeDetected = "";
                _lastRawBytesDetected = [];
              });
            },
          );
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
      _controller?.pauseCamera();
    }
    _controller?.resumeCamera();
  }

  @override
  void dispose() {
    _qrStreamSubscription?.cancel();
    _userInteractionTimer.cancel();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
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

void showScanDialog(BuildContext context) async {
  if (_isScanDialogOpen) return;
  _isScanDialogOpen = true;

  if (context.mounted) {
    showEnvoyDialog(
      context: context,
      useRootNavigator: true,
      cardColor: Colors.transparent,
      dialog: const ScanInfoAnimDialog(),
      dismissible: true,
    ).then((_) {
      _isScanDialogOpen = false;
    });
  }
}

class ScanInfoAnimDialog extends StatefulWidget {
  const ScanInfoAnimDialog({super.key});

  @override
  State<ScanInfoAnimDialog> createState() => _ScanInfoAnimDialogState();
}

class _ScanInfoAnimDialogState extends State<ScanInfoAnimDialog> {
  rive.RiveWidgetController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
      },
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Consumer(builder: (context, ref, child) {
          final riveFile = ref.watch(animatedQrScannerRiveProvider);
          if (riveFile != null && _controller == null) {
            _controller = rive.RiveWidgetController(
              riveFile,
              // If you have a specific state machine, use:
              // stateMachineSelector: rive.StateMachineSelector.byName('YourStateMachineName'),
              // Or if you want to play a specific animation, use:
              // animationSelector: rive.AnimationSelector.byName(Platform.isIOS ? "ios_scan" : "android_scan"),
            );
          }

          return SizedBox(
            height: 340,
            child: riveFile != null && _controller != null
                ? rive.RiveWidget(
                    controller: _controller!,
                    fit: rive.Fit.contain,
                  )
                : const SizedBox(),
          );
        }),
      ),
    );
  }
}
