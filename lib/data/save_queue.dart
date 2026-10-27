import 'dart:async';

import 'package:flutter/foundation.dart';

/// Runs saves one at a time, in order, and retries ones that fail.
///
/// A save never throws into the UI: if every retry fails, [run] completes
/// with null and the screen carries on (PLAN.md §6: "the quiz never gets
/// stuck if a save fails").
class SaveQueue {
  SaveQueue({this.retryDelays = const [Duration(milliseconds: 250), Duration(seconds: 1), Duration(seconds: 3)]});

  /// Waits between attempts. The number of retries is its length.
  final List<Duration> retryDelays;

  Future<void> _tail = Future.value();

  /// Saves waiting or running, for a "saving…" hint or tests.
  final ValueNotifier<int> pending = ValueNotifier(0);

  /// Saves that failed every retry since the app started.
  int failedCount = 0;

  Object? lastError;

  Future<T?> run<T>(Future<T> Function() job, {String label = 'save'}) {
    pending.value++;
    final done = Completer<T?>();
    _tail = _tail.then((_) async {
      try {
        done.complete(await _withRetries(job, label));
      } finally {
        pending.value--;
      }
    });
    return done.future;
  }

  /// Completes when every queued save has finished (or given up).
  Future<void> get idle => _tail;

  Future<T?> _withRetries<T>(Future<T> Function() job, String label) async {
    for (var attempt = 0; ; attempt++) {
      try {
        return await job();
      } catch (e, stack) {
        lastError = e;
        if (attempt >= retryDelays.length) {
          failedCount++;
          debugPrint('PlantQuest: $label failed after ${attempt + 1} tries: $e\n$stack');
          return null;
        }
        await Future<void>.delayed(retryDelays[attempt]);
      }
    }
  }

  void dispose() => pending.dispose();
}
