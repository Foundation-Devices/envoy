// SPDX-FileCopyrightText: 2024 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/services.dart' show rootBundle;
import 'package:rive/rive.dart';

/// Lightweight cache for Rive assets to avoid repeated GPU / memory
/// allocations when the same `.riv` file is used in multiple screens.
///
/// This helper keeps a single [RiveFile] per asset path in memory and
/// returns cloned [Artboard] instances so that each caller can attach its
/// own controllers while sharing the underlying textures.
class RiveCache {
  RiveCache._();

  static final Map<String, RiveFile> _fileCache = {};

  /// Returns an independent [Artboard] instance for [assetPath].  If
  /// [stateMachine] is provided, the corresponding controller is added to
  /// the artboard automatically.
  static Future<Artboard> loadArtboard(
    String assetPath, {
    String? artboardName,
    String? stateMachine,
  }) async {
    // Reuse previously imported file if available.
    final file = _fileCache.putIfAbsent(assetPath, () {
      // Note: This is a sync operation using the cached file
      throw UnsupportedError('File not cached - use loadArtboardAsync');
    });

    final original =
        file.artboardByName(artboardName ?? file.mainArtboard.name) ??
            file.mainArtboard;
    final artboard = original.instance();

    if (stateMachine != null) {
      final controller =
          StateMachineController.fromArtboard(artboard, stateMachine);
      if (controller != null) artboard.addController(controller);
    }
    return artboard;
  }

  /// Async version that loads the file if not cached
  static Future<Artboard> loadArtboardAsync(
    String assetPath, {
    String? artboardName,
    String? stateMachine,
  }) async {
    // Load file if not cached
    if (!_fileCache.containsKey(assetPath)) {
      final data = await rootBundle.load(assetPath);
      _fileCache[assetPath] = RiveFile.import(data);
    }

    final file = _fileCache[assetPath]!;
    final original =
        file.artboardByName(artboardName ?? file.mainArtboard.name) ??
            file.mainArtboard;
    final artboard = original.instance();

    if (stateMachine != null) {
      final controller =
          StateMachineController.fromArtboard(artboard, stateMachine);
      if (controller != null) artboard.addController(controller);
    }
    return artboard;
  }
}
