import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantquest/app/router.dart';
import 'package:plantquest/art/plants/plant_drawing.dart';
import 'package:plantquest/art/plants/plant_view.dart';
import 'package:plantquest/data/database.dart';
import 'package:plantquest/data/progress_repository.dart';
import 'package:plantquest/game/rules.dart';
import 'package:plantquest/main.dart';

import '../test_overrides.dart';

import 'flow_test.dart' show endApp, settle;

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  testWidgets("tapping Makahiya's flowers on its page folds its leaves", (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    final db = AppDatabase(NativeDatabase.memory());
    final repo = ProgressRepository(db);
    await repo.saveProfile(name: 'Jamie', grade: 4, avatarId: 'boy_cap');
    for (final id in ['sampaguita', 'gumamela']) {
      await repo.explorePlant(id);
      final a = await repo.startQuiz(QuizKind.plant, plantId: id, total: 1);
      await repo.saveAnswer(a, 'x', chosen: 'a', correct: true);
      await repo.finishQuiz(a);
    }
    await tester.pumpWidget(ProviderScope(overrides: testOverrides(db), child: const PlantQuestApp()));
    // Let the loading screen finish first.
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    ProviderScope.containerOf(tester.element(find.byType(MaterialApp))).read(routerProvider).push('/plant/makahiya');
    await settle(tester);
    await tester.pump(const Duration(seconds: 2));
    // First visit pays leaves; if Binhi grows, close his celebration.
    for (var i = 0; i < 60; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.text('YAY!').evaluate().isNotEmpty) {
        await tester.tap(find.text('YAY!'));
        await settle(tester);
      }
    }

    final view = find.byWidgetPredicate((w) => w is PlantView && w.mode == PlantMode.detail);
    expect(view, findsOneWidget);
    PlantPainter painter() => tester
        .widgetList<CustomPaint>(find.descendant(of: view, matching: find.byType(CustomPaint)))
        .map((c) => c.painter)
        .whereType<PlantPainter>()
        .single;

    // Tap the pink flowers on the drawing (design point → screen).
    final box = tester.getRect(view);
    final scale = box.height / PlantDrawing.designSize.height;
    final left = box.left + (box.width - PlantDrawing.designSize.width * scale) / 2;
    await tester.tapAt(Offset(left, box.top) + const Offset(106, 98) * scale);
    await tester.pump(); // the reaction's clock starts on this frame
    await tester.pump(const Duration(milliseconds: 600));
    expect(tester.widget<PlantView>(view).highlight, PlantPart.special);
    expect(painter().touch?.fold, 1, reason: 'the leaves folded');
    await tester.pump(const Duration(seconds: 5));
    expect(painter().touch, isNull, reason: 'open again');

    // The Flower button under the plant does the same.
    await tester.tap(find.text('Flower').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(painter().touch?.fold, 1, reason: 'the part button folds it too');
    await tester.pump(const Duration(seconds: 5));
    await endApp(tester, db);
  });
}
