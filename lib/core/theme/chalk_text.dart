import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'chalk_colors.dart';

/// Cairo type helpers written in chalk.
abstract final class ChalkboardText {
  /// Big chalk headings, like a title written on the board.
  static TextStyle heading(double size, {Color? color}) => GoogleFonts.cairo(
        fontSize: size,
        fontWeight: FontWeight.w900,
        color: color ?? ChalkboardColors.ink,
        height: 1.3,
      );

  /// Emphasised body copy.
  static TextStyle strong(double size, {Color? color}) => GoogleFonts.cairo(
        fontSize: size,
        fontWeight: FontWeight.w800,
        color: color ?? ChalkboardColors.ink,
      );

  /// Regular body copy.
  static TextStyle body(double size, {Color? color}) => GoogleFonts.cairo(
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: color ?? ChalkboardColors.ink,
      );

  /// Chalk-secondary copy (hints, notes, meta).
  static TextStyle note(double size, {Color? color}) => GoogleFonts.cairo(
        fontSize: size,
        fontWeight: FontWeight.w500,
        color: color ?? ChalkboardColors.chalkSoft,
      );
}
