/// Represents an individual milestone belonging to a parent Goal.
class Milestone {
  final String id;
  final String goalId;
  final String title;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;
  final bool isDailyFocus;
  final int orderIndex;

  const Milestone({
    required this.id,
    required this.goalId,
    required this.title,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
    this.isDailyFocus = false,
    this.orderIndex = 0,
  });

  Milestone copyWith({
    String? id,
    String? goalId,
    String? title,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
    bool? isDailyFocus,
    int? orderIndex,
    bool clearCompletedAt = false,
  }) {
    return Milestone(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      isDailyFocus: isDailyFocus ?? this.isDailyFocus,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goalId': goalId,
      'title': title,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'isDailyFocus': isDailyFocus,
      'orderIndex': orderIndex,
    };
  }

  factory Milestone.fromJson(Map<String, dynamic> json) {
    return Milestone(
      id: json['id'] as String,
      goalId: json['goalId'] as String? ?? '',
      title: json['title'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      isDailyFocus: json['isDailyFocus'] as bool? ?? false,
      orderIndex: json['orderIndex'] as int? ?? 0,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Milestone &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          goalId == other.goalId &&
          title == other.title &&
          isCompleted == other.isCompleted &&
          isDailyFocus == other.isDailyFocus &&
          orderIndex == other.orderIndex;

  @override
  int get hashCode =>
      id.hashCode ^
      goalId.hashCode ^
      title.hashCode ^
      isCompleted.hashCode ^
      isDailyFocus.hashCode ^
      orderIndex.hashCode;
}
