import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../art/binhi/binhi.dart';
import '../../data/backup.dart';
import '../../services/backup_files.dart';
import '../../services/read_aloud.dart';
import '../../state/providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_sizes.dart';
import '../../theme/app_text.dart';
import '../../widgets/chunky_button.dart';
import '../../widgets/chunky_card.dart';
import '../../state/settings.dart';
import '../../widgets/effects/reward_moment.dart';
import '../../widgets/kid_sheet.dart';
import '../../widgets/round_buttons.dart';
import '../../art/icons/kid_icon.dart';

/// Screen 14: sound, reading, Binhi's voice, motion, saving progress to a
/// file, and Start over
/// (docs/screens/14-settings.jpg, 15-start-over.jpg).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(profileProvider).value;
    final actions = ref.watch(gameActionsProvider);
    final leaves = ref.watch(leavesEarnedProvider).value ?? 0;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSizes.gutter, AppSizes.gapM, AppSizes.gutter, AppSizes.gapXxl),
          children: [
            Row(
              children: [
                SquareIconButton.back(context),
                const SizedBox(width: AppSizes.gapM),
                const Flexible(child: Text('Settings', style: AppText.title)),
              ],
            ),
            const _Section(icon: KidIcon.speaker, color: AppColors.sky, title: 'Sound'),
            _SwitchRow(
              title: 'Sounds',
              line: 'Turn off for a quiet classroom. Speaker buttons still work.',
              value: p?.soundOn ?? true,
              onChanged: (v) => actions.updateSettings(soundOn: v),
            ),
            const SizedBox(height: AppSizes.gapM),
            _SwitchRow(
              title: 'Music',
              line: 'Soft marimba music. It gets quieter in quizzes and when Binhi talks.',
              value: p?.musicOn ?? true,
              onChanged: (v) => actions.updateSettings(musicOn: v),
            ),
            const _Section(icon: KidIcon.book, color: AppColors.teal, title: 'Reading'),
            ChunkyCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SwitchLine(
                    title: 'Read questions to me',
                    line: 'Binhi reads each question out loud.',
                    value: p?.autoRead ?? true,
                    onChanged: (v) => actions.updateSettings(autoRead: v),
                  ),
                  const SizedBox(height: AppSizes.gapM),
                  const Text('Talking speed', style: AppText.heading),
                  const SizedBox(height: AppSizes.gapS),
                  _Choice(
                    options: const {'slow': 'Slow', 'normal': 'Normal'},
                    value: p?.speechRate ?? 'normal',
                    onChanged: (v) => actions.updateSettings(speechRate: v),
                  ),
                ],
              ),
            ),
            const _Section(icon: KidIcon.voice, color: AppColors.grapeInk, title: "Binhi's voice"),
            ChunkyCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tap the play button to listen. Then pick one you like.', style: AppText.bodySmall),
                  const SizedBox(height: AppSizes.gapM),
                  if (ref.watch(hasVoiceProvider).value == false) ...[
                    const NoVoiceTip(inline: true),
                    const SizedBox(height: AppSizes.gapM),
                  ],
                  _VoiceRow(
                    title: 'Automatic',
                    line: 'The clearest voice on this phone',
                    selected: p?.voiceId == null,
                    onPick: () => actions.updateSettings(voiceId: const Value(null)),
                    onPreview: () => speakOrExplain(context, ref, 'Hi! I am Binhi.'),
                  ),
                  for (final v in ref.watch(voicesProvider).value ?? const <VoiceOption>[]) ...[
                    const SizedBox(height: AppSizes.gapS),
                    _VoiceRow(
                      title: v.label,
                      line: 'A voice on this phone',
                      selected: p?.voiceId == v.name,
                      onPick: () => actions.updateSettings(voiceId: Value(v.name)),
                      onPreview: () => ref.read(readAloudProvider).speak('Hi! I am Binhi.', voiceName: v.name),
                    ),
                  ],
                  const SizedBox(height: AppSizes.gapL),
                  const Text('Voice style', style: AppText.heading),
                  const SizedBox(height: AppSizes.gapS),
                  _Choice(
                    options: const {'cheerful': 'Cheerful', 'normal': 'Normal', 'calm': 'Calm'},
                    value: p?.voiceStyle ?? 'cheerful',
                    onChanged: (v) => actions.updateSettings(voiceStyle: v),
                  ),
                ],
              ),
            ),
            const _Section(icon: KidIcon.sparkle, color: AppColors.sunshine, title: 'Motion'),
            _SwitchRow(
              title: 'Less motion',
              line: 'Calmer animations. Nothing moves in the background.',
              value: p?.lessMotion ?? false,
              onChanged: (v) => actions.updateSettings(lessMotion: v),
            ),
            const _Section(icon: KidIcon.restart, color: AppColors.coral, title: 'Progress'),
            const _BackupCard(),
            const SizedBox(height: AppSizes.gapM),
            ChunkyCard(
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Start over', style: AppText.heading),
                        Text(
                          'Clears leaves, garden and quiz scores. Your name and settings stay.',
                          style: AppText.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSizes.gapS),
                  ChunkyButton(
                    label: 'Start over',
                    small: true,
                    expand: false,
                    tone: ButtonTone.white,
                    onPressed: () async {
                      final yes = await showKidConfirm(
                        context,
                        title: 'Start over?',
                        message: 'This clears your leaves, garden and quiz scores. Binhi goes back to a seed.',
                        keepLabel: 'KEEP MY PROGRESS',
                        doLabel: 'Start over',
                        stage: BinhiStage.forLeaves(leaves),
                      );
                      if (yes) await actions.startOver();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Save all progress to a file, or load it back on a new or reset phone
/// (PLAN.md §5h).
class _BackupCard extends ConsumerStatefulWidget {
  const _BackupCard();

  @override
  ConsumerState<_BackupCard> createState() => _BackupCardState();
}

class _BackupCardState extends ConsumerState<_BackupCard> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() job) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await job();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save() => _run(() async {
    final backup = Backup(ref.read(databaseProvider));
    final name = Backup.fileName(ref.read(profileProvider).value?.name, DateTime.now());
    final saved = await ref.read(backupFilesProvider).save(name, await backup.export());
    if (!saved || !mounted) return;
    await showRewardMoment(
      context,
      title: 'Saved!',
      art: const KidIconView(KidIcon.check, size: 96),
      message: 'Your progress is safe in "$name". Keep it somewhere you can find it, like Downloads or Google Drive.',
      color: AppColors.leaf,
      titleColor: AppColors.leafDark,
      buttonLabel: 'OK',
      reduceMotion: ref.read(lessMotionProvider),
    );
  });

  Future<void> _load() => _run(() async {
    final bytes = await ref.read(backupFilesProvider).pick();
    if (bytes == null || !mounted) return;
    final yes = await showKidConfirm(
      context,
      title: 'Load this progress?',
      message: 'It replaces everything on this phone: leaves, plants, garden and badges.',
      keepLabel: "KEEP THIS PHONE'S",
      doLabel: 'Load it',
      mood: BinhiMood.encouraging,
    );
    if (!yes || !mounted) return;
    String title;
    String message;
    try {
      await Backup(ref.read(databaseProvider)).restore(bytes);
      title = 'Welcome back!';
      message = 'Your leaves, plants, garden and badges are all here.';
    } on BackupException catch (e) {
      title = "That file won't open";
      message = switch (e.problem) {
        BackupProblem.notABackup => "It isn't a PlantQuest save. Look for a file named like PlantQuest-….json.",
        BackupProblem.tooNew => 'It was saved by a newer PlantQuest. Update the app first, then try again.',
      };
    }
    if (!mounted) return;
    await showRewardMoment(
      context,
      title: title,
      art: Binhi(
        stage: BinhiStage.forLeaves(ref.read(leavesEarnedProvider).value ?? 0),
        size: 110,
        mood: title == 'Welcome back!' ? BinhiMood.cheering : BinhiMood.encouraging,
        reduceMotion: true,
      ),
      message: message,
      color: AppColors.sky,
      titleColor: AppColors.skyDark,
      buttonLabel: 'OK',
      reduceMotion: ref.read(lessMotionProvider),
    );
  });

  @override
  Widget build(BuildContext context) => ChunkyCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Save my progress', style: AppText.heading),
        const Text(
          'Keep a copy of everything in a file. Load it on a new phone, or after Start over, to pick up where you left off.',
          style: AppText.bodySmall,
        ),
        const SizedBox(height: AppSizes.gapM),
        Row(
          children: [
            Expanded(
              child: ChunkyButton(label: 'SAVE', icon: KidIcon.check, small: true, onPressed: _busy ? null : _save),
            ),
            const SizedBox(width: AppSizes.gapS),
            Expanded(
              child: ChunkyButton(
                label: 'LOAD',
                icon: KidIcon.restart,
                small: true,
                tone: ButtonTone.white,
                onPressed: _busy ? null : _load,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _Section extends StatelessWidget {
  const _Section({required this.icon, required this.color, required this.title});

  final KidIcon icon;
  final Color color;
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: AppSizes.gapXl, bottom: AppSizes.gapM),
    child: Row(
      children: [
        KidIconView(icon, size: AppSizes.iconMedium),
        const SizedBox(width: AppSizes.gapS),
        Text(title, style: AppText.heading),
      ],
    ),
  );
}

/// A whole-row switch: the full card is the tap target.
class _SwitchRow extends StatelessWidget {
  const _SwitchRow({required this.title, required this.line, required this.value, required this.onChanged});

  final String title;
  final String line;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => ChunkyCard(
    child: _SwitchLine(title: title, line: line, value: value, onChanged: onChanged),
  );
}

class _SwitchLine extends StatelessWidget {
  const _SwitchLine({required this.title, required this.line, required this.value, required this.onChanged});

  final String title;
  final String line;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSizes.minTap),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppText.heading),
                    Text(line, style: AppText.bodySmall),
                  ],
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeThumbColor: AppColors.card,
                activeTrackColor: AppColors.leafDark,
                inactiveThumbColor: AppColors.card,
                inactiveTrackColor: AppColors.borderDeep,
                trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Two or three big side-by-side choices (talking speed, voice style).
class _Choice extends StatelessWidget {
  const _Choice({required this.options, required this.value, required this.onChanged});

  final Map<String, String> options;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final entries = options.entries.toList();
    return Row(
      children: [
        for (final (i, e) in entries.indexed) ...[
          Expanded(
            child: Semantics(
              selected: e.key == value,
              child: ChunkyButton(
                label: e.value,
                small: true,
                tone: e.key == value ? ButtonTone.sky : ButtonTone.white,
                onPressed: () => onChanged(e.key),
              ),
            ),
          ),
          if (i < entries.length - 1) const SizedBox(width: AppSizes.gapS),
        ],
      ],
    );
  }
}

class _VoiceRow extends StatelessWidget {
  const _VoiceRow({
    required this.title,
    required this.line,
    required this.selected,
    required this.onPick,
    required this.onPreview,
  });

  final String title;
  final String line;
  final bool selected;
  final VoidCallback onPick;
  final VoidCallback onPreview;

  @override
  Widget build(BuildContext context) {
    return ChunkyCard(
      onTap: onPick,
      semanticLabel: '$title. $line${selected ? ', picked' : ''}',
      color: selected ? AppColors.leafTint : AppColors.card,
      outlineColor: selected ? AppColors.leaf : null,
      ledgeColor: selected ? AppColors.leafDark : AppColors.borderDeep,
      padding: const EdgeInsets.fromLTRB(AppSizes.gapM, AppSizes.gapS, AppSizes.gapS, AppSizes.gapS),
      child: Row(
        children: [
          KidIconView(selected ? KidIcon.check : KidIcon.empty, size: AppSizes.iconMedium),
          const SizedBox(width: AppSizes.gapM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.heading),
                Text(line, style: AppText.bodySmall),
              ],
            ),
          ),
          SquareIconButton(icon: KidIcon.play, semanticLabel: 'Listen to $title', onPressed: onPreview),
        ],
      ),
    );
  }
}
