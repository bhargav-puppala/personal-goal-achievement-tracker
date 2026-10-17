import 'package:flutter_test/flutter_test.dart';
import 'package:personal_goal_tracker/models/goal.dart';
import 'package:personal_goal_tracker/models/milestone.dart';
import 'package:personal_goal_tracker/core/utils/app_date_utils.dart';

void main() {
  group('Goal & Milestone Model Logic Tests', () {
    test(
      'Zero-milestone goal has 0% progress and is not completed automatically',
      () {
        final goal = Goal(
          id: 'g-zero',
          title: 'Empty Goal',
          category: 'Personal',
          createdAt: DateTime.now(),
          milestones: const [],
        );

        expect(goal.totalMilestonesCount, 0);
        expect(goal.completedMilestonesCount, 0);
        expect(goal.progressPercentage, 0.0);
        expect(goal.normalizedProgress, 0.0);
        expect(goal.effectiveIsCompleted, false);
        expect(goal.getStatus(), 'Active');
      },
    );

    test(
      'Progress percentage calculates correctly without division by zero',
      () {
        final m1 = Milestone(
          id: 'm1',
          goalId: 'g1',
          title: 'M1',
          isCompleted: true,
          createdAt: DateTime.now(),
        );
        final m2 = Milestone(
          id: 'm2',
          goalId: 'g1',
          title: 'M2',
          isCompleted: false,
          createdAt: DateTime.now(),
        );

        final goal = Goal(
          id: 'g1',
          title: 'Test Progress',
          category: 'Academic',
          createdAt: DateTime.now(),
          milestones: [m1, m2],
        );

        expect(goal.completedMilestonesCount, 1);
        expect(goal.totalMilestonesCount, 2);
        expect(goal.progressPercentage, 50.0);
        expect(goal.normalizedProgress, 0.5);
        expect(goal.effectiveIsCompleted, false);
      },
    );

    test('Goal with all milestones completed is completed automatically', () {
      final m1 = Milestone(
        id: 'm1',
        goalId: 'g1',
        title: 'M1',
        isCompleted: true,
        createdAt: DateTime.now(),
      );
      final m2 = Milestone(
        id: 'm2',
        goalId: 'g1',
        title: 'M2',
        isCompleted: true,
        createdAt: DateTime.now(),
      );

      final goal = Goal(
        id: 'g1',
        title: 'Complete Goal',
        category: 'Academic',
        createdAt: DateTime.now(),
        milestones: [m1, m2],
      );

      expect(goal.progressPercentage, 100.0);
      expect(goal.effectiveIsCompleted, true);
      expect(goal.getStatus(), 'Completed');
    });

    test('Reopening a milestone reverts parent goal completion', () {
      final m1 = Milestone(
        id: 'm1',
        goalId: 'g1',
        title: 'M1',
        isCompleted: true,
        createdAt: DateTime.now(),
      );
      final m2 = Milestone(
        id: 'm2',
        goalId: 'g1',
        title: 'M2',
        isCompleted: true,
        createdAt: DateTime.now(),
      );

      final completedGoal = Goal(
        id: 'g1',
        title: 'Complete Goal',
        category: 'Academic',
        createdAt: DateTime.now(),
        milestones: [m1, m2],
      );
      expect(completedGoal.effectiveIsCompleted, true);

      // Reopen m2
      final reopenedGoal = completedGoal.copyWith(
        milestones: [
          m1,
          m2.copyWith(isCompleted: false, clearCompletedAt: true),
        ],
      );

      expect(reopenedGoal.completedMilestonesCount, 1);
      expect(reopenedGoal.progressPercentage, 50.0);
      expect(reopenedGoal.effectiveIsCompleted, false);
      expect(reopenedGoal.getStatus(), 'Active');
    });

    test('Overdue deadline calculation behaves correctly', () {
      final referenceNow = DateTime(2026, 10, 17, 12, 0);

      // Past deadline
      final pastDate = DateTime(2026, 10, 15);
      expect(
        AppDateUtils.isOverdue(pastDate, false, referenceNow: referenceNow),
        true,
      );
      expect(
        AppDateUtils.isOverdue(pastDate, true, referenceNow: referenceNow),
        false,
      );

      // Future deadline
      final futureDate = DateTime(2026, 10, 20);
      expect(
        AppDateUtils.isOverdue(futureDate, false, referenceNow: referenceNow),
        false,
      );

      // Today deadline is not overdue yet
      final todayDate = DateTime(2026, 10, 17, 18, 0);
      expect(
        AppDateUtils.isOverdue(todayDate, false, referenceNow: referenceNow),
        false,
      );
    });

    test('Goal JSON serialization and deserialization roundtrip', () {
      final now = DateTime(2026, 10, 17, 10, 0);
      final goal = Goal(
        id: 'g-json',
        title: 'JSON Test Goal',
        description: 'Test description',
        category: 'Career',
        priority: 'High',
        createdAt: now,
        targetDate: now.add(const Duration(days: 5)),
        milestones: [
          Milestone(
            id: 'm-json',
            goalId: 'g-json',
            title: 'Subtask 1',
            isCompleted: true,
            createdAt: now,
            completedAt: now,
            isDailyFocus: true,
          ),
        ],
      );

      final json = goal.toJson();
      final recovered = Goal.fromJson(json);

      expect(recovered.id, goal.id);
      expect(recovered.title, goal.title);
      expect(recovered.description, goal.description);
      expect(recovered.category, goal.category);
      expect(recovered.priority, goal.priority);
      expect(recovered.milestones.length, 1);
      expect(recovered.milestones.first.title, 'Subtask 1');
      expect(recovered.milestones.first.isCompleted, true);
      expect(recovered.milestones.first.isDailyFocus, true);
    });
  });
}
