// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:json_annotation/json_annotation.dart';

// Generated
part 'blog_post.g.dart';

@JsonSerializable()
class BlogPost {
  final String title;
  final String description;
  List<int>? thumbnail;
  final String? thumbnailUrl;
  final DateTime publicationDate;
  final String url;
  final String id;
  bool? read;

  BlogPost(this.title, this.description, this.publicationDate, this.url,
      this.id, this.read,
      {this.thumbnail, this.thumbnailUrl}) {}

  // Generated
  factory BlogPost.fromJson(Map<String, dynamic> json) =>
      _$BlogPostFromJson(json);

  Map<String, dynamic> toJson() => _$BlogPostToJson(this);
}
