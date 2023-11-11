// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:json_annotation/json_annotation.dart';
import 'package:envoy/business/media.dart';

// Generated
part 'video.g.dart';

@JsonSerializable()
class Video extends Media {
  final int duration;
  final Map<int, String> resolutionLinkMap;
  bool? watched;
  final int? order;
  final List<String>? tags;

  Video(
      String title,
      String? description,
      this.duration,
      DateTime publicationDate,
      this.resolutionLinkMap,
      String url,
      String id,
      this.watched,
      this.order,
      this.tags,
      {String? thumbnailUrl})
      : super(title, description, thumbnailUrl, publicationDate, url, id);

  // Generated
  factory Video.fromJson(Map<String, dynamic> json) => _$VideoFromJson(json);

  Map<String, dynamic> toJson() => _$VideoToJson(this);
}
