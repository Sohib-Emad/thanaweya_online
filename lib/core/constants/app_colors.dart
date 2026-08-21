import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand / Student Primary (Modern Mint Emerald)
  static const Color studentPrimary = Color(0xFF0FA37F);
  static const Color studentPrimaryLight = Color(0xFFE6F7F2);
  static const Color studentPrimaryDark = Color(0xFF0B7B60);

  // Teacher Primary (Modern Emerald Mint - Unified Brand)
  static const Color teacherPrimary = Color(0xFF0FA37F);
  static const Color teacherPrimaryLight = Color(0xFFECFDF5);
  static const Color teacherPrimaryDark = Color(0xFF0B7B60);

  // Admin Primary (Royal Purple)
  static const Color adminPrimary = Color(0xFF7C3AED);
  static const Color adminPrimaryLight = Color(0xFFF5F3FF);

  // Backward-compatible aliases
  static const Color primary = studentPrimary;
  static const Color primaryLight = studentPrimaryLight;
  static const Color primaryDark = studentPrimaryDark;
  static const Color secondary = studentPrimary;
  static const Color secondaryLight = studentPrimaryLight;

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0FA37F), Color(0xFF10B981)],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  static const LinearGradient teacherGradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  // Semantic
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Neutral scale (Light Mode)
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color divider = Color(0xFFE2E8F0);

  // Text (Light)
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textHint = textTertiary;
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Borders & Shadows
  static const Color border = Color(0xFFE2E8F0);
  static const Color cardBorder = border;
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color cardShadow = Color(0x0A0F172A);

  // Skeleton
  static const Color skeletonBase = Color(0xFFE2E8F0);
  static const Color skeletonShimmer = Color(0xFFF1F5F9);

  // Dark mode
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkSurfaceElevated = Color(0xFF334155);
  static const Color darkDivider = Color(0xFF334155);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkBorder = Color(0xFF334155);

  // Accent shortcuts
  static Color accentForRole(String role) {
    if (role == 'teacher') return teacherPrimary;
    if (role == 'admin') return adminPrimary;
    return studentPrimary;
  }

  static Color accentLightForRole(String role) {
    if (role == 'teacher') return teacherPrimaryLight;
    if (role == 'admin') return adminPrimaryLight;
    return studentPrimaryLight;
  }
}
