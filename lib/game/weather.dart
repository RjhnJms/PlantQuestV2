import 'dart:math' as math;

/// The garden's weather (PLAN.md §5f).
enum GardenWeather {
  sunny('Sunny day'),
  cloudy('Cloudy day'),
  rainy('Rainy day');

  const GardenWeather(this.label);
  final String label;
}

/// What just happened to the weather, for the little note it shows.
enum WeatherChange { rain, sun, rainbow }

/// The garden opens on a random weather each visit; then the child plays
/// with it: tap a cloud for rain, tap the sun to clear it. A rainbow comes
/// when the rain stops or after watering Binhi.
abstract final class WeatherRules {
  /// Chances out of 100 for (sunny, cloudy); the rest is rain.
  static const opening = (40, 30);

  static GardenWeather pick(math.Random rnd) {
    final roll = rnd.nextInt(100);
    final (sunny, cloudy) = opening;
    if (roll < sunny) return GardenWeather.sunny;
    if (roll < sunny + cloudy) return GardenWeather.cloudy;
    return GardenWeather.rainy;
  }

  /// Short plant facts that go with each change, taken in turn.
  static const notes = {
    WeatherChange.rain: [
      'Plants drink rainwater through their roots!',
      'Rain fills the pond for the kangkong.',
      'In the Philippines, June to November is Tag-ulan, the rainy season.',
    ],
    WeatherChange.sun: [
      'Leaves use sunlight to make food!',
      'Plants grow toward the sun.',
      'December to May is Tag-init, the sunny season.',
    ],
    WeatherChange.rainbow: ['A rainbow! Sunlight shining through raindrops makes its colors.'],
  };

  /// The [n]th note (0 = first) for [change], going round.
  static String note(WeatherChange change, int n) {
    final list = notes[change]!;
    return list[n % list.length];
  }
}
