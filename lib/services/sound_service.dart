import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/providers.dart';

/// The game's sound effects (bundled in `assets/sounds/<pack>/`).
enum Sfx {
  tap('tap'),
  correct('correct'),
  tryAgain('try_again'),
  leaf('leaf'),
  levelUp('level_up');

  const Sfx(this.file);
  final String file;
}

/// Lets our players share the speaker. By default each Android player asks
/// for the phone's audio focus, so a tap sound would stop the music for good.
final mixingAudio = AudioContextConfig(focus: AudioContextConfigFocus.mixWithOthers).build();

/// Sets [p] to share the speaker (phones only; browsers already mix).
void shareSpeaker(AudioPlayer p) {
  if (kIsWeb) return;
  p.setAudioContext(mixingAudio).catchError((Object e) => debugPrint('PlantQuest: audio context failed: $e'));
}

/// Sound packs (folders in assets/sounds). Wooden was picked in the Style
/// lab (PLAN.md D11); the others were removed.
enum SoundPack {
  wooden('Wooden', 'Soft marimba taps');

  const SoundPack(this.title, this.line);
  final String title;
  final String line;
}

/// Plays short sound effects. One player per sound, so a tap never cuts off
/// a "correct" chime. Failures are silent: a missing sound must never stop
/// the game.
class SoundService {
  SoundService();

  SoundPack pack = SoundPack.wooden;
  bool enabled = true;

  final _players = <Sfx, AudioPlayer>{};

  AudioPlayer _player(Sfx sfx) => _players.putIfAbsent(sfx, () {
    final p = AudioPlayer();
    shareSpeaker(p);
    if (!kIsWeb) p.setPlayerMode(PlayerMode.lowLatency);
    return p;
  });

  Future<void> play(Sfx sfx, {SoundPack? pack}) async {
    if (!enabled) return;
    try {
      final p = _player(sfx);
      await p.stop();
      await p.play(AssetSource('sounds/${(pack ?? this.pack).name}/${sfx.file}.wav'), volume: 0.8);
    } catch (e) {
      debugPrint('PlantQuest: sound ${sfx.file} failed: $e');
    }
  }

  void dispose() {
    for (final p in _players.values) {
      p.dispose();
    }
  }
}

/// Plays nothing (tests, and anywhere sound must stay off).
class SilentSoundService extends SoundService {
  @override
  Future<void> play(Sfx sfx, {SoundPack? pack}) async {}
}

/// The app's sounds, switched on and off by Settings → Sounds.
final soundServiceProvider = Provider<SoundService>((ref) {
  final s = SoundService();
  ref.listen(profileProvider, (_, next) => s.enabled = next.value?.soundOn ?? true, fireImmediately: true);
  ref.onDispose(s.dispose);
  return s;
});
