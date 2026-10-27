import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/providers.dart';
import 'read_aloud.dart';
import 'sound_service.dart' show shareSpeaker;

/// Where the child is, for picking the music.
enum MusicArea {
  /// Everywhere except quizzes: "Bahay kubo morning".
  main('music/bahay_kubo_morning.wav', 0.35),

  /// Quizzes: the softer "Quiet focus".
  quiz('music/quiet_focus.wav', 0.45);

  const MusicArea(this.track, this.volume);
  final String track;
  final double volume;
}

/// Soft background music made by `tool/make_music.py` (PLAN.md §8b).
///
/// Two looping tracks crossfade (about a second) when a quiz opens or
/// closes; each one carries on from where it paused. Music sits behind
/// the sounds and Binhi's voice: it dips while Binhi reads aloud and stops
/// at once when the app goes to the background. Failures are silent.
class MusicService {
  MusicService();

  /// While read-aloud talks, music drops to this share of its volume.
  static const duckShare = 0.35;

  static const fade = Duration(milliseconds: 900);
  static const _tickEvery = Duration(milliseconds: 50);

  // Off until the saved setting has loaded, so music never blips on for a
  // child who turned it off.
  bool _enabled = false;
  bool _foreground = true;
  bool _speaking = false;
  MusicArea _area = MusicArea.main;

  /// Settings → Music.
  set enabled(bool v) => _set(() => _enabled = v);
  bool get enabled => _enabled;

  /// The app is on screen (false when backgrounded or the phone locks).
  set foreground(bool v) => _set(() => _foreground = v);

  /// Binhi is reading aloud.
  set speaking(bool v) => _set(() => _speaking = v);

  /// My Garden is on screen: the music steps back for its nature sounds.
  set inGarden(bool v) {
    if (v != _inGarden) _set(() => _inGarden = v);
  }

  bool _inGarden = false;

  /// Share of the music's volume while the garden shows.
  static const gardenShare = 0.7;

  /// Which track should be heard.
  set area(MusicArea a) => _set(() => _area = a);
  MusicArea get area => _area;

  bool get shouldPlay => _enabled && _foreground;

  int _quizzes = 0;

  /// A quiz screen opened. Counted, because NEXT PLANT opens the next quiz
  /// before the old one closes.
  void enterQuiz() {
    _quizzes++;
    area = MusicArea.quiz;
  }

  void leaveQuiz() {
    _quizzes = _quizzes > 0 ? _quizzes - 1 : 0;
    if (_quizzes == 0) area = MusicArea.main;
  }

  /// How loud [a] should end up: its volume if it is the current area,
  /// otherwise silent (it fades out and pauses).
  double targetFor(MusicArea a) =>
      shouldPlay && a == _area ? a.volume * (_speaking ? duckShare : 1) * (_inGarden ? gardenShare : 1) : 0;

  void _set(void Function() change) {
    change();
    if (!shouldPlay) {
      _stopNow();
    } else {
      _blocked = false;
      _run();
    }
  }

  final _players = <MusicArea, AudioPlayer>{};
  final _level = {for (final a in MusicArea.values) a: 0.0};
  final _loaded = <MusicArea>{};
  final _playing = <MusicArea>{};
  Timer? _timer;
  bool _busy = false;

  /// The browser refused to start sound before a tap; wait for [nudge].
  bool _blocked = false;

  AudioPlayer _player(MusicArea a) => _players.putIfAbsent(a, () {
    final p = AudioPlayer();
    shareSpeaker(p);
    return p;
  });

  /// Browsers block sound until the first tap, so every tap gives the music
  /// another chance (it does nothing once playing).
  void nudge() {
    if (_blocked && shouldPlay) {
      _blocked = false;
      _run();
    }
  }

  void _run() => _timer ??= Timer.periodic(_tickEvery, (_) => _tick());

  Future<void> _tick() async {
    if (_busy) return;
    _busy = true;
    try {
      final step =
          MusicArea.values.map((a) => a.volume).reduce((x, y) => x > y ? x : y) *
          _tickEvery.inMilliseconds /
          fade.inMilliseconds;
      var settled = true;
      for (final a in MusicArea.values) {
        final target = targetFor(a);
        final now = _level[a]!;
        final next = now < target ? (now + step).clamp(0.0, target) : (now - step).clamp(target, 1.0);
        if (next > 0 && !_playing.contains(a)) await _start(a, next);
        if (_blocked) break;
        if (_playing.contains(a)) {
          if (next != now) await _player(a).setVolume(next);
          if (next == 0) {
            await _player(a).pause();
            _playing.remove(a);
          }
        }
        _level[a] = next;
        if (next != target) settled = false;
      }
      if (settled || _blocked) {
        _timer?.cancel();
        _timer = null;
      }
    } catch (e) {
      debugPrint('PlantQuest: music failed: $e');
    } finally {
      _busy = false;
    }
  }

  Future<void> _start(MusicArea a, double volume) async {
    final p = _player(a);
    try {
      if (_loaded.contains(a)) {
        await p.setVolume(volume);
        await p.resume();
      } else {
        await p.setReleaseMode(ReleaseMode.loop);
        await p.play(AssetSource(a.track), volume: volume);
        _loaded.add(a);
      }
      _playing.add(a);
    } catch (e) {
      // e.g. the browser said "not until a tap".
      _blocked = true;
      debugPrint('PlantQuest: music waits for a tap: $e');
    }
  }

  void _stopNow() {
    _timer?.cancel();
    _timer = null;
    for (final a in _playing.toList()) {
      _player(a).pause().catchError((Object _) {});
      _level[a] = 0;
    }
    _playing.clear();
  }

  void dispose() {
    _timer?.cancel();
    for (final p in _players.values) {
      p.dispose();
    }
  }
}

/// Plays nothing (tests).
class SilentMusicService extends MusicService {
  @override
  void _run() {}

  @override
  void _stopNow() {}
}

/// The app's music, switched by Settings → Music.
final musicServiceProvider = Provider<MusicService>((ref) {
  final m = MusicService();
  ref.listen(profileProvider, (_, next) {
    // Before onboarding there is no profile yet: music is on.
    if (next.hasValue) m.enabled = next.value?.musicOn ?? true;
  }, fireImmediately: true);

  final speaking = ref.watch(readAloudProvider).speaking;
  void onSpeech() => m.speaking = speaking.value != null;
  speaking.addListener(onSpeech);

  final life = AppLifecycleListener(
    onStateChange: (s) => m.foreground = s == AppLifecycleState.resumed || s == AppLifecycleState.inactive,
  );

  ref.onDispose(() {
    speaking.removeListener(onSpeech);
    life.dispose();
    m.dispose();
  });
  return m;
});
