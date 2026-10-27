import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:plantquest/data/database.dart';
import 'package:plantquest/game/weather.dart';
import 'package:plantquest/services/garden_ambience.dart';
import 'package:plantquest/services/music_service.dart';
import 'package:plantquest/services/read_aloud.dart';
import 'package:plantquest/services/sound_service.dart';
import 'package:plantquest/state/providers.dart';

/// Runs the app on [db] with silent speech and sounds (there is no speech
/// engine or speaker in tests). Badge and daily gift popups are off unless
/// a test asks for them. My Garden opens sunny unless [weather] says otherwise.
List<Override> testOverrides(
  AppDatabase db, {
  bool badges = false,
  bool dailyGift = false,
  GardenWeather weather = GardenWeather.sunny,
}) => [
  gardenWeatherPickProvider.overrideWithValue(() => weather),
  badgesEnabledProvider.overrideWithValue(badges),
  dailyGiftEnabledProvider.overrideWithValue(dailyGift),
  databaseProvider.overrideWithValue(db),
  readAloudProvider.overrideWithValue(SilentReadAloud()),
  soundServiceProvider.overrideWithValue(SilentSoundService()),
  musicServiceProvider.overrideWithValue(SilentMusicService()),
  gardenAmbienceProvider.overrideWithValue(SilentGardenAmbience()),
];
