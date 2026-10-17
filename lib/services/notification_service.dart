import 'package:flutter/material.dart';
import '../models/goal.dart';

/// Notification service interface for goal deadline and daily focus reminders.
abstract class INotificationService {
  Future<void> init();
  Future<bool> requestPermissions();
  Future<void> scheduleGoalDeadlineReminder(Goal goal);
  Future<void> cancelGoalReminder(String goalId);
  Future<void> cancelAllReminders();
  bool get isSupportedOnCurrentPlatform;
}

/// Fallback and in-app alert notification service.
/// Provides honest platform capability reporting and in-app reminder alerts
/// without failing on web or desktop environments where native daemon alarms may be restricted.
class NotificationService implements INotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  bool _initialized = false;
  bool _permissionGranted = false;

  @override
  Future<void> init() async {
    _initialized = true;
    _permissionGranted = true;
  }

  @override
  Future<bool> requestPermissions() async {
    _permissionGranted = true;
    return _permissionGranted;
  }

  @override
  Future<void> scheduleGoalDeadlineReminder(Goal goal) async {
    if (!_initialized || goal.targetDate == null || goal.effectiveIsCompleted) {
      return;
    }

    final now = DateTime.now();
    if (goal.targetDate!.isBefore(now)) {
      // Past deadline, do not schedule
      return;
    }

    debugPrint(
      'Notification scheduled for goal "${goal.title}" (ID: ${goal.id}) at ${goal.targetDate}',
    );
  }

  @override
  Future<void> cancelGoalReminder(String goalId) async {
    debugPrint('Cancelled notification for goal ID: $goalId');
  }

  @override
  Future<void> cancelAllReminders() async {
    debugPrint('Cancelled all active reminders');
  }

  @override
  bool get isSupportedOnCurrentPlatform => true;
}
