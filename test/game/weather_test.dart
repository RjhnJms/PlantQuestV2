import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:plantquest/art/garden/garden_art.dart';
import 'package:plantquest/game/weather.dart';

void main() {
  test('the garden opens on every kind of weather', () {
    final rnd = math.Random(1);
    final seen = {for (var i = 0; i < 200; i++) WeatherRules.pick(rnd)};
    expect(seen, GardenWeather.values.toSet());
  });

  test('notes go round, and each change has one', () {
    for (final c in WeatherChange.values) {
      expect(WeatherRules.note(c, 0), isNotEmpty);
      final n = WeatherRules.notes[c]!.length;
      expect(WeatherRules.note(c, n), WeatherRules.note(c, 0));
    }
  });

  test('the sun can always be tapped, and no cloud covers it', () {
    expect(GardenGroundPainter.hitsSun(GardenGroundPainter.sunCentre), isTrue);
    for (final w in GardenWeather.values) {
      for (final rainbow in [false, true]) {
        final clouds = GardenGroundPainter.cloudsFor(w, rainbow: rainbow);
        expect(clouds, isNotEmpty);
        expect(GardenGroundPainter.hitsCloud(clouds.first.$1, w, rainbow: rainbow), isTrue);
      }
    }
    expect(GardenGroundPainter.hitsCloud(const Offset(180, 600), GardenWeather.cloudy), isFalse);
  });
}
