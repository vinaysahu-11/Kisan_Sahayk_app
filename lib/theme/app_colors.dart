import 'package:flutter/material.dart';

/// Centralized theme-aware color system
class AppColors {
  static Color background(BuildContext context) {
    return Theme.of(context).scaffoldBackgroundColor;
  }

  static Color cardBackground(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF1E1E1E) : Colors.white;
  }

  static Color primary(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }

  static Color secondary(BuildContext context) {
    return Theme.of(context).colorScheme.secondary;
  }

  static Color surface(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  static Color textPrimary(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.white : Colors.black87;
  }

  static Color textSecondary(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.white70 : Colors.grey[600]!;
  }

  static Color textHint(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.white54 : Colors.grey[400]!;
  }

  static Color divider(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.white24 : Colors.grey[300]!;
  }

  static Color iconColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.white70 : const Color(0xFF2E6B3F);
  }

  /// Background gradient for screens
  static LinearGradient backgroundGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: isDark
          ? [const Color(0xFF1E1E1E), const Color(0xFF121212)]
          : [const Color(0xFFF8FAF8), const Color(0xFFE8F5E9)],
    );
  }

  /// Primary gradient for AppBar and buttons
  static LinearGradient primaryGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      colors: isDark
          ? [const Color(0xFF1F4D2E), const Color(0xFF2E6B3F)]
          : [const Color(0xFF2E6B3F), const Color(0xFF3F8D54)],
    );
  }

  /// Accent gradient for secondary cards
  static LinearGradient accentGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      colors: isDark
          ? [const Color(0xFF1565C0), const Color(0xFF1976D2)]
          : [const Color(0xFF2E7D32), const Color(0xFF4CAF50)],
    );
  }

  /// Weather card gradient
  static LinearGradient weatherGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      colors: isDark
          ? [const Color(0xFF1976D2), const Color(0xFF1565C0)]
          : [const Color(0xFF4A90E2), const Color(0xFF357ABD)],
    );
  }

  /// Card shadow
  static List<BoxShadow> cardShadow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: isDark ? Colors.black45 : Colors.black.withOpacity(0.1),
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
    ];
  }

  /// Original green color for buttons and accents
  static const Color greenPrimary = Color(0xFF2E6B3F);
  static const Color greenSecondary = Color(0xFF3F8D54);
  static const Color greenLight = Color(0xFF4CAF50);
}
