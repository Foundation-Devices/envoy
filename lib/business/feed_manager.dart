// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:convert';
import 'package:envoy/business/local_storage.dart';
import 'package:envoy/business/venue.dart';
import 'package:envoy/business/video.dart';
import 'package:envoy/util/console.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:tor/tor.dart';
import 'package:webfeed/webfeed.dart';
import 'package:http_tor/http_tor.dart';
import 'package:envoy/business/blog_post.dart';
import 'package:envoy/business/scheduler.dart';

class FeedManager {
  static const vimeoToken = "141c53cdd50a0285e03885dc6f444f9a";
  static const vimeoAccountId = "210701027";

  List<Video> videos = [];
  List<BlogPost> blogs = [];
  List<Venue> venues = [];

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
    _restoreVenues();

    _addVideosFromVimeo();

    addVenues();

    HttpTor(Tor.instance, EnvoyScheduler().parallel)
        .get("https://foundationdevices.com/feed/")
        .then((response) {
      RssFeed feed = RssFeed.parse(response.body);
      _addBlogPostsFromRssFeed(feed);
    });
  }

  Future<Response> _getVimeoData(
      {int videosPerPage = 100, int page = 1}) async {
    String videoPerPageString = "?per_page=$videosPerPage";
    String pageString = "&page=$page";

    return await HttpTor(Tor.instance, EnvoyScheduler().parallel).get(
      "https://api.vimeo.com/users/$vimeoAccountId/videos$videoPerPageString$pageString",
      headers: {'authorization': "bearer $vimeoToken"},
    );
  }

  _addVideosFromVimeo() async {
    List<Video> currentVideos = [];

    final response = await _getVimeoData();

    final data = json.decode(response.body);
    final videos = (data['data'] as List);

    final lastPage = data["paging"]["last"];
    var lastNum = int.parse(lastPage[lastPage.length - 1]);

    currentVideos.addAll(_parseVideos(videos));

    if (lastNum > 1) {
      for (var i = 2; i <= lastNum; i++) {
        var response = await _getVimeoData(
          page: i,
        );

        final data = json.decode(response.body);
        final videos = (data['data'] as List);

        currentVideos.addAll(_parseVideos(videos));
      }
    }

    updateVideos(currentVideos);
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

  _dropVideos() {
    videos.clear();
  }

  _dropBlogs() {
    blogs.clear();
  }

  _dropVenues() {
    venues.clear();
  }

  _restoreVideos() async {
    _dropVideos();

    var storedVideos = await EnvoyStorage().getAllVideos();
    for (var video in storedVideos!) {
      videos.add(video!);
    }
  }

  _restoreVenues() async {
    _dropVenues();

    var storedVenues = await EnvoyStorage().getAllLocations();
    for (var venue in storedVenues!) {
      venues.add(venue!);
    }
  }

  _restoreBlogs() async {
    _dropBlogs();

    var storedBlogs = await EnvoyStorage().getAllBlogPosts();
    for (var blog in storedBlogs!) {
      blogs.add(blog!);
    }
  }

  updateVideos(List<Video> currentVideos) async {
    for (var video in currentVideos) {
      for (var storedVideo in videos) {
        if (video.url == storedVideo.url && storedVideo.watched != null) {
          video.watched = storedVideo.watched;
        }
      }

      final thumbnail = await video.thumbnail;
      if (thumbnail == null || thumbnail.isEmpty) {
        _getVideoThumbnail(video);
      }
    }

    videos = currentVideos;
    storeVideos();
  }

  void _getVideoThumbnail(Video video) {
    HttpTor(Tor.instance, EnvoyScheduler().parallel)
        .get(video.thumbnailUrl!)
        .then((response) async {
      await LocalStorage()
          .saveFileBytes(video.thumbnailHash!, response.bodyBytes);
    });
  }

  updateBlogPosts(List<BlogPost> currentBlogPosts) async {
    for (var blog in currentBlogPosts) {
      for (var storedBlogPosts in blogs) {
        if (blog.url == storedBlogPosts.url && storedBlogPosts.read != null) {
          blog.read = storedBlogPosts.read;
          storeBlogPosts();
        }
      }

      final thumbnail = await blog.thumbnail;
      if (thumbnail == null || thumbnail.isEmpty) {
        _getBlogThumbnail(blog);
      }
    }

    blogs = currentBlogPosts;
    storeBlogPosts();
  }

  void _getBlogThumbnail(BlogPost blog) {
    HttpTor(Tor.instance, EnvoyScheduler().parallel)
        .get(blog.thumbnailUrl!)
        .then((response) async {
      await LocalStorage()
          .saveFileBytes(blog.thumbnailHash!, response.bodyBytes);
    });
  }

  storeVideos() {
    for (var video in videos) {
      EnvoyStorage().insertVideo(video);
    }
  }

  storeVenues() async {
    for (var venue in venues) {
      var storedVenue = await EnvoyStorage().getLocationById(venue.id);
      if (storedVenue != null) {
        if (storedVenue.name != venue.name ||
            storedVenue.lon != venue.lon ||
            storedVenue.lat != venue.lat) {
          EnvoyStorage().updateLocation(venue);
        }
      } else {
        EnvoyStorage().insertLocation(venue);
      }
    }
  }

  storeBlogPosts() {
    for (var blog in blogs) {
      EnvoyStorage().insertBlogPost(blog);
    }
  }

  addVenues() async {
    final response = await HttpTor(Tor.instance, EnvoyScheduler().parallel).get(
      "https://coinmap.org/api/v1/venues/?category=atm",
    ); // fetch only atms

    final data = json.decode(response.body);
    List myVenues = data["venues"];

    List<Venue> updatedVenues = [];
    for (var venue in myVenues) {
      final id = venue["id"];
      final double lat = venue["lat"];
      final double lon = venue["lon"];
      final String category = venue["category"];
      final String name = venue["name"];
      final myVenue = Venue(id, lat, lon, category, name);
      updatedVenues.add(myVenue);
    }
    venues = updatedVenues;

    if (updatedVenues.isNotEmpty) storeVenues();
  }

  List<Venue> getLocallyVenues(
      double radius, double longitude, double latitude) {
    List<Venue> locallyVenues = [];

    for (var venue in venues) {
      final double lonDifference = (venue.lon - longitude).abs();
      final double latDifference = (venue.lat - latitude).abs();

      if (lonDifference <= radius && latDifference <= radius) {
        locallyVenues.add(venue);
      }
    }

    return locallyVenues;
  }
}
