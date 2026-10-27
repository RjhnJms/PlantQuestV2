import 'package:flutter_test/flutter_test.dart';
import 'package:plantquest/data/save_queue.dart';

void main() {
  SaveQueue fastQueue() => SaveQueue(retryDelays: const [Duration.zero, Duration.zero]);

  test('saves run one at a time, in the order they were queued', () async {
    final q = fastQueue();
    final log = <String>[];
    Future<void> job(String name, int ms) async {
      log.add('start $name');
      await Future<void>.delayed(Duration(milliseconds: ms));
      log.add('end $name');
    }

    q
      ..run(() => job('a', 30))
      ..run(() => job('b', 1));
    await q.idle;
    expect(log, ['start a', 'end a', 'start b', 'end b']);
  });

  test('a failing save is retried and can succeed', () async {
    final q = fastQueue();
    var tries = 0;
    final result = await q.run(() async {
      tries++;
      if (tries < 3) throw StateError('disk busy');
      return 'saved';
    });
    expect(result, 'saved');
    expect(tries, 3);
    expect(q.failedCount, 0);
  });

  test('a save that keeps failing returns null and never blocks the next one', () async {
    final q = fastQueue();
    final failed = await q.run<String>(() async => throw StateError('broken'));
    final next = await q.run(() async => 'ok');
    expect(failed, isNull);
    expect(next, 'ok');
    expect(q.failedCount, 1);
    expect(q.pending.value, 0);
  });
}
