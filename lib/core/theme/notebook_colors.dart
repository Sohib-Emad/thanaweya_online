import 'package:flutter/material.dart';

import 'package:thanaweya_online/core/constants/app_colors.dart';

/// Tokens of the دفتر (ruled school notebook) visual world.
///
/// The student surface is an Egyptian school exercise book: warm paper ground,
/// faint blue ruling, a classic red margin, pen-ink text, pencil secondary copy,
/// and the brand mint used as highlighter ink.
abstract final class NotebookColors {
  static const Color ground = Color(0xFFF8F4EA);
  static const Color surface = Color(0xFFFDFBF3);
  static const Color surfaceBright = Color(0xFFFFFDF5);
  static const Color ink = Color(0xFF1B2530);
  static const Color pencil = Color(0xFF7C828C);
  static const Color marginRed = Color(0xFFE03E3E);
  static const Color ruler = Color(0x2E5C7A99);
  static const Color rulerCard = Color(0x175C7A99);
  static const Color highlighter = Color(0xFFFFF2B8);

  /// Brand mint used as highlighter ink.
  static Color get green => AppColors.studentPrimary;
  static const Color onGreen = Colors.white;
}
