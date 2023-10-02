// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:json_annotation/json_annotation.dart';

import 'media.dart';

// Generated
part 'blog_post.g.dart';

@JsonSerializable()
class BlogPost extends Media {
  bool? read;

  BlogPost(String title, String? description, DateTime publicationDate,
      String url, String id, this.read,
      {String? thumbnailUrl})
      : super(title, description, thumbnailUrl, publicationDate, url, id) {}

  // Generated
  factory BlogPost.fromJson(Map<String, dynamic> json) =>
      _$BlogPostFromJson(json);

  Map<String, dynamic> toJson() => _$BlogPostToJson(this);
}
