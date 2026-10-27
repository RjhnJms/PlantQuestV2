import 'package:flutter_test/flutter_test.dart';
import 'package:plantquest/game/weather.dart';
import 'package:plantquest/services/garden_ambience.dart';
import 'package:plantquest/services/music_service.dart';

void main() {
  late SilentGardenAmbience a;
  late SilentMusicService music;
  final home = Object();
  final page = Object();

  setUp(() {
    music = SilentMusicService()..enabled = true;
    a = SilentGardenAmbience()
      ..music = music
      ..enabled = true;
  });

  test('each weather has its own sounds', () {
    a.show(home, GardenWeather.sunny, rainbow: false);
    expect(a.targetFor(GardenLoop.birds), greaterThan(0));
    expect(a.targetFor(GardenLoop.breeze), greaterThan(0));
    expect(a.targetFor(GardenLoop.rain), 0);

    a.show(home, GardenWeather.rainy, rainbow: false);
    expect(a.targetFor(GardenLoop.rain), greaterThan(0));
    expect(a.targetFor(GardenLoop.birds), 0);
    expect(a.targetFor(GardenLoop.breeze), 0);

    a.show(home, GardenWeather.cloudy, rainbow: false);
    expect(a.targetFor(GardenLoop.breeze), greaterThan(0));
    expect(a.targetFor(GardenLoop.birds), 0);

    a.show(home, GardenWeather.rainy, rainbow: true);
    expect(a.targetFor(GardenLoop.rain), 0, reason: 'the rainbow means the rain stopped');
    expect(a.targetFor(GardenLoop.birds), greaterThan(0));
  });

  test('quiet when Binhi talks; silent when off, hidden or in the background', () {
    a.show(home, GardenWeather.rainy, rainbow: false);
    final full = a.targetFor(GardenLoop.rain);
    a.speaking = true;
    expect(a.targetFor(GardenLoop.rain), lessThan(full));
    a.speaking = false;
    a.enabled = false;
    expect(a.targetFor(GardenLoop.rain), 0);
    a.enabled = true;
    a.foreground = false;
    expect(a.targetFor(GardenLoop.rain), 0);
    a.foreground = true;
    a.hide(home);
    expect(a.targetFor(GardenLoop.rain), 0);
  });

  test('plays while any garden shows, and the music steps back meanwhile', () {
    final musicBefore = music.targetFor(MusicArea.main);
    a.show(home, GardenWeather.sunny, rainbow: false);
    a.show(page, GardenWeather.sunny, rainbow: false);
    expect(music.targetFor(MusicArea.main), lessThan(musicBefore));
    a.hide(page);
    expect(a.targetFor(GardenLoop.birds), greaterThan(0), reason: "Home's garden still shows");
    a.hide(home);
    expect(a.targetFor(GardenLoop.birds), 0);
    expect(music.targetFor(MusicArea.main), musicBefore);
  });
}
