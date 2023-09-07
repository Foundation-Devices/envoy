// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';

import 'package:envoy/business/video.dart';
import 'package:envoy/util/envoy_storage.dart';
import 'package:tor/tor.dart';

import 'package:webfeed/webfeed.dart';
import 'package:http_tor/http_tor.dart';

class VideoManager {
  List<Video> videos = [];

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

  _restoreVideos() async {
    _dropVideos();

    var storedVideos = await EnvoyStorage().getAllVideos();
    for (var video in storedVideos!) {
      videos.add(video!);
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
        false,
        thumbnail: null,
        thumbnailUrl: thumbnailUrl,
      ));
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
    for (var video in videos) {
      EnvoyStorage().insertVideo(video);
    }
  }
}
