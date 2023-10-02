// SPDX-FileCopyrightText: 2022 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'local_storage.dart';
import 'package:crypto/crypto.dart';

class Media {
  final String title;
  final String? description;
  final String? thumbnailUrl;
  final DateTime publicationDate;
  final String url;
  final String id;

  Media(this.title, this.description, this.thumbnailUrl, this.publicationDate,
      this.url, this.id);

  Future<List<int>?> get thumbnail async {
    if (thumbnailHash == null ||
        !await LocalStorage().fileExists(thumbnailHash!)) {
      return null;
    }

    return LocalStorage().readFileBytes(thumbnailHash!);
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
}
