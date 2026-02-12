// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/feed_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:envoy/business/video.dart';
import 'package:envoy/business/blog_post.dart';
import 'package:envoy/ui/home/cards/learn/filter_state.dart';

final learnVideosProvider = Provider.family<List<Video>, String?>((
  ref,
  String? searchText,
) {
  final learnFilterState = ref.watch(learnFilterStateProvider);
  final learnSortState = ref.watch(learnSortStateProvider);
  final deviceFilterState = ref.watch(deviceFilterStateProvider);
  List<Video> allVideos = FeedManager().videos;

  List<Video> videosWithTag = [];
  List<Video> videosWithoutTag = [];

  for (var video in allVideos) {
    if (video.order != null) {
      videosWithTag.add(video);
    } else {
      videosWithoutTag.add(video);
    }
  }

  switch (learnSortState) {
    case LearnSortTypes.newestFirst:
      videosWithTag.sort((v1, v2) {
        return v2.order! - v1.order!;
      });

      videosWithoutTag.sort((v1, v2) {
        return v1.publicationDate.compareTo(v2.publicationDate);
      });

      allVideos = [...videosWithoutTag, ...videosWithTag];

      break;
    case LearnSortTypes.oldestFirst:
      videosWithTag.sort((v1, v2) {
        return v1.order! - v2.order!;
      });

      videosWithoutTag.sort((v1, v2) {
        return v2.publicationDate.compareTo(v1.publicationDate);
      });

      allVideos = [...videosWithTag, ...videosWithoutTag];

      break;
  }
  if (learnFilterState.contains(LearnFilters.all) ||
      learnFilterState.contains(LearnFilters.videos) ||
      deviceFilterState.contains(DeviceFilters.all)) {
    //do nothing
  } else {
    allVideos = [];
  }

  if (learnFilterState.isEmpty || deviceFilterState.isEmpty) {
    allVideos = [];
  }

  final Map<DeviceFilters, String> deviceTagMap = {
    DeviceFilters.envoy: "Envoy",
    DeviceFilters.passport: "Passport",
    DeviceFilters.passportPrime: "PassportPrime",
  };

  if (!deviceFilterState.contains(DeviceFilters.all)) {
    allVideos = allVideos.where((video) {
      final List<String> videoTags = video.tags ?? [];

      return deviceFilterState.any((device) {
        final String expectedTag = deviceTagMap[device] ?? "";
        return videoTags.contains(expectedTag);
      });
    }).toList();
  }

  if (searchText == null || searchText == "") {
    return allVideos;
  } else {
    var videos = allVideos
        .where(
          (element) =>
              element.title.toLowerCase().contains(searchText.toLowerCase()),
        )
        .toList();
    return videos;
  }
});

final learnBlogsProvider = Provider.family<List<BlogPost>, String?>((
  ref,
  String? searchText,
) {
  final learnFilterState = ref.watch(learnFilterStateProvider);
  final learnSortState = ref.watch(learnSortStateProvider);
  final deviceFilterState = ref.watch(deviceFilterStateProvider);
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
  if (learnFilterState.contains(LearnFilters.all) ||
      learnFilterState.contains(LearnFilters.blogs) ||
      deviceFilterState.contains(DeviceFilters.all)) {
    //do nothing
  } else {
    allBlogs = [];
  }

  if (learnFilterState.isEmpty || deviceFilterState.isEmpty) {
    allBlogs = [];
  }

  final Map<DeviceFilters, String> deviceTagMap = {
    DeviceFilters.envoy: "envoy",
    DeviceFilters.passport: "passport core",
    DeviceFilters.passportPrime: "passport prime",
  };

  if (!deviceFilterState.contains(DeviceFilters.all)) {
    allBlogs = allBlogs.where((blog) {
      final List<String> blogTags = blog.tags ?? [];

      return deviceFilterState.any((device) {
        final String expectedTag = deviceTagMap[device] ?? "";
        return blogTags.contains(expectedTag);
      });
    }).toList();
  }

  if (searchText == null || searchText == "") {
    return allBlogs;
  } else {
    var blogs = allBlogs
        .where(
          (element) =>
              element.title.toLowerCase().contains(searchText.toLowerCase()),
        )
        .toList();
    return blogs;
  }
});
