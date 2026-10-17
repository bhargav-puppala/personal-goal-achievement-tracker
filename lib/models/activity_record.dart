/// Represents an immutable historical activity event for milestone completions.
class ActivityRecord {
  final String id;
  final String milestoneId;
  final String goalId;
  final String milestoneTitle;
  final String goalTitle;
  final String category;
  final String action; // 'completed' or 'reopened'
  final DateTime timestamp;

  const ActivityRecord({
    required this.id,
    required this.milestoneId,
    required this.goalId,
    required this.milestoneTitle,
    required this.goalTitle,
    required this.category,
    required this.action,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'milestoneId': milestoneId,
      'goalId': goalId,
      'milestoneTitle': milestoneTitle,
      'goalTitle': goalTitle,
      'category': category,
      'action': action,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ActivityRecord.fromJson(Map<String, dynamic> json) {
    return ActivityRecord(
      id: json['id'] as String,
      milestoneId: json['milestoneId'] as String,
      goalId: json['goalId'] as String,
      milestoneTitle: json['milestoneTitle'] as String? ?? 'Milestone',
      goalTitle: json['goalTitle'] as String? ?? 'Goal',
      category: json['category'] as String? ?? 'Personal',
      action: json['action'] as String? ?? 'completed',
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
