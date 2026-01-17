// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:crypto/crypto.dart';
import 'package:envoy/business/local_storage.dart';
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

      if (await _looksLikeImage(bytes)) {
        return bytes;
      }

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

      if (!await _looksLikeImage(bytes)) return;

      await LocalStorage().saveFileBytes(path, bytes);
    } catch (_) {
      // fail silently; keep placeholder and retry later
    }
  }

  Future<bool> _looksLikeImage(List<int> bytes) async {
    if (bytes.isEmpty) return false;

    try {
      final buffer =
          await ui.ImmutableBuffer.fromUint8List(Uint8List.fromList(bytes));
      try {
        final descriptor = await ui.ImageDescriptor.encoded(buffer);
        descriptor.dispose();
        return true;
      } finally {
        buffer.dispose();
      }
    } catch (_) {
      return false;
    }
  }
}
