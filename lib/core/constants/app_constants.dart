import 'package:flutter/material.dart';

/// Application-wide constants, branding, and SDG alignments.
class AppConstants {
  static const String appName = 'Personal Goal Achievement Tracker';
  static const String appVersion = '1.0.0';
  static const String studentRollNumber = '24PA1A05I4';
  static const String studentName = 'Student 24PA1A05I4';

  // Storage keys
  static const String goalsStorageKey = 'pgat_goals_storage_v1';
  static const String activityStorageKey = 'pgat_activity_storage_v1';
  static const String settingsStorageKey = 'pgat_settings_storage_v1';
  static const String dailyFocusStorageKey = 'pgat_daily_focus_storage_v1';

  // Categories
  static const List<String> categories = [
    'Academic',
    'Career',
    'Fitness',
    'Personal',
    'Finance',
    'Health and Well-being',
    'Other',
  ];

  // Category Icons & Colors
  static IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Academic':
        return Icons.school_rounded;
      case 'Career':
        return Icons.work_rounded;
      case 'Fitness':
        return Icons.fitness_center_rounded;
      case 'Personal':
        return Icons.person_rounded;
      case 'Finance':
        return Icons.account_balance_wallet_rounded;
      case 'Health and Well-being':
        return Icons.favorite_rounded;
      default:
        return Icons.flag_rounded;
    }
  }

  static Color getCategoryColor(String category) {
    switch (category) {
      case 'Academic':
        return const Color(0xFF2563EB); // Royal Blue
      case 'Career':
        return const Color(0xFF7C3AED); // Deep Purple
      case 'Fitness':
        return const Color(0xFFF97316); // Vibrant Orange
      case 'Personal':
        return const Color(0xFFEC4899); // Rose Pink
      case 'Finance':
        return const Color(0xFF059669); // Emerald Green
      case 'Health and Well-being':
        return const Color(0xFF06B6D4); // Cyan / Teal
      default:
        return const Color(0xFF6B7280); // Cool Grey
    }
  }

  // SDG alignments
  static const String sdg3Title = 'SDG 3: Good Health and Well-being';
  static const String sdg3Description =
      'Promotes balanced lifestyle, mental well-being, regular exercise, and stress-reduction routines.';

  static const String sdg4Title = 'SDG 4: Quality Education';
  static const String sdg4Description =
      'Supports academic mastery, continuous skill development, structured study milestones, and career readiness.';
}
