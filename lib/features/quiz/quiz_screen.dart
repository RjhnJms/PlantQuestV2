import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../art/binhi/binhi.dart';
import '../../content/questions.dart';
import '../../data/progress_repository.dart';
import '../../game/quiz_session.dart';
import '../../game/review.dart';
import '../../game/rules.dart';
import '../../services/music_service.dart';
import '../../state/providers.dart';
import '../../state/effects.dart';
import '../../state/settings.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_sizes.dart';
import '../../theme/app_text.dart';
import '../../widgets/app_progress_bar.dart';
import '../../widgets/chunky_button.dart';
import '../../widgets/kid_sheet.dart';
import '../../widgets/round_buttons.dart';
import '../../widgets/speakable_text.dart';
import '../../widgets/speech_bubble.dart';
import '../../widgets/stat_pill.dart';
import 'answer_views.dart';
import 'results_view.dart';
import '../../app/navigation.dart';
import '../../art/icons/kid_icon.dart';

/// Screens 8–11: a quiz from question to Results
/// (docs/screens/08-quiz-question.jpg … 11-results.jpg).
///
/// [plantId] for a plant's 3-question quiz, [level] for Sprout/Sapling, or
/// [review] for smart review (PLAN.md §5i).
class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key, this.plantId, this.level, this.review = false})
    : assert((plantId != null ? 1 : 0) + (level != null ? 1 : 0) + (review ? 1 : 0) == 1);

  final String? plantId;
  final QuizLevel? level;
  final bool review;

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  late QuizSession _session;
  late Future<int?> _attempt;
  Future<QuizResult?>? _result;
  final _binhi = BinhiController();
  final _answersKey = GlobalKey();
  final _leavesCardKey = GlobalKey();
  final _growthKey = GlobalKey();

  /// For "You unlocked the next plant!": was the next stop locked before?
  bool _nextWasLocked = false;

  late final MusicService _music;

  @override
  void initState() {
    super.initState();
    _music = ref.read(musicServiceProvider)..enterQuiz();
    _start();
  }

  void _start() {
    final path = ref.read(pathProvider).value ?? PathState.from({});
    _session = widget.review
        ? QuizSession.review((ref.read(reviewPlanProvider).value ?? const ReviewPlan()).questions(math.Random()))
        : widget.plantId != null
        ? QuizSession.plant(widget.plantId!)
        : QuizSession.level(widget.level!, path.unlockedIds);
    final next = widget.plantId == null ? null : PathState.nextAfter(widget.plantId!);
    _nextWasLocked = next != null && !path.isUnlocked(next);
    _result = null;
    _attempt = ref.read(gameActionsProvider).startQuiz(_session.kind, plantId: widget.plantId, total: _session.total);
  }

  @override
  void dispose() {
    _music.leaveQuiz();
    _binhi.dispose();
    super.dispose();
  }

  void _pick(String id) {
    if (_session.select(id)) setState(() {});
  }

  void _check() {
    final q = _session.current;
    final chosen = _session.selected;
    final right = _session.check();
    if (right == null) return; // one tap only
    if (right) {
      _binhi.cheer();
      celebrateCorrect(ref, screenCenterOf(_answersKey));
    } else {
      comfortWrong(ref);
    }
    final actions = ref.read(gameActionsProvider);
    _attempt.then((id) => actions.saveAnswer(id, q.id, chosen: chosen!, correct: right));
    setState(() {});
  }

  void _continue() {
    if (!_session.next()) return; // one tap only
    if (_session.phase == QuizPhase.finished) {
      final actions = ref.read(gameActionsProvider);
      final result = _attempt.then(actions.finishQuiz);
      _result = result;
      result.then(_celebrateResult);
    }
    setState(() {});
  }

  /// Leaves fly from the LEAVES card into Binhi's growth bar; if Binhi
  /// grew, the full-screen celebration follows.
  Future<void> _celebrateResult(QuizResult? r) async {
    if (r == null || !mounted) return;
    // Let the Results screen draw first so the cards have a position.
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    if (r.score * 2 >= r.total) {
      final feel = ref.read(motionFeelProvider);
      final top = screenCenterOf(_leavesCardKey);
      if (top != null) ref.read(confettiProvider).burst(top, count: feel.confetti, seconds: feel.burstSeconds);
    }
    await celebrateLeaves(
      context,
      ref,
      from: screenCenterOf(_leavesCardKey),
      to: screenCenterOf(_growthKey),
      earned: r.leavesEarned,
      earnedBefore: r.earnedBefore,
    );
    if (!mounted) return;
    if (r.newSticker != null) await celebrateSticker(context, ref, r.newSticker!);
    if (mounted) await celebrateBadges(context, ref);
  }

  Future<void> _askToStop() async {
    final stop = await showKidConfirm(
      context,
      title: 'Stop this quiz?',
      message: 'If you stop now, this quiz will not count.',
      keepLabel: 'KEEP PLAYING',
      doLabel: 'Stop',
      mood: BinhiMood.encouraging,
    );
    if (stop && mounted) goBackOrHome(context);
  }

  @override
  Widget build(BuildContext context) {
    final finished = _session.phase == QuizPhase.finished;
    return PopScope(
      canPop: finished,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _askToStop();
      },
      child: finished ? _results() : _question(),
    );
  }

  Widget _results() => ResultsView(
    result: _result!,
    localScore: _session.correctCount,
    total: _session.total,
    plantId: widget.plantId,
    unlockedNext: _nextWasLocked,
    // A review ends when its questions are done; missed ones come back.
    onPlayAgain: widget.review ? null : () => setState(_start),
    review: widget.review,
    leavesCardKey: _leavesCardKey,
    growthKey: _growthKey,
  );

  Widget _question() {
    final q = _session.current;
    final checked = _session.phase == QuizPhase.checked;
    final right = _session.lastCorrect;
    final leaves = ref.watch(leavesProvider).value;
    final still = ref.watch(lessMotionProvider);
    final stage = ref.watch(binhiStageProvider).value ?? BinhiStage.seed;

    final answers = switch (q.type) {
      QuestionType.multipleChoice => ChoiceList(
        options: _session.options,
        selected: _session.selected,
        checked: checked,
        correctId: q.correctId,
        onPick: _pick,
      ),
      QuestionType.pictureChoice => PictureGrid(
        options: _session.options,
        selected: _session.selected,
        checked: checked,
        correctId: q.correctId,
        onPick: _pick,
      ),
      QuestionType.tapPart => TapPartAnswer(question: q, selected: _session.selected, checked: checked, onPick: _pick),
    };

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSizes.gapM, AppSizes.gapS, AppSizes.gapM, 0),
              child: Row(
                children: [
                  SquareIconButton(icon: KidIcon.close, semanticLabel: 'Stop quiz', onPressed: _askToStop),
                  const SizedBox(width: AppSizes.gapM),
                  Expanded(
                    child: AppProgressBar(value: _session.progress, height: 16, semanticLabel: 'Quiz progress'),
                  ),
                  const SizedBox(width: AppSizes.gapS),
                  LeafTarget(child: StatPill.leaves(value: leaves)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(AppSizes.gutter, AppSizes.gapM, AppSizes.gutter, AppSizes.gapL),
                children: [
                  Text('Question ${_session.index + 1} of ${_session.total}', style: AppText.label),
                  const SizedBox(height: AppSizes.gapS),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Binhi(
                        stage: stage,
                        outfit: ref.watch(binhiOutfitProvider),
                        size: 62,
                        controller: _binhi,
                        reduceMotion: still,
                        mood: !checked
                            ? BinhiMood.happy
                            : right!
                            ? BinhiMood.cheering
                            : BinhiMood.encouraging,
                      ),
                      const SizedBox(width: AppSizes.gapS),
                      Expanded(child: SpeechBubble(text: q.prompt)),
                    ],
                  ),
                  const SizedBox(height: AppSizes.gapL),
                  KeyedSubtree(key: _answersKey, child: answers),
                ],
              ),
            ),
            _Footer(
              checked: checked,
              right: right ?? false,
              canCheck: _session.selected != null,
              question: q,
              isLast: _session.isLast,
              onCheck: _check,
              onContinue: _continue,
            ),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.checked,
    required this.right,
    required this.canCheck,
    required this.question,
    required this.isLast,
    required this.onCheck,
    required this.onContinue,
  });

  final bool checked;
  final bool right;
  final bool canCheck;
  final Question question;
  final bool isLast;
  final VoidCallback onCheck;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    if (!checked) {
      return Container(
        decoration: const BoxDecoration(
          color: AppColors.card,
          border: Border(
            top: BorderSide(color: AppColors.border, width: AppSizes.borderWidth),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(AppSizes.gutter, AppSizes.gapM, AppSizes.gutter, AppSizes.gapL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              question.type == QuestionType.tapPart ? 'Tap a part of the plant.' : 'Tap an answer.',
              style: AppText.label.copyWith(color: AppColors.text),
            ),
            const SizedBox(height: AppSizes.gapS),
            ChunkyButton(label: 'CHECK', onPressed: canCheck ? onCheck : null),
          ],
        ),
      );
    }

    final title = right ? 'Correct!' : 'Good try!';
    final spoken = right
        ? '$title ${question.reason}'
        : '$title The answer is ${question.correctLabel}. ${question.reason}';
    return Semantics(
      liveRegion: true,
      child: Container(
        decoration: BoxDecoration(
          color: right ? AppColors.leafTint : AppColors.coralTint,
          border: Border(
            top: BorderSide(color: right ? AppColors.leaf : AppColors.coral, width: AppSizes.borderWidth),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(AppSizes.gutter, AppSizes.gapM, AppSizes.gapS, AppSizes.gapL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppText.title),
                      if (!right)
                        Text('Answer: ${question.correctLabel}', style: AppText.heading.copyWith(fontSize: 18)),
                      const SizedBox(height: 2),
                      SpeakableText(question.reason, style: AppText.body),
                    ],
                  ),
                ),
                SpeakerButton(text: spoken),
              ],
            ),
            const SizedBox(height: AppSizes.gapM),
            Padding(
              padding: const EdgeInsets.only(right: AppSizes.gapM),
              child: ChunkyButton(
                label: isLast ? 'SEE RESULTS' : 'CONTINUE',
                tone: right ? ButtonTone.leaf : ButtonTone.coral,
                onPressed: onContinue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
