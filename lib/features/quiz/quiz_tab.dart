import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../art/binhi/binhi.dart';
import '../../art/plants/plant_view.dart';
import '../../art/watering_can.dart';
import '../../content/plant_catalog.dart';
import '../../content/questions.dart';
import '../../data/database.dart';
import '../../game/review.dart';
import '../../game/rules.dart';
import '../../state/providers.dart';
import '../../state/settings.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_sizes.dart';
import '../../theme/app_text.dart';
import '../../widgets/chunky_card.dart';
import '../games/game_pieces.dart';
import '../../art/icons/kid_icon.dart';

/// Screen 12, "Binhi's Quiz Show" (PLAN.md D26, owner picked the puppet
/// theatre from docs/previews/quiz-show/): Binhi pops up in a puppet booth
/// holding the PLAY sign for your level. Below: the bonus round (smart
/// review), the challenge level, Match it and the plant "contestants".
class QuizTab extends ConsumerWidget {
  const QuizTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grade = ref.watch(profileProvider).value?.grade ?? 3;
    final yours = QuizLevel.forGrade(grade);
    final best = ref.watch(bestLevelScoreProvider).value;
    final path = ref.watch(pathProvider).value ?? PathState.from({});
    final progress = ref.watch(plantProgressProvider).value ?? const <String, PlantProgressRow>{};
    final wins = ref.watch(gameWinsProvider).value ?? const <(MiniGame, String)>{};
    final locked = PlantCatalog.all.where((p) => !path.isUnlocked(p.id)).length;
    final review = ref.watch(reviewPlanProvider).value ?? const ReviewPlan();
    final unlocked = PlantCatalog.all.where((p) => path.isUnlocked(p.id)).toList();

    return Scaffold(
      backgroundColor: _Booth.wall,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppSizes.gapXxl),
          children: [
            _PuppetStage(level: yours, best: best),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSizes.gutter, AppSizes.gapL, AppSizes.gutter, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // The bonus round comes first when something is waiting.
                  if (!review.isEmpty) ...[
                    _BonusTicket(plan: review),
                    const SizedBox(height: AppSizes.gapM),
                  ] else if (path.doneCount > 0) ...[
                    const _CaughtUp(),
                    const SizedBox(height: AppSizes.gapM),
                  ],
                  for (final level in QuizLevel.values.where((l) => l != yours)) _ChallengeCard(level: level),
                  const SizedBox(height: AppSizes.gapM),
                  GameCard(
                    title: 'Match it',
                    line: 'What is each plant known for?',
                    icon: KidIcon.match,
                    leavesLeft: PlantCatalog.all.fold(0, (sum, p) => sum + gameLeavesLeft(wins, MiniGame.match, p.id)),
                    onTap: () => context.push('/games/match'),
                  ),
                  const SizedBox(height: AppSizes.gapXl),
                  const Text('Contestants', style: AppText.title),
                  const Text('Each plant has its own quiz.', style: AppText.bodySmall),
                  const SizedBox(height: AppSizes.gapS),
                ],
              ),
            ),
            SizedBox(
              height: 150 + MediaQuery.textScalerOf(context).scale(30),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(AppSizes.gutter, 4, AppSizes.gutter, 8),
                itemCount: unlocked.length,
                separatorBuilder: (_, _) => const SizedBox(width: AppSizes.gapS),
                itemBuilder: (context, i) {
                  final plant = unlocked[i];
                  final done = path.of(plant.id) == StopState.done;
                  final score = progress[plant.id]?.bestScore;
                  return _Contestant(
                    plant: plant,
                    best: done && score != null ? (score, QuestionBank.plantQuiz(plant.id).length) : null,
                  );
                },
              ),
            ),
            // Locked quizzes are one line, not a wall of mystery tiles.
            if (locked > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSizes.gutter, AppSizes.gapS, AppSizes.gutter, 0),
                child: Semantics(
                  label: 'Locked plant quiz: $locked more unlock as you explore',
                  excludeSemantics: true,
                  child: Row(
                    children: [
                      const KidIconView(KidIcon.lock, size: AppSizes.iconSmall, muted: true),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '$locked more plant ${locked == 1 ? 'quiz unlocks' : 'quizzes unlock'} as you explore.',
                          style: AppText.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Colours of the puppet booth.
abstract final class _Booth {
  static const wall = Color(0xFFFFF4E0);
  static const dots = Color(0xFFF4E2BE);
  static const wood = Color(0xFFB9893F);
  static const woodDark = Color(0xFF8A5A2B);
  static const ink = Color(0xFF5B3A1E);
  static const night = Color(0xFF3E2A6E);
  static const curtain = Color(0xFFE0465A);
  static const curtainDark = Color(0xFFB5303F);

  /// The booth is drawn in a 320 × 310 box and scaled to fit.
  static const size = Size(320, 310);
}

/// The puppet theatre: curtains swing open, Binhi pops up holding the PLAY
/// sign, and a plaque shows the best level score.
class _PuppetStage extends ConsumerStatefulWidget {
  const _PuppetStage({required this.level, required this.best});

  final QuizLevel level;
  final (int, int)? best;

  @override
  ConsumerState<_PuppetStage> createState() => _PuppetStageState();
}

class _PuppetStageState extends ConsumerState<_PuppetStage> with TickerProviderStateMixin {
  /// Curtains opening (once, when the tab first shows).
  late final AnimationController _open = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));

  /// The PLAY sign gently rocking in Binhi's hands.
  late final AnimationController _rock = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (ref.read(lessMotionProvider) || MediaQuery.disableAnimationsOf(context)) {
        _open.value = 1;
      } else {
        _open.forward();
        _rock.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _open.dispose();
    _rock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final level = widget.level;
    final best = widget.best;
    final earned = ref.watch(leavesEarnedProvider).value ?? 0;
    final still = ref.watch(lessMotionProvider);
    // Never more than about 40% of the screen, so the cards below show.
    final height = math.min(330.0, MediaQuery.sizeOf(context).height * 0.4);
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: const _DotsPainter(),
        child: Center(
          child: FittedBox(
            child: SizedBox.fromSize(
              size: _Booth.size,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // The dark stage behind Binhi.
                  Positioned.fromRect(
                    rect: _BoothPainter.window,
                    child: const ColoredBox(color: _Booth.night),
                  ),
                  // Binhi the puppet, behind the curtains and the ledge.
                  Positioned(
                    left: 126,
                    top: 136,
                    child: AnimatedBuilder(
                      animation: _open,
                      builder: (context, child) {
                        final up = Curves.easeOutBack.transform(((_open.value - 0.45) / 0.55).clamp(0.0, 1.0));
                        return Transform.translate(offset: Offset(0, 70 * (1 - up)), child: child);
                      },
                      child: Binhi(
                        stage: BinhiStage.forLeaves(earned),
                        size: 68,
                        outfit: ref.watch(binhiOutfitProvider),
                        reduceMotion: still,
                        semanticLabel: 'Binhi, the quiz show host',
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: AnimatedBuilder(
                        animation: _open,
                        builder: (context, _) => CustomPaint(
                          painter: _BoothPainter(open: Curves.easeInOut.transform((_open.value / 0.6).clamp(0.0, 1.0))),
                        ),
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 40,
                    right: 40,
                    top: 40,
                    child: Center(
                      child: Text(
                        "Binhi's Quiz Show",
                        style: TextStyle(
                          fontFamily: AppText.family,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFFF1C7),
                        ),
                      ),
                    ),
                  ),
                  // The PLAY sign for your level.
                  Positioned(
                    left: 186,
                    top: 112,
                    width: 94,
                    child: AnimatedBuilder(
                      animation: Listenable.merge([_open, _rock]),
                      builder: (context, child) {
                        final up = Curves.easeOutBack.transform(((_open.value - 0.55) / 0.45).clamp(0.0, 1.0));
                        return Opacity(
                          opacity: up.clamp(0.0, 1.0),
                          child: Transform.translate(
                            offset: Offset(0, 60 * (1 - up)),
                            child: Transform.rotate(angle: 0.1 + (_rock.value - 0.5) * 0.08, child: child),
                          ),
                        );
                      },
                      child: ChunkyCard(
                        color: AppColors.leaf,
                        ledgeColor: AppColors.leafDark,
                        outlineColor: Colors.white,
                        radius: AppSizes.radiusS,
                        padding: const EdgeInsets.fromLTRB(6, 6, 6, 8),
                        onTap: () => context.push('/quiz/level/${level.name}'),
                        semanticLabel: 'YOUR LEVEL. ${level.title}. ${level.grades}, ${level.questionCount} questions.',
                        child: Column(
                          children: [
                            Text(
                              'YOUR LEVEL',
                              style: AppText.label.copyWith(color: Colors.white, fontSize: 9, letterSpacing: 0.6),
                            ),
                            const Text(
                              'PLAY',
                              style: TextStyle(
                                fontFamily: AppText.family,
                                fontSize: 26,
                                height: 1.05,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            FittedBox(
                              child: Text(
                                level.title,
                                style: AppText.label.copyWith(color: AppColors.text, fontSize: 12),
                              ),
                            ),
                            Text(
                              '${level.questionCount} questions',
                              style: AppText.label.copyWith(color: AppColors.text, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Best level score on a plaque.
                  Positioned(
                    left: 110,
                    right: 110,
                    top: 254,
                    height: 36,
                    child: Semantics(
                      label: best == null ? 'No best score yet' : 'Best score: ${best.$1} out of ${best.$2}',
                      excludeSemantics: true,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1C7),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _Booth.ink, width: 2.5),
                        ),
                        child: Text(
                          best == null ? 'BEST  –' : 'BEST  ${best.$1}/${best.$2}',
                          style: const TextStyle(
                            fontFamily: AppText.family,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _Booth.ink,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Little dots on the wall behind the booth.
class _DotsPainter extends CustomPainter {
  const _DotsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final dot = Paint()..color = _Booth.dots;
    for (var y = 7.0; y < size.height; y += 14) {
      for (var x = 7.0; x < size.width; x += 14) {
        canvas.drawCircle(Offset(x, y), 1.5, dot);
      }
    }
  }

  @override
  bool shouldRepaint(_DotsPainter old) => false;
}

/// The wooden booth around the window: roof arch, curtains (drawn [open]
/// from 0 shut to 1 tied back), the yellow valance and the ledge. The
/// window is see-through so Binhi can stand in it.
class _BoothPainter extends CustomPainter {
  const _BoothPainter({required this.open});

  final double open;

  static const window = Rect.fromLTRB(56, 96, 264, 226);

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeJoin = StrokeJoin.round
      ..color = _Booth.ink;
    void shape(Path p, Color c) => canvas
      ..drawPath(p, Paint()..color = c)
      ..drawPath(p, line);

    // The booth front, with the window cut out.
    final front = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(const Rect.fromLTRB(30, 78, 290, 304))
      ..addRect(window);
    shape(front, _Booth.wood);
    for (final y in [252.0, 280.0]) {
      canvas.drawLine(
        Offset(32, y),
        Offset(288, y),
        Paint()
          ..color = _Booth.woodDark.withValues(alpha: 0.35)
          ..strokeWidth = 2,
      );
    }
    // Curtains: from shut across the window to swept back at the sides.
    for (final left in [true, false]) {
      final inner = left ? 160 - (160 - 112) * open : 160 + (208 - 160) * open;
      final outer = left ? window.left : window.right;
      final sway = 20 * open;
      final p = Path()
        ..moveTo(outer, window.top)
        ..lineTo(inner + (left ? 18 : -18) * open, window.top)
        ..quadraticBezierTo(inner - (left ? sway : -sway), 160, inner, window.bottom)
        ..lineTo(outer, window.bottom)
        ..close();
      canvas.drawPath(p, Paint()..color = _Booth.curtain);
      for (var k = 1; k < 4; k++) {
        final x = outer + (inner - outer) * k / 4;
        canvas.drawLine(
          Offset(x, window.top + 14),
          Offset(x + (left ? -4 : 4), window.bottom - 4),
          Paint()
            ..color = _Booth.curtainDark
            ..strokeWidth = 2.5,
        );
      }
      if (open > 0.6) {
        canvas.drawCircle(
          Offset(left ? 112 : 208, 168),
          5,
          Paint()..color = AppColors.sunshine.withValues(alpha: (open - 0.6) / 0.4),
        );
      }
    }
    canvas.drawRect(window, line);

    // Scalloped valance.
    final valance = Path()
      ..moveTo(window.left, window.top)
      ..lineTo(window.right, window.top)
      ..lineTo(window.right, 112);
    for (var x = window.right; x > window.left + 1; x -= 20) {
      valance.quadraticBezierTo(x - 10, 124, x - 20, 112);
    }
    valance.close();
    shape(valance, AppColors.sunshine);

    // Roof arch.
    shape(
      Path()
        ..moveTo(30, 60)
        ..quadraticBezierTo(160, 6, 290, 60)
        ..lineTo(290, 80)
        ..lineTo(30, 80)
        ..close(),
      _Booth.woodDark,
    );

    // The ledge Binhi stands behind, and his puppet stick.
    shape(Path()..addRect(const Rect.fromLTRB(30, 224, 290, 240)), _Booth.woodDark);
    for (final (x, c) in const [(62.0, AppColors.bubblegum), (258.0, AppColors.sky)]) {
      shape(Path()..addOval(Rect.fromCircle(center: Offset(x, 272), radius: 13)), c);
    }
  }

  @override
  bool shouldRepaint(_BoothPainter old) => old.open != open;
}

/// The bonus round: smart review's tricky questions and plants to check on
/// (PLAN.md §5i), on a ticket.
class _BonusTicket extends StatelessWidget {
  const _BonusTicket({required this.plan});
  final ReviewPlan plan;

  @override
  Widget build(BuildContext context) {
    final t = plan.tricky.length;
    final r = plan.rusty.length;
    final parts = [
      if (t > 0) '$t tricky ${t == 1 ? 'question' : 'questions'}',
      if (r > 0) '$r ${r == 1 ? 'plant' : 'plants'} to check on',
    ];
    final count = plan.questions(math.Random(0)).length;
    return Semantics(
      button: true,
      label: 'Bonus round! ${parts.join(' and ')}. $count questions. Open.',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: () => context.push('/quiz/review'),
        child: ClipPath(
          clipper: const _TicketClipper(),
          child: Container(
            padding: const EdgeInsets.fromLTRB(AppSizes.gapL + 4, AppSizes.gapM, AppSizes.gapL, AppSizes.gapM + 4),
            decoration: const BoxDecoration(
              color: AppColors.sunshine,
              border: Border(bottom: BorderSide(color: AppColors.sunshineDark, width: 5)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 48, height: 48, child: CustomPaint(painter: WateringCanPainter())),
                const SizedBox(width: AppSizes.gapM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('BONUS ROUND', style: AppText.label.copyWith(color: AppColors.text, letterSpacing: 1)),
                      Text(parts.join(' · '), style: AppText.heading),
                      Text(
                        '$count quick ${count == 1 ? 'question' : 'questions'} · +${ReviewRules.leavesPerCorrect} leaf for each right answer',
                        style: AppText.bodySmall.copyWith(color: AppColors.text),
                      ),
                    ],
                  ),
                ),
                const KidIconView(KidIcon.next, size: AppSizes.iconSmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A ticket: rounded corners with a round notch bitten out of each side.
class _TicketClipper extends CustomClipper<Path> {
  const _TicketClipper();

  @override
  Path getClip(Size size) {
    final body = Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(14)));
    final notches = Path()
      ..addOval(Rect.fromCircle(center: Offset(0, size.height / 2), radius: 9))
      ..addOval(Rect.fromCircle(center: Offset(size.width, size.height / 2), radius: 9));
    return Path.combine(PathOperation.difference, body, notches);
  }

  @override
  bool shouldReclip(_TicketClipper old) => false;
}

/// Nothing to review right now.
class _CaughtUp extends StatelessWidget {
  const _CaughtUp();

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Review: all caught up. Questions you miss will come back here.',
    excludeSemantics: true,
    child: const Row(
      children: [
        KidIconView(KidIcon.check, size: AppSizes.iconSmall),
        SizedBox(width: 6),
        Expanded(child: Text('All caught up! Questions you miss will come back here.', style: AppText.bodySmall)),
      ],
    ),
  );
}

/// The other level, as a challenge.
class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({required this.level});

  final QuizLevel level;

  @override
  Widget build(BuildContext context) => ChunkyCard(
    color: AppColors.grapeTint,
    ledgeColor: AppColors.grape,
    onTap: () => context.push('/quiz/level/${level.name}'),
    semanticLabel: 'CHALLENGE. ${level.title}. ${level.grades}, ${level.questionCount} questions.',
    padding: const EdgeInsets.symmetric(horizontal: AppSizes.gapL, vertical: AppSizes.gapM),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('CHALLENGE', style: AppText.label.copyWith(color: AppColors.grapeDark)),
              Text(level.title, style: AppText.heading),
              Text('${level.questionCount} questions · ${level.grades}', style: AppText.bodySmall),
            ],
          ),
        ),
        const KidIconView(KidIcon.next, size: AppSizes.iconMedium),
      ],
    ),
  );
}

/// One plant quiz in the contestants row, with its best score.
class _Contestant extends StatelessWidget {
  const _Contestant({required this.plant, required this.best});

  final PlantInfo plant;

  /// (best, out of), once the quiz is done.
  final (int, int)? best;

  @override
  Widget build(BuildContext context) {
    final b = best;
    return SizedBox(
      width: 104,
      child: ChunkyCard(
        onTap: () => context.push('/quiz/plant/${plant.id}'),
        semanticLabel: '${plant.name} quiz${b == null ? '' : ', done, best ${b.$1} out of ${b.$2}'}',
        padding: const EdgeInsets.fromLTRB(6, 8, 6, 8),
        radius: AppSizes.radiusM,
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: b == null ? AppColors.sunshineTint : AppColors.leafTint,
              ),
              child: PlantView(plant: plant),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(plant.name, style: AppText.label.copyWith(color: AppColors.text, fontSize: 13)),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
              decoration: BoxDecoration(
                color: b == null ? AppColors.sunshineTint : AppColors.leafTint,
                borderRadius: BorderRadius.circular(AppSizes.radiusPill),
              ),
              child: Text(
                b == null ? 'New!' : '${b.$1}/${b.$2}',
                style: AppText.label.copyWith(
                  color: b == null ? const Color(0xFF8A6200) : AppColors.leafDark,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
