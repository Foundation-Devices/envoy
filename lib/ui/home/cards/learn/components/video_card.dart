// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:typed_data';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/business/video.dart';
import 'package:envoy/ui/home/cards/learn/video_player.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const double videoImageHeight = 172.0;
const double videoContainerWidth = 309.0;
const double videoInfoHeight = 60.0;

class VideoCard extends ConsumerStatefulWidget {
  final Video video;

  const VideoCard({
    Key? key,
    required this.video,
  }) : super(key: key);

  @override
  ConsumerState<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends ConsumerState<VideoCard> {
  bool _isVideoWatched = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    EnvoyStorage().isVideoWatched(widget.video.id).listen((watched) {
      if (!_isDisposed) {
        setState(() {
          _isVideoWatched = watched;
        });
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  _playBitcoinTvVideo(Video video) async {
    Navigator.of(context).push(
        PageRouteBuilder(pageBuilder: (context, animation, secondAnimation) {
      return FullScreenVideoPlayer(video, key: UniqueKey());
    }, transitionsBuilder: (context, animation, anotherAnimation, child) {
      animation = CurvedAnimation(curve: Curves.linear, parent: animation);
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(EnvoySpacing.medium1)),
      child: SizedBox(
        width: videoContainerWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                _playBitcoinTvVideo(widget.video);
                widget.video.watched = true;
                EnvoyStorage().updateVideo(widget.video);
              },
              onLongPress: () {
                widget.video.watched = false;
                EnvoyStorage().updateVideo(widget.video);
              },
              child: Stack(children: [
                widget.video.thumbnail == null
                    ? Container(
                        height: videoImageHeight,
                        child: Center(
                            child: Icon(
                          Icons.play_arrow,
                          color: EnvoyColors.textPrimaryInverse,
                          size: 40,
                        )),
                      )
                    : Container(
                        height: videoImageHeight,
                        width: videoContainerWidth,
                        child: Image.memory(
                          Uint8List.fromList(widget.video.thumbnail!),
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(
                          Radius.circular(EnvoySpacing.medium1)),
                      child: Container(
                        height: 50,
                        width: 70,
                        color: EnvoyColors.textPrimary.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: EnvoyColors.textPrimaryInverse,
                      size: 40,
                    ),
                  ),
                ),
                _isVideoWatched
                    ? Positioned.fill(
                        child: Container(
                          color:
                              EnvoyColors.textPrimaryInverse.withOpacity(0.5),
                        ),
                      )
                    : SizedBox(),
              ]),
            ),
            Container(
              height: videoInfoHeight,
              width: videoContainerWidth,
              color: EnvoyColors.surface2,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: EnvoySpacing.medium1,
                  vertical: EnvoySpacing.small,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Text(
                        widget.video.title,
                        style: EnvoyTypography.body2Semibold
                            .copyWith(color: EnvoyColors.textPrimary),
                      ),
                    ),
                    SizedBox(height: EnvoySpacing.xs),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            (widget.video.duration / 60).toStringAsFixed(0) +
                                ":" +
                                (widget.video.duration % 60)
                                    .toString()
                                    .padLeft(2, '0'),
                            style: EnvoyTypography.caption1Medium
                                .copyWith(color: EnvoyColors.textSecondary),
                          ),
                          _isVideoWatched
                              ? Text(
                                  "Watched",
                                  style: EnvoyTypography.caption1Medium
                                      .copyWith(
                                          color: EnvoyColors.textSecondary),
                                )
                              : Text("")
                        ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
