// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class EmbeddedVideo extends StatefulWidget {
  final String path;
  final double aspectRatio;

  const EmbeddedVideo({
    super.key,
    required this.path,
    this.aspectRatio = 4 / 3,
  });

  @override
  State<EmbeddedVideo> createState() => EmbeddedVideoState();
}

class EmbeddedVideoState extends State<EmbeddedVideo> {
  late final VideoPlayerController _videoPlayerController;
  late final Future<void> _initializeVideoPlayerFuture;
  bool _showReplay = false;
  bool _muted = false;

  @override
  void initState() {
    super.initState();

    _videoPlayerController = VideoPlayerController.asset(widget.path);
    _videoPlayerController.addListener(_onVideoUpdate);
    _initializeVideoPlayerFuture =
        _videoPlayerController.initialize().then((_) {
      if (!mounted) {
        return;
      }
      _videoPlayerController.play();
    });
  }

  void _onVideoUpdate() {
    final value = _videoPlayerController.value;
    if (!mounted || !value.isInitialized) {
      return;
    }

    final showReplay = value.isCompleted;
    if (showReplay != _showReplay) {
      setState(() {
        _showReplay = showReplay;
      });
    }
  }

  @override
  void dispose() {
    _videoPlayerController
      ..removeListener(_onVideoUpdate)
      ..dispose();
    super.dispose();
  }

  Widget _player() {
    return FutureBuilder<void>(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !_videoPlayerController.value.isInitialized) {
          return const Center(child: Icon(Icons.error, color: Colors.white));
        }

        return AspectRatio(
          aspectRatio: widget.aspectRatio,
          child: VideoPlayer(_videoPlayerController),
        );
      },
    );
  }

  Future<void> _toggleMute() async {
    final muted = !_muted;
    await _videoPlayerController.setVolume(muted ? 0 : 1);
    if (!mounted) {
      return;
    }
    setState(() {
      _muted = muted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Card(
          elevation: 12,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            child: _player(),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !_showReplay,
            child: GestureDetector(
              onTap: () async {
                await _replay();
              },
              child: Align(
                alignment: Alignment.center,
                child: AnimatedOpacity(
                  opacity: _showReplay ? 1.0 : 0.0,
                  duration: const Duration(seconds: 1),
                  child:
                      const Icon(Icons.replay, size: 60, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: Material(
            color: Colors.transparent,
            child: IconButton(
              color: Colors.white,
              icon: Icon(_muted ? Icons.volume_off_sharp : Icons.volume_up),
              onPressed: () async {
                await _toggleMute();
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _replay() async {
    if (!_videoPlayerController.value.isInitialized) {
      return;
    }
    await _videoPlayerController.seekTo(Duration.zero);
    await _videoPlayerController.play();
  }

  Future<void> pause() async {
    await _videoPlayerController.pause();
  }
}
