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
  static const vimeoToken = "141c53cdd50a0285e03885dc6f444f9a";
  static const vimeoAccountId = "210701027";

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

    _addVideosFromVimeo();

    final feedUrl = Settings().usingTor ? _onionFeed : _clearnetFeed;

    HttpTor().get(feedUrl).then((response) {
      RssFeed feed = RssFeed.parse(response.body);
      _addBlogPostsFromRssFeed(feed);
    }).catchError((error) {
      kPrint("Error fetching blog posts: $error");
      EnvoyReport().log("Feed Manager", error.toString());
    });
  }

  Future<Response> getVimeoData({int videosPerPage = 100, int page = 1}) async {
    String videoPerPageString = "?per_page=$videosPerPage";
    String pageString = "&page=$page";

    return await HttpTor().get(
      "https://api.vimeo.com/users/$vimeoAccountId/videos$videoPerPageString$pageString",
      headers: {'authorization': "bearer $vimeoToken"},
    );
  }

  Future<void> _addVideosFromVimeo() async {
    try {
      List<Video> currentVideos = [];

      final response = await getVimeoData();

      final data = json.decode(response.body);
      final videos = (data['data'] as List);

      final lastPage = data["paging"]["last"];
      var lastNum = int.parse(lastPage[lastPage.length - 1]);

      currentVideos.addAll(_parseVideos(videos));

      if (lastNum > 1) {
        for (var i = 2; i <= lastNum; i++) {
          var response = await getVimeoData(
            page: i,
          );

          final data = json.decode(response.body);
          final videos = (data['data'] as List);

          currentVideos.addAll(_parseVideos(videos));
        }
      }
      updateVideos(currentVideos);
    } catch (e) {
      kPrint("Error fetching Vimeo videos: $e");
      EnvoyReport().log("Feed Manager", e.toString());
    }
  }

  List<Video> _parseVideos(List<dynamic> videos) {
    List<Video> currentVideos = [];

    for (var video in videos) {
      var downloads = video["download"];

      Map<int, String> contentMap = {};

      for (var content in downloads) {
        contentMap[content['height']] = content["link"];
      }

      String orderString = "";

      List<String>? tags = [];

      var vimeoTags = video["tags"];

      if (vimeoTags.length >= 1) {
        Map<String, dynamic>? orderTag = vimeoTags.singleWhere(
            (element) => element["name"].toString().contains("Order"),
            orElse: () => null);

        orderString = orderTag?["tag"] ?? "";
      }

      tags.add(orderString);

      int? order = orderString.isEmpty
          ? null
          : int.tryParse(orderString.split('-').last);

      // Extract additional tags
      List<String> filterTags = [
        "Envoy",
        "Passport",
        "PassportPrime",
      ];

      for (var tag in vimeoTags) {
        String tagName = tag["name"].toString();
        if (filterTags.any((relevantTag) => tagName.contains(relevantTag))) {
          tags.add(tagName);
        }
      }

      currentVideos.add(Video(
        video["name"],
        video["description"],
        video["duration"],
        DateTime.parse(video["release_time"]),
        contentMap,
        video["player_embed_url"],
        video["link"],
        null,
        order,
        tags,
        thumbnailUrl: (video["pictures"])["sizes"][3]["link"],
      ));
    }

    return currentVideos;
  }

  static Uri _rewriteToOnionIfUsingTor(String url) {
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
        thumbnailUrl = _rewriteToOnionIfUsingTor(thumbnailUrl).toString();
      }
      String htmlContent = item.content!.value;

      List<String> tags = [];

      if (item.categories != null) {
        // Extract category values and store them in tags
        tags.addAll(item.categories!
            .map((category) => category.value.trim().toLowerCase()));
      }

      List<String> filterTags = [
        "envoy",
        "passport core",
        "passport prime",
      ];

      // Filter tags to include only the relevant ones
      tags = tags.where((tag) => filterTags.contains(tag)).toList();

      currentBlogPosts.add(BlogPost(
        item.title!,
        htmlContent, // Use the decoded HTML content
        item.pubDate!,
        item.link!,
        item.guid!,
        null,
        tags: tags,
        thumbnailUrl: thumbnailUrl,
      ));
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
