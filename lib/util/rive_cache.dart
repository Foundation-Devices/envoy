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
  /// the artboard automatically and returned to the caller.
  static Artboard loadArtboard(
    String assetPath, {
    String? artboardName,
    String? stateMachine,
  }) {
    // Reuse previously imported file if available.
    final file = _fileCache.putIfAbsent(assetPath, () {
      final data = rootBundle.loadSync(assetPath);
      return RiveFile.import(data);
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
}
