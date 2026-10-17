import 'package:flutter/material.dart';
import '../services/storage_service.dart';

/// Provider managing theme preferences, notification options, and student metadata.
class SettingsProvider extends ChangeNotifier {
  final IStorageService _storageService;

  ThemeMode _themeMode = ThemeMode.system;
  bool _notificationsEnabled = true;
  TimeOfDay _dailyReminderTime = const TimeOfDay(hour: 9, minute: 0);
  bool _isLoading = true;

  SettingsProvider({required IStorageService storageService})
    : _storageService = storageService;

  ThemeMode get themeMode => _themeMode;
  bool get notificationsEnabled => _notificationsEnabled;
  TimeOfDay get dailyReminderTime => _dailyReminderTime;
  bool get isLoading => _isLoading;

  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      final map = await _storageService.loadSettings();
      if (map.containsKey('themeMode')) {
        final modeIndex = map['themeMode'] as int;
        if (modeIndex >= 0 && modeIndex < ThemeMode.values.length) {
          _themeMode = ThemeMode.values[modeIndex];
        }
      }
      if (map.containsKey('notificationsEnabled')) {
        _notificationsEnabled = map['notificationsEnabled'] as bool;
      }
      if (map.containsKey('reminderHour') &&
          map.containsKey('reminderMinute')) {
        _dailyReminderTime = TimeOfDay(
          hour: map['reminderHour'] as int,
          minute: map['reminderMinute'] as int,
        );
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await _persist();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    notifyListeners();
    await _persist();
  }

  Future<void> setDailyReminderTime(TimeOfDay time) async {
    _dailyReminderTime = time;
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    await _storageService.saveSettings({
      'themeMode': _themeMode.index,
      'notificationsEnabled': _notificationsEnabled,
      'reminderHour': _dailyReminderTime.hour,
      'reminderMinute': _dailyReminderTime.minute,
    });
  }
}
