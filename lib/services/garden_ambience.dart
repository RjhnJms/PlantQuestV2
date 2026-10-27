import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../game/weather.dart';
import '../state/providers.dart';
import 'music_service.dart';
import 'read_aloud.dart';
import 'sound_service.dart' show shareSpeaker;

/// My Garden's nature sounds under the music (PLAN.md §5k), made by
/// tool/make_garden_sounds.py: rain when it rains, birds and a breeze when
/// it's sunny, a breeze when cloudy, and a chime when a rainbow appears.
/// They play only while the garden is on screen, follow Settings → Sounds,
/// dip while Binhi talks and stop when the app is in the background.
class GardenAmbience {
  GardenAmbience();

  static const _fade = Duration(milliseconds: 700);
  static const _tick = Duration(milliseconds: 50);

  /// Share of a loop's volume while Binhi reads aloud.
  static const duckShare = 0.3;

  bool _enabled = false;
  bool _foreground = true;
  bool _speaking = false;

  /// The gardens on screen (Home's and the full page can both be built).
  final _shownBy = <Object>{};
  bool get _showing => _shownBy.isNotEmpty;
  GardenWeather _weather = GardenWeather.sunny;

  /// The music, which plays a little quieter while the garden shows.
  MusicService? music;
  bool _rainbow = false;

  set enabled(bool v) => _set(() => _enabled = v);
  set foreground(bool v) => _set(() => _foreground = v);
  set speaking(bool v) => _set(() => _speaking = v);

  /// A garden ([owner]) is on screen with this weather.
  void show(Object owner, GardenWeather weather, {required bool rainbow}) {
    if (_shownBy.contains(owner) && _weather == weather && _rainbow == rainbow) return;
    _set(() {
      _shownBy.add(owner);
      _weather = weather;
      _rainbow = rainbow;
    });
  }

  /// That garden left the screen.
  void hide(Object owner) {
    if (!_shownBy.contains(owner)) return;
    _set(() => _shownBy.remove(owner));
  }

  /// One rainbow chime (if sounds are on and the garden is showing).
  void chime() {
    if (!_audible) return;
    final p = _chimePlayer ??= _newPlayer();
    p.play(AssetSource('sounds/garden/rainbow.wav'), volume: 0.6).catchError((Object e) {
      debugPrint('PlantQuest: chime failed: $e');
    });
  }

  bool get _audible => _enabled && _foreground && _showing;

  /// How loud each loop should be now.
  double targetFor(GardenLoop loop) {
    if (!_audible) return 0;
    final raining = _weather == GardenWeather.rainy && !_rainbow;
    final base = switch (loop) {
      GardenLoop.rain => raining ? 0.45 : 0,
      GardenLoop.birds => !raining && (_weather == GardenWeather.sunny || _rainbow) ? 0.35 : 0,
      GardenLoop.breeze => raining ? 0 : 0.22,
    };
    return base * (_speaking ? duckShare : 1);
  }

  final _players = <GardenLoop, AudioPlayer>{};
  final _level = {for (final l in GardenLoop.values) l: 0.0};
  final _playing = <GardenLoop>{};
  AudioPlayer? _chimePlayer;
  Timer? _timer;
  bool _busy = false;

  void _set(void Function() change) {
    change();
    music?.inGarden = _showing;
    _timer ??= Timer.periodic(_tick, (_) => _step());
  }

  AudioPlayer _player(GardenLoop l) => _players.putIfAbsent(l, _newPlayer);

  /// A player that shares the speaker with the music and other sounds.
  static AudioPlayer _newPlayer() {
    final p = AudioPlayer();
    shareSpeaker(p);
    return p;
  }

  Future<void> _step() async {
    if (_busy) return;
    _busy = true;
    try {
      final step = _tick.inMilliseconds / _fade.inMilliseconds * 0.45;
      var settled = true;
      for (final l in GardenLoop.values) {
        final target = targetFor(l);
        final now = _level[l]!;
        final next = now < target ? (now + step).clamp(0.0, target) : (now - step).clamp(target, 1.0);
        if (next > 0 && !_playing.contains(l)) {
          final p = _player(l);
          await p.setReleaseMode(ReleaseMode.loop);
          await p.play(AssetSource('sounds/garden/${l.name}.wav'), volume: next);
          _playing.add(l);
        } else if (_playing.contains(l)) {
          if (next != now) await _player(l).setVolume(next);
          if (next == 0) {
            await _player(l).pause();
            _playing.remove(l);
          }
        }
        _level[l] = next;
        if (next != target) settled = false;
      }
      if (settled) {
        _timer?.cancel();
        _timer = null;
      }
    } catch (e) {
      // e.g. the browser wants a tap first: try again on the next change.
      debugPrint('PlantQuest: garden sounds failed: $e');
      _timer?.cancel();
      _timer = null;
    } finally {
      _busy = false;
    }
  }

  void dispose() {
    _timer?.cancel();
    for (final p in [..._players.values, ?_chimePlayer]) {
      p.dispose();
    }
  }
}

/// The garden's looping sounds (file names in assets/sounds/garden/).
enum GardenLoop { rain, birds, breeze }

/// Plays nothing (tests).
class SilentGardenAmbience extends GardenAmbience {
  @override
  void _set(void Function() change) {
    change();
    music?.inGarden = _showing;
  }

  @override
  void chime() {}
}

/// The garden's sounds, switched by Settings → Sounds.
final gardenAmbienceProvider = Provider<GardenAmbience>((ref) {
  final a = GardenAmbience()..music = ref.watch(musicServiceProvider);
  ref.listen(profileProvider, (_, next) {
    if (next.hasValue) a.enabled = next.value?.soundOn ?? true;
  }, fireImmediately: true);
  final speaking = ref.watch(readAloudProvider).speaking;
  void onSpeech() => a.speaking = speaking.value != null;
  speaking.addListener(onSpeech);
  final life = AppLifecycleListener(
    onStateChange: (s) => a.foreground = s == AppLifecycleState.resumed || s == AppLifecycleState.inactive,
  );
  ref.onDispose(() {
    speaking.removeListener(onSpeech);
    life.dispose();
    a.dispose();
  });
  return a;
});
