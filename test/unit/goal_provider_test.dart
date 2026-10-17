import 'package:flutter_test/flutter_test.dart';
import 'package:personal_goal_tracker/repositories/goal_repository.dart';
import 'package:personal_goal_tracker/viewmodels/goal_provider.dart';
import '../mocks/mock_storage_service.dart';

void main() {
  group('GoalProvider State & Business Operations Tests', () {
    late MockStorageService mockStorage;
    late GoalRepository repository;
    late GoalProvider provider;

    setUp(() async {
      mockStorage = MockStorageService();
      repository = GoalRepository(storageService: mockStorage);
      provider = GoalProvider(repository: repository);
      await provider.initialize();
    });

    test('Creating a goal with empty title throws ArgumentError', () async {
      expect(
        () => provider.createGoal(title: '   ', category: 'Academic'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test(
      'Creating a goal adds to provider and storage with initial milestones',
      () async {
        await provider.createGoal(
          title: 'Master Flutter and Dart',
          description: 'Complete high quality lab project',
          category: 'Academic',
          priority: 'High',
          initialMilestoneTitles: [
            'Learn Provider',
            'Build Dashboard',
            'Write Tests',
          ],
        );

        expect(provider.goals.length, 1);
        final goal = provider.goals.first;
        expect(goal.title, 'Master Flutter and Dart');
        expect(goal.category, 'Academic');
        expect(goal.priority, 'High');
        expect(goal.milestones.length, 3);
        expect(goal.completedMilestonesCount, 0);
        expect(goal.progressPercentage, 0.0);
      },
    );

    test(
      'Completing a milestone updates goal progress and logs activity record',
      () async {
        await provider.createGoal(
          title: 'Fitness Habit',
          category: 'Fitness',
          initialMilestoneTitles: ['Morning Run', 'Evening Yoga'],
        );

        final goal = provider.goals.first;
        final m1 = goal.milestones.first;

        await provider.toggleMilestoneCompletion(goal.id, m1.id);

        final updatedGoal = provider.goals.first;
        expect(updatedGoal.completedMilestonesCount, 1);
        expect(updatedGoal.progressPercentage, 50.0);
        expect(provider.activityHistory.length, 1);
        expect(provider.activityHistory.first.action, 'completed');
      },
    );

    test(
      'Completing all milestones completes the goal; reopening one reopens goal',
      () async {
        await provider.createGoal(
          title: 'Short Task',
          category: 'Personal',
          initialMilestoneTitles: ['Task 1'],
        );

        final goal = provider.goals.first;
        final m1 = goal.milestones.first;

        // Complete
        await provider.toggleMilestoneCompletion(goal.id, m1.id);
        expect(provider.goals.first.effectiveIsCompleted, true);
        expect(provider.completedGoalsCount, 1);
        expect(provider.activeGoalsCount, 0);

        // Reopen
        await provider.toggleMilestoneCompletion(goal.id, m1.id);
        expect(provider.goals.first.effectiveIsCompleted, false);
        expect(provider.completedGoalsCount, 0);
        expect(provider.activeGoalsCount, 1);
      },
    );

    test(
      'Daily Focus toggling persists and surfaces in dailyFocusItems',
      () async {
        await provider.createGoal(
          title: 'Study Goal',
          category: 'Academic',
          initialMilestoneTitles: ['Read Chapter 1', 'Solve Exercises'],
        );

        final goal = provider.goals.first;
        final m1 = goal.milestones.first;

        await provider.toggleDailyFocus(goal.id, m1.id);

        expect(provider.dailyFocusIds.contains(m1.id), true);
        expect(provider.dailyFocusItems.length, 1);
        expect(provider.dailyFocusItems.first.milestone.id, m1.id);
        expect(provider.dailyFocusItems.first.goal.title, 'Study Goal');

        // Toggling again removes it from Daily Focus
        await provider.toggleDailyFocus(goal.id, m1.id);
        expect(provider.dailyFocusIds.contains(m1.id), false);
        expect(provider.dailyFocusItems.isEmpty, true);
      },
    );

    test(
      'Deleting a goal cleans up milestones and daily focus records',
      () async {
        await provider.createGoal(
          title: 'Temporary Goal',
          category: 'Other',
          initialMilestoneTitles: ['Temp Milestone'],
        );

        final goal = provider.goals.first;
        final m = goal.milestones.first;
        await provider.toggleDailyFocus(goal.id, m.id);

        expect(provider.goals.length, 1);
        expect(provider.dailyFocusIds.length, 1);

        await provider.deleteGoal(goal.id);

        expect(provider.goals.isEmpty, true);
        expect(provider.dailyFocusIds.isEmpty, true);
      },
    );

    test(
      'Persistence survives reinitialization on fresh provider instance',
      () async {
        await provider.createGoal(
          title: 'Persisted Goal',
          category: 'Finance',
          initialMilestoneTitles: ['Save 100', 'Invest 50'],
        );

        final goal = provider.goals.first;
        await provider.toggleMilestoneCompletion(
          goal.id,
          goal.milestones.first.id,
        );

        // Create new provider sharing the same storage
        final secondProvider = GoalProvider(
          repository: GoalRepository(storageService: mockStorage),
        );
        await secondProvider.initialize();

        expect(secondProvider.goals.length, 1);
        expect(secondProvider.goals.first.title, 'Persisted Goal');
        expect(secondProvider.goals.first.completedMilestonesCount, 1);
        expect(secondProvider.activityHistory.length, 1);
      },
    );

    test('Analytics calculations reflect real dataset accurately', () async {
      await provider.createGoal(
        title: 'Goal A',
        category: 'Academic',
        initialMilestoneTitles: ['A1', 'A2'],
      );
      await provider.createGoal(
        title: 'Goal B',
        category: 'Health and Well-being',
        initialMilestoneTitles: ['B1'],
      );

      final gA = provider.goals.firstWhere((g) => g.title == 'Goal A');
      await provider.toggleMilestoneCompletion(gA.id, gA.milestones[0].id);
      await provider.toggleMilestoneCompletion(gA.id, gA.milestones[1].id);

      expect(provider.totalGoalsCount, 2);
      expect(provider.completedGoalsCount, 1);
      expect(provider.activeGoalsCount, 1);
      expect(provider.totalMilestonesCount, 3);
      expect(provider.completedMilestonesCount, 2);
      expect(provider.overallMilestoneCompletionRate, closeTo(66.66, 0.1));

      final dist = provider.categoryGoalDistribution;
      expect(dist['Academic'], 1);
      expect(dist['Health and Well-being'], 1);
    });
  });
}
