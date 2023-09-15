// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/feed_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:envoy/business/video.dart';
import 'package:envoy/business/blog_post.dart';
import 'package:envoy/ui/home/cards/learn/filter_state.dart';

final learnVideosProvider =
    Provider.family<List<Video>, String?>((ref, String? searchText) {
  final learnFilterState = ref.watch(learnFilterStateProvider);
  final learnSortState = ref.watch(learnSortStateProvider);
  List<Video> allVideos = FeedManager().videos;

  switch (learnSortState) {
    case LearnSortTypes.newestFirst:
      allVideos.sort((v1, v2) {
        return v2.publicationDate.compareTo(v1.publicationDate);
      });
      break;
    case LearnSortTypes.oldestFirst:
      allVideos.sort((v1, v2) {
        return v1.publicationDate.compareTo(v2.publicationDate);
      });
      break;
  }
  if (learnFilterState.contains(LearnFilters.All) ||
      learnFilterState.contains(LearnFilters.Videos)) {
    //do nothing
  } else {
    allVideos = [];
  }

  if (learnFilterState.isEmpty) {
    allVideos = [];
  }
  if (searchText == null || searchText == "")
    return allVideos;
  else {
    var videos = allVideos
        .where((element) =>
            element.title.toLowerCase().contains(searchText.toLowerCase()))
        .toList();
    return videos;
  }
});

final learnBlogsProvider =
    Provider.family<List<BlogPost>, String?>((ref, String? searchText) {
  final learnFilterState = ref.watch(learnFilterStateProvider);
  final learnSortState = ref.watch(learnSortStateProvider);
  List<BlogPost> allBlogs = FeedManager().blogs;

  switch (learnSortState) {
    case LearnSortTypes.newestFirst:
      allBlogs.sort((b1, b2) {
        return b2.publicationDate.compareTo(b1.publicationDate);
      });
      break;
    case LearnSortTypes.oldestFirst:
      allBlogs.sort((b1, b2) {
        return b1.publicationDate.compareTo(b2.publicationDate);
      });
      break;
  }
  if (learnFilterState.contains(LearnFilters.All) ||
      learnFilterState.contains(LearnFilters.Blogs)) {
    //do nothing
  } else {
    allBlogs = [];
  }

  if (learnFilterState.isEmpty) {
    allBlogs = [];
  }
  if (searchText == null || searchText == "")
    return allBlogs;
  else {
    var blogs = allBlogs
        .where((element) =>
            element.title.toLowerCase().contains(searchText.toLowerCase()))
        .toList();
    return blogs;
  }
});
