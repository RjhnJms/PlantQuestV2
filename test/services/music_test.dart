import 'package:flutter_test/flutter_test.dart';
import 'package:plantquest/services/music_service.dart';

void main() {
  MusicService ready() => SilentMusicService()..enabled = true;

  test('silent until the saved setting loads', () {
    final m = SilentMusicService();
    expect(m.shouldPlay, isFalse);
    expect(m.targetFor(MusicArea.main), 0);
  });

  test('main track everywhere; quiet focus in quizzes (crossfade targets)', () {
    final m = ready();
    expect(m.targetFor(MusicArea.main), MusicArea.main.volume);
    expect(m.targetFor(MusicArea.quiz), 0);
    m.enterQuiz();
    expect(m.targetFor(MusicArea.main), 0);
    expect(m.targetFor(MusicArea.quiz), MusicArea.quiz.volume);
  });

  test('NEXT PLANT: the next quiz opens before the old one closes', () {
    final m = ready()
      ..enterQuiz()
      ..enterQuiz()
      ..leaveQuiz();
    expect(m.area, MusicArea.quiz);
    m.leaveQuiz();
    expect(m.area, MusicArea.main);
    m.leaveQuiz(); // never below zero
    m.enterQuiz();
    expect(m.area, MusicArea.quiz);
  });

  test('dips while Binhi reads aloud; silent when off or in the background', () {
    final m = ready()..speaking = true;
    expect(m.targetFor(MusicArea.main), closeTo(MusicArea.main.volume * MusicService.duckShare, 1e-9));
    m.speaking = false;
    m.foreground = false;
    expect(m.targetFor(MusicArea.main), 0);
    m.foreground = true;
    m.enabled = false;
    expect(m.targetFor(MusicArea.main), 0);
  });
}
