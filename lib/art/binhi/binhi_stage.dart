/// Binhi's growth stages (PLAN.md §3). Pure game rules, no drawing.
enum BinhiStage {
  seed(0, 'a seed'),
  sprout(10, 'a sprout'),
  sapling(25, 'a sapling'),
  blooming(50, 'blooming');

  const BinhiStage(this.minLeaves, this.label);

  /// Leaves needed to reach this stage.
  final int minLeaves;

  /// For sentences like "Binhi is a seed".
  final String label;

  static BinhiStage forLeaves(int leaves) {
    var stage = BinhiStage.seed;
    for (final s in values) {
      if (leaves >= s.minLeaves) stage = s;
    }
    return stage;
  }

  /// The next stage, or null when Binhi is fully grown.
  BinhiStage? get next => index + 1 < values.length ? values[index + 1] : null;

  /// Leaves still needed for the next stage (0 when blooming).
  static int leavesToGrow(int leaves) {
    final next = forLeaves(leaves).next;
    return next == null ? 0 : next.minLeaves - leaves;
  }

  /// 0.0–1.0 progress from this stage to the next (1.0 when blooming).
  static double growthProgress(int leaves) {
    final stage = forLeaves(leaves);
    final next = stage.next;
    if (next == null) return 1;
    return (leaves - stage.minLeaves) / (next.minLeaves - stage.minLeaves);
  }
}

enum BinhiMood { happy, cheering, encouraging, worried }
