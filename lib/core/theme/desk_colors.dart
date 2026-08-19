import 'package:flutter/material.dart';

/// Tokens of the مكتب المعلم visual world.
abstract final class DeskColors {
  static const Color ground = Color(0xFFF4F6FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF1F5F9);
  static const Color ink = Color(0xFF0F172A);
  static const Color muted = Color(0xFF64748B);
  static const Color faint = Color(0xFF94A3B8);
  static const Color line = Color(0xFFE2E8F0);
  static const Color primary = Color(0xFF0284C7);
  static const Color primaryDeep = Color(0xFF0369A1);
  static const Color primarySoft = Color(0xFFF0F9FF);
  static const Color accent = Color(0xFFF59E0B);
  static const Color success = Color(0xFF10B981);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF0EA5E9);
  static const Color onPrimary = Colors.white;

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0284C7), Color(0xFF0EA5E9)],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  // Reference UI Colors
  static const Color heroBannerBg = Color(0xFFFFF2E8);
  static const Color heroBannerBtn = Color(0xFF1E293B);

  // Pastel Grid Tokens
  static const Color pastelBlue = Color(0xFFE0F2FE);
  static const Color pastelPink = Color(0xFFFCE7F3);
  static const Color pastelGreen = Color(0xFFDCFCE7);
  static const Color pastelPurple = Color(0xFFF3E8FF);
  static const Color pastelYellow = Color(0xFFFEF3C7);
  static const Color pastelRose = Color(0xFFFFE4E6);
  static const Color pastelOrange = Color(0xFFFFEDD5);
  static const Color pastelMint = Color(0xFFF0F9FF);
}
