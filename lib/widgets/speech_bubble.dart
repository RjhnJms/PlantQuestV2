import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/read_aloud.dart';
import '../state/providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';
import '../theme/app_text.dart';
import 'round_buttons.dart';
import 'speakable_text.dart';

/// Binhi's speech bubble, with its tail pointing left toward Binhi and a
/// speaker button.
///
/// With "Read questions to me" on, Binhi reads the bubble aloud when it
/// appears and whenever its text changes (the next quiz question).
class SpeechBubble extends ConsumerStatefulWidget {
  const SpeechBubble({super.key, required this.text, this.speaker = true, this.style, this.autoRead = true});

  final String text;
  final bool speaker;
  final TextStyle? style;
  final bool autoRead;

  @override
  ConsumerState<SpeechBubble> createState() => _SpeechBubbleState();
}

class _SpeechBubbleState extends ConsumerState<SpeechBubble> {
  @override
  void initState() {
    super.initState();
    _maybeRead();
  }

  @override
  void didUpdateWidget(SpeechBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) _maybeRead();
  }

  void _maybeRead() {
    if (!widget.autoRead) return;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final autoRead = ref.read(profileProvider).value?.autoRead ?? true;
      final reader = ref.read(readAloudProvider);
      if (autoRead && await reader.hasVoice() && mounted) await reader.speak(widget.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _BubblePainter(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSizes.gapL + 8, AppSizes.gapM, AppSizes.gapS, AppSizes.gapM),
        child: Row(
          children: [
            Expanded(child: SpeakableText(widget.text, style: widget.style ?? AppText.heading)),
            if (widget.speaker) SpeakerButton(text: widget.text),
          ],
        ),
      ),
    );
  }
}

class _BubblePainter extends CustomPainter {
  const _BubblePainter();

  @override
  void paint(Canvas canvas, Size size) {
    const tail = 10.0;
    final body = RRect.fromLTRBR(tail, 0, size.width, size.height, const Radius.circular(AppSizes.radiusM));
    final mid = size.height * 0.62;
    final path = Path()
      ..addRRect(body)
      ..moveTo(tail + 1, mid - 9)
      ..lineTo(0, mid + 2)
      ..lineTo(tail + 1, mid + 7)
      ..close();
    canvas
      ..drawPath(path.shift(const Offset(0, 3)), Paint()..color = AppColors.borderDeep)
      ..drawPath(path, Paint()..color = AppColors.card)
      ..drawRRect(
        body,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = AppSizes.borderWidth
          ..color = AppColors.border,
      );
  }

  @override
  bool shouldRepaint(_BubblePainter oldDelegate) => false;
}
