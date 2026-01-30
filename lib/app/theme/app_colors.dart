import 'package:flutter/material.dart';

/// App Color Palette
///
/// Centralized color definitions for the application
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // ==================== Primary Colors ====================
  static const Color primary = Color(0xFF1E88E5); // Blue
  static const Color primaryDark = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFF42A5F5);

  // ==================== Accent Colors ====================
  static const Color accent = Color(0xFFFF6F00); // Orange
  static const Color accentLight = Color(0xFFFF8F00);

  // ==================== Background Colors ====================
  static const Color background = Color(0xFFF5F5F5);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color overlayBackground = Color(0x66000000); // 40% black

  // ==================== Text Colors ====================
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textHint = Color(0xFFBDBDBD);

  // ==================== Status Colors ====================
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFB55454); // Muted red
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);

  // ==================== App Red (Muted) ====================
  static const Color red = Color(0xFFB55454); // Muted/dull red
  static const Color redLight = Color(0xFFC76A6A);
  static const Color redDark = Color(0xFF8B4242);

  // ==================== Neutral Colors ====================
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color greyLight = Color(0xFFE0E0E0);
  static const Color greyDark = Color(0xFF616161);

  // ==================== Border Colors ====================
  static const Color borderColor = Color(0xFFE0E0E0);
  static const Color dividerColor = Color(0xFFBDBDBD);
}
