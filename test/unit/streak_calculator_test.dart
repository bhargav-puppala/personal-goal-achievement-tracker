import 'package:flutter_test/flutter_test.dart';
import 'package:personal_goal_tracker/core/utils/streak_calculator.dart';

void main() {
  group('StreakCalculator Logic Tests', () {
    final refToday = DateTime(2026, 10, 17, 14, 0);

    test('Empty completion timestamps returns zero streak', () {
      final result = StreakCalculator.calculate(
        completionTimestamps: [],
        referenceNow: refToday,
      );

      expect(result.currentStreak, 0);
      expect(result.longestStreak, 0);
      expect(result.completedToday, false);
      expect(result.totalActiveDays, 0);
    });

    test('Completion today gives streak of 1', () {
      final result = StreakCalculator.calculate(
        completionTimestamps: [DateTime(2026, 10, 17, 9, 30)],
        referenceNow: refToday,
      );

      expect(result.currentStreak, 1);
      expect(result.longestStreak, 1);
      expect(result.completedToday, true);
      expect(result.totalActiveDays, 1);
    });

    test(
      'Completion yesterday (none yet today) preserves active streak of 1',
      () {
        final result = StreakCalculator.calculate(
          completionTimestamps: [
            DateTime(2026, 10, 16, 18, 0), // yesterday
          ],
          referenceNow: refToday,
        );

        expect(result.currentStreak, 1);
        expect(result.completedToday, false);
        expect(result.totalActiveDays, 1);
      },
    );

    test(
      'Consecutive completions over 3 days (today, yesterday, day before) yields streak 3',
      () {
        final result = StreakCalculator.calculate(
          completionTimestamps: [
            DateTime(2026, 10, 17, 10, 0),
            DateTime(2026, 10, 16, 14, 0),
            DateTime(2026, 10, 15, 20, 0),
          ],
          referenceNow: refToday,
        );

        expect(result.currentStreak, 3);
        expect(result.longestStreak, 3);
        expect(result.completedToday, true);
        expect(result.totalActiveDays, 3);
      },
    );

    test('Missed day (break in consistency) resets current streak to 0', () {
      final result = StreakCalculator.calculate(
        completionTimestamps: [
          DateTime(2026, 10, 14, 10, 0), // 3 days ago (gap!)
          DateTime(2026, 10, 13, 10, 0),
        ],
        referenceNow: refToday,
      );

      expect(result.currentStreak, 0);
      expect(result.longestStreak, 2);
      expect(result.completedToday, false);
      expect(result.totalActiveDays, 2);
    });

    test(
      'Multiple completions on the same day deduplicate and count as one day',
      () {
        final result = StreakCalculator.calculate(
          completionTimestamps: [
            DateTime(2026, 10, 17, 8, 0),
            DateTime(2026, 10, 17, 11, 0),
            DateTime(2026, 10, 17, 16, 0),
          ],
          referenceNow: refToday,
        );

        expect(result.currentStreak, 1);
        expect(result.totalActiveDays, 1);
      },
    );
  });
}
