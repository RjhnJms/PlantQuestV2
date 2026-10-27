import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/read_aloud.dart';
import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';
import '../theme/app_text.dart';
import 'pressable_3d.dart';
import '../app/navigation.dart';
import '../art/icons/kid_icon.dart';

/// A square chunky icon button, e.g. Back or the Settings gear.
class SquareIconButton extends StatelessWidget {
  const SquareIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
    this.size = AppSizes.minTap,
  });

  /// The usual Back button at the top left of a screen.
  factory SquareIconButton.back(BuildContext context, {VoidCallback? onPressed}) =>
      SquareIconButton(icon: KidIcon.back, semanticLabel: 'Back', onPressed: onPressed ?? () => goBackOrHome(context));

  final KidIcon icon;
  final VoidCallback? onPressed;
  final String semanticLabel;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Pressable3D(
        onTap: onPressed,
        faceColor: AppColors.card,
        ledgeColor: AppColors.borderDeep,
        borderColor: AppColors.border,
        radius: AppSizes.radiusS,
        highlight: false,
        glow: false,
        semanticLabel: semanticLabel,
        child: Center(child: KidIconView(icon, size: AppSizes.iconMedium)),
      ),
    );
  }
}

/// A round sky-blue speaker button that reads [text] aloud.
///
/// The visible circle is small, but the tap area is the full 56 dp.
class SpeakerButton extends ConsumerWidget {
  const SpeakerButton({super.key, required this.text, this.onDark = false});

  final String text;

  /// Use on colored cards: a white circle instead of sky blue.
  final bool onDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: AppSizes.minTap,
      height: AppSizes.minTap,
      child: Center(
        child: SizedBox(
          width: 44,
          height: 44,
          child: Pressable3D(
            onTap: () => speakOrExplain(context, ref, text),
            faceColor: onDark ? AppColors.card : AppColors.skyTint,
            ledgeColor: onDark ? AppColors.borderDeep : AppColors.skyLight,
            radius: 22,
            glow: false,
            semanticLabel: 'Read aloud',
            child: const KidIconView(KidIcon.speaker, size: AppSizes.iconMedium),
          ),
        ),
      ),
    );
  }
}

/// Reads [text] aloud, or, on a phone with no English voice, explains
/// (once per app run) how a grown-up can add one. Never links out.
Future<void> speakOrExplain(BuildContext context, WidgetRef ref, String text) async {
  final reader = ref.read(readAloudProvider);
  if (await reader.hasVoice()) {
    await reader.speak(text);
    return;
  }
  if (_toldAboutVoice || !context.mounted) return;
  _toldAboutVoice = true;
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.background,
    showDragHandle: true,
    builder: (context) => const NoVoiceTip(),
  );
}

bool _toldAboutVoice = false;

/// Friendly help when the phone has no offline voice.
class NoVoiceTip extends StatelessWidget {
  const NoVoiceTip({super.key, this.inline = false});

  /// Shown as a card inside Settings instead of a sheet.
  final bool inline;

  @override
  Widget build(BuildContext context) {
    const body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            KidIconView(KidIcon.voice, size: AppSizes.iconMedium),
            SizedBox(width: AppSizes.gapS),
            Expanded(child: Text('Binhi needs a voice', style: AppText.heading)),
          ],
        ),
        SizedBox(height: AppSizes.gapS),
        Text(
          'This phone has no reading voice yet. Ask a grown-up to open the phone Settings, '
          'find Text-to-speech, and download an English voice. It works without internet after that.',
          style: AppText.body,
        ),
      ],
    );
    if (inline) {
      return Container(
        padding: const EdgeInsets.all(AppSizes.gapL),
        decoration: BoxDecoration(color: AppColors.grapeTint, borderRadius: BorderRadius.circular(AppSizes.radiusM)),
        child: body,
      );
    }
    return const SafeArea(
      child: Padding(padding: EdgeInsets.fromLTRB(AppSizes.gutter, 0, AppSizes.gutter, AppSizes.gapXl), child: body),
    );
  }
}
