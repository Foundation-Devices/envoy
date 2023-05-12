// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class EmbeddedVideo extends StatefulWidget {
  final String path;
  const EmbeddedVideo({Key? key, required this.path}) : super(key: key);

  @override
  State<EmbeddedVideo> createState() => EmbeddedVideoState();
}

class EmbeddedVideoState extends State<EmbeddedVideo> {
  VlcPlayerController? _videoPlayerController;
  bool isPlaying = true;

  Timer? _updatePositionTimer;
  int _position = 0;
  int _duration = 3;

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
    _updatePositionTimer = Timer.periodic(Duration(seconds: 1), (_) async {
      _position = (await _videoPlayerController!.getPosition()).inSeconds;
      _duration = (await _videoPlayerController!.getDuration()).inSeconds;

      setState(() {});
    });
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _updatePositionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          child: VlcPlayer(
            controller: _videoPlayerController!,
            aspectRatio: 4 / 3,
            placeholder: Center(child: CircularProgressIndicator()),
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
                  duration: Duration(seconds: 1),
                  child: Icon(
                    Icons.replay,
                    size: 60,
                    color: Colors.white,
                  )),
            ),
          ),
        ),
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
