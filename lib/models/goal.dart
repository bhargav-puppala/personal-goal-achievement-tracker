import 'milestone.dart';
import '../core/utils/app_date_utils.dart';

/// Represents a user goal with nested milestones, category, priority, and progress.
class Goal {
  final String id;
  final String title;
  final String description;
  final String category;
  final String priority; // 'Low', 'Medium', 'High'
  final DateTime createdAt;
  final DateTime? targetDate;
  final List<Milestone> milestones;
  final int? colorHex;
  final bool isCompleted;
  final DateTime? completedAt;

  const Goal({
    required this.id,
    required this.title,
    this.description = '',
    required this.category,
    this.priority = 'Medium',
    required this.createdAt,
    this.targetDate,
    this.milestones = const [],
    this.colorHex,
    this.isCompleted = false,
    this.completedAt,
  });

  /// Count of completed milestones.
  int get completedMilestonesCount =>
      milestones.where((m) => m.isCompleted).length;

  /// Total count of milestones.
  int get totalMilestonesCount => milestones.length;

  /// Progress percentage (0.0 to 100.0). Safe from division by zero or NaN.
  double get progressPercentage {
    if (milestones.isEmpty) {
      return isCompleted ? 100.0 : 0.0;
    }
    return (completedMilestonesCount / milestones.length) * 100.0;
  }

  /// Normalized progress between 0.0 and 1.0 for Flutter progress indicators.
  double get normalizedProgress {
    if (milestones.isEmpty) {
      return isCompleted ? 1.0 : 0.0;
    }
    return completedMilestonesCount / milestones.length;
  }

  /// Evaluates completion status according to the goal completion policy:
  /// - A goal with >=1 milestones is completed when all milestones are completed.
  /// - A goal with 0 milestones is not treated as completed automatically.
  bool get effectiveIsCompleted {
    if (milestones.isNotEmpty) {
      return completedMilestonesCount == milestones.length;
    }
    return isCompleted;
  }

  /// Determines if the goal has passed its deadline without being completed.
  bool isOverdue({DateTime? referenceNow}) {
    return AppDateUtils.isOverdue(
      targetDate,
      effectiveIsCompleted,
      referenceNow: referenceNow,
    );
  }

  /// Returns current status descriptor: 'Completed', 'Overdue', or 'Active'.
  String getStatus({DateTime? referenceNow}) {
    if (effectiveIsCompleted) {
      return 'Completed';
    } else if (isOverdue(referenceNow: referenceNow)) {
      return 'Overdue';
    }
    return 'Active';
  }

  Goal copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? priority,
    DateTime? createdAt,
    DateTime? targetDate,
    List<Milestone>? milestones,
    int? colorHex,
    bool? isCompleted,
    DateTime? completedAt,
    bool clearTargetDate = false,
    bool clearCompletedAt = false,
  }) {
    final updatedMilestones = milestones ?? this.milestones;
    bool computedIsCompleted = isCompleted ?? this.isCompleted;
    DateTime? computedCompletedAt = clearCompletedAt
        ? null
        : (completedAt ?? this.completedAt);

    // Apply completion policy consistency:
    if (updatedMilestones.isNotEmpty) {
      final allDone = updatedMilestones.every((m) => m.isCompleted);
      computedIsCompleted = allDone;
      if (allDone && computedCompletedAt == null) {
        computedCompletedAt = DateTime.now();
      } else if (!allDone) {
        computedCompletedAt = null;
      }
    }

    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      targetDate: clearTargetDate ? null : (targetDate ?? this.targetDate),
      milestones: updatedMilestones,
      colorHex: colorHex ?? this.colorHex,
      isCompleted: computedIsCompleted,
      completedAt: computedCompletedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
      'targetDate': targetDate?.toIso8601String(),
      'milestones': milestones.map((m) => m.toJson()).toList(),
      'colorHex': colorHex,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    final rawMilestones = json['milestones'] as List<dynamic>? ?? [];
    return Goal(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'Personal',
      priority: json['priority'] as String? ?? 'Medium',
      createdAt: DateTime.parse(json['createdAt'] as String),
      targetDate: json['targetDate'] != null
          ? DateTime.parse(json['targetDate'] as String)
          : null,
      milestones: rawMilestones
          .map((m) => Milestone.fromJson(m as Map<String, dynamic>))
          .toList(),
      colorHex: json['colorHex'] as int?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }
}
