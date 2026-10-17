import 'package:uuid/uuid.dart';
import '../models/goal.dart';
import '../models/milestone.dart';
import '../models/activity_record.dart';
import '../services/storage_service.dart';

/// Repository interface separating state/business logic from storage.
abstract class IGoalRepository {
  Future<List<Goal>> getGoals();
  Future<void> saveGoal(Goal goal);
  Future<void> updateGoal(Goal goal);
  Future<void> deleteGoal(String goalId);
  Future<List<ActivityRecord>> getActivityHistory();
  Future<void> recordActivity(ActivityRecord record);
  Future<List<String>> getDailyFocusIds();
  Future<void> setDailyFocusIds(List<String> ids);
  Future<void> clearAll();
  Future<List<Goal>> seedSampleData();
  Future<String> exportBackup();
  Future<bool> importBackup(String json);
}

/// Concrete GoalRepository managing domain entities with local persistence.
class GoalRepository implements IGoalRepository {
  final IStorageService _storageService;
  static const _uuid = Uuid();

  GoalRepository({required IStorageService storageService})
    : _storageService = storageService;

  @override
  Future<List<Goal>> getGoals() async {
    return _storageService.loadGoals();
  }

  @override
  Future<void> saveGoal(Goal goal) async {
    final currentGoals = await _storageService.loadGoals();
    final index = currentGoals.indexWhere((g) => g.id == goal.id);
    if (index >= 0) {
      currentGoals[index] = goal;
    } else {
      currentGoals.insert(0, goal);
    }
    await _storageService.saveGoals(currentGoals);
  }

  @override
  Future<void> updateGoal(Goal goal) async {
    await saveGoal(goal);
  }

  @override
  Future<void> deleteGoal(String goalId) async {
    final currentGoals = await _storageService.loadGoals();
    currentGoals.removeWhere((g) => g.id == goalId);
    await _storageService.saveGoals(currentGoals);

    // Clean up daily focus items that belonged to this goal
    final focusIds = await _storageService.loadDailyFocusIds();
    // Keep only IDs that still exist in remaining goals
    final remainingMilestoneIds = currentGoals
        .expand((g) => g.milestones)
        .map((m) => m.id)
        .toSet();
    final updatedFocusIds = focusIds
        .where(remainingMilestoneIds.contains)
        .toList();
    await _storageService.saveDailyFocusIds(updatedFocusIds);
  }

  @override
  Future<List<ActivityRecord>> getActivityHistory() async {
    final list = await _storageService.loadActivityRecords();
    // Sort descending by timestamp (newest first)
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  @override
  Future<void> recordActivity(ActivityRecord record) async {
    final records = await _storageService.loadActivityRecords();
    records.insert(0, record);
    // Keep last 500 records to prevent unbounded growth
    if (records.length > 500) {
      records.removeRange(500, records.length);
    }
    await _storageService.saveActivityRecords(records);
  }

  @override
  Future<List<String>> getDailyFocusIds() async {
    return _storageService.loadDailyFocusIds();
  }

  @override
  Future<void> setDailyFocusIds(List<String> ids) async {
    await _storageService.saveDailyFocusIds(ids);
  }

  @override
  Future<void> clearAll() async {
    await _storageService.clearAllData();
  }

  @override
  Future<String> exportBackup() async {
    return _storageService.exportBackupJson();
  }

  @override
  Future<bool> importBackup(String json) async {
    return _storageService.importBackupJson(json);
  }

  @override
  Future<List<Goal>> seedSampleData() async {
    final now = DateTime.now();

    // Goal 1: SDG 4 - Quality Education: Data Structures & Algorithms Mastery
    final dsaGoalId = _uuid.v4();
    final dsaMilestone1Id = _uuid.v4();
    final dsaMilestone2Id = _uuid.v4();
    final dsaMilestone3Id = _uuid.v4();
    final dsaMilestone4Id = _uuid.v4();

    final goal1 = Goal(
      id: dsaGoalId,
      title: 'Master Data Structures & Algorithms',
      description:
          'Deepen problem-solving foundation in Trees, Graphs, and Dynamic Programming for placement excellence (SDG 4: Quality Education).',
      category: 'Academic',
      priority: 'High',
      createdAt: now.subtract(const Duration(days: 10)),
      targetDate: now.add(const Duration(days: 20)),
      milestones: [
        Milestone(
          id: dsaMilestone1Id,
          goalId: dsaGoalId,
          title: 'Complete Arrays & HashMaps practice on LeetCode',
          isCompleted: true,
          createdAt: now.subtract(const Duration(days: 10)),
          completedAt: now.subtract(const Duration(days: 8)),
          orderIndex: 0,
        ),
        Milestone(
          id: dsaMilestone2Id,
          goalId: dsaGoalId,
          title: 'Implement Binary Search & 2-Pointer techniques',
          isCompleted: true,
          createdAt: now.subtract(const Duration(days: 8)),
          completedAt: now.subtract(const Duration(days: 4)),
          orderIndex: 1,
        ),
        Milestone(
          id: dsaMilestone3Id,
          goalId: dsaGoalId,
          title: 'Solve 15 Tree traversal & recursion problems',
          isCompleted: false,
          createdAt: now.subtract(const Duration(days: 4)),
          isDailyFocus: true,
          orderIndex: 2,
        ),
        Milestone(
          id: dsaMilestone4Id,
          goalId: dsaGoalId,
          title: 'Dynamic Programming memoization & tabulation drills',
          isCompleted: false,
          createdAt: now.subtract(const Duration(days: 2)),
          orderIndex: 3,
        ),
      ],
    );

    // Goal 2: SDG 3 - Good Health and Well-being: 10K Steps & Hydration Routine
    final fitnessGoalId = _uuid.v4();
    final fitMilestone1Id = _uuid.v4();
    final fitMilestone2Id = _uuid.v4();
    final fitMilestone3Id = _uuid.v4();

    final goal2 = Goal(
      id: fitnessGoalId,
      title: 'Daily Fitness & Well-being Habit',
      description:
          'Maintain regular physical activity, 10,000 steps daily, and mindful hydration to boost focus and health (SDG 3: Good Health).',
      category: 'Health and Well-being',
      priority: 'Medium',
      createdAt: now.subtract(const Duration(days: 7)),
      targetDate: now.add(const Duration(days: 14)),
      milestones: [
        Milestone(
          id: fitMilestone1Id,
          goalId: fitnessGoalId,
          title: 'Complete 30-minute morning brisk walk & stretching',
          isCompleted: true,
          createdAt: now.subtract(const Duration(days: 7)),
          completedAt: now.subtract(const Duration(days: 1)),
          isDailyFocus: false,
          orderIndex: 0,
        ),
        Milestone(
          id: fitMilestone2Id,
          goalId: fitnessGoalId,
          title: 'Drink 3 liters of water and maintain hydration log',
          isCompleted: false,
          createdAt: now.subtract(const Duration(days: 7)),
          isDailyFocus: true,
          orderIndex: 1,
        ),
        Milestone(
          id: fitMilestone3Id,
          goalId: fitnessGoalId,
          title: '15-minute guided evening mindfulness meditation',
          isCompleted: false,
          createdAt: now.subtract(const Duration(days: 7)),
          orderIndex: 2,
        ),
      ],
    );

    // Goal 3: Career - Resume & Mock Placement Interviews
    final careerGoalId = _uuid.v4();
    final careerMilestone1Id = _uuid.v4();
    final careerMilestone2Id = _uuid.v4();

    final goal3 = Goal(
      id: careerGoalId,
      title: 'Placement Preparation & Mock Interviews',
      description:
          'Polish resume, build GitHub portfolio, and complete peer mock interviews.',
      category: 'Career',
      priority: 'High',
      createdAt: now.subtract(const Duration(days: 14)),
      targetDate: now.add(const Duration(days: 5)),
      milestones: [
        Milestone(
          id: careerMilestone1Id,
          goalId: careerGoalId,
          title: 'Update LinkedIn profile & format ATS resume',
          isCompleted: true,
          createdAt: now.subtract(const Duration(days: 14)),
          completedAt: now.subtract(const Duration(days: 12)),
          orderIndex: 0,
        ),
        Milestone(
          id: careerMilestone2Id,
          goalId: careerGoalId,
          title: 'Conduct two behavioral and system design mock sessions',
          isCompleted: false,
          createdAt: now.subtract(const Duration(days: 14)),
          orderIndex: 1,
        ),
      ],
    );

    // Goal 4: Personal - Read 1 Non-Fiction Productivity Book (Completed Goal)
    final readGoalId = _uuid.v4();
    final readMilestone1Id = _uuid.v4();
    final readMilestone2Id = _uuid.v4();

    final goal4 = Goal(
      id: readGoalId,
      title: 'Read Atomic Habits by James Clear',
      description:
          'Apply the 4 laws of behavior change to daily academic study schedules.',
      category: 'Personal',
      priority: 'Low',
      createdAt: now.subtract(const Duration(days: 21)),
      targetDate: now.subtract(const Duration(days: 2)),
      isCompleted: true,
      completedAt: now.subtract(const Duration(days: 2)),
      milestones: [
        Milestone(
          id: readMilestone1Id,
          goalId: readGoalId,
          title: 'Read Chapters 1 to 10 and take notes on habit cues',
          isCompleted: true,
          createdAt: now.subtract(const Duration(days: 21)),
          completedAt: now.subtract(const Duration(days: 10)),
          orderIndex: 0,
        ),
        Milestone(
          id: readMilestone2Id,
          goalId: readGoalId,
          title: 'Implement environment redesign for distraction-free study',
          isCompleted: true,
          createdAt: now.subtract(const Duration(days: 21)),
          completedAt: now.subtract(const Duration(days: 2)),
          orderIndex: 1,
        ),
      ],
    );

    final seededGoals = [goal1, goal2, goal3, goal4];
    await _storageService.saveGoals(seededGoals);

    // Seed realistic activity history corresponding to completed milestones
    final activities = [
      ActivityRecord(
        id: _uuid.v4(),
        milestoneId: fitMilestone1Id,
        goalId: fitnessGoalId,
        milestoneTitle: 'Complete 30-minute morning brisk walk & stretching',
        goalTitle: goal2.title,
        category: goal2.category,
        action: 'completed',
        timestamp: now.subtract(const Duration(days: 1, hours: 2)),
      ),
      ActivityRecord(
        id: _uuid.v4(),
        milestoneId: dsaMilestone2Id,
        goalId: dsaGoalId,
        milestoneTitle: 'Implement Binary Search & 2-Pointer techniques',
        goalTitle: goal1.title,
        category: goal1.category,
        action: 'completed',
        timestamp: now.subtract(const Duration(days: 4, hours: 5)),
      ),
      ActivityRecord(
        id: _uuid.v4(),
        milestoneId: dsaMilestone1Id,
        goalId: dsaGoalId,
        milestoneTitle: 'Complete Arrays & HashMaps practice on LeetCode',
        goalTitle: goal1.title,
        category: goal1.category,
        action: 'completed',
        timestamp: now.subtract(const Duration(days: 8, hours: 3)),
      ),
      ActivityRecord(
        id: _uuid.v4(),
        milestoneId: readMilestone2Id,
        goalId: readGoalId,
        milestoneTitle:
            'Implement environment redesign for distraction-free study',
        goalTitle: goal4.title,
        category: goal4.category,
        action: 'completed',
        timestamp: now.subtract(const Duration(days: 2, hours: 4)),
      ),
    ];
    await _storageService.saveActivityRecords(activities);

    // Seed Daily Focus items
    final focusIds = [dsaMilestone3Id, fitMilestone2Id];
    await _storageService.saveDailyFocusIds(focusIds);

    return seededGoals;
  }
}
