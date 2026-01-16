// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'package:envoy/business/local_storage.dart';
import 'package:crypto/crypto.dart';
import 'package:http_tor/http_tor.dart';

class Media {
  final String title;
  final String? description;
  final String? thumbnailUrl;
  final DateTime publicationDate;
  final String url;
  final String id;

  final String thumbnailsFolder = "thumbnails";
  Future<void>? _thumbnailFetchInFlight;

  Media(this.title, this.description, this.thumbnailUrl, this.publicationDate,
      this.url, this.id);

  String? get thumbnailHash {
    final thumbnail = thumbnailUrl;
    if (thumbnail == null || thumbnail.isEmpty) return null;
    return sha256.convert(thumbnail.codeUnits).toString();
  }

  Future<List<int>?> get thumbnail async {
    final hash = thumbnailHash;
    if (hash == null) return null;

    final path = "$thumbnailsFolder/$hash";

    if (await LocalStorage().fileExists(path)) {
      final bytes = await LocalStorage().readFileBytes(path);
      if (_looksLikeImage(bytes)) return bytes;
      await LocalStorage().deleteFile(path);
    }

    _thumbnailFetchInFlight ??= _fetchThumbnail(path).whenComplete(() {
      _thumbnailFetchInFlight = null;
    });
    unawaited(_thumbnailFetchInFlight);

    return null;
  }

  Future<void> _fetchThumbnail(String path) async {
    final thumbnail = thumbnailUrl;
    if (thumbnail == null || thumbnail.isEmpty) return;

    try {
      final response = await HttpTor().get(thumbnail);
      if (response.statusCode != 200) return;

      final bytes = response.bodyBytes;
      if (!_looksLikeImage(bytes)) return;

      await LocalStorage().saveFileBytes(path, bytes);
    } catch (_) {
      // fail silently; keep placeholder and retry later
    }
  }

  bool _looksLikeImage(List<int> bytes) {
    if (bytes.length < 12) return false;

    // JPEG
    if (bytes[0] == 0xFF && bytes[1] == 0xD8) return true;

    // PNG
    if (bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return true;
    }

    // WebP ("RIFF....WEBP")
    if (bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46) {
      if (bytes[8] == 0x57 &&
          bytes[9] == 0x45 &&
          bytes[10] == 0x42 &&
          bytes[11] == 0x50) {
        return true;
      }
    }

    return false;
  }
}
