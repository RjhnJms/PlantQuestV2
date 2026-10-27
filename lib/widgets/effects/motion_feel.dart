/// How lively rewards and celebrations are. Bouncy was picked (PLAN.md
/// D10); Gentle is what the "less motion" setting uses.
enum MotionFeel {
  gentle('Gentle', 'Calm and short', confetti: 0, leaves: 3, hops: 1, pop: 1.04, burstSeconds: 1.0),
  bouncy('Bouncy', 'Playful and springy', confetti: 45, leaves: 5, hops: 2, pop: 1.08, burstSeconds: 1.6);

  const MotionFeel(
    this.title,
    this.line, {
    required this.confetti,
    required this.leaves,
    required this.hops,
    required this.pop,
    required this.burstSeconds,
  });

  final String title;
  final String line;

  /// Confetti pieces per burst (0 = a few sparkles instead).
  final int confetti;

  /// Leaf icons that fly to the counter.
  final int leaves;

  /// How many times Binhi hops when cheering.
  final int hops;

  /// How much a correct answer card swells when it pops.
  final double pop;

  final double burstSeconds;
}
