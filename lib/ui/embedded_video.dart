// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class EmbeddedVideo extends StatefulWidget {
  final String path;
  final double aspectRatio;

  const EmbeddedVideo({Key? key, required this.path, this.aspectRatio = 4 / 3})
      : super(key: key);

  @override
  State<EmbeddedVideo> createState() => EmbeddedVideoState();
}

class EmbeddedVideoState extends State<EmbeddedVideo> {
  VlcPlayerController? _videoPlayerController;
  bool isPlaying = true;

  Timer? _updatePositionTimer;
  int _position = 0;
  int _duration = 3;
  bool _muted = false;

  @override
  void initState() {
    super.initState();

    _videoPlayerController = VlcPlayerController.asset(
      widget.path,
      autoInitialize: true,
      autoPlay: true,
      hwAcc: HwAcc.full,
      options: VlcPlayerOptions(),
    );

    _periodicallyUpdatePosition();
  }

  void _periodicallyUpdatePosition() {
    _updatePositionTimer =
        Timer.periodic(const Duration(seconds: 1), (_) async {
      _position = (await _videoPlayerController!.getPosition()).inSeconds;
      _duration = (await _videoPlayerController!.getDuration()).inSeconds;

      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _updatePositionTimer?.cancel();

    _videoPlayerController?.stop().then((_) {
      _videoPlayerController?.dispose();
    });
    super.dispose();
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
            child: VlcPlayer(
              controller: _videoPlayerController!,
              aspectRatio: widget.aspectRatio,
              placeholder: const Center(child: CircularProgressIndicator()),
            ),
          ),
        ),
        Positioned.fill(
          child: GestureDetector(
            onTap: () async {
              await _replay();
            },
            child: Align(
              alignment: Alignment.center,
              child: AnimatedOpacity(
                  opacity: _position >= _duration - 1 ? 1.0 : 0.0,
                  duration: const Duration(seconds: 1),
                  child: const Icon(
                    Icons.replay,
                    size: 60,
                    color: Colors.white,
                  )),
            ),
          ),
        ),
        Align(
          child: Material(
            color: Colors.transparent,
            child: IconButton(
              color: Colors.white,
              icon: Icon(_muted ? Icons.volume_off_sharp : Icons.volume_up),
              onPressed: () async {
                setState(() {
                  _muted = !_muted;
                  if (_muted) {
                    _videoPlayerController?.setVolume(0);
                  } else {
                    _videoPlayerController?.setVolume(100);
                  }
                });
              },
            ),
          ),
          alignment: Alignment.topRight,
        )
      ],
    );
  }

  Future<void> _replay() async {
    await _videoPlayerController?.setMediaFromAsset(widget.path);
    await _videoPlayerController?.play();
  }

  Future<void> pause() async {
    await _videoPlayerController?.pause();
  }
}
