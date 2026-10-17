import 'dart:convert';
import 'package:personal_goal_tracker/models/goal.dart';
import 'package:personal_goal_tracker/models/activity_record.dart';
import 'package:personal_goal_tracker/services/storage_service.dart';

/// In-memory mock storage implementation for automated test execution.
class MockStorageService implements IStorageService {
  List<Goal> _goals = [];
  List<ActivityRecord> _records = [];
  List<String> _focusIds = [];
  Map<String, dynamic> _settings = {};

  @override
  Future<void> init() async {}

  @override
  Future<List<Goal>> loadGoals() async => List.from(_goals);

  @override
  Future<void> saveGoals(List<Goal> goals) async {
    _goals = List.from(goals);
  }

  @override
  Future<List<ActivityRecord>> loadActivityRecords() async =>
      List.from(_records);

  @override
  Future<void> saveActivityRecords(List<ActivityRecord> records) async {
    _records = List.from(records);
  }

  @override
  Future<List<String>> loadDailyFocusIds() async => List.from(_focusIds);

  @override
  Future<void> saveDailyFocusIds(List<String> milestoneIds) async {
    _focusIds = List.from(milestoneIds.toSet());
  }

  @override
  Future<Map<String, dynamic>> loadSettings() async => Map.from(_settings);

  @override
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    _settings = Map.from(settings);
  }

  @override
  Future<void> clearAllData() async {
    _goals.clear();
    _records.clear();
    _focusIds.clear();
  }

  @override
  Future<String> exportBackupJson() async {
    return jsonEncode({
      'goals': _goals.map((g) => g.toJson()).toList(),
      'activity': _records.map((a) => a.toJson()).toList(),
      'dailyFocus': _focusIds,
    });
  }

  @override
  Future<bool> importBackupJson(String rawJson) async {
    try {
      final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
      final rawGoals = decoded['goals'] as List<dynamic>;
      _goals = rawGoals
          .map((g) => Goal.fromJson(g as Map<String, dynamic>))
          .toList();
      return true;
    } catch (_) {
      return false;
    }
  }
}
