// SPDX-FileCopyrightText: 2025 Foundation Devices Inc.
//
// SPDX-License-Identifier: GPL-3.0-or-later

class TransferRateEstimator {
  DateTime? _transferStartTime;
  DateTime? _lastUpdateTime;
  double? _smoothedBytesPerSecond;
  int? _lastBytesProcessed;
  String _lastRemainingTime = "";
  int _sampleCount = 0;

  static const _smoothingFactor = 0.15;
  //to reduce sudden spkies
  static const _outlierThreshold = 2.5;

  static const _minSamplesForEstimate = 3;
  static const _minTimeDiffSeconds = 0.1;

  static const _updateThrottle = Duration(milliseconds: 500);

  void reset() {
    _transferStartTime = null;
    _lastUpdateTime = null;
    _smoothedBytesPerSecond = null;
    _lastBytesProcessed = null;
    _lastRemainingTime = "";
    _sampleCount = 0;
  }

  /// Update with new progress and get remaining time estimate
  /// Returns null if update should be throttled
  String? updateProgress({
    required int bytesProcessed,
    required int totalBytes,
    required double progress,
  }) {
    final now = DateTime.now();
    _transferStartTime ??= now;

    // Throttle updates (except at completion)
    if (_lastUpdateTime != null &&
        now.difference(_lastUpdateTime!) < _updateThrottle &&
        progress < 1.0) {
      return null;
    }

    String remainingTime = _lastRemainingTime;

    if (bytesProcessed > 0 && totalBytes > 0 && progress > 0.05) {
      _updateTransferRate(now, bytesProcessed);
      remainingTime = _calculateRemainingTime(bytesProcessed, totalBytes);
    }

    _lastUpdateTime = now;
    _lastBytesProcessed = bytesProcessed;

    return remainingTime;
  }

  void _updateTransferRate(DateTime now, int bytesProcessed) {
    if (_lastUpdateTime == null || _lastBytesProcessed == null) {
      return;
    }

    final timeDiff = now.difference(_lastUpdateTime!).inMilliseconds / 1000.0;
    final bytesDiff = bytesProcessed - _lastBytesProcessed!;

    if (timeDiff < _minTimeDiffSeconds || bytesDiff <= 0) {
      return;
    }

    final instantRate = bytesDiff / timeDiff;

    //  ignore rates that are too different from current average
    if (_smoothedBytesPerSecond != null &&
        _sampleCount >= _minSamplesForEstimate) {
      final ratio = instantRate / _smoothedBytesPerSecond!;
      if (ratio > _outlierThreshold || ratio < (1 / _outlierThreshold)) {
        return;
      }
    }

    // Apply exponential smoothing
    if (_smoothedBytesPerSecond == null) {
      _smoothedBytesPerSecond = instantRate;
    } else {
      _smoothedBytesPerSecond = (_smoothingFactor * instantRate) +
          ((1 - _smoothingFactor) * _smoothedBytesPerSecond!);
    }
    _sampleCount++;
  }

  String _calculateRemainingTime(int bytesProcessed, int totalBytes) {
    if (_smoothedBytesPerSecond == null ||
        _smoothedBytesPerSecond! <= 0 ||
        _sampleCount < _minSamplesForEstimate) {
      return _lastRemainingTime;
    }

    final remainingBytes = totalBytes - bytesProcessed;
    final secondsRemaining = (remainingBytes / _smoothedBytesPerSecond!).ceil();

    final formattedTime = _formatTimeRemaining(secondsRemaining);
    _lastRemainingTime = formattedTime;
    return formattedTime;
  }

  String _formatTimeRemaining(int seconds) {
    if (seconds < 60) {
      return "~1 min";
    } else if (seconds < 3600) {
      final minutes = (seconds / 60).ceil();
      return "$minutes min";
    } else {
      final hours = (seconds / 3600).floor();
      final minutes = ((seconds % 3600) / 60).ceil();
      return "${hours}h ${minutes}m";
    }
  }
}
