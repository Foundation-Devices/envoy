// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'package:envoy/business/local_storage.dart';
import 'package:envoy/business/video.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:tor/tor.dart';
import 'package:webfeed/webfeed.dart';
import 'package:http_tor/http_tor.dart';
import 'package:envoy/business/blog_post.dart';

class FeedManager {
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
    print("Instance of FeedManager created!");
    _restoreVideos();
    _restoreBlogs();

    HttpTor(Tor.instance)
        .get("https://bitcointv.com/feeds/videos.xml?videoChannelId=62")
        // .get(
        //     "https://www.youtube.com/feeds/videos.xml?channel_id=UC3UcWMQ53oimbVxGJUnRXGw")
        .then((response) {
      RssFeed feed = RssFeed.parse(response.body);
      _addVideosFromBitcoinTv(feed);
    });

    HttpTor(Tor.instance)
        .get("https://foundationdevices.com/feed/")
        .then((response) {
      RssFeed feed = RssFeed.parse(response.body);
      _addBlogPostsFromRssFeed(feed);
    });
  }

  _dropVideos() {
    videos.clear();
  }

  _dropBlogs() {
    blogs.clear();
  }

  _restoreVideos() async {
    _dropVideos();

    var storedVideos = await EnvoyStorage().getAllVideos();
    for (var video in storedVideos!) {
      videos.add(video!);
    }
  }

  _restoreBlogs() async {
    _dropBlogs();

    var storedBlogs = await EnvoyStorage().getAllBlogPosts();
    for (var blog in storedBlogs!) {
      blogs.add(blog!);
    }
  }

  _addVideosFromBitcoinTv(RssFeed feed) async {
    List<Video> currentVideos = [];

    for (RssItem item in feed.items!) {
      var thumbnailUrl = item.media!.thumbnails![0].url!;

      Map<int, String> contentMap = {};
      for (var content in item.media!.group!.contents!) {
        if (content.height != null) {
          contentMap[content.height!] = content.url!;
        }
      }

      currentVideos.add(Video(
        VideoType.bitcoinTv,
        item.title!,
        item.content?.value,
        item.media!.group!.contents![0].duration!,
        item.pubDate!,
        contentMap,
        item.link!,
        item.guid!,
        null,
        thumbnailUrl: thumbnailUrl,
      ));
    }

    updateVideos(currentVideos);
  }

  _addBlogPostsFromRssFeed(RssFeed feed) async {
    List<BlogPost> currentBlogPosts = [];

    for (RssItem item in feed.items!) {
      var thumbnailUrl = item.content?.images.first;
      String htmlContent = item.content!.value;

      currentBlogPosts.add(BlogPost(
        item.title!,
        htmlContent, // Use the decoded HTML content
        item.pubDate!,
        item.link!,
        item.guid!,
        null,
        thumbnailUrl: thumbnailUrl,
      ));
    }
    updateBlogPosts(currentBlogPosts);
  }

  updateVideos(List<Video> currentVideos) async {
    for (var video in currentVideos) {
      for (var storedVideo in videos) {
        if (video.url == storedVideo.url && storedVideo.watched != null) {
          video.watched = storedVideo.watched;
        }
      }

      if (await video.thumbnail == null) {
        HttpTor(Tor.instance).get(video.thumbnailUrl!).then((response) async {
          await LocalStorage()
              .saveFileBytes(video.thumbnailHash!, response.bodyBytes);
        });
      }
    }

    videos = currentVideos;
    storeVideos();
  }

  updateBlogPosts(List<BlogPost> currentBlogPosts) async {
    for (var blog in currentBlogPosts) {
      for (var storedBlogPosts in blogs) {
        if (blog.url == storedBlogPosts.url && storedBlogPosts.read != null) {
          blog.read = storedBlogPosts.read;
          storeBlogPosts();
        }
      }

      if (await blog.thumbnail == null) {
        HttpTor(Tor.instance).get(blog.thumbnailUrl!).then((response) async {
          await LocalStorage().saveFileBytes(blog.thumbnailHash!, response.bodyBytes);
        });
      }
    }

    blogs = currentBlogPosts;
    storeBlogPosts();
  }

  storeVideos() {
    for (var video in videos) {
      EnvoyStorage().insertVideo(video);
    }
  }

  storeBlogPosts() {
    for (var BlogPost in blogs) {
      EnvoyStorage().insertBlogPost(BlogPost);
    }
  }
}
