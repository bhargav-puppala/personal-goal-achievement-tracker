import 'package:intl/intl.dart';

/// Date utility helper methods for display, normalization, and deadline checks.
class AppDateUtils {
  static final DateFormat _shortDateFormatter = DateFormat('MMM d, yyyy');
  static final DateFormat _dayMonthFormatter = DateFormat('MMM d');
  static final DateFormat _timeFormatter = DateFormat('h:mm a');

  /// Normalizes a DateTime to midnight (00:00:00.000) local time for pure calendar day math.
  static DateTime normalizeDate(DateTime date) {
    final local = date.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  /// Formats date to standard display (e.g., "Oct 17, 2026").
  static String formatShortDate(DateTime? date) {
    if (date == null) return 'No deadline';
    return _shortDateFormatter.format(date.toLocal());
  }

  /// Formats date with time (e.g., "Oct 17, 2:30 PM").
  static String formatDateTime(DateTime date) {
    final local = date.toLocal();
    return '${_dayMonthFormatter.format(local)}, ${_timeFormatter.format(local)}';
  }

  /// Returns friendly human-readable deadline text (e.g. "Today", "Tomorrow", "In 3 days", "Overdue by 2 days").
  static String getRelativeDeadlineText(
    DateTime targetDate, {
    DateTime? referenceNow,
  }) {
    final now = referenceNow ?? DateTime.now();
    final today = normalizeDate(now);
    final target = normalizeDate(targetDate);
    final differenceDays = target.difference(today).inDays;

    if (differenceDays == 0) {
      return 'Due today';
    } else if (differenceDays == 1) {
      return 'Due tomorrow';
    } else if (differenceDays == -1) {
      return 'Overdue by 1 day';
    } else if (differenceDays < -1) {
      return 'Overdue by ${-differenceDays} days';
    } else if (differenceDays <= 7) {
      return 'In $differenceDays days';
    } else {
      return _shortDateFormatter.format(targetDate.toLocal());
    }
  }

  /// Determines if a goal is overdue.
  static bool isOverdue(
    DateTime? targetDate,
    bool isCompleted, {
    DateTime? referenceNow,
  }) {
    if (isCompleted || targetDate == null) return false;
    final now = referenceNow ?? DateTime.now();
    final today = normalizeDate(now);
    final target = normalizeDate(targetDate);
    return target.isBefore(today);
  }

  /// Returns whether two dates represent the exact same calendar day.
  static bool isSameDay(DateTime a, DateTime b) {
    final localA = a.toLocal();
    final localB = b.toLocal();
    return localA.year == localB.year &&
        localA.month == localB.month &&
        localA.day == localB.day;
  }
}
