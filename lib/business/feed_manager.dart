// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:convert';
import 'package:envoy/business/settings.dart';
import 'package:envoy/business/video.dart';
import 'package:envoy/util/bug_report_helper.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:webfeed/webfeed.dart';
import 'package:http_tor/http_tor.dart';
import 'package:envoy/business/blog_post.dart';

class FeedManager {
  static const _clearnetFeed = 'https://foundation.xyz/feed';
  static const _onionFeed =
      'http://wmkivkyzuekkp54zhnt6jdn776xxymxs6oevzcgvbjoe5ovp2og2nlqd.onion/feed/';

  List<Video> videos = [];
  List<BlogPost> blogs = [];

  static final FeedManager _instance = FeedManager._internal();

  factory FeedManager() {
    return _instance;
  }

  static Future<FeedManager> init() async {
    var singleton = FeedManager._instance;
    return singleton;
  }

  FeedManager._internal() {
    kPrint("Instance of FeedManager created!");
    _restoreVideos();
    _restoreBlogs();

    _addVideosFromServer();

    final feedUrl = Settings().usingTor ? _onionFeed : _clearnetFeed;

    HttpTor().get(feedUrl).then((response) {
      RssFeed feed = RssFeed.parse(response.body);
      _addBlogPostsFromRssFeed(feed);
    }).catchError((error) {
      kPrint("Error fetching blog posts: $error");
      EnvoyReport().log("Feed Manager", error.toString());
    });
  }

  Future<Response> getVideoData() async {
    return await HttpTor().get("${Settings().envoyServerAddress}/videos");
  }

  Future<void> _addVideosFromServer() async {
    try {
      final response = await getVideoData();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          "Video server returned HTTP ${response.statusCode}",
        );
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final videos = data["videos"];
      if (videos is! List) {
        throw const FormatException(
          "Video server response does not contain a videos list",
        );
      }

      updateVideos(_parseVideos(videos));
    } catch (e) {
      kPrint("Error fetching videos: $e");
      EnvoyReport().log("Feed Manager", e.toString());
    }
  }

  List<Video> _parseVideos(List<dynamic> videos) {
    List<Video> currentVideos = [];

    for (var video in videos) {
      final playback = video["playback"] as Map<String, dynamic>;
      final contentMap = <int, String>{
        (playback["height"] as num).toInt(): playback["url"] as String,
      };

      final serverTags = video["tags"] as List<dynamic>;
      final tagNames = serverTags
          .map(
            (tag) => (tag as Map<String, dynamic>)["name"] as String,
          )
          .toList();

      final orderString = tagNames.firstWhere(
        (tag) => tag.contains("Order"),
        orElse: () => "",
      );
      final order = orderString.isEmpty
          ? null
          : int.tryParse(orderString.split("-").last);

      final tags = <String>[
        if (orderString.isNotEmpty) orderString,
        ...tagNames.where(
          (tag) => const [
            "Envoy",
            "Passport",
            "PassportPrime",
          ].any(tag.contains),
        ),
      ];

      currentVideos.add(
        Video(
          video["title"] as String,
          video["description"] as String?,
          (video["duration"] as num).toInt(),
          DateTime.parse(video["release_time"] as String),
          contentMap,
          video["player_url"] as String,
          video["public_url"] as String,
          null,
          order,
          tags,
          thumbnailUrl: video["thumbnail_url"] as String?,
        ),
      );
    }

    return currentVideos;
  }

  static Uri rewriteToOnionIfUsingTor(String url) {
    final originalUri = Uri.parse(url);

    // Only rewrite when we’re in Tor mode
    if (!Settings().usingTor) return originalUri;
    // only rewrite URLs that point to foundation.xyz.
    if (originalUri.host != 'foundation.xyz') return originalUri;

    final onionHost = Uri.parse(_onionFeed).host;

    return originalUri.replace(scheme: 'http', host: onionHost);
  }

  Future<void> _addBlogPostsFromRssFeed(RssFeed feed) async {
    List<BlogPost> currentBlogPosts = [];

    for (RssItem item in feed.items!) {
      String? thumbnailUrl = item.content?.images.firstOrNull;
      if (thumbnailUrl != null) {
        thumbnailUrl = rewriteToOnionIfUsingTor(thumbnailUrl).toString();
      }
      String htmlContent = item.content!.value;

      List<String> tags = [];

      if (item.categories != null) {
        // Extract category values and store them in tags
        tags.addAll(
          item.categories!.map(
            (category) => category.value.trim().toLowerCase(),
          ),
        );
      }

      List<String> filterTags = ["envoy", "passport core", "passport prime"];

      // Filter tags to include only the relevant ones
      tags = tags.where((tag) => filterTags.contains(tag)).toList();

      currentBlogPosts.add(
        BlogPost(
          item.title!,
          htmlContent, // Use the decoded HTML content
          item.pubDate!,
          item.link!,
          item.guid!,
          null,
          tags: tags,
          thumbnailUrl: thumbnailUrl,
        ),
      );
    }
    updateBlogPosts(currentBlogPosts);
  }

  void _dropVideos() {
    videos.clear();
  }

  void _dropBlogs() {
    blogs.clear();
  }

  Future<void> _restoreVideos() async {
    _dropVideos();

    var storedVideos = await EnvoyStorage().getAllVideos();
    for (var video in storedVideos!) {
      videos.add(video!);
    }
  }

  Future<void> _restoreBlogs() async {
    _dropBlogs();

    var storedBlogs = await EnvoyStorage().getAllBlogPosts();
    for (var blog in storedBlogs!) {
      blogs.add(blog!);
    }
  }

  Future<void> updateVideos(List<Video> currentVideos) async {
    for (var video in currentVideos) {
      for (var storedVideo in videos) {
        if (video.url == storedVideo.url && storedVideo.watched != null) {
          video.watched = storedVideo.watched;
        }
      }

      // This will fetch the thumbnail before we enter the Learn tab
      video.thumbnail;
    }

    videos = currentVideos;
    storeVideos();
  }

  Future<void> updateBlogPosts(List<BlogPost> currentBlogPosts) async {
    for (var blog in currentBlogPosts) {
      for (var storedBlogPosts in blogs) {
        if (blog.url == storedBlogPosts.url && storedBlogPosts.read != null) {
          blog.read = storedBlogPosts.read;
          storeBlogPosts();
        }
      }

      // This will fetch the thumbnail before we enter the Learn tab
      blog.thumbnail;
    }

    blogs = currentBlogPosts;
    storeBlogPosts();
  }

  void storeVideos() {
    for (var video in videos) {
      EnvoyStorage().insertVideo(video);
    }
  }

  void storeBlogPosts() {
    for (var blog in blogs) {
      EnvoyStorage().insertBlogPost(blog);
    }
  }
}
