/// Daily things that bring a child back (PLAN.md §5e): Binhi's gift and
/// watering Binhi. Each happens once per calendar day. Missing days never
/// takes anything away; the count just waits.
abstract final class DailyRules {
  /// Leaves in gifts 1 to 7; then the week starts again. Gift 7 is the
  /// "big surprise".
  static const gifts = [3, 3, 4, 4, 5, 5, 15];

  /// Leaves in gift number [n] (1 = the first gift ever).
  static int giftLeaves(int n) => gifts[(n - 1) % gifts.length];

  /// Where gift [n] sits in its week, 1–7.
  static int weekDay(int n) => (n - 1) % gifts.length + 1;

  /// Leaves for watering Binhi (once a day).
  static const water = 2;

  /// Watering on this many days (any days) earns the flower pot.
  static const flowerPotDays = 7;
}

/// The two daily things, as stored in `daily_care`.
enum DailyKind { gift, water }

/// What watering Binhi did.
class WaterResult {
  const WaterResult({required this.leaves, required this.daysWatered, required this.flowerPot});

  /// Leaves earned (0 if Binhi was already watered today).
  final int leaves;
  final int daysWatered;

  /// True the day the flower pot is earned.
  final bool flowerPot;
}
