import 'app_date_utils.dart';

/// Result summary for streak calculations.
class StreakResult {
  final int currentStreak;
  final int longestStreak;
  final bool completedToday;
  final int totalActiveDays;

  const StreakResult({
    required this.currentStreak,
    required this.longestStreak,
    required this.completedToday,
    required this.totalActiveDays,
  });

  static const StreakResult zero = StreakResult(
    currentStreak: 0,
    longestStreak: 0,
    completedToday: false,
    totalActiveDays: 0,
  );
}

/// Deterministic, transparent streak calculation logic.
class StreakCalculator {
  /// Computes streak statistics from recorded milestone completion timestamps.
  static StreakResult calculate({
    required Iterable<DateTime> completionTimestamps,
    DateTime? referenceNow,
  }) {
    if (completionTimestamps.isEmpty) {
      return StreakResult.zero;
    }

    final now = referenceNow ?? DateTime.now();
    final today = AppDateUtils.normalizeDate(now);
    final yesterday = today.subtract(const Duration(days: 1));

    // 1. Collect distinct calendar days (normalized to midnight)
    final Set<DateTime> uniqueDays = {};
    for (final ts in completionTimestamps) {
      uniqueDays.add(AppDateUtils.normalizeDate(ts));
    }

    if (uniqueDays.isEmpty) {
      return StreakResult.zero;
    }

    final totalActiveDays = uniqueDays.length;
    final bool completedToday = uniqueDays.contains(today);
    final bool completedYesterday = uniqueDays.contains(yesterday);

    // 2. Calculate current streak
    int currentStreak = 0;
    if (completedToday) {
      currentStreak = 1;
      var checkDay = yesterday;
      while (uniqueDays.contains(checkDay)) {
        currentStreak++;
        checkDay = checkDay.subtract(const Duration(days: 1));
      }
    } else if (completedYesterday) {
      // User hasn't finished today yet, but yesterday was active, so streak is maintained
      currentStreak = 1;
      var checkDay = yesterday.subtract(const Duration(days: 1));
      while (uniqueDays.contains(checkDay)) {
        currentStreak++;
        checkDay = checkDay.subtract(const Duration(days: 1));
      }
    } else {
      currentStreak = 0;
    }

    // 3. Calculate longest streak across history
    final sortedDays = uniqueDays.toList()..sort();
    int longest = 0;
    int run = 0;
    DateTime? prev;

    for (final day in sortedDays) {
      if (prev == null) {
        run = 1;
      } else {
        final diff = day.difference(prev).inDays;
        if (diff == 1) {
          run++;
        } else if (diff > 1) {
          run = 1;
        }
      }
      if (run > longest) {
        longest = run;
      }
      prev = day;
    }

    return StreakResult(
      currentStreak: currentStreak,
      longestStreak: longest,
      completedToday: completedToday,
      totalActiveDays: totalActiveDays,
    );
  }
}
