import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/goal.dart';
import '../models/milestone.dart';
import '../models/activity_record.dart';
import '../repositories/goal_repository.dart';
import '../services/notification_service.dart';
import '../core/utils/app_date_utils.dart';
import '../core/utils/streak_calculator.dart';

/// Presentation model pairing a daily focus milestone with its parent goal context.
class DailyFocusItem {
  final Goal goal;
  final Milestone milestone;

  const DailyFocusItem({required this.goal, required this.milestone});
}

/// Day activity model for the weekly milestone completion analytics chart.
class DayActivityCount {
  final DateTime date;
  final String dayLabel;
  final int count;

  const DayActivityCount({
    required this.date,
    required this.dayLabel,
    required this.count,
  });
}

/// Central state management for Goals, Milestones, Daily Focus, and Analytics.
class GoalProvider extends ChangeNotifier {
  final IGoalRepository _repository;
  final INotificationService _notificationService;
  static const _uuid = Uuid();

  List<Goal> _goals = [];
  List<ActivityRecord> _activityHistory = [];
  List<String> _dailyFocusIds = [];

  bool _isLoading = true;
  String? _errorMessage;

  // Filter & Search state
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedStatus = 'All'; // 'All', 'Active', 'Completed', 'Overdue'
  String _sortBy = 'Deadline'; // 'Deadline', 'Priority', 'Newest', 'Title'

  GoalProvider({
    required IGoalRepository repository,
    INotificationService? notificationService,
  }) : _repository = repository,
       _notificationService = notificationService ?? NotificationService();

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Goal> get goals => List.unmodifiable(_goals);
  List<ActivityRecord> get activityHistory =>
      List.unmodifiable(_activityHistory);
  List<String> get dailyFocusIds => List.unmodifiable(_dailyFocusIds);

  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  String get selectedStatus => _selectedStatus;
  String get sortBy => _sortBy;

  // Setters for filters
  void setSearchQuery(String query) {
    _searchQuery = query.trim();
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSelectedStatus(String status) {
    _selectedStatus = status;
    notifyListeners();
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    notifyListeners();
  }

  /// Initializer: Loads all goals, activities, and daily focus items from storage.
  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _goals = await _repository.getGoals();
      _activityHistory = await _repository.getActivityHistory();
      _dailyFocusIds = await _repository.getDailyFocusIds();
    } catch (e) {
      _errorMessage = 'Failed to load goals: $e';
      debugPrint(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Filtered and sorted goals list based on active dashboard criteria.
  List<Goal> get filteredGoals {
    return _goals.where((goal) {
      // 1. Search Query filter
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesTitle = goal.title.toLowerCase().contains(q);
        final matchesDesc = goal.description.toLowerCase().contains(q);
        final matchesMilestone = goal.milestones.any(
          (m) => m.title.toLowerCase().contains(q),
        );
        if (!matchesTitle && !matchesDesc && !matchesMilestone) {
          return false;
        }
      }

      // 2. Category filter
      if (_selectedCategory != 'All' && goal.category != _selectedCategory) {
        return false;
      }

      // 3. Status filter
      if (_selectedStatus != 'All') {
        final status = goal.getStatus();
        if (_selectedStatus == 'Active' &&
            (status != 'Active' && status != 'Overdue')) {
          return false;
        } else if (_selectedStatus == 'Completed' && status != 'Completed') {
          return false;
        } else if (_selectedStatus == 'Overdue' && status != 'Overdue') {
          return false;
        }
      }

      return true;
    }).toList()..sort((a, b) {
      switch (_sortBy) {
        case 'Priority':
          // High = 3, Medium = 2, Low = 1
          int score(String p) => p == 'High' ? 3 : (p == 'Medium' ? 2 : 1);
          return score(b.priority).compareTo(score(a.priority));
        case 'Newest':
          return b.createdAt.compareTo(a.createdAt);
        case 'Title':
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        case 'Deadline':
        default:
          if (a.targetDate == null && b.targetDate == null) return 0;
          if (a.targetDate == null) return 1;
          if (b.targetDate == null) return -1;
          return a.targetDate!.compareTo(b.targetDate!);
      }
    });
  }

  /// Returns active Daily Focus items with their parent goals.
  List<DailyFocusItem> get dailyFocusItems {
    final List<DailyFocusItem> items = [];
    final focusSet = _dailyFocusIds.toSet();

    for (final goal in _goals) {
      for (final milestone in goal.milestones) {
        if (focusSet.contains(milestone.id) || milestone.isDailyFocus) {
          items.add(DailyFocusItem(goal: goal, milestone: milestone));
        }
      }
    }
    return items;
  }

  // Statistics & Analytics Getters
  int get totalGoalsCount => _goals.length;
  int get activeGoalsCount =>
      _goals.where((g) => !g.effectiveIsCompleted).length;
  int get completedGoalsCount =>
      _goals.where((g) => g.effectiveIsCompleted).length;
  int get overdueGoalsCount => _goals.where((g) => g.isOverdue()).length;

  int get totalMilestonesCount =>
      _goals.fold(0, (sum, g) => sum + g.totalMilestonesCount);
  int get completedMilestonesCount =>
      _goals.fold(0, (sum, g) => sum + g.completedMilestonesCount);

  double get overallMilestoneCompletionRate {
    if (totalMilestonesCount == 0) return 0.0;
    return (completedMilestonesCount / totalMilestonesCount) * 100.0;
  }

  /// Number of milestones completed today.
  int get todayMilestoneCompletionCount {
    final now = DateTime.now();
    return _activityHistory
        .where(
          (r) =>
              r.action == 'completed' &&
              AppDateUtils.isSameDay(r.timestamp, now),
        )
        .length;
  }

  /// Evaluates current streak from recorded activity timestamps.
  StreakResult get streak {
    final completionDates = _activityHistory
        .where((r) => r.action == 'completed')
        .map((r) => r.timestamp);
    return StreakCalculator.calculate(completionTimestamps: completionDates);
  }

  /// Category breakdown of goals.
  Map<String, int> get categoryGoalDistribution {
    final map = <String, int>{};
    for (final goal in _goals) {
      map[goal.category] = (map[goal.category] ?? 0) + 1;
    }
    return map;
  }

  /// Weekly milestone completion data for the last 7 calendar days.
  List<DayActivityCount> get weeklyMilestoneActivity {
    final now = DateTime.now();
    final today = AppDateUtils.normalizeDate(now);
    final List<DayActivityCount> result = [];
    final dayFormat = DateFormat('E'); // 'Mon', 'Tue'

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final count = _activityHistory
          .where(
            (r) =>
                r.action == 'completed' &&
                AppDateUtils.isSameDay(r.timestamp, date),
          )
          .length;
      result.add(
        DayActivityCount(
          date: date,
          dayLabel: dayFormat.format(date),
          count: count,
        ),
      );
    }
    return result;
  }

  /// Recent milestone achievements (last 10 completed activities).
  List<ActivityRecord> get recentAchievements {
    return _activityHistory
        .where((r) => r.action == 'completed')
        .take(10)
        .toList();
  }

  // --- GOAL OPERATIONS ---

  Future<void> createGoal({
    required String title,
    String description = '',
    required String category,
    String priority = 'Medium',
    DateTime? targetDate,
    List<String> initialMilestoneTitles = const [],
    int? colorHex,
  }) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      throw ArgumentError('Goal title cannot be empty.');
    }

    final goalId = _uuid.v4();
    final now = DateTime.now();
    final milestones = <Milestone>[];

    for (int i = 0; i < initialMilestoneTitles.length; i++) {
      final mTitle = initialMilestoneTitles[i].trim();
      if (mTitle.isNotEmpty) {
        milestones.add(
          Milestone(
            id: _uuid.v4(),
            goalId: goalId,
            title: mTitle,
            createdAt: now,
            orderIndex: i,
          ),
        );
      }
    }

    final newGoal = Goal(
      id: goalId,
      title: trimmedTitle,
      description: description.trim(),
      category: category,
      priority: priority,
      createdAt: now,
      targetDate: targetDate,
      milestones: milestones,
      colorHex: colorHex,
    );

    _goals.insert(0, newGoal);
    notifyListeners();

    await _repository.saveGoal(newGoal);
    await _notificationService.scheduleGoalDeadlineReminder(newGoal);
  }

  Future<void> updateGoal(Goal updatedGoal) async {
    final index = _goals.indexWhere((g) => g.id == updatedGoal.id);
    if (index >= 0) {
      _goals[index] = updatedGoal;
      notifyListeners();
      await _repository.updateGoal(updatedGoal);
      await _notificationService.scheduleGoalDeadlineReminder(updatedGoal);
    }
  }

  Future<void> deleteGoal(String goalId) async {
    final target = _goals.firstWhere(
      (g) => g.id == goalId,
      orElse: () => _goals.first,
    );
    final milestoneIdsToRemove = target.milestones.map((m) => m.id).toSet();

    _goals.removeWhere((g) => g.id == goalId);
    _dailyFocusIds.removeWhere(milestoneIdsToRemove.contains);

    notifyListeners();

    await _repository.deleteGoal(goalId);
    await _notificationService.cancelGoalReminder(goalId);
  }

  // --- MILESTONE OPERATIONS ---

  Future<void> addMilestone(String goalId, String title) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;

    final goalIndex = _goals.indexWhere((g) => g.id == goalId);
    if (goalIndex < 0) return;

    final goal = _goals[goalIndex];
    final newMilestone = Milestone(
      id: _uuid.v4(),
      goalId: goalId,
      title: trimmed,
      createdAt: DateTime.now(),
      orderIndex: goal.milestones.length,
    );

    final updatedMilestones = List<Milestone>.from(goal.milestones)
      ..add(newMilestone);
    final updatedGoal = goal.copyWith(milestones: updatedMilestones);

    _goals[goalIndex] = updatedGoal;
    notifyListeners();

    await _repository.updateGoal(updatedGoal);
  }

  Future<void> editMilestone(
    String goalId,
    String milestoneId,
    String newTitle,
  ) async {
    final trimmed = newTitle.trim();
    if (trimmed.isEmpty) return;

    final goalIndex = _goals.indexWhere((g) => g.id == goalId);
    if (goalIndex < 0) return;

    final goal = _goals[goalIndex];
    final updatedMilestones = goal.milestones.map((m) {
      if (m.id == milestoneId) {
        return m.copyWith(title: trimmed);
      }
      return m;
    }).toList();

    final updatedGoal = goal.copyWith(milestones: updatedMilestones);
    _goals[goalIndex] = updatedGoal;
    notifyListeners();

    await _repository.updateGoal(updatedGoal);
  }

  Future<void> deleteMilestone(String goalId, String milestoneId) async {
    final goalIndex = _goals.indexWhere((g) => g.id == goalId);
    if (goalIndex < 0) return;

    final goal = _goals[goalIndex];
    final updatedMilestones = goal.milestones
        .where((m) => m.id != milestoneId)
        .toList();
    final updatedGoal = goal.copyWith(milestones: updatedMilestones);

    _goals[goalIndex] = updatedGoal;
    _dailyFocusIds.remove(milestoneId);
    notifyListeners();

    await _repository.updateGoal(updatedGoal);
    await _repository.setDailyFocusIds(_dailyFocusIds);
  }

  /// Toggles milestone completion, logs activity, updates parent goal progress & streak.
  Future<void> toggleMilestoneCompletion(
    String goalId,
    String milestoneId,
  ) async {
    final goalIndex = _goals.indexWhere((g) => g.id == goalId);
    if (goalIndex < 0) return;

    final goal = _goals[goalIndex];
    final milestoneIndex = goal.milestones.indexWhere(
      (m) => m.id == milestoneId,
    );
    if (milestoneIndex < 0) return;

    final milestone = goal.milestones[milestoneIndex];
    final willComplete = !milestone.isCompleted;
    final now = DateTime.now();

    final updatedMilestone = milestone.copyWith(
      isCompleted: willComplete,
      completedAt: willComplete ? now : null,
      clearCompletedAt: !willComplete,
    );

    final updatedMilestones = List<Milestone>.from(goal.milestones);
    updatedMilestones[milestoneIndex] = updatedMilestone;

    final updatedGoal = goal.copyWith(milestones: updatedMilestones);
    _goals[goalIndex] = updatedGoal;

    // Record activity record
    final record = ActivityRecord(
      id: _uuid.v4(),
      milestoneId: milestoneId,
      goalId: goalId,
      milestoneTitle: milestone.title,
      goalTitle: goal.title,
      category: goal.category,
      action: willComplete ? 'completed' : 'reopened',
      timestamp: now,
    );

    _activityHistory.insert(0, record);
    notifyListeners();

    await _repository.updateGoal(updatedGoal);
    await _repository.recordActivity(record);
  }

  /// Toggles milestone's inclusion in Daily Focus.
  Future<void> toggleDailyFocus(String goalId, String milestoneId) async {
    final goalIndex = _goals.indexWhere((g) => g.id == goalId);
    if (goalIndex < 0) return;

    final goal = _goals[goalIndex];
    final mIndex = goal.milestones.indexWhere((m) => m.id == milestoneId);
    if (mIndex < 0) return;

    final milestone = goal.milestones[mIndex];
    final newFocusState =
        !(_dailyFocusIds.contains(milestoneId) || milestone.isDailyFocus);

    if (newFocusState) {
      if (!_dailyFocusIds.contains(milestoneId)) {
        _dailyFocusIds.add(milestoneId);
      }
    } else {
      _dailyFocusIds.remove(milestoneId);
    }

    final updatedMilestone = milestone.copyWith(isDailyFocus: newFocusState);
    final updatedMilestones = List<Milestone>.from(goal.milestones);
    updatedMilestones[mIndex] = updatedMilestone;

    final updatedGoal = goal.copyWith(milestones: updatedMilestones);
    _goals[goalIndex] = updatedGoal;
    notifyListeners();

    await _repository.updateGoal(updatedGoal);
    await _repository.setDailyFocusIds(_dailyFocusIds);
  }

  Future<void> reorderMilestones(
    String goalId,
    int oldIndex,
    int newIndex,
  ) async {
    final goalIndex = _goals.indexWhere((g) => g.id == goalId);
    if (goalIndex < 0) return;

    final goal = _goals[goalIndex];
    final list = List<Milestone>.from(goal.milestones);
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);

    // Update orderIndex
    final reordered = <Milestone>[];
    for (int i = 0; i < list.length; i++) {
      reordered.add(list[i].copyWith(orderIndex: i));
    }

    final updatedGoal = goal.copyWith(milestones: reordered);
    _goals[goalIndex] = updatedGoal;
    notifyListeners();

    await _repository.updateGoal(updatedGoal);
  }

  // --- SEED SAMPLE DATA & BACKUP ---

  Future<void> seedSampleData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _goals = await _repository.seedSampleData();
      _activityHistory = await _repository.getActivityHistory();
      _dailyFocusIds = await _repository.getDailyFocusIds();
    } catch (e) {
      _errorMessage = 'Failed to seed sample data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearAllData() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.clearAll();
      _goals = [];
      _activityHistory = [];
      _dailyFocusIds = [];
    } catch (e) {
      _errorMessage = 'Failed to clear data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> exportBackup() async {
    return _repository.exportBackup();
  }

  Future<bool> importBackup(String rawJson) async {
    final success = await _repository.importBackup(rawJson);
    if (success) {
      await initialize();
    }
    return success;
  }
}
