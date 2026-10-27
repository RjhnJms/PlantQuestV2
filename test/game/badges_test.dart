import 'package:flutter_test/flutter_test.dart';
import 'package:plantquest/art/avatars/animal_avatar.dart';
import 'package:plantquest/content/plant_catalog.dart';
import 'package:plantquest/game/badges.dart';
import 'package:plantquest/game/rules.dart';

void main() {
  Set<String> world(int n) => {for (final p in PlantCatalog.inWorld(n)) p.id};
  final all = {for (final p in PlantCatalog.all) p.id};

  test('nothing is earned at the start', () {
    const f = BadgeFacts();
    expect(Achievement.values.where((a) => a.earned(f)), isEmpty);
    expect(Achievement.explorerWeek.progress(f), (0, 7));
  });

  test('each badge earns at its goal', () {
    expect(Achievement.firstSprout.earned(const BadgeFacts(quizDone: {'sampaguita'})), isTrue);
    expect(Achievement.backyard.progress(BadgeFacts(quizDone: world(1).take(3).toSet())), (3, 5));
    expect(Achievement.backyard.earned(BadgeFacts(quizDone: world(1))), isTrue);
    expect(Achievement.farm.earned(BadgeFacts(quizDone: world(1))), isFalse);
    expect(Achievement.explorerWeek.earned(const BadgeFacts(daysVisited: 7)), isTrue);
    expect(Achievement.quizStar.earned(const BadgeFacts(bestLevel: (4, 5))), isTrue);
    expect(Achievement.quizStar.earned(const BadgeFacts(bestLevel: (7, 10))), isFalse);
    expect(Achievement.quizStar.earned(const BadgeFacts(bestLevel: (8, 10))), isTrue);
    expect(Achievement.sharpEye.progress(BadgeFacts(perfect: world(1).take(4).toSet())), (4, 5));
    expect(Achievement.stickers.earned(BadgeFacts(quizDone: {...world(1), ...world(2)})), isTrue);
  });

  test('Game Master needs both games for the same 5 plants', () {
    final some = world(1).toList();
    final half = BadgeFacts(gameWins: {for (final id in some) (MiniGame.label, id)});
    expect(Achievement.gameMaster.progress(half), (0, 5));
    final both = BadgeFacts(
      gameWins: {
        for (final id in some) ...{(MiniGame.label, id), (MiniGame.grow, id)},
      },
    );
    expect(Achievement.gameMaster.earned(both), isTrue);
  });

  test('Plant Expert needs every part and every quiz', () {
    expect(Achievement.plantExpert.earned(BadgeFacts(quizDone: all)), isFalse);
    expect(Achievement.plantExpert.earned(BadgeFacts(quizDone: all, allParts: all)), isTrue);
  });

  test('six badges give the six animal friends; the rest give leaves', () {
    final animals = [for (final a in Achievement.values) ?a.animal];
    expect(animals.toSet(), AnimalAvatar.values.toSet());
    for (final a in Achievement.values) {
      expect(a.animal == null ? a.leaves > 0 : a.leaves == 0, isTrue, reason: a.name);
    }
  });

  test('animal avatar ids', () {
    expect(AnimalIds.of(AnimalAvatar.tarsier), 'animal_tarsier');
    expect(AnimalIds.parse('animal_carabao'), AnimalAvatar.carabao);
    expect(AnimalIds.parse('boy_cap'), isNull);
  });
}
