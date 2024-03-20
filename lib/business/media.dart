// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:envoy/business/local_storage.dart';
import 'package:crypto/crypto.dart';
import 'package:envoy/business/scheduler.dart';
import 'package:http_tor/http_tor.dart';
import 'package:tor/tor.dart';

class Media {
  final String title;
  final String? description;
  final String? thumbnailUrl;
  final DateTime publicationDate;
  final String url;
  final String id;

  final String thumbnailsFolder = "thumbnails";

  Media(this.title, this.description, this.thumbnailUrl, this.publicationDate,
      this.url, this.id);

  Future<List<int>?> get thumbnail async {
    if (thumbnailHash == null ||
        !await LocalStorage()
            .fileExists(thumbnailsFolder + "/" + thumbnailHash!)) {
      _fetchThumbnail();
      return null;
    }

    return LocalStorage()
        .readFileBytes(thumbnailsFolder + "/" + thumbnailHash!);
  }

  String? get thumbnailHash {
    if (thumbnailUrl == null) {
      return null;
    }

    if (thumbnailUrl!.isEmpty) {
      return null;
    }

    return sha256.convert(thumbnailUrl!.codeUnits).toString();
  }

  _fetchThumbnail() async {
    HttpTor(Tor.instance, EnvoyScheduler().parallel)
        .get(thumbnailUrl!)
        .then((response) async {
      await LocalStorage().saveFileBytes(
          thumbnailsFolder + "/" + thumbnailHash!, response.bodyBytes);
    });
  }
}
