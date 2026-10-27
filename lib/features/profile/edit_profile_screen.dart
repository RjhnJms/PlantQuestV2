import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../art/avatars/avatar_view.dart';
import '../../state/providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_sizes.dart';
import '../../theme/app_text.dart';
import '../../widgets/chunky_button.dart';
import '../../widgets/form_pieces.dart';
import '../../widgets/round_buttons.dart';
import '../../app/navigation.dart';
import '../../game/badges.dart';

/// Screen 16: change name, grade and look (docs/screens/16-edit-profile.jpg).
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _name = TextEditingController();
  int? _grade;
  String? _avatar;
  bool _loaded = false;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return; // one tap only
    setState(() => _saving = true);
    await ref
        .read(gameActionsProvider)
        .saveProfile(name: _name.text, grade: _grade ?? 3, avatarId: _avatar ?? AvatarSpec.all.first.id);
    if (mounted) goBackOrHome(context);
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider).value;
    if (!_loaded && profile != null) {
      _loaded = true;
      _name.text = profile.name;
      _grade = profile.grade;
      _avatar = profile.avatarId;
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSizes.gutter, AppSizes.gapM, AppSizes.gutter, 0),
              child: Row(
                children: [
                  SquareIconButton.back(context),
                  const SizedBox(width: AppSizes.gapM),
                  const Flexible(child: Text('Edit profile', style: AppText.title)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(AppSizes.gutter, AppSizes.gapL, AppSizes.gutter, AppSizes.gapL),
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(color: AppColors.card, shape: BoxShape.circle),
                      child: AvatarView(avatarId: _avatar, size: 112),
                    ),
                  ),
                  const FieldLabel('Your name'),
                  NameField(controller: _name),
                  const FieldLabel('Your grade'),
                  GradePicker(selected: _grade, onChanged: (g) => setState(() => _grade = g)),
                  const FieldLabel('Your look'),
                  AvatarGrid(
                    selected: _avatar,
                    onChanged: (a) => setState(() => _avatar = a),
                    animalsUnlocked: ref.watch(animalsUnlockedProvider),
                    animalHints: {
                      for (final b in Achievement.values)
                        if (b.animal != null) b.animal!: b.shortHow,
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSizes.gutter, AppSizes.gapS, AppSizes.gutter, AppSizes.gapL),
              child: ChunkyButton(label: 'SAVE', onPressed: _saving ? null : _save),
            ),
          ],
        ),
      ),
    );
  }
}
