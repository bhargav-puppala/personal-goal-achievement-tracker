import 'package:flutter/material.dart';

/// Design tokens and semantic colors for the Personal Goal Achievement Tracker.
class AppColors {
  // Brand Primary (Deep Indigo / Dark Navy)
  static const Color primary = Color(0xFF1E293B); // Slate 800
  static const Color primaryDark = Color(0xFF0F172A); // Slate 900
  static const Color primaryLight = Color(0xFF334155); // Slate 700

  // Brand Accent (Emerald / Teal for success and progress)
  static const Color accent = Color(0xFF10B981); // Emerald 500
  static const Color accentLight = Color(0xFF34D399); // Emerald 400
  static const Color accentDark = Color(0xFF059669); // Emerald 600

  // Supporting Accent (Amber / Orange for pending & streak)
  static const Color warning = Color(0xFFF59E0B);
  static const Color fireStreak = Color(0xFFEA580C);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Light Theme Surfaces
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceSubtle = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightTextMuted = Color(0xFF94A3B8);

  // Dark Theme Surfaces
  static const Color darkBackground = Color(0xFF0B0F19);
  static const Color darkSurface = Color(0xFF131B2E);
  static const Color darkSurfaceSubtle = Color(0xFF1E293B);
  static const Color darkBorder = Color(0xFF26334D);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);

  // Priority Colors
  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return const Color(0xFFEF4444); // Red
      case 'medium':
        return const Color(0xFFF59E0B); // Amber
      case 'low':
      default:
        return const Color(0xFF10B981); // Emerald
    }
  }
}
