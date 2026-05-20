// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:io';

import 'package:envoy/business/connectivity_manager.dart';
import 'package:envoy/business/video.dart';
import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http_tor/http_tor.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart' as vp;
import 'package:wakelock_plus/wakelock_plus.dart';

class FullScreenVideoPlayer extends StatefulWidget {
  final Video video;

  const FullScreenVideoPlayer(this.video, {super.key});

  @override
  State<FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer>
    with SingleTickerProviderStateMixin {
  static const _downloadUiUpdateInterval = Duration(milliseconds: 120);

  vp.VideoPlayerController? _controller;
  late Future<void> _initializeVideoPlayerFuture;
  File? _streamFile;
  bool _showTorExplainer = false;
  bool _isPlaying = true;
  late final AnimationController _playPauseIconController;

  final int _playThreshold = 1000000; // Download 1MB before trying playback.
  final int _desiredResolution = 540;

  double _playerProgress = 0;

  bool _visibleTimeline = false;

  // Dart linter is reporting a false positive here
  // https://github.com/dart-lang/linter/issues/1381
  // Subscription is closed on widget disposal
  //ignore: cancel_subscriptions
  StreamSubscription? _downloadProgressSubscription;
  double _downloadProgressRaw = 0; // latest raw completion [0..1]
  double _downloadProgressUi = 0; // throttled UI progress [0..1]
  DateTime? _lastDownloadUiUpdateAt;

  static const _isMaestroTest =
      bool.fromEnvironment('IS_MAESTRO_TEST', defaultValue: false);
  Timer? _updatePositionTimer;
  Timer? _hideTopBarTimer;
  Timer? _showTimelineTimer;

  void Function()? _cancelDownload;
  bool _curtains = false;
  bool _playerExited = false;
  bool _isClosing = false;

  bool get _isWaitingForPendingSeek => false;

  double _metadataDurationSeconds() {
    return widget.video.duration <= 0 ? 1.0 : widget.video.duration.toDouble();
  }

  void _updateDownloadProgress(double completion, {bool force = false}) {
    final progress = completion.clamp(0, 1).toDouble();
    _downloadProgressRaw = progress;

    final now = DateTime.now();
    final shouldRebuild = force ||
        _lastDownloadUiUpdateAt == null ||
        now.difference(_lastDownloadUiUpdateAt!) >= _downloadUiUpdateInterval ||
        (progress - _downloadProgressUi).abs() >= 0.02;

    if (!shouldRebuild || !mounted || _playerExited) {
      return;
    }

    _lastDownloadUiUpdateAt = now;
    setState(() {
      _downloadProgressUi = progress;
    });
  }

  /// Get download link with optimal resolution
  String _getDownloadLink() {
    final resolutionLinkMap = widget.video.resolutionLinkMap;
    final List<int> availableResolutions = resolutionLinkMap.keys.toList()
      ..sort();
    if (availableResolutions.contains(_desiredResolution)) {
      return resolutionLinkMap[_desiredResolution]!;
    }

    try {
      final int greater = availableResolutions.firstWhere(
        (e) => e > _desiredResolution,
      );
      return resolutionLinkMap[greater]!;
    } catch (_) {
      return resolutionLinkMap[availableResolutions.last]!;
    }
  }

  @override
  void initState() {
    super.initState();
    _playPauseIconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      value: 1.0,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _playerExited) {
        return;
      }
      setFullScreenLandscapeMode();

      final torEnabled = ConnectivityManager().torEnabled;
      if (!mounted || _playerExited) {
        return;
      }
      setState(() {
        _showTorExplainer = torEnabled;
      });
    });
    final Completer<void> completer = Completer<void>();

    getApplicationCacheDirectory().then((dir) async {
      final streamFile = File(
        '${dir.path}/stream_${DateTime.now().microsecondsSinceEpoch}.mp4',
      );
      _streamFile = streamFile;
      final download = await HttpTor().getFile(
        streamFile.path,
        _getDownloadLink(),
      );

      if (_playerExited) {
        download.cancel();
        return;
      }

      _cancelDownload = download.cancel;
      _downloadProgressSubscription =
          download.progress.listen((progress) async {
        if (!mounted || _playerExited) {
          return;
        }

        final double completion = progress.total == BigInt.zero
            ? 0
            : (progress.downloaded.toDouble() / progress.total.toDouble())
                .clamp(0, 1)
                .toDouble();
        _updateDownloadProgress(completion, force: completion == 1);

        // Start playback once there is enough local buffer for smoother startup.
        if ((progress.downloaded.toInt() > _playThreshold ||
                progress.downloaded >= progress.total) &&
            _controller == null) {
          final controller = vp.VideoPlayerController.file(
            streamFile,
            videoPlayerOptions: vp.VideoPlayerOptions(
              allowBackgroundPlayback: false,
            ),
          );

          _controller = controller;
          _initializeVideoPlayerFuture =
              controller.initialize().then((_) async {
            await _onControllerInitialized(controller);
          });

          if (!completer.isCompleted) {
            completer.complete(_initializeVideoPlayerFuture);
          }
        }
      }, onError: (Object error, StackTrace stackTrace) {
        if (!completer.isCompleted) {
          completer.completeError(error, stackTrace);
        }
      });
    }).catchError((Object error, StackTrace stackTrace) {
      if (!completer.isCompleted) {
        completer.completeError(error, stackTrace);
      }
    });

    _initializeVideoPlayerFuture = completer.future;
  }

  Future<void> _onControllerInitialized(
      vp.VideoPlayerController controller) async {
    if (_playerExited) {
      return;
    }

    await controller.play();
    if (!mounted || _playerExited) {
      return;
    }

    setState(() {
      _isPlaying = controller.value.isPlaying;
      _playerProgress = controller.value.position.inSeconds.toDouble();
    });
    _syncPlayPauseIcon(_isPlaying, animated: false);

    periodicallyUpdatePosition();
    showTimeline();
    periodicallyHideBar();
  }

  void showTimeline() {
    if (!mounted || _playerExited) {
      return;
    }

    _showTimelineTimer?.cancel();

    if (!_visibleTimeline) {
      setState(() {
        _visibleTimeline = true;
      });
    }

    _showTimelineTimer = Timer(
      Duration(seconds: _isMaestroTest ? 20 : 5),
      () {
        if (mounted && !_playerExited) {
          setState(() {
            _visibleTimeline = false;
          });
        }
      },
    );
  }

  Future<void> restoreSystemUIOverlays() async {
    await SystemChannels.platform.invokeMethod<void>(
      'SystemChrome.restoreSystemUIOverlays',
    );
  }

  void setFullScreenLandscapeMode() {
    // Keep the screen on
    WakelockPlus.enable();

    if (_isMaestroTest) {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: const [SystemUiOverlay.top, SystemUiOverlay.bottom],
      );
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    }
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  void periodicallyUpdatePosition() {
    _updatePositionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final controller = _controller;
      if (!mounted || _playerExited || controller == null) {
        return;
      }
      final value = controller.value;
      if (!value.isInitialized) {
        return;
      }

      final previousIsPlaying = _isPlaying;
      setState(() {
        _playerProgress = value.position.inSeconds.toDouble();
        _isPlaying = value.isPlaying;
      });
      if (previousIsPlaying != _isPlaying) {
        _syncPlayPauseIcon(_isPlaying);
      }
    });
  }

  void periodicallyHideBar() {
    _hideTopBarTimer =
        Timer.periodic(Duration(seconds: _isMaestroTest ? 15 : 5), (_) async {
      restoreSystemUIOverlays();
    });
  }

  @override
  void dispose() {
    _playPauseIconController.dispose();
    unawaited(exitPlayer());
    final streamFile = _streamFile;
    if (streamFile != null) {
      unawaited(streamFile.delete());
    }
    super.dispose();
  }

  void setPortraitMode() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
  }

  Future<void> _togglePlayPause() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      await controller.play();
    }

    if (!mounted || _playerExited) {
      return;
    }

    setState(() {
      _isPlaying = controller.value.isPlaying;
    });
    _syncPlayPauseIcon(_isPlaying);
  }

  Future<void> _handleSeekRequest(double newValue) async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    final maxDuration = _metadataDurationSeconds();
    final clampedSeconds = newValue.clamp(0, maxDuration).toDouble();
    final targetProgress =
        (clampedSeconds / maxDuration).clamp(0, 1).toDouble();

    if (_downloadProgressRaw + 1e-6 >= targetProgress) {
      await controller.seekTo(
        Duration(milliseconds: (clampedSeconds * 1000).round()),
      );
      if (!mounted || _playerExited) {
        return;
      }
      setState(() {
        _playerProgress = clampedSeconds;
      });
      return;
    }

    final currentSeconds = controller.value.position.inSeconds.toDouble();
    if (!mounted || _playerExited) {
      return;
    }
    setState(() {
      _playerProgress = currentSeconds;
      _isPlaying = controller.value.isPlaying;
    });
    _syncPlayPauseIcon(_isPlaying);
  }

  void _syncPlayPauseIcon(bool isPlaying, {bool animated = true}) {
    if (animated) {
      if (isPlaying) {
        unawaited(_playPauseIconController.forward());
      } else {
        unawaited(_playPauseIconController.reverse());
      }
      return;
    }
    _playPauseIconController.value = isPlaying ? 1.0 : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, __) async {
        if (didPop) {
          await exitPlayer();
          return;
        }
        if (_isClosing || !mounted) {
          return;
        }
        await _closeAndPop();
      },
      child: Material(
        color: Colors.black,
        child: Stack(
          children: [
            FutureBuilder(
                future: _initializeVideoPlayerFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.white70,
                            size: 52,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Unable to load video',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    );
                  }

                  final controller = _controller;
                  final initialized =
                      snapshot.connectionState == ConnectionState.done &&
                          controller != null &&
                          controller.value.isInitialized;
                  if (initialized) {
                    // Keep slider range stable by using metadata duration.
                    final maxDuration = _metadataDurationSeconds();
                    final sliderValue =
                        _playerProgress.clamp(0, maxDuration).toDouble();

                    return Stack(
                      children: [
                        InteractiveViewer(
                          maxScale: 2.5,
                          minScale: .5,
                          child: Center(
                            child: AspectRatio(
                              aspectRatio: controller.value.aspectRatio > 0
                                  ? controller.value.aspectRatio
                                  : 16 / 9,
                              child: vp.VideoPlayer(controller),
                            ),
                          ),
                        ),
                        Center(
                          child: !_isWaitingForPendingSeek
                              ? AnimatedOpacity(
                                  duration: const Duration(milliseconds: 180),
                                  opacity: _isPlaying ? 0.0 : 1.0,
                                  child: AnimatedIcon(
                                    icon: AnimatedIcons.play_pause,
                                    progress: _playPauseIconController,
                                    color: Colors.white,
                                    size: 100.0,
                                    semanticLabel:
                                        _isPlaying ? 'Pause' : 'Play',
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        if (_isWaitingForPendingSeek)
                          const Positioned.fill(
                            child: IgnorePointer(
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onTap: () {
                              showTimeline();
                            },
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 100,
                          bottom: 100,
                          child: GestureDetector(
                            onTap: () async {
                              await _togglePlayPause();
                              showTimeline();
                            },
                          ),
                        ),
                        if (_visibleTimeline)
                          Positioned(
                            bottom: 20,
                            left: 20,
                            right: 20,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 25.0,
                                  ),
                                  child: LinearProgressIndicator(
                                    color: Colors.white70,
                                    backgroundColor: Colors.grey,
                                    value: _downloadProgressUi,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                                Slider(
                                  allowedInteraction:
                                      SliderInteraction.tapAndSlide,
                                  activeColor: EnvoyColors.darkTeal,
                                  inactiveColor: Colors.transparent,
                                  min: 0,
                                  value: sliderValue,
                                  max: maxDuration,
                                  onChanged: (value) {
                                    setState(() {
                                      _playerProgress = value;
                                    });
                                  },
                                  onChangeEnd: (double newValue) async {
                                    await _handleSeekRequest(newValue);
                                  },
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                  }

                  // If the VideoPlayerController is still initializing, show a
                  // loading spinner.
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: EnvoyColors.darkTeal,
                          value: _downloadProgressUi > 0
                              ? _downloadProgressUi
                              : null,
                        ),
                        if (ConnectivityManager().torEnabled)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 1000),
                              opacity: _showTorExplainer ? 1.0 : 0.0,
                              child: Text(
                                ConnectivityManager().torEnabled &&
                                        !ConnectivityManager()
                                            .torCircuitEstablished
                                    ? S().video_connectingToTorNetwork
                                    : S().video_loadingTorText,
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
            if (_visibleTimeline || _playerProgress == 0)
              Positioned(
                top: 20,
                left: 20,
                child: BackButton(
                  color: Colors.white,
                  onPressed: () async {
                    await _closeAndPop();
                  },
                ),
              ),
            // Black curtains
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _curtains ? 1.0 : 0.0,
                  child: Container(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _closeAndPop() async {
    if (_isClosing) {
      return;
    }

    _isClosing = true;

    await _prepareForClose();
    await exitPlayer();

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _prepareForClose() async {
    final controller = _controller;
    if (controller != null) {
      try {
        await controller.pause();
      } catch (_) {}
    }

    _updatePositionTimer?.cancel();
    _updatePositionTimer = null;
    _hideTopBarTimer?.cancel();
    _hideTopBarTimer = null;

    if (!mounted || _playerExited) {
      return;
    }

    setState(() {
      _curtains = true;
      _showTorExplainer = false;
    });
  }

  Future<void> exitPlayer() async {
    if (_playerExited) {
      return;
    }
    _playerExited = true;

    await _downloadProgressSubscription?.cancel();
    _downloadProgressSubscription = null;

    _cancelDownload?.call();
    _cancelDownload = null;

    _hideTopBarTimer?.cancel();
    _updatePositionTimer?.cancel();
    _showTimelineTimer?.cancel();
    _hideTopBarTimer = null;
    _updatePositionTimer = null;
    _showTimelineTimer = null;

    final controller = _controller;
    _controller = null;
    if (controller != null) {
      try {
        await controller.dispose();
      } catch (_) {}
    }

    setPortraitMode();
    await WakelockPlus.disable();
  }
}
