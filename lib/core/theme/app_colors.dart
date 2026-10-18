import 'package:flutter/material.dart';

/// Design tokens and semantic colors for the Personal Goal Achievement Tracker.
/// Warm, minimal, premium productivity-app palette (sage, neutral, slate).
class AppColors {
  // Main Natural Palette Tokens
  static const Color background = Color(0xFFF7F6F2); // Warm off-white
  static const Color surface = Color(0xFFFFFFFF); // Card and surface pure white
  static const Color surfaceSubtle = Color(0xFFF2F1EC); // Soft warm neutral
  static const Color border = Color(0xFFE4E3DD); // Soft gray border
  static const Color textPrimary = Color(0xFF252A31); // Deep charcoal
  static const Color textSecondary = Color(0xFF747B83); // Muted gray
  static const Color textMuted = Color(0xFF9AA0A6); // Soft gray muted

  // Primary Accent: Muted Sage Green
  static const Color sage = Color(0xFF6B8F71); // Muted sage green
  static const Color sageDark = Color(0xFF527558); // Dark sage (hover / pressed)
  static const Color sagePale = Color(0xFFE8EFE7); // Pale sage (subtle background)
  static const Color sageLight = Color(0xFF8BAA90); // Light sage tint

  // Secondary Accent & Status Semantics
  static const Color slateBlue = Color(0xFF71869B); // Muted slate blue
  static const Color success = Color(0xFF568160); // Natural green
  static const Color warning = Color(0xFFC18A43); // Muted amber
  static const Color error = Color(0xFFB85C56); // Muted brick red
  static const Color fireStreak = Color(0xFFC18A43); // Warm amber streak (no neon)

  // Primary Aliases
  static const Color primary = sage;
  static const Color primaryDark = sageDark;
  static const Color primaryLight = sageLight;
  static const Color accent = sage;
  static const Color accentLight = sageLight;
  static const Color accentDark = sageDark;
  static const Color info = slateBlue;

  // Light Aliases
  static const Color lightBackground = background;
  static const Color lightSurface = surface;
  static const Color lightSurfaceSubtle = surfaceSubtle;
  static const Color lightBorder = border;
  static const Color lightTextPrimary = textPrimary;
  static const Color lightTextSecondary = textSecondary;
  static const Color lightTextMuted = textMuted;

  // Refined, comfortable Dark Theme (charcoal & warm slate, no pure black, no neon)
  static const Color darkBackground = Color(0xFF191C20); // Warm deep charcoal
  static const Color darkSurface = Color(0xFF22262C); // Refined dark surface
  static const Color darkSurfaceSubtle = Color(0xFF2B3037); // Subtle elevation
  static const Color darkBorder = Color(0xFF383E46); // Restrained dark border
  static const Color darkTextPrimary = Color(0xFFEDECE8); // Warm off-white text
  static const Color darkTextSecondary = Color(0xFF9EA5AD); // Muted soft slate
  static const Color darkTextMuted = Color(0xFF6F767E); // Restrained muted text
  static const Color darkAccent = Color(0xFF82A888); // Soft muted sage
  static const Color darkAccentSubtle = Color(0xFF273429); // Restrained sage backdrop

  // Priority Colors (Muted, natural tones)
  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return error; // Muted brick red #B85C56
      case 'medium':
        return warning; // Muted amber #C18A43
      case 'low':
      default:
        return sage; // Muted sage green #6B8F71
    }
  }
}
