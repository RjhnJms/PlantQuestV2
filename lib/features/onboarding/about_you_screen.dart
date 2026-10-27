import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../art/avatars/avatar_view.dart';
import '../../art/binhi/binhi.dart';
import '../../state/providers.dart';
import '../../state/settings.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_sizes.dart';
import '../../theme/app_text.dart';
import '../../widgets/chunky_button.dart';
import '../../widgets/form_pieces.dart';
import '../../widgets/round_buttons.dart';
import '../../widgets/speech_bubble.dart';

/// Screen 4: name, grade and look (docs/screens/04-about-you.jpg).
/// Skip makes the name "Explorer".
class AboutYouScreen extends ConsumerStatefulWidget {
  const AboutYouScreen({super.key});

  @override
  ConsumerState<AboutYouScreen> createState() => _AboutYouScreenState();
}

class _AboutYouScreenState extends ConsumerState<AboutYouScreen> {
  final _name = TextEditingController();
  int? _grade;
  String? _avatar;
  bool _saving = false;

  bool get _ready => _name.text.trim().isNotEmpty && _grade != null;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _finish({required bool skip}) async {
    if (_saving) return; // one tap only
    setState(() => _saving = true);
    await ref
        .read(gameActionsProvider)
        .saveProfile(name: skip ? null : _name.text, grade: _grade ?? 3, avatarId: _avatar ?? AvatarSpec.all.first.id);
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSizes.gutter, AppSizes.gapM, AppSizes.gapS, 0),
              child: Row(
                children: [
                  SquareIconButton.back(context),
                  const Spacer(),
                  TextButton(
                    onPressed: _saving ? null : () => _finish(skip: true),
                    style: TextButton.styleFrom(minimumSize: const Size(AppSizes.minTap * 1.4, AppSizes.minTap)),
                    child: Text('Skip', style: AppText.heading.copyWith(color: AppColors.textMuted)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(AppSizes.gutter, AppSizes.gapM, AppSizes.gutter, AppSizes.gapL),
                children: [
                  Row(
                    children: [
                      Binhi(stage: BinhiStage.sprout, size: 66, reduceMotion: ref.watch(lessMotionProvider)),
                      const SizedBox(width: AppSizes.gapS),
                      const Expanded(child: SpeechBubble(text: 'Hi! I am Binhi. What should I call you?')),
                    ],
                  ),
                  const FieldLabel('Your name'),
                  NameField(controller: _name, onChanged: (_) => setState(() {})),
                  const FieldLabel('Your grade'),
                  GradePicker(selected: _grade, onChanged: (g) => setState(() => _grade = g)),
                  const FieldLabel('Pick your look'),
                  Transform.translate(
                    offset: const Offset(0, -AppSizes.gapS),
                    child: const Text('Swipe to see more. You can change it later.', style: AppText.bodySmall),
                  ),
                  AvatarCarousel(selected: _avatar, onChanged: (a) => setState(() => _avatar = a)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSizes.gutter, AppSizes.gapS, AppSizes.gutter, AppSizes.gapL),
              child: ChunkyButton(
                label: "LET'S GO!",
                onPressed: _ready && !_saving ? () => _finish(skip: false) : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
