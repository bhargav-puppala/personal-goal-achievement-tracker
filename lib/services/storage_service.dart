import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/goal.dart';
import '../models/activity_record.dart';

/// Abstract storage service contract facilitating dependency injection and testing.
abstract class IStorageService {
  Future<void> init();
  Future<List<Goal>> loadGoals();
  Future<void> saveGoals(List<Goal> goals);
  Future<List<ActivityRecord>> loadActivityRecords();
  Future<void> saveActivityRecords(List<ActivityRecord> records);
  Future<List<String>> loadDailyFocusIds();
  Future<void> saveDailyFocusIds(List<String> milestoneIds);
  Future<Map<String, dynamic>> loadSettings();
  Future<void> saveSettings(Map<String, dynamic> settings);
  Future<void> clearAllData();
  Future<String> exportBackupJson();
  Future<bool> importBackupJson(String rawJson);
}

/// Robust, asynchronous local persistence service backed by SharedPreferences.
class LocalStorageService implements IStorageService {
  SharedPreferences? _prefs;

  @override
  Future<void> init() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
    } catch (e) {
      debugPrint('Failed to initialize SharedPreferences: $e');
    }
  }

  SharedPreferences get _instance {
    final prefs = _prefs;
    if (prefs == null) {
      throw StateError('StorageService must be initialized before use.');
    }
    return prefs;
  }

  @override
  Future<List<Goal>> loadGoals() async {
    try {
      final jsonString = _instance.getString(AppConstants.goalsStorageKey);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      final decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded
          .map((item) => Goal.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading goals from storage: $e');
      return [];
    }
  }

  @override
  Future<void> saveGoals(List<Goal> goals) async {
    try {
      final serialized = jsonEncode(goals.map((g) => g.toJson()).toList());
      await _instance.setString(AppConstants.goalsStorageKey, serialized);
    } catch (e) {
      debugPrint('Error saving goals to storage: $e');
    }
  }

  @override
  Future<List<ActivityRecord>> loadActivityRecords() async {
    try {
      final jsonString = _instance.getString(AppConstants.activityStorageKey);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      final decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded
          .map((item) => ActivityRecord.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading activity records: $e');
      return [];
    }
  }

  @override
  Future<void> saveActivityRecords(List<ActivityRecord> records) async {
    try {
      final serialized = jsonEncode(records.map((r) => r.toJson()).toList());
      await _instance.setString(AppConstants.activityStorageKey, serialized);
    } catch (e) {
      debugPrint('Error saving activity records: $e');
    }
  }

  @override
  Future<List<String>> loadDailyFocusIds() async {
    try {
      final list = _instance.getStringList(AppConstants.dailyFocusStorageKey);
      return list ?? [];
    } catch (e) {
      debugPrint('Error loading daily focus IDs: $e');
      return [];
    }
  }

  @override
  Future<void> saveDailyFocusIds(List<String> milestoneIds) async {
    try {
      await _instance.setStringList(
        AppConstants.dailyFocusStorageKey,
        milestoneIds.toSet().toList(), // deduplicate
      );
    } catch (e) {
      debugPrint('Error saving daily focus IDs: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> loadSettings() async {
    try {
      final jsonString = _instance.getString(AppConstants.settingsStorageKey);
      if (jsonString == null || jsonString.isEmpty) {
        return {};
      }
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error loading settings: $e');
      return {};
    }
  }

  @override
  Future<void> saveSettings(Map<String, dynamic> settings) async {
    try {
      final serialized = jsonEncode(settings);
      await _instance.setString(AppConstants.settingsStorageKey, serialized);
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  @override
  Future<void> clearAllData() async {
    try {
      await _instance.remove(AppConstants.goalsStorageKey);
      await _instance.remove(AppConstants.activityStorageKey);
      await _instance.remove(AppConstants.dailyFocusStorageKey);
    } catch (e) {
      debugPrint('Error clearing data: $e');
    }
  }

  @override
  Future<String> exportBackupJson() async {
    final goals = await loadGoals();
    final activities = await loadActivityRecords();
    final dailyFocus = await loadDailyFocusIds();

    final backup = {
      'app': AppConstants.appName,
      'studentRollNumber': AppConstants.studentRollNumber,
      'version': AppConstants.appVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'goals': goals.map((g) => g.toJson()).toList(),
      'activity': activities.map((a) => a.toJson()).toList(),
      'dailyFocus': dailyFocus,
    };
    return const JsonEncoder.withIndent('  ').convert(backup);
  }

  @override
  Future<bool> importBackupJson(String rawJson) async {
    try {
      final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
      if (!decoded.containsKey('goals')) return false;

      final rawGoals = decoded['goals'] as List<dynamic>;
      final goals = rawGoals
          .map((g) => Goal.fromJson(g as Map<String, dynamic>))
          .toList();
      await saveGoals(goals);

      if (decoded.containsKey('activity')) {
        final rawActivity = decoded['activity'] as List<dynamic>;
        final activities = rawActivity
            .map((a) => ActivityRecord.fromJson(a as Map<String, dynamic>))
            .toList();
        await saveActivityRecords(activities);
      }

      if (decoded.containsKey('dailyFocus')) {
        final rawDailyFocus = (decoded['dailyFocus'] as List<dynamic>)
            .map((e) => e.toString())
            .toList();
        await saveDailyFocusIds(rawDailyFocus);
      }

      return true;
    } catch (e) {
      debugPrint('Failed to import backup JSON: $e');
      return false;
    }
  }
}
