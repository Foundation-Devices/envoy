// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:http_tor/http_tor.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tor/tor.dart';

// Generated
part 'video.g.dart';

enum VideoType { youTube, bitcoinTv }

@JsonSerializable()
class Video {
  final VideoType type;
  final String title;
  final String? description;
  List<int>? thumbnail;
  final String? thumbnailUrl;
  final int duration;
  final DateTime publicationDate;
  final Map<int, String> resolutionLinkMap;
  final String url;
  final String id;

  String _getYouTubeThumbnailUrl() {
    return "https://img.youtube.com/vi/" + id.substring(9) + "/1.jpg";
  }

  Video(this.type, this.title, this.description, this.duration,
      this.publicationDate, this.resolutionLinkMap, this.url, this.id,
      {this.thumbnail, this.thumbnailUrl}) {
    if (type == VideoType.youTube) {
      HttpTor(Tor()).get(_getYouTubeThumbnailUrl()).then((response) {
        thumbnail = response.bodyBytes;
      });
    }
  }

  // Generated
  factory Video.fromJson(Map<String, dynamic> json) => _$VideoFromJson(json);

  Map<String, dynamic> toJson() => _$VideoToJson(this);
}
