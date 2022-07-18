// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:convert';

import 'package:envoy/business/local_storage.dart';
import 'package:envoy/business/video.dart';
import 'package:tor/tor.dart';

import 'package:webfeed/webfeed.dart';
import 'package:http_tor/http_tor.dart';

class VideoManager {
  List<Video> videos = [];
  LocalStorage _ls = LocalStorage();

  static const String _VIDEO_PREFS = "videos";
  static final VideoManager _instance = VideoManager._internal();

  factory VideoManager() {
    return _instance;
  }

  static Future<VideoManager> init() async {
    var singleton = VideoManager._instance;
    return singleton;
  }

  VideoManager._internal() {
    print("Instance of VideoManager created!");
    _restoreVideos();

    HttpTor(Tor())
        .get("https://bitcointv.com/feeds/videos.xml?videoChannelId=62")
        // .get(
        //     "https://www.youtube.com/feeds/videos.xml?channel_id=UC3UcWMQ53oimbVxGJUnRXGw")
        .then((response) {
      RssFeed feed = RssFeed.parse(response.body);
      _addVideosFromBitcoinTv(feed);
    });
  }

  _dropVideos() {
    videos.clear();
  }

  _restoreVideos() {
    _dropVideos();
    if (_ls.prefs.containsKey(_VIDEO_PREFS)) {
      var storedVideos = jsonDecode(_ls.prefs.getString(_VIDEO_PREFS)!);
      for (var video in storedVideos) {
        videos.add(Video.fromJson(video));
      }
    }
  }

  //ignore:unused_element
  _addVideosFromYouTube(AtomFeed feed) async {
    for (AtomItem item in feed.items!) {
      Map<int, String> contentMap = {};
      for (var content in item.media!.group!.contents!) {
        if (content.height != null) {
          contentMap[content.height!] = content.url!;
        }
      }

      videos.add(Video(
          VideoType.youTube,
          item.title!,
          item.content?.toString(),
          item.media!.group!.contents![0].duration!,
          item.updated!,
          contentMap,
          item.links![0].href!,
          item.id!));
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
          thumbnail: null,
          thumbnailUrl: thumbnailUrl));
    }

    updateVideos(currentVideos);
  }

  updateVideos(List<Video> currentVideos) {
    for (var video in currentVideos) {
      for (var storedVideo in videos) {
        if (storedVideo.thumbnailUrl == video.thumbnailUrl &&
            storedVideo.thumbnail != null) {
          video.thumbnail = storedVideo.thumbnail;
        }
      }

      if (video.thumbnail == null) {
        HttpTor(Tor()).get(video.thumbnailUrl!).then((response) {
          video.thumbnail = response.bodyBytes;
          storeVideos();
        });
      }
    }

    videos = currentVideos;
    storeVideos();
  }

  storeVideos() {
    String json = jsonEncode(videos);
    _ls.prefs.setString(_VIDEO_PREFS, json);
  }
}
