import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/read_aloud.dart';
import '../theme/app_colors.dart';

/// Text that highlights the sentence being read aloud (PLAN.md §8).
class SpeakableText extends ConsumerWidget {
  const SpeakableText(this.text, {super.key, this.style, this.textAlign, this.highlight = AppColors.sunshineTint});

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final Color highlight;

  /// The sentence (start, end) in [text] that contains [at].
  static (int, int) sentenceAround(String text, int at) {
    final ends = RegExp(r'[.!?](\s|$)');
    var start = 0;
    for (final m in ends.allMatches(text)) {
      final end = m.start + 1;
      if (at < end) return (start, end);
      start = m.end;
    }
    return (start, text.length);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speaking = ref.watch(readAloudProvider).speaking;
    return ValueListenableBuilder<SpokenSpan?>(
      valueListenable: speaking,
      builder: (context, span, _) {
        // The spoken line may include this text after a short lead-in
        // (e.g. "Fun fact! …"), so find where this text sits in it.
        final offset = span == null ? -1 : span.text.indexOf(text);
        if (offset < 0) return Text(text, style: style, textAlign: textAlign);
        final at = (span!.start - offset).clamp(0, text.length);
        final (s, e) = sentenceAround(text, at);
        return Text.rich(
          TextSpan(
            style: style,
            children: [
              TextSpan(text: text.substring(0, s)),
              TextSpan(
                text: text.substring(s, e),
                style: TextStyle(background: Paint()..color = highlight),
              ),
              TextSpan(text: text.substring(e)),
            ],
          ),
          textAlign: textAlign,
        );
      },
    );
  }
}
