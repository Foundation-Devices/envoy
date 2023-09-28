// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:json_annotation/json_annotation.dart';
import 'package:envoy/business/media.dart';

// Generated
part 'video.g.dart';

enum VideoType { youTube, bitcoinTv }

@JsonSerializable()
class Video extends Media {
  final VideoType type;
  final int duration;
  final Map<int, String> resolutionLinkMap;
  bool? watched;

  Video(
      this.type,
      String title,
      String? description,
      this.duration,
      DateTime publicationDate,
      this.resolutionLinkMap,
      String url,
      String id,
      this.watched,
      {String? thumbnailUrl})
      : super(title, description, thumbnailUrl, publicationDate, url, id) {}

  // Generated
  factory Video.fromJson(Map<String, dynamic> json) => _$VideoFromJson(json);

  Map<String, dynamic> toJson() => _$VideoToJson(this);
}
