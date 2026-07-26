import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle _base({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    letterSpacing,
  }) {
    return GoogleFonts.cairo(
      fontSize: fontSize?.sp,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  // Display - hero headings, big numbers
  static TextStyle get display => _base(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.2,
      );

  // H1 - screen titles
  static TextStyle get h1 => _base(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  // H2 - section headings
  static TextStyle get h2 => _base(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  // H3 - card titles
  static TextStyle get h3 => _base(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  // Body - main readable text
  static TextStyle get body1 => _base(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.6,
      );

  // Body small
  static TextStyle get body2 => _base(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  // Aliases for backward compatibility
  static TextStyle get subtitle1 => h3;
  static TextStyle get subtitle2 => body2;

  // Caption - metadata, timestamps
  static TextStyle get caption => _base(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  // Overline - labels, tags
  static TextStyle get overline => _base(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textTertiary,
        height: 1.4,
        letterSpacing: 0.5,
      );

  // Button text
  static TextStyle get button => _base(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textOnPrimary,
        height: 1.4,
      );

  // Timer / numbers
  static TextStyle get timer => _base(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.0,
      );

  // Big stat number
  static TextStyle get statNumber => _base(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.0,
      );
}
