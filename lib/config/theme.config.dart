import 'package:flutter/material.dart';

class AppTheme {
  static bool isDarkMode = false;

  static Color get primary => const Color(0xFF7553F6);
  static const Color primaryLight = Color(0xFFD61A3C);
  static const Color primaryDark = Color(0xFFE82B4B);
  static Color get error => const Color(0xFFFF3B30);
  static Color get background =>
      isDarkMode ? const Color(0xFF121212) : const Color(0xFFF2F2F7);
  static Color get cardBackground =>
      isDarkMode ? const Color(0xFF1C1C1E) : Colors.white;
  static Color get textPrimary =>
      isDarkMode ? Colors.white : const Color(0xFF1C1C1E);
  static Color get textSecondary =>
      isDarkMode ? Colors.white60 : const Color(0xFF8E8E93);
  static Color get borderColor =>
      isDarkMode ? Colors.white12 : const Color(0xFFE5E5EA);
  static Color get divider =>
      isDarkMode ? Colors.white12 : const Color(0xFFE5E5EA);
}
