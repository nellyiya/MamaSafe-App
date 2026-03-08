import 'package:flutter/material.dart';

/// MamaSafe App Colors - Minimal 2-Color Design
class AppColors {
  // PRIMARY COLOR - Deep Navy Blue (#1F2347)
  static const Color primaryPurple = Color(0xFF1F2347);
  static const Color primaryLight = Color(0xFF2C2F5A);
  static const Color primaryDark = Color(0xFF1A1D3A);

  // SURFACE COLOR - White (#FFFFFF)
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color cardBorder = Color(0xFFE8E4F3); // Very light soft purple

  // Aliases for compatibility
  static const Color secondaryBlue = Color(0xFF2C2F5A);
  static const Color accentLight = Color(0xFFF8F9FA);

  // Dark theme colors
  static const Color backgroundDark = Color(0xFF1A1D3A);
  static const Color surfaceDark = Color(0xFF1F2347);
  static const Color cardDark = Color(0xFF1F2347);
  static const Color borderDark = Color(0xFF2C2F5A);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  static const Color textTertiaryDark = Color(0xFF6B7280);

  // Text colors
  static const Color textPrimaryLight = Color(0xFF1F2347);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textTertiaryLight = Color(0xFF9CA3AF);

  // Gradients (All Navy Blue)
  static const List<Color> softPurpleGradient = [Color(0xFF2C2F5A), Color(0xFF1F2347)];
  static const List<Color> softBlueGradient = [Color(0xFF1F2347), Color(0xFF2C2F5A)];
  static const List<Color> softPinkGradient = [Color(0xFF1F2347), Color(0xFF1A1D3A)];
  static const List<Color> softOrangeGradient = [Color(0xFF2C2F5A), Color(0xFF1F2347)];
  static const List<Color> softGreenGradient = [Color(0xFF1F2347), Color(0xFF2C2F5A)];

  // Accent colors (Navy Blue)
  static const Color accentGreen = Color(0xFF1F2347);

  // Risk colors (standard for safety)
  static const Color highRisk = Color(0xFFEF4444);
  static const Color riskHigh = Color(0xFFEF4444);
  static const Color mediumRisk = Color(0xFFF59E0B);
  static const Color riskMedium = Color(0xFFF59E0B);
  static const Color lowRisk = Color(0xFF10B981);
  static const Color riskLow = Color(0xFF10B981);

  // Status colors (Navy Blue for non-risk)
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF1F2347);

  // Shadows
  static const Color shadowLight = Color(0x0A000000);
  static const Color shadowMedium = Color(0x14000000);
  static const Color shadowDark = Color(0x1F000000);
}
