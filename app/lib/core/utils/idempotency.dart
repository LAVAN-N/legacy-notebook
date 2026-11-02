import 'dart:async';
import 'package:flutter/foundation.dart';

/// Idempotency manager that prevents concurrent and rapid duplicate execution
/// of asynchronous operations (e.g., save/update requests across the application).
class IdempotencyLock {
  IdempotencyLock._();
  static final IdempotencyLock instance = IdempotencyLock._();

  final Set<String> _inFlightKeys = <String>{};
  final Map<String, DateTime> _completedTimestamps = <String, DateTime>{};

  /// Check whether an operation with [key] is currently running.
  bool isInFlight(String key) => _inFlightKeys.contains(key);

  /// Check whether an operation is currently locked (in flight or within [cooldown]).
  bool isLocked(String key, {Duration cooldown = const Duration(milliseconds: 800)}) {
    if (_inFlightKeys.contains(key)) return true;
    final lastTime = _completedTimestamps[key];
    if (lastTime != null) {
      if (DateTime.now().difference(lastTime) < cooldown) {
        return true;
      }
    }
    return false;
  }

  /// Executes [action] idempotently.
  /// If an action with [key] is already in progress, or was completed within [cooldown],
  /// subsequent calls are safely ignored and return `null`.
  Future<T?> run<T>(
    String key,
    Future<T> Function() action, {
    Duration cooldown = const Duration(milliseconds: 800),
  }) async {
    if (_inFlightKeys.contains(key)) {
      debugPrint('[Idempotency] Skipped duplicate concurrent execution for key: $key');
      return null;
    }

    final lastTime = _completedTimestamps[key];
    if (lastTime != null && DateTime.now().difference(lastTime) < cooldown) {
      debugPrint('[Idempotency] Skipped debounced execution for key: $key');
      return null;
    }

    _inFlightKeys.add(key);
    try {
      final result = await action();
      _completedTimestamps[key] = DateTime.now();
      // Clean up old entries from completed cache periodically
      if (_completedTimestamps.length > 200) {
        final cutoff = DateTime.now().subtract(const Duration(minutes: 5));
        _completedTimestamps.removeWhere((_, time) => time.isBefore(cutoff));
      }
      return result;
    } finally {
      _inFlightKeys.remove(key);
    }
  }

  /// Manually release a lock if needed.
  void release(String key) {
    _inFlightKeys.remove(key);
    _completedTimestamps.remove(key);
  }
}

/// Helper for debouncing quick consecutive user taps (e.g. on navigation or buttons).
class TapDebouncer {
  DateTime? _lastTap;
  final Duration interval;

  TapDebouncer({this.interval = const Duration(milliseconds: 600)});

  /// Returns true if the tap is allowed, false if it occurred too soon after the last tap.
  bool allowTap() {
    final now = DateTime.now();
    if (_lastTap == null || now.difference(_lastTap!) >= interval) {
      _lastTap = now;
      return true;
    }
    return false;
  }

  /// Run [action] only if enough time has elapsed since the last tap.
  void run(VoidCallback action) {
    if (allowTap()) {
      action();
    }
  }
}
