// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:io';
import 'package:envoy/ui/envoy_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http_tor/http_tor.dart';
import 'package:tor/tor.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:envoy/business/video.dart';
import 'package:path_provider/path_provider.dart';
import 'package:envoy/business/connectivity_manager.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:envoy/business/scheduler.dart';
import 'package:envoy/generated/l10n.dart';

class FullScreenVideoPlayer extends StatefulWidget {
  final Video video;

  const FullScreenVideoPlayer(this.video, {super.key});

  @override
  State<FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  late final File streamFile;

  VlcPlayer? _vlcPlayer;

  VlcPlayerController? _controller;
  late Future<void> _initializeVideoPlayerFuture;

  bool _showTorExplainer = false;
  bool _isPlaying = true;

  final int _playThreshold = 2000000; // Download 2 mb before even trying
  int _downloaded = 0;

  final int _desiredResolution = 540;

  double _playerProgress = 0;

  bool _visibleTimeline = false;

  // Dart linter is reporting a false positive here
  // https://github.com/dart-lang/linter/issues/1381
  // Subscription is closed on widget disposal
  //ignore: cancel_subscriptions
  StreamSubscription? _downloadProgressSubscription;
  double _downloadProgress = 0;

  Timer? _updatePositionTimer;
  Timer? _hideTopBarTimer;
  Timer? _showTorExplainerTimer;
  Timer? _showTimelineTimer;

  void Function()? _cancelDownload;
  bool _curtains = false;

  /// Get download link with optimal resolution
  String _getDownloadLink() {
    final resolutionLinkMap = widget.video.resolutionLinkMap;
    List<int> availableResolutions = resolutionLinkMap.keys.toList()..sort();

    if (availableResolutions.contains(_desiredResolution)) {
      return resolutionLinkMap[_desiredResolution]!;
    }

    try {
      int greater =
          availableResolutions.firstWhere((e) => e > _desiredResolution);
      return resolutionLinkMap[greater]!;
    } catch (_) {
      return resolutionLinkMap[availableResolutions.last]!;
    }
  }

  @override
  void initState() {
    super.initState();

    _showTorExplainerTimer = Timer(const Duration(milliseconds: 300), () {
      setFullScreenLandscapeMode();
      if (ConnectivityManager().torEnabled) {
        setState(() {
          _showTorExplainer = true;
        });
      }
    });

    final Completer completer = Completer();

    getApplicationDocumentsDirectory().then((dir) {
      streamFile = File("${dir.path}/stream.mp4");
      HttpTor(Tor.instance, EnvoyScheduler().parallel)
          .getFile(streamFile.path, _getDownloadLink())
          .then((download) {
        _cancelDownload = download.cancel;
        _downloadProgressSubscription = download.progress.listen((progress) {
          setState(() {
            _downloadProgress = progress.downloaded / progress.total;
          });
          if (progress.downloaded > _playThreshold ||
              progress.downloaded >= progress.total) {
            if (_controller == null) {
              _controller = VlcPlayerController.file(streamFile,
                  autoInitialize: true,
                  autoPlay: true,
                  hwAcc: HwAcc.full,
                  options: VlcPlayerOptions());

              _vlcPlayer = VlcPlayer(
                controller: _controller!,
                aspectRatio: 16 / 9,
              );

              completer.complete();
              periodicallyUpdatePosition();
              showTimeline();
              periodicallyHideBar();
            }
          } else {
            // Update the loading circle
            setState(() {
              _downloaded = progress.downloaded;
            });
          }
        });
      });
    });

    _initializeVideoPlayerFuture = Future.wait([completer.future]);
  }

  void showTimeline() {
    if (!_visibleTimeline) {
      setState(() {
        _visibleTimeline = true;
      });
      _showTimelineTimer = Timer(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _visibleTimeline = false;
          });
        }
      });
    }
  }

  Future<void> restoreSystemUIOverlays() async {
    await SystemChannels.platform.invokeMethod<void>(
      'SystemChrome.restoreSystemUIOverlays',
    );
  }

  void setFullScreenLandscapeMode() {
    // Keep the screen on
    WakelockPlus.enable();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  void periodicallyUpdatePosition() {
    _updatePositionTimer =
        Timer.periodic(const Duration(seconds: 1), (_) async {
      _controller!.getPosition().then((value) {
        setState(() {
          _playerProgress = value.inSeconds.toDouble();
        });
      });
    });
  }

  void periodicallyHideBar() {
    _hideTopBarTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      restoreSystemUIOverlays();
    });
  }

  @override
  void dispose() {
    exitPlayer(context);
    super.dispose();
  }

  void setPortraitMode() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (_, __) async {
        _controller?.stop();

        setState(() {
          _curtains = true;
          _downloaded = 0;
          _showTorExplainer = false;
        });

        setPortraitMode();

        await Future.delayed(const Duration(milliseconds: 300));
      },
      child: Material(
          color: Colors.black,
          child: Stack(children: [
            FutureBuilder(
              future: _initializeVideoPlayerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Stack(children: [
                    Center(
                      child: _vlcPlayer,
                    ),
                    Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 50),
                        reverseDuration: const Duration(milliseconds: 200),
                        child: !_isPlaying
                            ? const Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 100.0,
                                semanticLabel: 'Play',
                              )
                            : const SizedBox.shrink(),
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
                        onTap: () {
                          setState(() {
                            _isPlaying
                                ? _controller!.pause()
                                : _controller!.play();
                            _isPlaying = !_isPlaying;
                          });
                          showTimeline();
                        },
                      ),
                    ),
                    if (_visibleTimeline)
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: Stack(alignment: Alignment.center, children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 25.0),
                            child: LinearProgressIndicator(
                                color: EnvoyColors.grey85,
                                backgroundColor: Colors.white,
                                value: _downloadProgress),
                          ),
                          Slider(
                            activeColor: EnvoyColors.darkTeal,
                            inactiveColor: Colors.transparent,
                            min: 0,
                            value: _playerProgress,
                            max: widget.video.duration.toDouble(),
                            onChanged: (value) {
                              setState(() {
                                _playerProgress = value;
                              });
                            },
                            onChangeEnd: (double newValue) {
                              if (_updatePositionTimer != null) {
                                _updatePositionTimer!.cancel();
                              }

                              _controller!
                                  .setMediaFromFile(streamFile,
                                      hwAcc: HwAcc.full)
                                  .then((_) {
                                Future.delayed(
                                        const Duration(milliseconds: 250))
                                    .then((_) {
                                  _controller!
                                      .setPosition(newValue /
                                          widget.video.duration.toDouble() /
                                          _downloadProgress)
                                      .then((_) {
                                    periodicallyUpdatePosition();
                                  });
                                });
                              });
                            },
                          ),
                        ]),
                      )
                  ]);
                } else {
                  // If the VideoPlayerController is still initializing, show a
                  // loading spinner.
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                            color: EnvoyColors.darkTeal,
                            value: _downloaded > 0
                                ? (_downloaded / _playThreshold)
                                : null),
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
                                    ? "Connecting to the Tor Network" // TODO: FIGMA
                                    : S().video_loadingTorText,
                                style: const TextStyle(
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }
              },
            ),
            if (_visibleTimeline || _playerProgress == 0)
              Positioned(
                  top: 20,
                  left: 20,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white70,
                    ),
                    onPressed: () async {
                      _controller?.stop();

                      setState(() {
                        _curtains = true;
                        _downloaded = 0;
                        _showTorExplainer = false;
                      });

                      setPortraitMode();

                      await Future.delayed(const Duration(milliseconds: 300));
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                  )),
            // Black curtains
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _curtains ? 1.0 : 0.0,
                  child: Container(
                    color: Colors.black,
                  ),
                ),
              ),
            )
          ])),
    );
  }

  void exitPlayer(BuildContext context) {
    _downloadProgressSubscription?.cancel();

    if (_cancelDownload != null) {
      _cancelDownload!();
    }

    if (streamFile.existsSync()) {
      streamFile.deleteSync();
    }

    _hideTopBarTimer?.cancel();
    _updatePositionTimer?.cancel();
    _showTorExplainerTimer?.cancel();
    _showTimelineTimer?.cancel();

    WakelockPlus.disable();
  }
}
