// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/generated/l10n.dart';
import 'package:envoy/ui/widgets/color_util.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:flutter/material.dart';
import 'package:envoy/ui/theme/envoy_spacing.dart';
import 'package:envoy/ui/theme/envoy_colors.dart';
import 'package:envoy/ui/theme/envoy_typography.dart';
import 'package:envoy/business/video.dart';
import 'package:envoy/ui/home/cards/learn/video_player.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const double videoImageHeight = 172.0;
const double videoContainerWidth = 309.0;
const double videoInfoHeight = 60.0;

class VideoCard extends ConsumerStatefulWidget {
  final Video video;

  const VideoCard({
    super.key,
    required this.video,
  });

  @override
  ConsumerState<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends ConsumerState<VideoCard> {
  _playVimeoVideo(Video video) async {
    await Navigator.of(context, rootNavigator: true).push(
        PageRouteBuilder(pageBuilder: (context, animation, secondAnimation) {
      return FullScreenVideoPlayer(video);
    }, transitionsBuilder: (context, animation, anotherAnimation, child) {
      animation = CurvedAnimation(curve: Curves.linear, parent: animation);
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    }));
    //make sure to reset the system ui mode after the video is closed
    //video player sometimes doesn't reset it
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  Widget build(BuildContext context) {
    final isVideoWatched =
        ref.watch(watchedVideoStreamProvider(widget.video.id)).value ?? false;
    return GestureDetector(
      onTap: () {
        _playVimeoVideo(widget.video);
        widget.video.watched = true;
        EnvoyStorage().updateVideo(widget.video);
      },
      onLongPress: () {
        widget.video.watched = false;
        EnvoyStorage().updateVideo(widget.video);
      },
      child: ClipRRect(
        borderRadius:
            const BorderRadius.all(Radius.circular(EnvoySpacing.medium1)),
        child: Stack(
          children: [
            SizedBox(
              width: videoContainerWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(children: [
                    FutureBuilder(
                        future: widget.video.thumbnail,
                        builder: (context, snapshot) {
                          return !snapshot.hasData || snapshot.data == null
                              ? const SizedBox(
                                  height: videoImageHeight,
                                  child: Center(
                                      child: Icon(
                                    Icons.play_arrow,
                                    color: EnvoyColors.textPrimaryInverse,
                                    size: 40,
                                  )),
                                )
                              : SizedBox(
                                  height: videoImageHeight,
                                  width: videoContainerWidth,
                                  child: Image.memory(
                                    Uint8List.fromList(snapshot.data!),
                                    fit: BoxFit.fitWidth,
                                  ),
                                );
                        }),
                    Positioned(
                      top: 0,
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.all(
                              Radius.circular(EnvoySpacing.medium1)),
                          child: Container(
                            height: 50,
                            width: 70,
                            color: EnvoyColors.textPrimary.applyOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                    const Positioned(
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
                  ]),
                  Container(
                    height: videoInfoHeight,
                    width: videoContainerWidth,
                    color: EnvoyColors.surface2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: EnvoySpacing.medium1,
                        vertical: EnvoySpacing.xs,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.video.title,
                            style: EnvoyTypography.button
                                .copyWith(color: EnvoyColors.textPrimary),
                            softWrap: false,
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                          ),
                          const SizedBox(height: EnvoySpacing.xs),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${(widget.video.duration / 60).toStringAsFixed(0)}:${(widget.video.duration % 60).toString().padLeft(2, '0')}",
                                  style: EnvoyTypography.info.copyWith(
                                      color: EnvoyColors.textSecondary),
                                ),
                                isVideoWatched
                                    ? Text(
                                        S().learningcenter_status_watched,
                                        style: EnvoyTypography.info.copyWith(
                                            color: EnvoyColors.textSecondary),
                                      )
                                    : const Text("")
                              ]),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isVideoWatched)
              Positioned.fill(
                child: Container(
                  color: EnvoyColors.textPrimaryInverse.applyOpacity(0.5),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
