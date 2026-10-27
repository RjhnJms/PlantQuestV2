import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../state/providers.dart';

/// What is being read right now: the text and the character range of the
/// current word, so the sentence around it can be highlighted.
@immutable
class SpokenSpan {
  const SpokenSpan(this.text, this.start, this.end);
  final String text;
  final int start;
  final int end;
}

/// An offline voice installed on the phone.
@immutable
class VoiceOption {
  const VoiceOption({required this.name, required this.locale, required this.label});

  /// The engine's voice name (saved as `profile.voice_id`).
  final String name;
  final String locale;

  /// Kid-friendly label, e.g. "Voice 2 · British".
  final String label;
}

/// Reads text aloud with the phone's offline voice (PLAN.md §8).
abstract class ReadAloud {
  /// The text being spoken, or null when quiet.
  ValueListenable<SpokenSpan?> get speaking;

  /// False when the phone has no English voice to speak with.
  Future<bool> hasVoice();

  /// English voices on this phone (empty if none).
  Future<List<VoiceOption>> voices();

  /// Applies the Settings choices.
  Future<void> configure({required String speechRate, required String voiceStyle, String? voiceName});

  /// Speaks [text], stopping anything already being read. [voiceName] picks
  /// a voice just for this line (the Settings preview).
  Future<void> speak(String text, {String? voiceName});

  Future<void> stop();

  void dispose();
}

/// For tests and anywhere speech must stay quiet.
class SilentReadAloud implements ReadAloud {
  SilentReadAloud();

  final _speaking = ValueNotifier<SpokenSpan?>(null);

  @override
  ValueListenable<SpokenSpan?> get speaking => _speaking;

  @override
  Future<bool> hasVoice() async => true;

  @override
  Future<List<VoiceOption>> voices() async => const [];

  @override
  Future<void> configure({required String speechRate, required String voiceStyle, String? voiceName}) async {}

  @override
  Future<void> speak(String text, {String? voiceName}) async {}

  @override
  Future<void> stop() async {}

  @override
  void dispose() => _speaking.dispose();
}

/// flutter_tts on the phone (and the browser's speech in the preview).
/// Every call is wrapped: a missing voice or engine must never crash the
/// game.
class TtsReadAloud implements ReadAloud {
  TtsReadAloud() {
    _tts
      ..setStartHandler(() {})
      ..setCompletionHandler(_done)
      ..setCancelHandler(_done)
      ..setErrorHandler((_) => _done())
      ..setProgressHandler((text, start, end, word) {
        final current = _current;
        if (current != null) _speaking.value = SpokenSpan(current, start, end);
      });
    unawaited(_safe(() => _tts.awaitSpeakCompletion(false)));
  }

  final _tts = FlutterTts();
  final _speaking = ValueNotifier<SpokenSpan?>(null);
  String? _current;
  String _rate = 'normal';
  String _style = 'cheerful';
  String? _voice;
  List<VoiceOption>? _voices;

  @override
  ValueListenable<SpokenSpan?> get speaking => _speaking;

  void _done() {
    _current = null;
    _speaking.value = null;
  }

  Future<T?> _safe<T>(Future<T> Function() f) async {
    try {
      return await f();
    } catch (e) {
      debugPrint('PlantQuest: read-aloud: $e');
      return null;
    }
  }

  static const _regions = {
    'US': 'American',
    'GB': 'British',
    'AU': 'Australian',
    'IN': 'Indian',
    'PH': 'Filipino',
    'CA': 'Canadian',
    'NZ': 'New Zealand',
    'IE': 'Irish',
    'ZA': 'South African',
    'SG': 'Singapore',
  };

  @override
  Future<List<VoiceOption>> voices() async {
    if (_voices != null) return _voices!;
    final raw = await _safe(() => _tts.getVoices) ?? const [];
    final english = <VoiceOption>[];
    for (final v in raw as List) {
      if (v is! Map) continue;
      final name = '${v['name'] ?? ''}';
      final locale = '${v['locale'] ?? ''}'.replaceAll('_', '-');
      if (name.isEmpty || !locale.toLowerCase().startsWith('en')) continue;
      // Voices that need the internet are not offline voices.
      if ('${v['network_required'] ?? '0'}' == '1' || name.toLowerCase().contains('network')) continue;
      final region = locale.split('-').length > 1 ? locale.split('-')[1].toUpperCase() : '';
      english.add(VoiceOption(name: name, locale: locale, label: _regions[region] ?? locale));
    }
    // Keep the list short for kids: at most 6, numbered.
    final picked = english.take(6).toList();
    return _voices = [
      for (final (i, v) in picked.indexed)
        VoiceOption(name: v.name, locale: v.locale, label: 'Voice ${i + 1} · ${v.label}'),
    ];
  }

  @override
  Future<bool> hasVoice() async {
    if ((await voices()).isNotEmpty) return true;
    final available = await _safe(() => _tts.isLanguageAvailable('en-US'));
    return available == true;
  }

  @override
  Future<void> configure({required String speechRate, required String voiceStyle, String? voiceName}) async {
    _rate = speechRate;
    _style = voiceStyle;
    _voice = voiceName;
  }

  Future<void> _apply(String? voiceName) async {
    // Speech rate scales differ: phones use 0–1 (0.5 normal), browsers 0.1–10 (1 normal).
    const normal = kIsWeb ? 1.0 : 0.5;
    var rate = _rate == 'slow' ? normal * 0.75 : normal;
    final pitch = switch (_style) {
      'cheerful' => 1.15,
      'calm' => 0.92,
      _ => 1.0,
    };
    if (_style == 'calm') rate *= 0.92;
    await _safe(() => _tts.setSpeechRate(rate));
    await _safe(() => _tts.setPitch(pitch));
    final name = voiceName ?? _voice;
    final voice = name == null ? null : (await voices()).where((v) => v.name == name).firstOrNull;
    if (voice != null) {
      await _safe(() => _tts.setVoice({'name': voice.name, 'locale': voice.locale}));
    } else {
      await _safe(() => _tts.setLanguage('en-US'));
    }
  }

  @override
  Future<void> speak(String text, {String? voiceName}) async {
    await stop();
    await _apply(voiceName);
    _current = text;
    _speaking.value = SpokenSpan(text, 0, 0);
    await _safe(() => _tts.speak(text));
  }

  @override
  Future<void> stop() async {
    _done();
    await _safe(() => _tts.stop());
  }

  @override
  void dispose() {
    _safe(() => _tts.stop());
    _speaking.dispose();
  }
}

/// The app's read-aloud, kept in step with the Settings choices.
final readAloudProvider = Provider<ReadAloud>((ref) {
  final r = TtsReadAloud();
  ref.listen(profileProvider, (_, next) {
    final p = next.value;
    if (p != null) r.configure(speechRate: p.speechRate, voiceStyle: p.voiceStyle, voiceName: p.voiceId);
  }, fireImmediately: true);
  ref.onDispose(r.dispose);
  return r;
});

/// English offline voices on this phone, for the Settings list.
final voicesProvider = FutureProvider<List<VoiceOption>>((ref) => ref.watch(readAloudProvider).voices());

/// False when the phone has no voice to read with.
final hasVoiceProvider = FutureProvider<bool>((ref) => ref.watch(readAloudProvider).hasVoice());
